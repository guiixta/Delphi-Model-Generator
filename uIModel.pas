unit uIModel;

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
   Contnrs,
   Data.SqlExpr,
   Data.DB,
   FireDAC.Comp.Client,
   FireDAC.Comp.DataSet,
   FireDAC.Stan.Param;

type
   TTypeConn = (tcFireDac, tcExpress);

   IModel = interface
      ['{47E13D14-AFF6-4B03-96EC-697221423171}']

      procedure Delete(AID: integer); overload;
      procedure DeleteWhere(Where: TStringList); overload;

      procedure Update(AID: integer; AValues: TStringList); overload;
      procedure UpdateWhere(AValues: TStringList; AWhere: TStringList);
        overload;

      procedure Insert(AValues: TStringList);

      procedure SelectAll(var Q: TSQLQuery); overload;
      procedure SelectAll(var Q: TFDQuery); overload;

      procedure SelectWith(ASQL: TStringList; var Q: TSQLQuery); overload;
      procedure SelectWith(ASQL: TStringList; var Q: TFDQuery); overload;

   end;

   TModelBase = class(TInterfacedObject, IModel)
   private
      { private declarations }
      FTipoConnection: TTypeConn;
      FQuery: TDataSet;
      FTable: String;
      FPK: string;
   protected
      { protected declarations }
   public
      { public declarations }
      procedure Delete(AID: integer); overload;
      procedure DeleteWhere(Where: TStringList); overload;

      procedure Update(AID: integer; AValues: TStringList); overload;
      procedure UpdateWhere(AValues: TStringList; AWhere: TStringList);
        overload;

      procedure Insert(AValues: TStringList);

      procedure SelectAll(var Q: TSQLQuery); overload;
      procedure SelectAll(var Q: TFDQuery); overload;

      procedure SelectWith(ASQL: TStringList; var Q: TSQLQuery); overload;
      procedure SelectWith(ASQL: TStringList; var Q: TFDQuery); overload;

      constructor Create(AConn: TSQLConnection; ATable: string; APK: string);
        reintroduce; overload;
      constructor Create(AConn: TFDConnection; ATable: string; APK: string);
        reintroduce; overload;

      destructor Destroy; override;
   end;

implementation

{ TModel }

constructor TModel.Create(AConn: TFDConnection; ATable: string; APK: string);
begin
   inherited Create;
   FQuery := TFDQuery.Create(nil);
   TFDQuery(FQuery).Connection := AConn;

   FTipoConnection := tcFireDac;
   FTable := ATable;
   FPK := APK;
end;

constructor TModel.Create(AConn: TSQLConnection; ATable: string; APK: string);
begin
   inherited Create;
   FQuery := TSQLQuery.Create(nil);
   TSQLQuery(FQuery).SQLConnection := AConn;

   FTipoConnection := tcExpress;
   FTable := ATable;
   FPK := APK;
end;

procedure TModel.Delete(AID: integer);
begin
   case FTipoConnection of
      tcFireDac:
         begin
            with TFDQuery(FQuery) do
            begin
               SQL.Clear;
               SQL.Add(Format('DELETE FROM %s', [FTable]));
               SQL.Add(Format('WHERE %s = :IDVAl', [FPK]));
               ParamByName('IDVAL').AsInteger := AID;
               ExecSQL;
            end;
         end;
      tcExpress:
         begin
            with TSQLQuery(FQuery) do
            begin
               SQL.Clear;
               SQL.Add(Format('DELETE FROM %s', [FTable]));
               SQL.Add(Format('WHERE %s = :IDVAl', [FPK]));
               ParamByName('IDVAL').AsInteger := AID;
               ExecSQL;
            end;
         end;
   end;
end;

procedure TModel.DeleteWhere(Where: TStringList);
begin
   if Where.Count = 0 then
      exit;

   case FTipoConnection of
      tcFireDac:
         begin
            with TFDQuery(FQuery) do
            begin
               SQL.Clear;
               SQL.Add(Format('DELETE FROM %s', [FTable]));
               SQL.AddStrings(Where);
               ExecSQL;
            end;
         end;
      tcExpress:
         begin
            with TSQLQuery(FQuery) do
            begin
               SQL.Clear;
               SQL.Add(Format('DELETE FROM %s', [FTable]));
               SQL.AddStrings(Where);
               ExecSQL;
            end;
         end;
   end;
end;

destructor TModel.Destroy;
begin
   if Assigned(FQuery) then
      FreeAndNil(FQuery);
   inherited;
end;

procedure TModel.Insert(AValues: TStringList);
var
   Values, Colunas: string;
   I: integer;
begin
   {
     Estructure expected (AValues):
     ['Column=value', 'Column=value']
   }
   for I := 0 to AValues.Count - 1 do
   begin
      if Colunas = '' then
         Colunas := Format('%s', [AValues.Names[I]])
      else
         Colunas := Format('%s, %s', [Colunas, AValues.Names[I]]);

      if Values = '' then
         Values := Format('%s', [AValues.ValuesFromIndex[I]])
      else
         Values := Format('%s, %s', [Values, AValues.ValueFromIndex[I]]);
   end;

   case FTipoConnection of
      tcFireDac:
         begin
            with TFDQuery(FQuery) do
            begin
               SQL.Clear;
               SQL.Add(Format('INSERT INTO %s (%s)', [FTable, Colunas]));
               SQL.Add(Format('VALUES (%s)', [Values]));
               ExecSQL;
            end;
         end;
      tcExpress:
         begin
            with TSQLQuery(FQuery) do
            begin
               SQL.Clear;
               SQL.Add(Format('INSERT INTO %s (%s)', [FTable, Colunas]));
               SQL.Add(Format('VALUES (%s)', [Values]));
               ExecSQL;
            end;
         end;
   end;

