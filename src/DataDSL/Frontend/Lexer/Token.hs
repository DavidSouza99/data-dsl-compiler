module DataDSL.Frontend.Lexer.Token where

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