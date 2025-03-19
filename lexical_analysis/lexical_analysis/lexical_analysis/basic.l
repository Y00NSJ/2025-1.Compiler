%{
#include <stdio.h>
%}


%%

[ \t\n]+                         {}
char|int|void|float              {printf("TYPE ");}
[A-Za-z_][A-Za-z0-9_]*           {printf("ID ");}
0|[1-9][0-9]*                    {printf("INTEGER ");}
[\+\-\*\/\=]                     {printf("OPERATOR ");}
.                                {printf("OTHER ");}

%%