end;

procedure TModel.SelectAll(var Q: TSQLQuery);
begin

   if not Assigned(Q) then
   begin
      raise Exception.Create('Query não instanciado');
   end;

   try
      with Q do
      begin
         SQL.Clear;
         SQL.Add(Format('SELECT * FROM %s', [FTable]));
         Open;
      end;
   except
      on E: Exception do
         raise Exception.Create('Error Data: ' + E.Message);
   end;

end;

procedure TModel.SelectAll(var Q: TFDQuery);
begin
   if not Assigned(Q) then
   begin
      raise Exception.Create('Query não instanciado');
   end;

   try
      with Q do
      begin
         SQL.Clear;
         SQL.Add(Format('SELECT * FROM %s', [FTable]));
         Open;
      end;
   except
      on E: Exception do
         raise Exception.Create('Error Data: ' + E.Message);
   end;
end;

procedure TModel.SelectWith(ASQL: TStringList; var Q: TFDQuery);
begin
   if not Assigned(Q) then
   begin
      raise Exception.Create('Query não instanciado');
   end;

   if ASQL.Count = 0 then
      exit;

   try
      with Q do
      begin
         SQL.Clear;
         SQL.Add(Format('SELECT * FROM %s', [FTable]));
         SQL.AddStrings(ASQL);
         Open;
      end;
   except
      on E: Exception do
         raise Exception.Create('Error Data: ' + E.Message);
   end;
end;

procedure TModel.SelectWith(ASQL: TStringList; var Q: TSQLQuery);
begin
   if not Assigned(Q) then
   begin
      raise Exception.Create('Query não instanciado');
   end;

   if ASQL.Count = 0 then
      exit;

   try
      with Q do
      begin
         SQL.Clear;
         SQL.Add(Format('SELECT * FROM %s', [FTable]));
         SQL.AddStrings(ASQL);
         Open;
      end;
   except
      on E: Exception do
         raise Exception.Create('Error Data: ' + E.Message);
   end;
end;

procedure TModel.Update(AID: integer; AValues: TStringList);
var
   Sets: String;
   I: integer;
begin
   {
     Estructure expected (AValues):
     ['Column=value', 'Column=value']
   }
   if AValues.Count = 0 then
      exit;

   for I := 0 to AValues.Count - 1 do
   begin
      if Sets = '' then
         Sets := Format('%s = %s', [AValues.Names[I],
           AValues.ValueFromIndex[I]])
      else
         Sets := Format('%s, %s = %s', [Sets, AValues.Names[I],
           AValues.ValueFromIndex[I]]);
   end;

   try
      case FTipoConnection of
         tcFireDac:
            begin
               with TFDQuery(FQuery) do
               begin
                  SQL.Clear;
                  SQL.Add(Format('UPDATE %s', [FTable]));
                  SQL.Add(Format('SET %s', [Sets]));
                  SQL.Add(Format('WHERE %s = :IDVALUE', [FPK]));
                  ParamByName('IDVALUE').AsInteger := AID;
                  ExecSQL;
               end;
            end;
         tcExpress:
            begin
               with TFDQuery(FQuery) do
               begin
                  SQL.Clear;
                  SQL.Add(Format('UPDATE %s', [FTable]));
                  SQL.Add(Format('SET %s', [Sets]));
                  SQL.Add(Format('WHERE %s = :IDVALUE', [FPK]));
                  ParamByName('IDVALUE').AsInteger := AID;
                  ExecSQL;
               end;
            end;
      end;
   except
      on E: Exception do
         raise Exception.Create('Error Data: ' + E.Message);
   end;
end;

procedure TModel.UpdateWhere(AValues, AWhere: TStringList);
var
   Sets: String;
   I: integer;
begin
   {
     Estructure expected (AValues):
     ['Column=value', 'Column=value']
   }
   if (AValues.Count = 0) or (AWhere.Count = 0) then
      exit;

   for I := 0 to AValues.Count - 1 do
   begin
      if Sets = '' then
         Sets := Format('%s = %s', [AValues.Names[I],
           AValues.ValueFromIndex[I]])
      else
         Sets := Format('%s, %s = %s', [Sets, AValues.Names[I],
           AValues.ValueFromIndex[I]]);
   end;

   try
      case FTipoConnection of
         tcFireDac:
            begin
               with TFDQuery(FQuery) do
               begin
                  SQL.Clear;
                  SQL.Add(Format('UPDATE %s', [FTable]));
                  SQL.Add(Format('SET %s', [Sets]));
                  SQL.AddStrings(AWhere);
                  ExecSQL;
               end;
            end;
         tcExpress:
            begin
               with TFDQuery(FQuery) do
               begin
                  SQL.Clear;
                  SQL.Add(Format('UPDATE %s', [FTable]));
                  SQL.Add(Format('SET %s', [Sets]));
                  SQL.AddStrings(AWhere);
                  ExecSQL;
               end;
            end;
      end;
   except
      on E: Exception do
         raise Exception.Create('Error Data: ' + E.Message);
   end;
end;

initialization

finalization

if Assigned(Model) then
   FreeAndNil(Model);

end.
