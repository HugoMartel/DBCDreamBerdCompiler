grammar CCC;

//==========================================================================
// Parser rules

file        : expr EOF
            ;

expr        : VAR '=' STRING line_end
            | FUNCTION ' ' VAR '=' '>' ' '* '{' expr '}'
            ;

line_end    : '?'
            | line_end_rec
            ;
line_end_rec: '!'
            | line_end_rec '!'
            ;


//==========================================================================
// Lexer rules

FUNCTION    :  'f''u'?'n'?'c'?'t'?'i'?'o'?'n'?|'u''n'?'c'?'t'?'i'?'o'?'n'?|'n''c'?'t'?'i'?'o'?'n'?|'c''t'?'i'?'o'?'n'?|'t''i'?'o'?'n'?|'i''o'?'n'?|'o''n'?|'n';

NEWLINE     : ('\r'? '\n' | '\r') -> skip ;
TAB         : ('\t' | '   ') ;

STRING      : '"'.*?'"' ;

VAR         : .+? ;

