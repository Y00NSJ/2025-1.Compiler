%{
#include <stdio.h>
int yylex(void);
int yyerror(char*);
%}

%start Program
%union{
	int iVal;
	float rVal;
	char* sVal;
}
%token TEOF TBREAK TCASE TCHAR TDEFAULT TDO TELSE TFLOAT TFOR TIF TINT TRETURN TSWITCH TVOID TWHILE TCOMMENT TOPERATOR TPUNCTUATION TERROR TPLUSASSIGN TMINUSASSIGN TMULASSIGN TDIVASSIGN TMODASSIGN TEQ TNE TOR TAND TGE TLE TINC TDEC
%token<iVal> TINTEGER
%token<rVal> TREAL
%token<sVal> TIDENTIFIER TSTRING

%%

Program : Program ExternalDec { printf("Program -> Program ExternalDec\n"); }
	| ExternalDec { printf("Program -> ExternalDec\n"); }

ExternalDec : Dec { printf("ExternalDec -> Dec\n"); }
	    | FuncDef { printf("ExternalDec -> FuncDef\n"); }

FuncDef : VarType TIDENTIFIER '(' Params ')' CpndStmt { printf("FuncDef -> Vartype %s ( Params ) CpndStmt\n", $2); }
	| 'void' TIDENTIFIER '(' Params ')' ';' { printf("FuncDef -> void %s ( Params ) ;\n", %2); }
	| VarDec { printf("FuncDef -> VarDec\n"); }


%%

int main(int argc, char* argv[]){
	extern FILE *yyin;
	yyin = fopen(argv[1], "r");
	yyparse();
	fclose(yyin);
	return 0;
}

int yyerror(char* s){
	printf("%s\n", s);
	return 0;
}
