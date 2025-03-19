%{
#include <stdio.h>
enum tnumber {TEOF, TTYPE, TID, TCOMMA, TSEMI, TOPER, TREAL};
%}

WS	    [\t\n]+
TYPE	int|float|double|char|void
DIGIT	[0-9]
LETTER_	[A-Za-z_]
ID	    {LETTER_}({LETTER_}|{DIGIT})*
REAL	([0-9]+\.[0-9]*|\[0-9]+)([Ee][\+\-]?[0-9]+)?

%%

{WS}	{}
{TYPE}	{return TTYPE;}
{ID}	{return TID;}
","	{return TCOMMA;}
;	{return TSEMI;}
=	{return TOPER;}
{REAL}	{return TREAL;}

%%

int main(int argc, char *argv[]){
	enum tnumber tn;

	if (argc == 1)	exit(0);
	yyin = fopen(argv[1], "r");	

	while ((tn = yylex()) != TEOF) {
		switch(tn) {
		case TTYPE:
			printf("<keyword, %s>\n", yytext);
			break;
		case TID:
			printf("<id, %s>\n", yytext);
			break;
		case TCOMMA: case TSEMI: case TOPER:
			printf("<%s>\n", yytext);
			break;
		case TREAL:
			printf("<real, %s>\n", yytext);
			break;
		}
	}
	fclose(yyin);
	return 0;
}