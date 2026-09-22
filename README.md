# ModelMake Utility

**ModelMake** (`uModelMake.pas`) é uma utilitário em **Delphi** projetado para escanear o banco de dados e gerar automaticamente classes de modelo (*Models*) e a interface base (`uIModel.pas`). Ela mapeia as tabelas do seu banco de dados, identifica as chaves primárias (PK) e gera o código Delphi com operações básicas de CRUD.

---

## 🚀 Funcionalidades

- **Escaneamento Automático:** Mapeia todas as tabelas do banco de dados e obtém suas chaves primárias (suporte nativo para Firebird via metadados `RDB$`).
- **Geração Dinâmica de Código:** Cria automaticamente unidades Delphi (`u<NomeTabela>.pas`) contendo a estrutura da classe e seus métodos de persistência.
- **Geração de Interface Base:** Cria a unidade `uIModel.pas`, definindo o contrato comum para todos os modelos gerados.
- **Suporte Multi-Engine:** Compatível com **FireDAC** (`TFDConnection`) e **dbExpress** (`TSQLConnection`).

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem:** Delphi (Pascal)
- **Acesso a Dados:** FireDAC, dbExpress
- **Banco de Dados:** Firebird (para resolução automática de PKs)

---

## 📂 Arquivos Gerados Automatizados

Ao executar a classe `TModelScan`, a seguinte estrutura de arquivos é criada no diretório de saída:

```text
Models/
├── uIModel.pas          # Interface base (IModel)
├── uCLIENTES.pas        # Modelo gerado para a tabela CLIENTES
├── uPRODUTOS.pas        # Modelo gerado para a tabela PRODUTOS
└── ...
```

---

## 💻 Como Usar

### 1. Inicialização e Geração dos Models

Para escanear o banco e gerar os modelos, basta instanciar a classe `TModelScan` informando a conexão e, opcionalmente, o diretório de destino:

#### Utilizando **FireDAC**:
```pascal
uses uModelMake;

procedure GerarModelosComFireDAC;
begin
  // Instancia e gera todos os modelos na pasta padrão (\Models) ou em um caminho customizado
  TModelScan.Create(FDConnection1, 'C:\MeuProjeto\Models\');
end;
```

#### Utilizando **dbExpress**:
```pascal
uses uModelMake;

procedure GerarModelosComDBExpress;
begin
  TModelScan.Create(SQLConnection1);
end;
```

---

### 2. Exemplo de Uso dos Models Gerados

Após a geração, você pode utilizar as classes geradas diretamente na sua aplicação para realizar operações no banco de dados.

#### **Inclusão (Insert)**
```pascal
var
  Valores: TStringList;
  ClienteModel: TCLIENTES;
begin
  Valores := TStringList.Create;
  try
    Valores.Add('NOME=''João da Silva''');
    Valores.Add('EMAIL=''joao@email.com''');

    ClienteModel := TCLIENTES.Create(FDConnection1);
    try
      ClienteModel.Insert(Valores);
    finally
      ClienteModel.Free;
    end;
  finally
    Valores.Free;
  end;
end;
```

#### **Atualização (Update)**
```pascal
var
  Valores: TStringList;
  ClienteModel: TCLIENTES;
begin
  Valores := TStringList.Create;
  try
    Valores.Add('NOME=''João Silva Sauro''');

    ClienteModel := TCLIENTES.Create(FDConnection1);
    try
      // Atualiza o registro com PK (ID) = 10
      ClienteModel.Update(10, Valores);
    finally
      ClienteModel.Free;
    end;
  finally
    Valores.Free;
  end;
end;
```

#### **Exclusão (Delete)**
```pascal
var
  ClienteModel: TCLIENTES;
begin
  ClienteModel := TCLIENTES.Create(FDConnection1);
  try
    ClienteModel.Delete(10);
  finally
    ClienteModel.Free;
  end;
end;
```

#### **Consulta (SelectAll / SelectWhere)**
```pascal
var
  ClienteModel: TCLIENTES;
  Q: TFDQuery;
  Filtro: TStringList;
begin
  Q := TFDQuery.Create(nil);
  Filtro := TStringList.Create;
  try
    Filtro.Add('WHERE STATUS = ''A''');

    ClienteModel := TCLIENTES.Create(FDConnection1);
    try
      ClienteModel.SelectWhere(Filtro, Q);
      
      // Itera sobre os resultados
      while not Q.Eof do
      begin
        // Fazer algo com os dados
        Q.Next;
      end;
    finally
      ClienteModel.Free;
    end;
  finally
    Filtro.Free;
    Q.Free;
  end;
end;
```

---

## 👤 Autor

Desenvolvido por **guiixta** - [GitHub Profile](https://github.com/guiixta)
