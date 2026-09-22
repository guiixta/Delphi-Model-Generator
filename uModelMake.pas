{ ******************************************************* }
{                                                         }
{                 ModelMake Utility                       }
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
   FireDAC.Stan.Param;

type

   TModelScan = class
   private
      { private declarations }
      FCaminhoUsado: string;
      FTables: TStringList;
      FCampos: TDictionary<String, String>;

      function getPKField(ATable: string; AConn: TSQLConnection)
        : String; overload;
      function getPKField(ATable: string; AConn: TFDConnection)
        : String; overload;
      procedure GerarModels(Map: TDictionary<String, string>);
      function ObterModelo: TStringList;
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
function TModelScan.getPKField(ATable: string; AConn: TFDConnection): String;
var
   Q: TFDQuery;
begin
   Result := '';
   Q := TFDQuery.Create(nil);
   Q.Connection := AConn;
{$REGION 'SQL'}
   try
      with Q do
      begin
         SQL.Clear;
         SQL.Add('SELECT ISG.RDB$FIELD_NAME AS CAMPO_PK');
         SQL.Add('FROM RDB$RELATION_CONSTRAINTS RC');
         SQL.Add('JOIN RDB$INDEX_SEGMENTS ISG ON RC.RDB$INDEX_NAME = ISG.RDB$INDEX_NAME');
         SQL.Add('WHERE UPPER(RC.RDB$RELATION_NAME) = UPPER(:TABLE)');
         SQL.Add('AND RC.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''');

         ParamByName('TABLE').AsString := ATable;
         Open;

         if not EOF then
            Result := Trim(FieldByName('CAMPO_PK').AsString);

         Close;
      end;
   finally
      Q.Free;
   end;
{$ENDREGION}
end;

function TModelScan.getPKField(ATable: string; AConn: TSQLConnection): String;
var
   Q: TSQLQuery;
begin
   Result := '';
   Q := TSQLQuery.Create(nil);
   Q.SQLConnection := AConn;
{$REGION 'SQL'}
   try
      with Q do
      begin
         SQL.Clear;
         SQL.Add('SELECT ISG.RDB$FIELD_NAME AS CAMPO_PK');
         SQL.Add('FROM RDB$RELATION_CONSTRAINTS RC');
         SQL.Add('JOIN RDB$INDEX_SEGMENTS ISG ON RC.RDB$INDEX_NAME = ISG.RDB$INDEX_NAME');
         SQL.Add('WHERE UPPER(RC.RDB$RELATION_NAME) = UPPER(:TABLE)');
         SQL.Add('AND RC.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''');

         ParamByName('TABLE').AsString := ATable;
         Open;

         if not EOF then
            Result := Trim(FieldByName('CAMPO_PK').AsString);

         Close;
      end;
   finally
      Q.Free;
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

   for I := 0 to FTables.Count - 1 do
      FCampos.Add(FTables[I], getPKField(FTables[I], AConnection));

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

   for I := 0 to FTables.Count - 1 do
      FCampos.Add(FTables[I], getPKField(FTables[I], AConnection));

   GerarModels(FCampos);
end;

procedure TModelScan.GerarInterface(const APath: string);
var
   IModel: TStringList;
