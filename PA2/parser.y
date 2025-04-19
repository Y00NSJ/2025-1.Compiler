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
	;

ExternalDec : Dec { printf("ExternalDec -> Dec\n"); }
	    | FuncDef { printf("ExternalDec -> FuncDef\n"); }
	    ;

FuncDef : VarType TIDENTIFIER TPUNCTUATION Params TPUNCTUATION CpndStmt { printf("FuncDef -> Vartype %s ( Params ) CpndStmt\n", $2); }
	| TVOID TIDENTIFIER TPUNCTUATION Params TPUNCTUATION CpndStmt { printf("FuncDef -> void %s ( Params ) CpndStmt\n", $2); }
	;

Dec : VarType TIDENTIFIER TPUNCTUATION Params TPUNCTUATION TPUNCTUATION { printf("Dec -> Vartype %s ( Params ) ;\n", $2); }
	| TVOID TIDENTIFIER TPUNCTUATION Params TPUNCTUATION TPUNCTUATION { printf("Dec -> void %s ( Params ) ;\n", $2); }
	| VarDec { printf("Dec -> VarDec\n"); }
	;

Params : ParamList { printf("Params -> ParamList\n"); }
	| TVOID { printf("Params -> void\n"); }
	| { printf("Params -> Empty\n"); }
	;

ParamList : ParamList TOPERATOR Param { printf("ParamList -> ParamList , Param\n"); }
	  | Param { printf("ParamList -> Param\n"); }
	  ;

Param : VarType Declarator { printf("Param -> Vartype Declarator\n"); }
	;

CpndStmt : TPUNCTUATION LDecList StmtList TPUNCTUATION { printf("CpndStmt -> LDecList StmtList\n"); }
	 ;

LDecList : LDecList VarDec { printf("LDecList -> LDecList VarDec\n"); }
	 | { printf("LDecList -> Empty\n"); }

VarDec : VarType IDDecList TPUNCTUATION { printf("VarDec -> VarType IDDecList ;\n"); }
	;

VarType : 'int'	{ printf("VarType -> int\n"); }
	| 'char' { printf("VarType -> char\n"); }
	| 'float' { printf("VarType -> float\n"); }
	;

IDDecList : IDDecList ',' IDDec { printf("IDDecList -> IDDecList , IDDec\n"); }
	  | IDDec { printf("IDDecList -> IDDec\n"); }
	  ;

IDDec: Declarator '=' Initializer { printf("IDDec -> Declarator = Initializer\n"); }
	| Declarator { printf("IDDec -> Declarator\n"); }
	;

Declarator : TIDENTIFIER '[' TINTEGER ']' { printf("Declarator -> %s [ %d ]\n", $1, $3); }
	   | TINTEGER { printf("Declarator -> %d\n", $1); }
	   ;

Initializer : AssignExpr { printf("Initializer -> AssignExpr\n"); }
	    | '{' InitializerList '}' { printf("Initializer -> { InitializerList }\n"); }
	    ;

InitializerList : InitializerList ',' Initializer { printf("InitializerList -> InitializerList , Initializer\n"); }
		| Initializer { printf("InitializerList -> Initializer\n"); }
		;

StmtList : StmtList Stmt { printf("StmtList -> StmtList Stmt\n"); }
	 | { printf("StmtList -> Empty\n"); }
	 ;

Stmt : MatchedStmt { printf("Stmt -> MatchedStmt\n"); }
     | OpenStmt { printf("Stmt -> OpenStmt\n"); }
     ;

