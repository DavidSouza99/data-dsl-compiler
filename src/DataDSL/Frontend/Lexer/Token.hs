module DataDSL.Frontend.Lexer.Token where

-- Esse arquivo é uma análise léxica Ad-hoc para a linguagem DataDSL. Serve como um exemplo de como implementar um lexer simples em Haskell.
-- O projeto será continuado em Alex, que é uma ferramenta mais robusta para gerar lexers.

-- Este lexer cobre apenas palavras-chave, identificadores e números.
-- Operadores, vírgula e strings ainda não são suportados nesta versão ad-hoc
-- (ver versão final com Alex em DataDSLLexer.x).

import Data.Char (isSpace, isDigit, isAlpha)

-- Define tipos line e Column que são basicamente inteiros.
type Line = Int
type Column = Int

-- Define o tipo Token, que carrega linha, coluna e o lexema correspondente.
data Token = Token
    {   pos :: (Line, Column)
    ,   lexeme :: Lexeme
    } deriving (Show)

-- Define o tipo Lexeme, que representa os diferentes tipos de tokens que podem ser reconhecidos pelo lexer.
data Lexeme
    = TLoad             -- Representa a palavra-chave "load".
    | TFilter           -- Representa a palavra-chave "filter".
    | TSelect           -- Representa a palavra-chave "select".
    | TString String    -- Representa uma string entre aspas duplas.
    | TIdent String     -- Representa um identificador, que é uma sequência de letras minúsculas e dígitos.
    | TNumber Int       -- Representa um número inteiro.
    | TDouble Double    -- Representa um número decimal.
    | TComma            -- Representa o símbolo de vírgula ','.
    | TGt               -- Representa o símbolo de maior '>'.
    | TLt               -- Representa o símbolo de menor '<'.
    | TGe               -- Representa o símbolo de maior ou igual '>='.
    | TLe               -- Representa o símbolo de menor ou igual '<='.
    | TEq               -- Representa o símbolo de igual '='.
    | TNotEq            -- Representa o símbolo de diferente '!='.
    | TEOF              -- Representa o fim do arquivo.
    deriving (Show, Eq)

