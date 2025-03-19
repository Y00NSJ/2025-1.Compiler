%{
enum TNUMBER {TEOF, TWORD, TLINE};
int ll=0, ww=0;
%}

WORD	        [A-Za-z]+
LINE	        \n
OTHER	        .

%%

{WORD}          {ww++;}
{LINE}          {ll++; return TLINE;}
{OTHER}         {}

%%

int main(void){
	yylex();
    yylex();
	printf("%d words, %d lines\n", ww, ll);
}