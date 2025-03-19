%{
#include <stdio.h>
%}


%%

[ \t\n]+                         {}
char|int|void|float              {printf("TYPE ");}
{LETTER}({LETTER}|{DIGIT})*      {printf("ID ");}
0|[1-9]{DIGIT}*                  {printf("INTEGER ");}
[\+\-\*\/\=]                     {printf("OPERATOR ");}
.                                {printf("OTHER ");}

%%

