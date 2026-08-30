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
    = TLoad 
    | TFilter 
    | TSelect 
    | TIdent String
    | TNumber Int
    deriving (Show)

-- Define o tipo State, que representa o estado atual do lexer, incluindo linha, coluna, string acumulada e a lista de tokens reconhecidos até o momento.
type State = (Line, Column, String, [Token])

-- lexer é a função principal que recebe uma string de entrada e retorna uma lista de tokens ou um erro.
-- finish . foldl step base percorre cada caractere da string de entrada, atualizando o estado do lexer e acumulando tokens reconhecidos.
lexer :: String -> Either String [Token]
lexer = finish . foldl step base
    where
        base = Right (1, 1, "", [])
        step (Left e) _ = Left e
        step (Right s) c = transition s c
        finish = either Left (Right . extract)
        extract (l, c, s, ts)
            | null s = reverse ts
            | all isAlpha s = let t = Token (l, c - length s) (classificarPalavra (reverse s))
                              in reverse (t : ts)
            | all isDigit s = let n = read (reverse s)
                                  t = Token (l, c - length s) (TNumber n)
                              in reverse (t : ts)

-- Função auxiliar para identificar e criar tokens de dígitos. Se a string acumulada for vazia, apenas atualiza a posição.
-- se todos os caracteres acumulados forem dígitos, cria um token TNumber. Caso contrario, retorna um erro.
mkDigits :: State -> Char -> Either String State
mkDigits state@(l, col, s, ts) c
    | null s = -- Nenhum dígito acumulado so atualiza a posição e continua
        let l' = if c == '\n' then l + 1 else l
            col' = if isSpace c then col + 1 else col
        in Right (l', col', s, ts)
    | all isDigit s = -- digitos válidos cria token TNumber
        let t = Token (l, col) (TNumber (read $ reverse s))
            l' = if c == '\n' then l + 1 else l
            col' = if c /= '\n' && isSpace c then col + 1 else col
        in Right (l', col', "", t : ts)
    | otherwise = Left $ unexpectedCharError l col c

-- Função auxiliar para identificar e criar tokens de palavras. Se a string acumulada for vazia, apenas atualiza a posição.
-- se todos os caracteres acumulados forem letras, cria um token TIdent ou uma palavra reservada. Caso contrario, retorna um erro.
mkWord :: State -> Char -> Either String State
mkWord state@(l, col, s, ts) c
    | null s = -- Nenhuma palavra acumulada: so atualiza a posição e continua
        let l' = if c == '\n' then l + 1 else l
            col' = if isSpace c then col + 1 else col
        in Right (l', col', s, ts)
    | all isAlpha s = -- palavra válida: cria token TIdent ou uma palavra reservada
        let t = Token (l, col - length s) (classificarPalavra (reverse s))
            l' = if c == '\n' then l + 1 else l
            col' = if c /= '\n' && isSpace c then col + 1 else col
        in Right (l', col', "", t : ts)
    | otherwise = Left $ unexpectedCharError l col c

-- função auxiliar para classificar palavras reservadas ou identificadores. Se a palavra for uma palavra reservada, retorna o token correspondente.
classificarPalavra :: String -> Lexeme
classificarPalavra s
    | s == "load" = TLoad
    | s == "filter" = TFilter
    | s == "select" = TSelect
    | otherwise = TIdent s

-- função de transição que recebe o estado atual e um caractere, e retorna o proximo estado ou um erro.
-- Vai verificando o caractere recebido e chamando as funções auxiliares que são mkDigits e mkWord, dependendo do tipo de caractere recebido.
-- Se o caractere for inesperado, retorna um erro com a posição do caractere.
transition :: State -> Char -> Either String State
transition state@(line, col, t, ts) c
    | c == '\n' && null t = mkDigits state c  -- Nova linha
    | c == '\n' && all isDigit t = mkDigits state c  -- Nova linha, mas acumulando dígitos
    | c == '\n' && all isAlpha t = mkWord state c -- Nova linha, mas acumulando letras
    | isSpace c && null t = mkDigits state c  -- Espaço em branco, sem token acumulado
    | isSpace c && all isDigit t = mkDigits state c  -- Espaço em branco, mas acumulando dígitos
    | isSpace c && all isAlpha t = mkWord state c -- Espaço em branco, mas acumulando letras
    | isDigit c = Right (line, col + 1, c : t, ts)  -- Acumula dígito
    | isAlpha c = Right (line, col + 1, c : t, ts) -- Acumula letra
    | otherwise = Left $ unexpectedCharError line col c

-- função auxiliar para gerar uma mensagem de erro quando um caractere inesperado é encontrado.
unexpectedCharError :: Line -> Column -> Char -> String
unexpectedCharError l c char =
    "Caractere inesperado '" ++ [char] ++ "' na linha " ++ show l ++ ", coluna " ++ show c