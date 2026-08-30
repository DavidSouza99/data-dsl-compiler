module DataDSL.Frontend.Lexer.Token where

import Data.Char (isSpace, isDigit, isAlpha)

type Line = Int
type Column = Int

data Token = Token
    {   pos :: (Line, Column)
    ,   lexeme :: Lexeme
    } deriving (Show)

data Lexeme
    = TLoad 
    | TFilter 
    | TSelect 
    | TIdent String
    | TString String
    | TNumber Int
    | TGt
    | TLt
    | TGe
    | TLe
    | TEq
    | TComma
    | TEOF
    deriving (Show)

type State = (Line, Column, String, [Token])

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

mkDigits :: State -> Char -> Either String State
mkDigits state@(l, col, s, ts) c
    | null s = -- Nenhum dígito acumulado: so atualiza a posição e continua
        let l' = if c == '\n' then l + 1 else l
            col' = if isSpace c then col + 1 else col
        in Right (l', col', s, ts)
    | all isDigit s = -- digitos válidos: cria token TNumber
        let t = Token (l, col) (TNumber (read $ reverse s))
            l' = if c == '\n' then l + 1 else l
            col' = if c /= '\n' && isSpace c then col + 1 else col
        in Right (l', col', "", t : ts)
    | otherwise = Left $ unexpectedCharError l col c

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

classificarPalavra :: String -> Lexeme
classificarPalavra s
    | s == "load" = TLoad
    | s == "filter" = TFilter
    | s == "select" = TSelect
    | otherwise = TIdent s


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

unexpectedCharError :: Line -> Column -> Char -> String
unexpectedCharError l c char =
    "Caractere inesperado '" ++ [char] ++ "' na linha " ++ show l ++ ", coluna " ++ show c