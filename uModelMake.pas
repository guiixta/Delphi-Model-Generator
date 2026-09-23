{ ******************************************************* }
{                                                         }
{              ModelMake Utility v1.0.3                   }
{                                                         }
{              Author: guiixta (GitHub)                   }
{                                                         }
{ ******************************************************* }

unit uModelMake;

interface

uses
   System.SysUtils,
   System.Classes,
   System.StrUtils,
   System.DateUtils,
   System.Math,
   System.UITypes,
   System.Generics.Collections,
   Vcl.Dialogs,
   Winapi.Windows,
   Data.SqlExpr,
   FireDAC.Comp.Client,
   FireDAC.Stan.Param,
   System.Net.HttpClient,
   System.Net.URLClient;

type

   TModelScan = class
   private
      { private declarations }
      FCaminhoUsado: string;
      FTables: TStringList;
      FCampos: TDictionary<String, String>;
      DataBase: string;
      FSQL: string;
      procedure DefinirSQL(ADataBase: string);
      function getPKField(ATable: string; AConn: TSQLConnection)
        : String; overload;
      function getPKField(ATable: string; AConn: TFDConnection)
        : String; overload;
      procedure GerarModels(Map: TDictionary<String, string>);
      function ObterDoGithub(const AUrl: string): TStringList;
      function ObterLocal(const APath: string): TStringList;
      procedure GerarInterface(const APath: string);
   protected
      { protected declarations }
   public
      { public declarations }
      constructor Create(AConnection: TSQLConnection;
        APath: string = ''); overload;
      constructor Create(AConnection: TFDConnection;
        APath: string = ''); overload;
      destructor Destroy; override;
   end;

var
   ModelMake: TModelScan;

implementation

{ TModelScan }

const
   URL_MOLDE =
     'https://github.com/guiixta/Delphi-Model-Generator/raw/refs/heads/main/uModelMolde.pas';
   URL_INTERFACE =
     'https://github.com/guiixta/Delphi-Model-Generator/raw/refs/heads/main/uIModel.pas';
   LOCAL_MOLDE = '';
   LOCAL_INTERFACE = '';

function TModelScan.getPKField(ATable: string; AConn: TFDConnection): String;
var
   Q: TFDQuery;
begin
   Result := '';
   Q := TFDQuery.Create(nil);
   Q.Connection := AConn;
   try
      with Q do
      begin
         SQL.Clear;
         SQL.Text := FSQL;
         ParamByName('TABLE').AsString := ATable;
         Open;

         if not EOF then
            Result := Trim(FieldByName('CAMPO_PK').AsString);

         Close;
      end;
   finally
      Q.Free;
   end;
end;

function TModelScan.getPKField(ATable: string; AConn: TSQLConnection): String;
var
   Q: TSQLQuery;
begin
   Result := '';
   Q := TSQLQuery.Create(nil);
   Q.SQLConnection := AConn;
   try
      with Q do
      begin
         SQL.Clear;
         SQL.Text := FSQL;
         ParamByName('TABLE').AsString := ATable;
         Open;

         if not EOF then
            Result := Trim(FieldByName('CAMPO_PK').AsString);

         Close;
      end;
   finally
      Q.Free;
   end;
end;

procedure TModelScan.DefinirSQL(ADataBase: string);
var
   SQLLines: TStringList;
begin
{$REGION 'SQL'}
   SQLLines := TStringList.Create;
   try
      case IndexText(ADataBase, ['FB', 'Firebird', 'IB', 'Interbase', 'MSSQL',
        'PG', 'PostgreSQL', 'SQLite', 'Ora', 'Oracle', 'MySQL']) of
         0, 1, 2, 3:
            begin
               with SQLLines do
               begin
                  add('SELECT ISG.RDB$FIELD_NAME AS CAMPO_PK');
                  add('FROM RDB$RELATION_CONSTRAINTS RC');
                  add('JOIN RDB$INDEX_SEGMENTS ISG ON RC.RDB$INDEX_NAME = ISG.RDB$INDEX_NAME');
                  add('WHERE UPPER(RC.RDB$RELATION_NAME) = UPPER(:TABLE)');
                  add('AND RC.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''');
               end;
            end;
         4, 5, 6:
            begin
               with SQLLines do
               begin
                  add('SELECT KU.COLUMN_NAME AS CAMPO_PK');
                  add('FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC');
                  add('JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KU');
                  add(' ON TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME');
                  add('  AND TC.TABLE_SCHEMA = KU.TABLE_SCHEMA');
                  add('WHERE TC.CONSTRAINT_TYPE = ''PRIMARY KEY''');
                  add('AND UPPER(TC.TABLE_NAME) = UPPER(:TABLE)');
               end;
            end;
         7:
            begin
               with SQLLines do
               begin
                  add('SELECT NAME AS CAMPO_PK');
                  add('FROM PRAGMA_TABLE_INFO(:TABLE)');
                  add('WHERE PK > 0');
               end;
            end;
         8, 9:
            begin
               with SQLLines do
               begin
                  add('SELECT COLS.COLUMN_NAME AS CAMPO_PK');
                  add('FROM ALL_CONSTRAINTS CONS');
                  add('JOIN ALL_CONS_COLUMNS COLS');
                  add('  ON CONS.CONSTRAINT_NAME = COLS.CONSTRAINT_NAME');
                  add('  AND CONS.OWNER = COLS.OWNER');
                  add('WHERE CONS.CONSTRAINT_TYPE = ''P''');
                  add('AND UPPER(CONS.TABLE_NAME) = UPPER(:TABLE)');
               end;
            end;
         10:
            begin
               with SQLLines do
               begin
                  add('SELECT COLUMN_NAME AS CAMPO_PK');
                  add('FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE');
                  add('WHERE CONSTRAINT_NAME = ''PRIMARY''');
                  add('AND UPPER(TABLE_NAME) = UPPER(:TABLE)');
                  add('AND TABLE_SCHEMA = DATABASE()');
               end;
            end;
      end;

      FSQL := SQLLines.Text;
   finally
      SQLLines.Free;
   end;
{$ENDREGION}
end;

