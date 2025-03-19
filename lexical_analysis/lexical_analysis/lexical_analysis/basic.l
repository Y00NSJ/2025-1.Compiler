%{
#include <stdio.h>
%}

LETTER  [A-Za-z_]
DIGIT   [0-9]

%%

[ \t\n]+                         {}
char|int|void|float              {printf("TYPE ");}
{LETTER}({LETTER}|{DIGIT})*      {printf("ID ");}
0|[1-9]{DIGIT}*                    {printf("INTEGER ");}
[\+\-\*\/\=]                     {printf("OPERATOR ");}
.                                {printf("OTHER ");}

%%

