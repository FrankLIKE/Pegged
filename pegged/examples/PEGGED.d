module pegged.examples.PEGGED;

import pegged.grammar;

enum PEGGEDgrammar = `
# This is the PEG extended grammar used by Pegged

Grammar     <- S GrammarName? Definition+ EOI
GrammarName <- Identifier S :":" S       # Ext: named grammars
Definition  <- RuleName Arrow Expression S
RuleName    <- Identifier (ParamList?) S # Ext: different arrows
Expression  <- Sequence (OR Sequence)*
Sequence    <- Prefix+
Prefix      <- (LOOKAHEAD / NOT / DROP / FUSE)? Suffix
Suffix      <- Primary ( OPTION 
                       / ONEORMORE 
                       / ZEROORMORE 
                       / NamedExpr 
                       / WithAction)? S
Primary     <- Name !Arrow
             / GroupExpr
             / Literal 
             / Class 
             / ANY

Name        <- QualifiedIdentifier ArgList? S #Ext: names can be qualified
GroupExpr   <- :OPEN Expression :CLOSE S
Literal     <~ :Quote (!Quote Char)* :Quote S
             / :DoubleQuote (!DoubleQuote Char)* :DoubleQuote S
Class       <- :'[' (!']' CharRange)* :']' S
CharRange   <- Char :'-' Char / Char
Char        <~ BackSlash ( Quote
                         / DoubleQuote
                         / BackQuote
                         / BackSlash 
                         / '-'         # Ext: escaping -,[,] in char ranges
                         / '[' 
                         / ']' 
                         / [nrt]
                         / [0-2][0-7][0-7]
                         / [0-7][0-7]?)
             / !BackSlash .

# Ext: parameterized rules
ParamList   <~ OPEN Identifier (',' Identifier)* CLOSE S 
ArgList     <- :OPEN Expression (:',' Expression)* :CLOSE S

NamedExpr   <- NAME Identifier? S # Ext: named captures
WithAction  <~ :ACTIONOPEN Identifier :ACTIONCLOSE S # Ext: semantic actions

Arrow       <- LEFTARROW / FUSEARROW / DROPARROW / ACTIONARROW / SPACEARROW
LEFTARROW   <- "<-" S
FUSEARROW   <- "<~" S           # Ext: rule-level fuse
DROPARROW   <- "<:" S           # Ext: rule-level drop
ACTIONARROW <- "<" WithAction S # Ext: rule-level semantic action
SPACEARROW  <- "<" S            # Ext: rule-level space-munching
  
OR          <- '/' S
    
LOOKAHEAD   <- '&' S
NOT         <- '!' S

DROP        <- ':' S # Ext: dropping the current node from the parse tree
FUSE        <- '~' S # Ext: fusing the captures of the current node
      
NAME        <- '=' S 
ACTIONOPEN  <- '{' S 
ACTIONCLOSE <- '}' S
    
OPTION     <- '?' S
ZEROORMORE <- '*' S
ONEORMORE  <- '+' S
    
OPEN       <- '(' S
CLOSE      <- ')' S
    
ANY        <- '.' S
    
S          <: ~(Blank / EOL / Comment)*
Comment    <- "#" (!EOL .)* (EOL/EOI)
`;

// TODO: add unit tests