%{
#include <stdio.h>
#include <stdlib.h>

char* tokenType[] = {"Keyword", "Identifier", "Integer", "Real", "String", "Comment", "Operator", "Punctuation"};
enum tnumber {TEOF, TBREAK, TCASE, TCHAR, TDEFAULT, TDO, TELSE, TFLOAT, TFOR, TIF, TINT, TRETURN, TSWITCH, TVOID, TWHILE, TIDENTIFIER, TINTEGER, TREAL, TSTRING, TCOMMENT, TOPERATOR, TPUNCTUATION, TERROR};

// Declare additional variables or functions here if you need...

union{
	int iVal;
	float rVal;
	char* sVal;
} yylval;

%}

%%

%%

int main(int argc, char *argv[]){
	enum tnumber tn;
	if(!argc)	exit(0);
	yyin = fopen(argv[1], "r");

// Insert source code here...

	fclose(yyin);
	return 0;
}

// Define additional functions here if you need...