destructor TModelScan.Destroy;
begin

   if Assigned(FTables) then
      FTables.Free;

   if Assigned(FCampos) then
      FreeAndNil(FCampos);

   inherited;
end;

constructor TModelScan.Create(AConnection: TSQLConnection; APath: string = '');
var
   I: integer;
begin
   if not Assigned(AConnection) then
      exit;

   GerarInterface(APath);

   FTables := TStringList.Create;
   FCampos := TDictionary<String, string>.Create;
   AConnection.GetTableNames(FTables);
   DataBase := AConnection.DriverName;
   DefinirSQL(DataBase);

   for I := 0 to FTables.Count - 1 do
      FCampos.add(FTables[I], getPKField(FTables[I], AConnection));

   GerarModels(FCampos);

end;

constructor TModelScan.Create(AConnection: TFDConnection; APath: string = '');
var
   I: integer;
begin
   if not Assigned(AConnection) then
      exit;

   GerarInterface(APath);

   FTables := TStringList.Create;
   FCampos := TDictionary<String, string>.Create;
   AConnection.GetTableNames('', '', '', FTables);
   DataBase := AConnection.Params.DriverID;
   DefinirSQL(DataBase);

   for I := 0 to FTables.Count - 1 do
      FCampos.add(FTables[I], getPKField(FTables[I], AConnection));

   GerarModels(FCampos);
end;

procedure TModelScan.GerarInterface(const APath: string);
var
   IModel: TStringList;
begin
   FCaminhoUsado := ExtractFilePath(ParamStr(0)) + 'Models\';

   IModel := ObterDoGithub(URL_INTERFACE); { ObterLocal(LOCAL_INTERFACE) }
   try
      if APath <> '' then
      begin
         if not DirectoryExists(APath) then
         begin
            if not CreateDir(APath) then
               raise Exception.Create
                 ('Falha ao criar estrutura especifica ' + APath);
         end;

         if not FileExists(APath + 'uIModel.pas') then
            IModel.SaveToFile(APath + 'uIModel.pas', TEncoding.UTF8);

         FCaminhoUsado := APath;
      end
      else
      begin
         if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'Models') then
         begin
            if not CreateDir(ExtractFilePath(ParamStr(0)) + 'Models') then
               raise Exception.Create('Falha ao criar estrutura');
         end;

         if not FileExists(ExtractFilePath(ParamStr(0)) + 'Models\' +
           'uIModel.pas') then
            IModel.SaveToFile(ExtractFilePath(ParamStr(0)) + 'Models\' +
              'uIModel.pas', TEncoding.UTF8);
      end;
   finally
      IModel.Free;
   end;

end;

procedure TModelScan.GerarModels(Map: TDictionary<String, string>);
var
   Tabela, NomePk: string;
   Molde: TStringList;
   Par: TPair<string, string>;
begin

   for Par in Map do
   begin
      Tabela := Par.Key;
      if Pos(Tabela, '_') > 0 then
         Tabela := StringReplace(Tabela, '_', '', [rfReplaceAll]);

      NomePk := Par.Value;
      Molde := ObterDoGithub(URL_MOLDE); { ObterLocal(LOCAL_MOLDE) }
      try
         Molde.Text := StringReplace(Molde.Text, '{NOME_TABELA}', Tabela,
           [rfReplaceAll]);
         Molde.Text := StringReplace(Molde.Text, '{NOME_PK}', NomePk,
           [rfReplaceAll]);
         try
            if FileExists(FCaminhoUsado + Format('u%s.pas', [Tabela])) then
               continue;

            Molde.SaveToFile(FCaminhoUsado + Format('u%s.pas', [Tabela]),
              TEncoding.UTF8);
         except
            on E: Exception do
               raise Exception.Create('Falha ao Gravar: ' + E.Message);
         end;
      finally
         Molde.Free;
      end;
   end;

end;

function TModelScan.ObterDoGithub(const AUrl: string): TStringList;
var
   HTTP: THTTPClient;
   res: IHTTPResponse;
   Stream: TStringStream;
begin

   Result := TStringList.Create;
   HTTP := THTTPClient.Create;
   Stream := TStringStream.Create('', TEncoding.UTF8);
   try
      try
         res := HTTP.Get(AUrl, Stream);

         if res.StatusCode = 200 then
         begin
            Stream.Position := 0;
            Result.LoadFromStream(Stream);
         end
         else
         begin
            raise Exception.CreateFmt('Error ao baixar template: %d',
              [res.StatusCode]);
         end;
      except
         on E: Exception do
         begin
            Result.Free;
            raise Exception.Create('Falha na conexão: ' + E.Message);
         end;
      end;
   finally
      Stream.Free;
      HTTP.Free;
   end;

end;

function TModelScan.ObterLocal(const APath: string): TStringList;
begin
   Result := TStringList.Create;
   try
      Result.LoadFromFile(APath);
   except
      on E: Exception do
      begin
         Result.Free;
         raise Exception.Create('Error ao puxar arquivo: ' + E.Message);
      end;
   end;
end;

initialization

finalization

if Assigned(ModelMake) then
   FreeAndNil(ModelMake);

end.