begin
   FCaminhoUsado := ExtractFilePath(ParamStr(0)) + 'Models\';

   IModel := TStringList.Create;
   try
{$REGION 'IModel'}
      with IModel do
      begin
         Add('unit uIModel;');
         Add('');
         Add('interface');
         Add('');
         Add('uses' + #13#10 + '   System.SysUtils,' + #13#10 +
           '   System.Classes,' + #13#10 + '   System.StrUtils,' + #13#10 +
           '   System.DateUtils,' + #13#10 + '   System.Math,' + #13#10 +
           '   System.UITypes,' + #13#10 + '   System.Generics.Collections,' +
           #13#10 + '   Vcl.Dialogs,' + #13#10 + '   Winapi.Windows,' + #13#10 +
           '   Contnrs,' + #13#10 + '   Data.SqlExpr,' + #13#10 +
           '   FireDAC.Comp.Client;');
         Add('');
         Add('type');
         Add('');
         Add('   TTypeQuery = (tqExecSQL, tqOpen);');
         Add('');
         Add('   IModel = interface');
         Add('   [' + QuotedStr
           ('{47E13D14-AFF6-4B03-96EC-697221423171}') + ']');
         Add('');
         Add('      procedure Delete(AID: integer); overload;');
         Add('      procedure DeleteWhere(Where: TStringList); overload;');
         Add('');
         Add('      procedure Update(AID: integer; AValues: TStringList); overload;');
         Add('      procedure UpdateWhere(AValues: TStringlist; AWhere: TStringList); overload;');
         Add('');
         Add('      procedure Insert(AValues: TStringList);');
         Add('');
         Add('      procedure SelectJoin(AJoin: TStringList; var Q: TSQLQuery); overload;');
         Add('      procedure SelectJoin(AJoin: TStringList; var Q: TFDQuery); overload;');
         Add('');
         Add('      procedure SelectAll(var Q: TSQLQuery); overload;');
         Add('      procedure SelectAll(var Q: TFDQuery); overload;');
         Add('');
         Add('      procedure SelectWhere(AWhere: TStringList; var Q: TSQLQuery); overload;');
         Add('      procedure SelectWhere(AWhere: TStringList; var Q: TFDQuery); overload;');
         Add('');
         Add('      procedure Query(var Q: TSQLQuery; AQuery: TStringList; ATypeQuery: TTypeQuery); overload;');
         Add('      procedure Query(var Q: TFDQuery; AQuery: TStringList; ATypeQuery: TTypeQuery); overload;');
         Add('end;');
         Add('');
         Add('implementation');
         Add('');
         Add('end.');
      end;
{$ENDREGION}
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
      Molde := ObterModelo;
      try
         Molde.Text := StringReplace(Molde.Text, '#NOME_TABELA#', Tabela,
           [rfReplaceAll]);
         Molde.Text := StringReplace(Molde.Text, '#NomePK#', NomePk,
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

function TModelScan.ObterModelo: TStringList;
begin
{$REGION 'ModeloModel'}
   Result := TStringList.Create;

   Result.Add('unit u' + '#NOME_TABELA#;');
   Result.Add('');
   Result.Add('interface');
   Result.Add('');
   Result.Add('uses');
   Result.Add('   System.SysUtils,');
   Result.Add('   System.Classes,');
   Result.Add('   System.StrUtils,');
   Result.Add('   System.DateUtils,');
   Result.Add('   System.Math,');
   Result.Add('   System.UITypes,');
   Result.Add('   System.Generics.Collections,');
   Result.Add('   Vcl.Dialogs,');
   Result.Add('   Winapi.Windows,');
   Result.Add('   Contnrs,');
   Result.Add('   Data.SqlExpr,');
   Result.Add('   Data.DB,');
   Result.Add('   FireDAC.Comp.Client,');
   Result.Add('   FireDAC.Comp.DataSet,');
   Result.Add('   FireDAC.Stan.Param,');
   Result.Add('   uIModel;');
   Result.Add('');
   Result.Add('type');
   Result.Add('');
   Result.Add('   TTypeConn = (tcFireDac, tcExpress);');
   Result.Add('');
   Result.Add('   T' + '#NOME_TABELA# = class(TInterfacedObject, IModel)');
   Result.Add('   private');
   Result.Add('      { private declarations }');
   Result.Add('      FTipoConnection: TTypeConn;');
   Result.Add('      FQuery: TDataSet;');
   Result.Add('      FTable: String;');
   Result.Add('   protected');
   Result.Add('      { protected declarations }');
   Result.Add('   public');
   Result.Add('      { public declarations }');
   Result.Add('      procedure Delete(AID: integer); overload;');
   Result.Add('      procedure DeleteWhere(Where: TStringList); overload;');
   Result.Add('');
   Result.Add
     ('      procedure Update(AID: integer; AValues: TStringList); overload;');
   Result.Add
     ('      procedure UpdateWhere(AValues: TStringList; AWhere: TStringList);');
   Result.Add('        overload;');
   Result.Add('');
   Result.Add('      procedure Insert(AValues: TStringList);');
   Result.Add('');
   Result.Add
     ('      procedure SelectJoin(AJoin: TStringList; var Q: TSQLQuery); overload;');
   Result.Add
     ('      procedure SelectJoin(AJoin: TStringList; var Q: TFDQuery); overload;');
   Result.Add('');
   Result.Add('      procedure SelectAll(var Q: TSQLQuery); overload;');
   Result.Add('      procedure SelectAll(var Q: TFDQuery); overload;');
   Result.Add('');
   Result.Add
     ('      procedure SelectWhere(AWhere: TStringList; var Q: TSQLQuery); overload;');
   Result.Add
     ('      procedure SelectWhere(AWhere: TStringList; var Q: TFDQuery); overload;');
   Result.Add('');
   Result.Add
     ('      procedure Query(var Q: TSQLQuery; AQuery: TStringList; ATypeQuery: TTypeQuery); overload;');
   Result.Add
     ('      procedure Query(var Q: TFDQuery; AQuery: TStringList;  ATypeQuery: TTypeQuery); overload;');
   Result.Add('');
   Result.Add
     ('      constructor Create(AConn: TSQLConnection); reintroduce; overload;');
   Result.Add
     ('      constructor Create(AConn: TFDConnection); reintroduce; overload;');
   Result.Add('');
   Result.Add('      destructor Destroy; override;');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('var');
   Result.Add('   ' + '#NOME_TABELA# : T' + '#NOME_TABELA#;');
   Result.Add('');
   Result.Add('implementation');
   Result.Add('');
   Result.Add('{ T' + '#NOME_TABELA# }');
   Result.Add('');
   Result.Add('constructor T' + '#NOME_TABELA#.Create(AConn: TFDConnection);');
   Result.Add('begin');
   Result.Add('   inherited Create;');
   Result.Add('   FQuery := TFDQuery.Create(nil);');
   Result.Add('   TFDQuery(FQuery).Connection := AConn;');
   Result.Add('');
   Result.Add('   FTipoConnection := tcFireDac;');
   Result.Add('   FTable := ''' + '#NOME_TABELA#' + ''';');
   Result.Add('end;');
   Result.Add('');
   Result.Add('constructor T' + '#NOME_TABELA#.Create(AConn: TSQLConnection);');
   Result.Add('begin');
   Result.Add('   inherited Create;');
   Result.Add('   FQuery := TSQLQuery.Create(nil);');
   Result.Add('   TSQLQuery(FQuery).SQLConnection := AConn;');
   Result.Add('');
   Result.Add('   FTipoConnection := tcExpress;');
   Result.Add('   FTable := ''' + '#NOME_TABELA#' + ''';');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' + '#NOME_TABELA#.Delete(AID: integer);');
   Result.Add('begin');
   Result.Add('   case FTipoConnection of');
   Result.Add('      tcFireDac:');
   Result.Add('         begin');
   Result.Add('            with TFDQuery(FQuery) do');
   Result.Add('            begin');
   Result.Add('               SQL.Clear;');
   Result.Add('               SQL.Add(Format(''DELETE FROM %s'', [FTable]));');
   Result.Add('               SQL.Add(''WHERE #NomePK# = :IDValue'');');
   Result.Add('               ParamByName(''IDVALUE'').AsInteger := AID;');
   Result.Add('               ExecSQL;');
   Result.Add('            end;');
   Result.Add('         end;');
   Result.Add('      tcExpress:');
   Result.Add('         begin');
   Result.Add('            with TSQLQuery(FQuery) do');
   Result.Add('            begin');
   Result.Add('               SQL.Clear;');
   Result.Add('               SQL.Add(Format(''DELETE FROM %s'', [FTable]));');
   Result.Add('               SQL.Add(''WHERE #NomePK# = :IDValue'');');
   Result.Add('               ParamByName(''IDVALUE'').AsInteger := AID;');
   Result.Add('               ExecSQL;');
   Result.Add('            end;');
   Result.Add('         end;');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' + '#NOME_TABELA#.DeleteWhere(Where: TStringList);');
   Result.Add('begin');
   Result.Add('   if Where.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   case FTipoConnection of');
   Result.Add('      tcFireDac:');
   Result.Add('         begin');
   Result.Add('            with TFDQuery(FQuery) do');
   Result.Add('            begin');
   Result.Add('               SQL.Clear;');
   Result.Add('               SQL.Add(Format(''DELETE FROM %s'', [FTable]));');
   Result.Add('               SQL.AddStrings(Where);');
   Result.Add('               ExecSQL;');
   Result.Add('            end;');
   Result.Add('         end;');
   Result.Add('      tcExpress:');
   Result.Add('         begin');
   Result.Add('            with TSQLQuery(FQuery) do');
   Result.Add('            begin');
   Result.Add('               SQL.Clear;');
   Result.Add('               SQL.Add(Format(''DELETE FROM %s'', [FTable]));');
   Result.Add('               SQL.AddStrings(Where);');
   Result.Add('               ExecSQL;');
   Result.Add('            end;');
   Result.Add('         end;');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('destructor T' + '#NOME_TABELA#.Destroy;');
   Result.Add('begin');
   Result.Add('   if Assigned(FQuery) then');
   Result.Add('      FreeAndNil(FQuery);');
   Result.Add('   inherited;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' + '#NOME_TABELA#.Insert(AValues: TStringList);');
   Result.Add('var');
   Result.Add('   Values, Colunas: string;');
   Result.Add('   I: integer;');
   Result.Add('begin');
   Result.Add('   {');
   Result.Add('     Estructure expected (AValues):');
   Result.Add('     [''Column=value'', ''Column=value'']');
   Result.Add('   }');
   Result.Add('   for I := 0 to AValues.Count - 1 do');
   Result.Add('   begin');
   Result.Add('      if Colunas = '''' then');
   Result.Add('         Colunas := Format(''%s'', [AValues.Names[I]])');
   Result.Add('      else');
   Result.Add
     ('                 Colunas := Format(''%s, %s'', [Colunas, AValues.Names[I]]);');
   Result.Add('');
   Result.Add('      if Values = '''' then');
   Result.Add('         Values := Format(''%s'', [AValues.ValueFromIndex[I]])');
   Result.Add('      else');
   Result.Add
     ('         Values := Format(''%s, %s'', [Values, AValues.ValueFromIndex[I]]);');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   case FTipoConnection of');
   Result.Add('      tcFireDac:');
   Result.Add('         begin');
   Result.Add('            with TFDQuery(FQuery) do');
   Result.Add('            begin');
   Result.Add('               SQL.Clear;');
   Result.Add
     ('               SQL.Add(Format(''INSERT INTO %s (%s)'', [FTable, Colunas]));');
   Result.Add('               SQL.Add(Format(''VALUES (%s)'', [Values]));');
   Result.Add('               ExecSQL;');
   Result.Add('            end;');
   Result.Add('         end;');
   Result.Add('      tcExpress:');
   Result.Add('         begin');
   Result.Add('            with TSQLQuery(FQuery) do');
   Result.Add('            begin');
   Result.Add('               SQL.Clear;');
   Result.Add
     ('               SQL.Add(Format(''INSERT INTO %s (%s)'', [FTable, Colunas]));');
   Result.Add('               SQL.Add(Format(''VALUES (%s)'', [Values]));');
   Result.Add('               ExecSQL;');
   Result.Add('            end;');
   Result.Add('         end;');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.Query(var Q: TFDQuery; AQuery: TStringList; ATypeQuery: TTypeQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('      raise Exception.Create(' +
     QuotedStr('Query não instanciado') + ');');
   Result.Add('');
   Result.Add('   if AQuery.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      case ATypeQuery of');
   Result.Add('         tqExecSQL:');
   Result.Add('            begin');
   Result.Add('               with Q do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.AddStrings(AQuery);');
   Result.Add('                  ExecSQL;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('         tqOpen:');
   Result.Add('            begin');
   Result.Add('               with Q do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.AddStrings(AQuery);');
   Result.Add('                  Open;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(' + QuotedStr('Error Data: ') +
     ' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.Query(var Q: TSQLQuery; AQuery: TStringList; ATypeQuery: TTypeQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('      raise Exception.Create(' +
     QuotedStr('Query não instanciado') + ');');
   Result.Add('');
   Result.Add('   if AQuery.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      case ATypeQuery of');
   Result.Add('         tqExecSQL:');
   Result.Add('            begin');
   Result.Add('               with Q do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.AddStrings(AQuery);');
   Result.Add('                  ExecSQL;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('         tqOpen:');
   Result.Add('            begin');
   Result.Add('               with Q do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.AddStrings(AQuery);');
   Result.Add('                  Open;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(' + QuotedStr('Error Data: ') +
     ' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' + '#NOME_TABELA#.SelectAll(var Q: TSQLQuery);');
   Result.Add('begin');
   Result.Add('');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('   begin');
   Result.Add('      raise Exception.Create(''Query não instanciado'');');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      with Q do');
   Result.Add('      begin');
   Result.Add('         SQL.Clear;');
   Result.Add('         SQL.Add(Format(''SELECT * FROM %s'', [FTable]));');
   Result.Add('         Open;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' + '#NOME_TABELA#.SelectAll(var Q: TFDQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('   begin');
   Result.Add('      raise Exception.Create(''Query não instanciado'');');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      with Q do');
   Result.Add('      begin');
   Result.Add('         SQL.Clear;');
   Result.Add('         SQL.Add(Format(''SELECT * FROM %s'', [FTable]));');
   Result.Add('         Open;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.SelectJoin(AJoin: TStringList; var Q: TFDQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('   begin');
   Result.Add('      raise Exception.Create(''Query não instanciado'');');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   if AJoin.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      with Q do');
   Result.Add('      begin');
   Result.Add('         SQL.Clear;');
   Result.Add('         SQL.Add(Format(''SELECT * FROM %s'', [FTable]));');
   Result.Add('         SQL.AddStrings(AJoin);');
   Result.Add('         Open;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.SelectJoin(AJoin: TStringList; var Q: TSQLQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('   begin');
   Result.Add('      raise Exception.Create(''Query não instanciado'');');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   if AJoin.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      with Q do');
   Result.Add('      begin');
   Result.Add('         SQL.Clear;');
   Result.Add('         SQL.Add(Format(''SELECT * FROM %s'', [FTable]));');
   Result.Add('         SQL.AddStrings(AJoin);');
   Result.Add('         Open;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.SelectWhere(AWhere: TStringList; var Q: TSQLQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('   begin');
   Result.Add('      raise Exception.Create(''Query não instanciado'');');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   if AWhere.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      with Q do');
   Result.Add('      begin');
   Result.Add('         SQL.Clear;');
   Result.Add('         SQL.Add(Format(''SELECT * FROM %s'', [FTable]));');
   Result.Add('         SQL.AddStrings(AWhere);');
   Result.Add('         Open;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.SelectWhere(AWhere: TStringList; var Q: TFDQuery);');
   Result.Add('begin');
   Result.Add('   if not Assigned(Q) then');
   Result.Add('   begin');
   Result.Add('      raise Exception.Create(''Query não instanciado'');');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   if AWhere.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      with Q do');
   Result.Add('      begin');
   Result.Add('         SQL.Clear;');
   Result.Add('         SQL.Add(Format(''SELECT * FROM %s'', [FTable]));');
   Result.Add('         SQL.AddStrings(AWhere);');
   Result.Add('         Open;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.Update(AID: integer; AValues: TStringList);');
   Result.Add('var');
   Result.Add('   Sets: String;');
   Result.Add('   I: integer;');
   Result.Add('begin');
   Result.Add('   {');
   Result.Add('     Estructure expected (AValues):');
   Result.Add('     [''Column=value'', ''Column=value'']');
   Result.Add('   }');
   Result.Add('   if AValues.Count = 0 then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   for I := 0 to AValues.Count - 1 do');
   Result.Add('   begin');
   Result.Add('      if Sets = '''' then');
   Result.Add('         Sets := Format(''%s = %s'', [AValues.Names[I], AValues.ValueFromIndex[I]])');
   Result.Add('      else');
   Result.Add('         Sets := Format(''%s, %s = %s'', [Sets, AValues.Names[I], AValues.ValueFromIndex[I]]);');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      case FTipoConnection of');
   Result.Add('         tcFireDac:');
   Result.Add('            begin');
   Result.Add('               with TFDQuery(FQuery) do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.Add(Format(''UPDATE %s'', [FTable]));');
   Result.Add('                  SQL.Add(Format(''SET %s'', [Sets]));');
   Result.Add('                  SQL.Add(''WHERE #NomePK# = :IDValue'');');
   Result.Add('                  ParamByName(''IDVALUE'').AsInteger := AID;');
   Result.Add('                  ExecSQL;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('         tcExpress:');
   Result.Add('            begin');
   Result.Add('               with TFDQuery(FQuery) do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.Add(Format(''UPDATE %s'', [FTable]));');
   Result.Add('                  SQL.Add(Format(''SET %s'', [Sets]));');
   Result.Add('                  SQL.Add(''WHERE #NomePK# = :IDValue'');');
   Result.Add('                  ParamByName(''IDVALUE'').AsInteger := AID;');
   Result.Add('                  ExecSQL;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('procedure T' +
     '#NOME_TABELA#.UpdateWhere(AValues: TStringList; AWhere: TStringList);');
   Result.Add('var');
   Result.Add('   Sets: String;');
   Result.Add('   I: integer;');
   Result.Add('begin');
   Result.Add('   {');
   Result.Add('     Estructure expected (AValues):');
   Result.Add('     [''Column=value'', ''Column=value'']');
   Result.Add('   }');
   Result.Add('    if (AValues.Count = 0) or (AWhere.Count = 0) then');
   Result.Add('      exit;');
   Result.Add('');
   Result.Add('   for I := 0 to AValues.Count - 1 do');
   Result.Add('   begin');
   Result.Add('      if Sets = '''' then');
   Result.Add('         Sets := Format(''%s = %s'', [AValues.Names[I], AValues.ValueFromIndex[I]])');
   Result.Add('      else');
   Result.Add('         Sets := Format(''%s, %s = %s'', [Sets, AValues.Names[I], AValues.ValueFromIndex[I]]);');
   Result.Add('   end;');
   Result.Add('');
   Result.Add('   try');
   Result.Add('      case FTipoConnection of');
   Result.Add('         tcFireDac:');
   Result.Add('            begin');
   Result.Add('               with TFDQuery(FQuery) do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.Add(Format(''UPDATE %s'', [FTable]));');
   Result.Add('                  SQL.Add(Format(''SET %s'', [Sets]));');
   Result.Add('                  SQL.AddStrings(AWhere);');
   Result.Add('                  ExecSQL;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('         tcExpress:');
   Result.Add('            begin');
   Result.Add('               with TFDQuery(FQuery) do');
   Result.Add('               begin');
   Result.Add('                  SQL.Clear;');
   Result.Add('                  SQL.Add(Format(''UPDATE %s'', [FTable]));');
   Result.Add('                  SQL.Add(Format(''SET %s'', [Sets]));');
   Result.Add('                  SQL.AddStrings(AWhere);');
   Result.Add('                  ExecSQL;');
   Result.Add('               end;');
   Result.Add('            end;');
   Result.Add('      end;');
   Result.Add('   except');
   Result.Add('      on E: Exception do');
   Result.Add('         raise Exception.Create(''Error Data: '' + E.Message);');
   Result.Add('   end;');
   Result.Add('end;');
   Result.Add('');
   Result.Add('end.');
{$ENDREGION}
end;

end.
