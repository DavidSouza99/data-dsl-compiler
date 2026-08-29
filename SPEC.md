# DataDSL — Especificação (v1)

## Objetivo

DataDSL é uma linguagem declarativa para descrever pipelines simples de
transformação de dados. Um compilador (escrito em Haskell) traduz um
programa DataDSL em código Python/pandas equivalente.

## Escopo da v1

Três comandos, executados em sequência, um por linha:

- `load` — carrega um arquivo CSV
- `filter` — filtra linhas por uma condição de comparação
- `select` — seleciona um subconjunto de colunas

## Exemplo de programa

```
load "dados.csv"
filter idade > 18
select nome, idade, cidade
```

## Saída esperada (Python gerado)

```python
import pandas as pd

df = pd.read_csv("dados.csv")
df = df[df["idade"] > 18]
df = df[["nome", "idade", "cidade"]]
print(df)
```

## Gramática (BNF)

```
programa   ::= comando+

comando    ::= load
             | filter
             | select

load       ::= "load" string

filter     ::= "filter" coluna operador valor

select     ::= "select" coluna ("," coluna)*

operador   ::= ">" | "<" | ">=" | "<=" | "=="

valor      ::= numero | string

coluna     ::= identificador

identificador ::= letra (letra | digito)*

string     ::= '"' caractere* '"'

numero     ::= digito+
```

## Tokens (categorias léxicas)

| Token         | Exemplo      | Descrição                          |
|---------------|--------------|-------------------------------------|
| `TLoad`       | `load`       | palavra-chave                       |
| `TFilter`     | `filter`     | palavra-chave                       |
| `TSelect`     | `select`     | palavra-chave                       |
| `TIdent`      | `idade`      | identificador (nome de coluna)      |
| `TString`     | `"dados.csv"`| literal string                      |
| `TNumber`     | `18`         | literal numérico                    |
| `TGt`         | `>`          | operador: maior que                 |
| `TLt`         | `<`          | operador: menor que                 |
| `TGe`         | `>=`         | operador: maior ou igual            |
| `TLe`         | `<=`         | operador: menor ou igual            |
| `TEq`         | `==`         | operador: igual                     |
| `TComma`      | `,`          | separador de colunas                |
| `TEOF`        | —            | fim de entrada                      |

## Regras léxicas

- Identificadores de coluna: começam com letra minúscula, seguidos de
  letras ou dígitos (mesma regra do exercício de identificadores já
  praticado em Compiladores).
- Strings: delimitadas por aspas duplas, sem suporte a escape na v1.
- Espaços em branco entre tokens são ignorados; cada comando ocupa
  uma linha.

## Estrutura de módulos planejada

```
src/DataDSL/
  Frontend/
    Lexer/
      Token.hs
      DataDSLLexer.hs
    Parser/
      DataDSLSyntax.hs      -- definição da AST
      DataDSLParser.hs
  Backend/
    Python/
      PythonCodegen.hs
app/
  Main.hs                   -- lê arquivo .ddsl, imprime .py gerado
```

## Fora de escopo na v1 (backlog para versões futuras)

- `group_by` e agregações (`mean`, `sum`, `count`)
- `join` entre múltiplas fontes
- Colunas calculadas (expressões aritméticas)
- Condições compostas (`and` / `or`) no `filter`
- Ordenação (`sort`)
