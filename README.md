# ModelMake Utility `v1.0.2`

**ModelMake** (`uModelMake.pas`) é um utilitário inteligente em **Delphi** projetado para escanear a estrutura do seu banco de dados e gerar automaticamente uma arquitetura de dados baseada no padrão MVC.

A partir da versão **1.0.2**, o utilitário adota o padrão de **Herança de Classe Base Reutilizável**. O motor do utilitário busca as estruturas base de contratos (`uIModel.pas` contendo a classe pai `TModelBase`) diretamente do repositório remoto ou de um caminho local, gerando arquivos de tabelas específicos totalmente limpos e focados, prontos para a extensão segura de regras de negócio sem quebrar o MVC.

---

## 🚀 Novas Funcionalidades (v1.0.2)

- **Arquitetura Baseada em Herança:** As classes geradas para cada tabela nascem limpas (sem repetição de código) e herdam toda a inteligência do CRUD genérico de uma classe pai comum (`TModelBase`).
- **Templates Dinâmicos Remotos/Locais:** Integração nativa com `THTTPClient` para obter os moldes atualizados em tempo real via GitHub (branch `main`), contando também com uma rotina de contingência para carregamento de arquivos locais (`ObterLocal`) - Se preferir.
- **Fim da Redundância (SelectWith):** Consolidação dos antigos métodos separados de filtragem e junção em um único método abstrato maleável.

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem:** Delphi (Pascal) [2]
- **Protocolos:** HTTP Nativo (`System.Net.HttpClient`) [2]
- **Acesso a Dados:** FireDAC, dbExpress [2]
- **Banco de Dados:** Firebird (Mapeamento automático de chaves) [2]

---

## 📂 Arquivos Gerados e Arquitetura

Ao executar a classe `TModelScan`, o diretório de saída conterá:

```text
Models/
├── uIModel.pas          # Contrato da Interface (IModel) + Implementação da Classe Pai (TModelBase)
├── uCLIENTES.pas        # Classe filha TCLIENTES = class(TModelBase) -> Limpa e extensível
├── uPRODUTOS.pas        # Classe filha TPRODUTOS = class(TModelBase) -> Limpa e extensível
└── ...
```

---

## 💻 Como Usar

### 1. Inicialização e Geração dos Models

Para escanear o banco e gerar a estrutura desacoplada, basta passar a sua conexão de dados ativa e o diretório físico onde as Units devem ser salvas:

#### Utilizando **FireDAC**:
```pascal
uses uModelMake;

procedure GerarModelosComFireDAC;
begin
  // Busca os templates remotamente e cria a árvore de herança de banco na pasta indicada
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

### 2. Exemplo de Uso dos Models Gerados (CRUD Herdado)

O seu Controller passará a instanciar a classe da tabela correspondente. Como ela herda nativamente de `TModelBase`, todas as operações básicas de persistência funcionam instantaneamente.

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
      ClienteModel.Insert(Valores); // Método herdado automaticamente da classe pai
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
      // Atualiza o registro buscando dinamicamente pelo campo PK resolvido no banco
      ClienteModel.Update(10, Valores);
    finally
      ClienteModel.Free;
    end;
  finally
    Valores.Free;
  end;
end;
```

#### **Consulta Flexível com Encadeamento (SelectWith)**
O método `SelectWith` unifica e simplifica consultas ao banco, permitindo que você passe filtros (`WHERE`), junções (`JOIN`) e ordenações (`ORDER BY`) dinamicamente em uma única lista de comandos:

```pascal
var
  ClienteModel: TCLIENTES;
  Q: TFDQuery;
  Especificacao: TStringList;
begin
  Q := TFDQuery.Create(nil);
  Especificacao := TStringList.Create;
  try
    // Você pode encadear cláusulas livremente em um único parâmetro de strings
    Especificacao.Add('INNER JOIN CIDADES C ON C.CID_ID = CLIENTES.CID_ID ');
    Especificacao.Add('WHERE CLIENTES.STATUS = ''A'' ');
    Especificacao.Add('ORDER BY CLIENTES.NOME DESC');

    ClienteModel := TCLIENTES.Create(FDConnection1);
    try
      // Executa o SELECT básico acoplando as especificações fornecidas
      ClienteModel.SelectWith(Especificacao, Q);

      while not Q.Eof do
      begin
        // Acesse os dados da query mapeada normalmente
        Q.Next;
      end;
    finally
      ClienteModel.Free;
    end;
  finally
    Especificacao.Free;
    Q.Free;
  end;
end;
```

---

## 🛡️ Mantendo o MVC Correto (Extensão de Negócio)

A grande vantagem da versão **1.0.2** é a blindagem arquitetural. O arquivo `uCLIENTES.pas` gerado nasce apenas com os construtores configurados. Se você precisar aplicar uma regra de negócio complexa ou um SQL matemático que o Controller não deve conhecer (ex: cálculo de Cosseno de Similaridade Vetorial), **escreva o método de negócio diretamente dentro da classe filha**:

```pascal
// Dentro do arquivo uCLIENTES.pas criado pelo utilitário:
type
   TCLIENTES = class(TModelBase)
   public
      constructor Create(AConn: TFDConnection); overload;
      
      // Seu método customizado que o Controller chamará de forma limpa:
      procedure CalcularSimilaridadeDeClientes(IdA, IdB: Integer; var Q: TFDQuery);
   end;
```

---

## 👤 Autor

Desenvolvido por **guiixta** - [GitHub Profile](https://github.com/guiixta) 