MatchedStmt : ExprStmt		{ printf("MatchedStmt -> ExprStmt\n"); }
	    | ForMatchedStmt	{ printf("MatchedStmt -> ForMatchedStmt\n"); }
	    | WhileMatchedStmt	{ printf("MatchedStmt -> WhileMatchedStmt\n"); }
	    | DoWhileStmt	{ printf("MatchedStmt -> DoWhileMatchedStmt\n"); }
	    | ReturnStmt	{ printf("MatchedStmt -> ReturnStmt\n"); }
	    | CpndStmt		{ printf("MatchedStmt -> CpndStmt\n"); }
	    | BreakStmt		{ printf("MatchedStmt -> BreakStmt\n"); }
	    | SwitchStmt	{ printf("MatchedStmt -> SwitchStmt\n"); }
	    | TIF '(' Expr ')' MatchedStmt TELSE MatchedStmt { printf("MatchedStmt -> if ( Expr ) MatchedStmt else MatchedStmt\n");}
	    ;

OpenStmt : ForOpenStmt { printf("OpenStmt -> ForOpenStmt\n"); }
	 | WhileOpenStmt { printf("OpenStmt -> WhileOpenStmt\n"); }
	 | TIF '(' Expr ')' Stmt { printf("OpenStmt -> if ( Expr ) Stmt\n"); }
	 | TIF '(' Expr ')' MatchedStmt TELSE OpenStmt	{ printf("OpenStmt -> if ( Expr ) MatchedStmt else OpenStmt\n"); }
	 ;

SwitchStmt : TSWITCH '(' Expr ')' '{' CaseList DefaultCase '}' { printf("SwitchStmt -> switch ( Expr ) { CaseList DefaultCase }\n"); }
	   ;

CaseList : CaseList TCASE TINTEGER ':' StmtList { printf("CaseList -> CaseList case %d : StmtList\n", $3); }
	 | TCASE TINTEGER ':' StmtList { printf("CaseList -> case %d : StmtList\n", $3); }
	 ;

DefaultCase : TDEFAULT : StmtList { printf("DefaultCase -> default : StmtList\n"); }
	    | { printf("DefaultCase -> Empty\n"); }
	    ;

ReturnStmt : TRETURN Expr ';' { printf("ReturnStmt -> return Expr ;\n"); }
	   | TRETURN ';' { printf("ReturnStmt -> return ;\n"); }
	   ;

BreakStmt : TBREAK ';' { printf("BreakStmt -> break ;\n"); }
	  ;

ExprStmt : Expr ';' { printf("ExprStmt -> Expr ;\n"); }
	 | ';' { printf("ExprStmt -> ;\n"); }
	 ;

Expr : Expr ',' AssignExpr { printf("Expr -> Expr , AssignExpr\n"); }
     | AssignExpr { printf("Expr -> AssignExpr\n"); }
     ;

AssignExpr : Variable '=' AssignExpr { printf("AssignExpr -> Variable = AssignExpr\n"); }
	   | Variable '+''=' AssignExpr { printf("AssignExpr -> Variable += AssignExpr\n"); }
	   | Variable '-''=' AssignExpr { printf("AssignExpr -> Variable -= AssignExpr\n"); }
	   | Variable '*''=' AssignExpr { printf("AssignExpr -> Variable *= AssignExpr\n"); }
	   | Variable '/''=' AssignExpr { printf("AssignExpr -> Variable /= AssignExpr\n"); }
	   | Variable '%''=' AssignExpr { printf("AssignExpr -> Variable %= AssignExpr\n"); }
	   | SimpleExpr { printf("AssignExpr -> SimpleExpr\n"); }
	   ;

Variable : TIDENTIFIER '[' Expr ']' { printf("Variable -> %s [ Expr ]\n", $1); }
	 | TIDENTIFIER { printf("Variable -> %s\n", $1); }
	 ;

SimpleExpr : SimpleExpr '|''|' AndExpr { printf("SimpleExpr -> SimpleExpr || AndExpr\n"); }
	   | AndExpr { printf("SimpleExpr -> AndExpr\n"); }
	   ;

AndExpr : AndExpr '&''&' EqualityExpr { printf("AndExpr -> AndExpr && EqualityExpr\n"); }
	| EqualityExpr { printf("AndExpr -> EqualityExpr\n"); }
	;

