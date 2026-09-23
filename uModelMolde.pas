unit u{NOME_TABELA};

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
   Data.SqlExpr,                                     1
   FireDAC.Comp.Client,
   FireDAC.Stan.Param,
   uIModel;

type

   T{NOME_TABELA} = class(TModelBase)
   private
      { private declarations }
   protected
      { protected declarations }
   public
      { public declarations }
      constructor Create(AConn: TSQLConnection); overload;
      constructor Create(AConn: TFDConnection); overload;
   end;

   var
      {NOME_TABELA}: T{NOME_TABELA};

implementation

{ T{NOME_TABELA} }

constructor T{NOME_TABELA}.Create(AConn: TSQLConnection);
begin
   inherited Create(AConn, '{NOME_TABELA}', '{NOME_PK}');
end;

constructor T{NOME_TABELA}.Create(AConn: TFDConnection);
begin
   inherited Create(AConn, '{NOME_TABELA}', '{NOME_PK}');
end;

end.
