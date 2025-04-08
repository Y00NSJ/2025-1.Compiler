%{
    #include "y.tab.h"
%}

%%
[ \t\n]+        {}
0|[1-9][0-9]*   {return TINTEGER;}
[\+\-\*\/\(\)]  {return yytext[0];}
.   {
    printf("Error!\n");
    return 0;
    }
%%
