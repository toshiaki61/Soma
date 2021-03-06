// Signature file for parser generated by fsyacc
module internal Soma.Core.ExpressionParser
type token = 
  | EOF
  | LPAREN
  | RPAREN
  | DOT
  | AND_ALSO
  | OR_ELSE
  | EQUAL
  | NOT_EQUAL
  | LESS_THAN
  | GREATER_THAN
  | LESS_THAN_OR_EQUAL
  | GREATER_THAN_OR_EQUAL
  | ADD
  | SUB
  | MUL
  | DIV
  | MOD
  | COMMA
  | IN
  | NULL
  | NOT of (string)
  | TYPENAME of (string)
  | IDENT of (string)
  | STRING of (string)
  | DECIMAL of (string)
  | DOUBLE of (string)
  | SINGLE of (string)
  | UNATIVEINT of (string)
  | NATIVEINT of (string)
  | UINT64 of (string)
  | INT64 of (string)
  | UINT32 of (string)
  | INT32 of (string)
  | UINT16 of (string)
  | INT16 of (string)
  | SBYTE of (string)
  | BYTE of (string)
  | BOOLEAN of (bool)
type tokenId = 
    | TOKEN_EOF
    | TOKEN_LPAREN
    | TOKEN_RPAREN
    | TOKEN_DOT
    | TOKEN_AND_ALSO
    | TOKEN_OR_ELSE
    | TOKEN_EQUAL
    | TOKEN_NOT_EQUAL
    | TOKEN_LESS_THAN
    | TOKEN_GREATER_THAN
    | TOKEN_LESS_THAN_OR_EQUAL
    | TOKEN_GREATER_THAN_OR_EQUAL
    | TOKEN_ADD
    | TOKEN_SUB
    | TOKEN_MUL
    | TOKEN_DIV
    | TOKEN_MOD
    | TOKEN_COMMA
    | TOKEN_IN
    | TOKEN_NULL
    | TOKEN_NOT
    | TOKEN_TYPENAME
    | TOKEN_IDENT
    | TOKEN_STRING
    | TOKEN_DECIMAL
    | TOKEN_DOUBLE
    | TOKEN_SINGLE
    | TOKEN_UNATIVEINT
    | TOKEN_NATIVEINT
    | TOKEN_UINT64
    | TOKEN_INT64
    | TOKEN_UINT32
    | TOKEN_INT32
    | TOKEN_UINT16
    | TOKEN_INT16
    | TOKEN_SBYTE
    | TOKEN_BYTE
    | TOKEN_BOOLEAN
    | TOKEN_end_of_input
    | TOKEN_error
type nonTerminalId = 
    | NONTERM__startstart
    | NONTERM_start
    | NONTERM_Prog
    | NONTERM_Expression
    | NONTERM_Factor
    | NONTERM_Tuple
/// This function maps integers indexes to symbolic token ids
val tagOfToken: token -> int

/// This function maps integers indexes to symbolic token ids
val tokenTagToTokenId: int -> tokenId

/// This function maps production indexes returned in syntax errors to strings representing the non terminal that would be produced by that production
val prodIdxToNonTerminal: int -> nonTerminalId

/// This function gets the name of a token as a string
val token_to_string: token -> string
val start : (Microsoft.FSharp.Text.Lexing.LexBuffer<'cty> -> token) -> Microsoft.FSharp.Text.Lexing.LexBuffer<'cty> -> ( ExpressionAst.Expression ) 
