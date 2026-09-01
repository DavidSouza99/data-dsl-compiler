{
{-# OPTIONS_GHC -Wno-unused-imports #-}
module DataDSL.Frontend.Lexer.DataDSLLexer where

import Control.Monad
import DataDSL.Frontend.Lexer.Token
}

%wrapper "monadUserState"

$digit = 0-9
$alphaLower = a-z
$alphaUpper = A-Z

@number = $digit+ ('.' $digit+)? -- Um número é um ou mais dígitos, possivelmente seguido por um ponto e mais dígitos (para números decimais).
@ident = $alphaLower ($alphaLower | $digit)* -- Um identificador começa com uma letra minúscula, seguida por letras minúsculas ou dígitos.

tokens :-       -- Deve ser plural para ser reconhecida pelo Alex
    <0> $white+          ;
    <0> @number          { mkNumber }
    -- A regra de desempate do Alex quando há empate no tamanho do match: ele escolhe a regra que aparece primeiro no arquivo .x 
    -- (ordem textual, de cima pra baixo).
    -- É diferente do "maximal munch" (que resolve tamanho de match) — aqui é sobre qual regra ganha quando o tamanho é igual.
    <0> "load"           { simpleToken TLoad }
    <0> "filter"         { simpleToken TFilter }
    <0> "select"         { simpleToken TSelect }
    <0> ","              { simpleToken TComma }
    <0> @ident           { mkIdent }
    <0> \" [^\"]* \"     { mkString }           -- Qualquer coisa exceto aspas duplas é considerada parte de uma string. 
    <0> "<="             { simpleToken TLe }    -- A string termina quando encontramos a próxima aspa dupla.
    <0> ">="             { simpleToken TGe } 
    <0> "=="             { simpleToken TEq }
    <0> "!="             { simpleToken TNotEq }
    <0> "<"              { simpleToken TLt }
    <0> ">"              { simpleToken TGt }
-- No wrapper monádico do Alex, uma ação não é o valor do token diretamente — é uma função que recebe informações do que foi casado (posição, texto) e 
-- devolve um Token completo (com posição), dentro da mônada Alex. simpleToken é uma função auxiliar
-- que faz esse trabalho de "empacotar" um Lexeme sem valor associado (TLParen, TPlus, etc.) num Token completo, capturando automaticamente a posição.

data AlexUserState = AlexUserState{
  layerLevel :: Int
  }
alexInitUserState :: AlexUserState
alexInitUserState = AlexUserState{
    layerLevel = 0
}