EqualityExpr : EqualityExpr '=''=' RelExpr { printf("EqualityExpr -> EqualityExpr == RelExpr\n"); }
	     | EqualityExpr '!''=' RelExpr { printf("EqualityExpr -> EqualityExpr != RelExpr\n"); }
	     | RelExpr { printf("EqualityExpr -> RelExpr\n"); }
	     ;

RelExpr : RelExpr '<' AddExpr { printf("RelExpr -> RelExpr < AddExpr\n"); }
	| RelExpr '<''=' AddExpr { printf("RelExpr -> RelExpr <= AddExpr\n"); }
	| RelExpr > AddExpr { printf("RelExpr -> RelExpr > AddExpr\n"); }
	| RelExpr >''= AddExpr { printf("RelExpr -> RelExpr >= AddExpr\n"); }
	| AddExpr { printf("RelExpr -> AddExpr\n"); }
	;

AddExpr : AddExpr '+' Term { printf("AddExpr -> AddExpr + Term\n"); }
	| AddExpr '-' Term { printf("AddExpr -> AddExpr - Term\n"); }
	| Term		   { printf("AddExpr -> Term\n"); }
	;

Term : Term '*' Factor { printf("Term -> Term * Factor\n"); }
	| Term '/' Factor { printf("Term -> Term / Factor\n"); }
	| Term '%' Factor { printf("Term -> Term % Factor\n"); }
	| Factor { printf("Term -> Factor\n"); }
	;

Factor : '(' Expr ')' { printf("Factor -> ( Expr )\n"); }
	| FuncCall { printf("Factor -> FuncCall\n"); }
	| '-' Factor { printf("Factor -> - Factor\n"); }
	| Variable { printf("Factor -> Variable\n"); }
	| Variable IncDec { printf("Factor -> Variable IncDec\n"); }
	| IncDec Variable { printf("Factor -> IncDec Variable\n"); }
	| NumberLiteral { printf("Factor -> NumberLiteral\n"); }
	;

NumberLiteral : TINTEGER { printf("NumberLiteral -> %d\n", $1); }
		| TREAL { printf("NumberLiteral -> %.2d\n", $1); }
		;

IncDec : '+''+' { printf("IncDec -> ++\n"); }
	| '-''-' { printf("IncDec -> --\n"); }
	;

WhileMatchedStmt : TWHILE '(' Expr ')' MatchedStmt { printf("WhileMatchedStmt -> while ( Expr ) MatchedStmt\n"); }
		 ;

WhileOpenStmt : TWHILE '(' Expr ')' OpenStmt { printf("WhileOpenStmt -> while ( Expr ) OpenStmt\n"); }
		;

DoWhileStmt : TDO Stmt TWHILE '(' Expr ')' ';' { printf("WhileMatchedStmt -> do Stmt while ( Expr ) ;\n"); }
		;

ForMatchedStmt : TFOR '(' ExprStmt ExprStmt Expr ')' MatchedStmt { printf("ForMatchedStmt -> for ( ExprStmt ExprStmt Expr ) MatchedStmt\n"); }
		;

ForOpenStmt : TFOR '(' ExprStmt ExprStmt Expr ')' OpenStmt { printf("ForOpenStmt -> for ( ExprStmt ExprStmt Expr ) OpenStmt\n"); }
		;

FuncCall : TIDENTIFIER '(' Arguments ')' { printf("FuncCall -> %s ( Arguments )\n", $1); }
	 ;

Arguments : ArgumentList { printf("Arguments -> ArgumentList\n"); }
	  | { printf("Arguments -> Empty\n"); }
	  ;

ArgumentList : ArgumentList ',' AssignExpr { printf("ArgumentList -> ArgumentList , AssignExpr\n"); }
	     | ArgumentList ',' TSTRING { printf("ArgumentList -> ArgumentList , %s\n", $3); }
	     | AssignExpr { printf("ArgumentList -> AssignExpr\n"); }
	     | TSTRING { printf("ArgumentList -> %s\n", $1); }
	     ;

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
