%{
    #include "y.tab.h"
%}

%%
[ \t\n]+        {}
0|[1-9][0-9]*   {
    yylval = atoi(yytext);
    return TINTEGER;
    }
[\+\-\*\/\(\)]  {return yytext[0];}
.   {
    printf("Error!\n");
    return 0;
    }
%%
// main 함수 대신 grammer3.y가 받음!
