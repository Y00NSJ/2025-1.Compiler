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
%token TEOF TBREAK TCASE TCHAR TDEFAULT TDO TELSE TFLOAT TFOR TIF TINT TRETURN TSWITCH TVOID TWHILE TCOMMENT TOPERATOR TPUNCTUATION TERROR TPLUSASSIGN TMINUSASSIGN TMULASSIGN TDIVASSIGN TMODASSIGN TEQ TNE TOR TAND TGE TLE TINC TDEC TCOMMA TLPAREN TRPAREN TSEMI TCOLON TLBRACE TRBRACE TLBRACKET TRBRACKET TPLUS TMINUS TMUL TDIV TMOD TLT TGT
%token<iVal> TINTEGER
%token<rVal> TREAL
%token<sVal> TIDENTIFIER TSTRING

%nonassoc LOWCOMMA
%left TCOMMA

%%


Program : Program ExternalDec { printf("Program -> Program ExternalDec\n"); }
	| ExternalDec { printf("Program -> ExternalDec\n"); }
	;

ExternalDec : Dec { printf("ExternalDec -> Dec\n"); }
	    | FuncDef { printf("ExternalDec -> FuncDef\n"); }
	    ;

FuncDef : VarType TIDENTIFIER TLPAREN Params TRPAREN CpndStmt { printf("FuncDef -> VarType %s ( Params ) CpndStmt\n", $2); free($2); }
	| TVOID TIDENTIFIER TLPAREN Params TRPAREN CpndStmt { printf("FuncDef -> void %s ( Params ) CpndStmt\n", $2); free($2); }
	;

Dec : VarType TIDENTIFIER TLPAREN Params TRPAREN TSEMI { printf("Dec -> VarType %s ( Params ) ;\n", $2); free($2); }
	| TVOID TIDENTIFIER TLPAREN Params TRPAREN TSEMI { printf("Dec -> void %s ( Params ) ;\n", $2); free($2); }
	| VarDec { printf("Dec -> VarDec\n"); }
	;

Params : ParamList { printf("Params -> ParamList\n"); }
	| TVOID { printf("Params -> void\n"); }
	| { printf("Params -> Empty\n"); }
	;

ParamList : ParamList TCOMMA Param { printf("ParamList -> ParamList , Param\n"); }
	  | Param { printf("ParamList -> Param\n"); }
	  ;

Param : VarType Declarator { printf("Param -> VarType Declarator\n"); }
	;

CpndStmt : TLBRACE LDecList StmtList TRBRACE { printf("CpndStmt -> { LDecList StmtList }\n"); }
	 ;

LDecList : LDecList VarDec { printf("LDecList -> LDecList VarDec\n"); }
	 | { printf("LDecList -> Empty\n"); }

VarDec : VarType IDDecList TSEMI { printf("VarDec -> VarType IDDecList ;\n"); }
	;

VarType : TINT	{ printf("VarType -> int\n"); }
	| TCHAR { printf("VarType -> char\n"); }
	| TFLOAT { printf("VarType -> float\n"); }
	;

IDDecList : IDDecList TCOMMA IDDec { printf("IDDecList -> IDDecList , IDDec\n"); }
	  | IDDec { printf("IDDecList -> IDDec\n"); }
	  ;

IDDec: Declarator TOPERATOR Initializer { printf("IDDec -> Declarator = Initializer\n"); }
	| Declarator { printf("IDDec -> Declarator\n"); }
	;

Declarator : TIDENTIFIER TLBRACKET TINTEGER TRBRACKET { printf("Declarator -> %s [ %d ]\n", $1, $3); }
	   | TIDENTIFIER { printf("Declarator -> %s\n", $1); free($1); }
	   ;

Initializer : AssignExpr { printf("Initializer -> AssignExpr\n"); }
	    | TLBRACE InitializerList TRBRACE { printf("Initializer -> { InitializerList }\n"); }
	    ;

InitializerList : InitializerList TCOMMA Initializer %prec LOWCOMMA { printf("InitializerList -> InitializerList , Initializer\n"); }
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
	    | DoWhileStmt	{ printf("MatchedStmt -> DoWhileStmt\n"); }
	    | ReturnStmt	{ printf("MatchedStmt -> ReturnStmt\n"); }
	    | CpndStmt		{ printf("MatchedStmt -> CpndStmt\n"); }
	    | BreakStmt		{ printf("MatchedStmt -> BreakStmt\n"); }
	    | SwitchStmt	{ printf("MatchedStmt -> SwitchStmt\n"); }
	    | TIF TLPAREN Expr TRPAREN MatchedStmt TELSE MatchedStmt { printf("MatchedStmt -> if ( Expr ) MatchedStmt else MatchedStmt\n");}
	    ;

OpenStmt : ForOpenStmt { printf("OpenStmt -> ForOpenStmt\n"); }
	 | WhileOpenStmt { printf("OpenStmt -> WhileOpenStmt\n"); }
	 | TIF TLPAREN Expr TRPAREN Stmt { printf("OpenStmt -> if ( Expr ) Stmt\n"); }
	 | TIF TLPAREN Expr TRPAREN MatchedStmt TELSE OpenStmt	{ printf("OpenStmt -> if ( Expr ) MatchedStmt else OpenStmt\n"); }
	 ;

SwitchStmt : TSWITCH TLPAREN Expr TRPAREN TLBRACE CaseList DefaultCase TRBRACE { printf("SwitchStmt -> switch ( Expr ) { CaseList DefaultCase }\n"); }
	   ;

CaseList : CaseList TCASE TINTEGER TCOLON StmtList { printf("CaseList -> CaseList case %d : StmtList\n", $3); }
	 | TCASE TINTEGER TCOLON StmtList { printf("CaseList -> case %d : StmtList\n", $2); }
	 ;

DefaultCase : TDEFAULT TCOLON StmtList { printf("DefaultCase -> default : StmtList\n"); }
	    | { printf("DefaultCase -> Empty\n"); }
	    ;

ReturnStmt : TRETURN Expr TSEMI { printf("ReturnStmt -> return Expr ;\n"); }
	   | TRETURN TSEMI { printf("ReturnStmt -> return ;\n"); }
	   ;

BreakStmt : TBREAK TSEMI { printf("BreakStmt -> break ;\n"); }
	  ;

ExprStmt : Expr TSEMI { printf("ExprStmt -> Expr ;\n"); }
	 | TSEMI { printf("ExprStmt -> ;\n"); }
	 ;

Expr : Expr TCOMMA AssignExpr { printf("Expr -> Expr , AssignExpr\n"); }
     | AssignExpr { printf("Expr -> AssignExpr\n"); }
     ;

AssignExpr : Variable TOPERATOR AssignExpr { printf("AssignExpr -> Variable = AssignExpr\n"); }
	   | Variable TPLUSASSIGN AssignExpr { printf("AssignExpr -> Variable += AssignExpr\n"); }
	   | Variable TMINUSASSIGN AssignExpr { printf("AssignExpr -> Variable -= AssignExpr\n"); }
	   | Variable TMULASSIGN AssignExpr { printf("AssignExpr -> Variable *= AssignExpr\n"); }
	   | Variable TDIVASSIGN AssignExpr { printf("AssignExpr -> Variable /= AssignExpr\n"); }
	   | Variable TMODASSIGN AssignExpr { printf("AssignExpr -> Variable %%= AssignExpr\n"); }
	   | SimpleExpr { printf("AssignExpr -> SimpleExpr\n"); }
	   ;

Variable : TIDENTIFIER TLBRACKET Expr TLBRACKET { printf("Variable -> %s [ Expr ]\n", $1); free($1); }
	 | TIDENTIFIER { printf("Variable -> %s\n", $1); free($1); }
	 ;

SimpleExpr : SimpleExpr TOR AndExpr { printf("SimpleExpr -> SimpleExpr || AndExpr\n"); }
	   | AndExpr { printf("SimpleExpr -> AndExpr\n"); }
	   ;

AndExpr : AndExpr TAND EqualityExpr { printf("AndExpr -> AndExpr && EqualityExpr\n"); }
	| EqualityExpr { printf("AndExpr -> EqualityExpr\n"); }
	;

EqualityExpr : EqualityExpr TEQ RelExpr { printf("EqualityExpr -> EqualityExpr == RelExpr\n"); }
	     | EqualityExpr TNE RelExpr { printf("EqualityExpr -> EqualityExpr != RelExpr\n"); }
	     | RelExpr { printf("EqualityExpr -> RelExpr\n"); }
	     ;

RelExpr : RelExpr TLT AddExpr { printf("RelExpr -> RelExpr < AddExpr\n"); }
	| RelExpr TLE AddExpr { printf("RelExpr -> RelExpr <= AddExpr\n"); }
	| RelExpr TGT AddExpr { printf("RelExpr -> RelExpr > AddExpr\n"); }
	| RelExpr TGE AddExpr { printf("RelExpr -> RelExpr >= AddExpr\n"); }
	| AddExpr { printf("RelExpr -> AddExpr\n"); }
	;

AddExpr : AddExpr TPLUS Term { printf("AddExpr -> AddExpr + Term\n"); }
	| AddExpr TMINUS Term { printf("AddExpr -> AddExpr - Term\n"); }
	| Term		   { printf("AddExpr -> Term\n"); }
	;

Term : Term TMUL Factor { printf("Term -> Term * Factor\n"); }
	| Term TDIV Factor { printf("Term -> Term / Factor\n"); }
	| Term TMOD Factor { printf("Term -> Term %% Factor\n"); }
	| Factor { printf("Term -> Factor\n"); }
	;

Factor : TLPAREN Expr TRPAREN { printf("Factor -> ( Expr )\n"); }
	| FuncCall { printf("Factor -> FuncCall\n"); }
	| TOPERATOR Factor { printf("Factor -> - Factor\n"); }
	| Variable { printf("Factor -> Variable\n"); }
	| Variable IncDec { printf("Factor -> Variable IncDec\n"); }
	| IncDec Variable { printf("Factor -> IncDec Variable\n"); }
	| NumberLiteral { printf("Factor -> NumberLiteral\n"); }
	;

NumberLiteral : TINTEGER { printf("NumberLiteral -> %d\n", $1); }
		| TREAL { printf("NumberLiteral -> %.2f\n", $1); }
		;

IncDec : TINC { printf("IncDec -> ++\n"); }
	| TDEC { printf("IncDec -> --\n"); }
	;

WhileMatchedStmt : TWHILE TLPAREN Expr TRPAREN MatchedStmt { printf("WhileMatchedStmt -> while ( Expr ) MatchedStmt\n"); }
		 ;

WhileOpenStmt : TWHILE TLPAREN Expr TRPAREN OpenStmt { printf("WhileOpenStmt -> while ( Expr ) OpenStmt\n"); }
		;

DoWhileStmt : TDO Stmt TWHILE TLPAREN Expr TRPAREN TSEMI { printf("DoWhileStmt -> do Stmt while ( Expr ) ;\n"); }
		;

ForMatchedStmt : TFOR TLPAREN ExprStmt ExprStmt Expr TRPAREN MatchedStmt { printf("ForMatchedStmt -> for ( ExprStmt ExprStmt Expr ) MatchedStmt\n"); }
		;

ForOpenStmt : TFOR TLPAREN ExprStmt ExprStmt Expr TRPAREN OpenStmt { printf("ForOpenStmt -> for ( ExprStmt ExprStmt Expr ) OpenStmt\n"); }
		;

FuncCall : TIDENTIFIER TLPAREN Arguments TRPAREN { printf("FuncCall -> %s ( Arguments )\n", $1); free($1); }
	 ;

Arguments : ArgumentList { printf("Arguments -> ArgumentList\n"); }
	  | { printf("Arguments -> Empty\n"); }
	  ;

ArgumentList : ArgumentList TCOMMA AssignExpr { printf("ArgumentList -> ArgumentList , AssignExpr\n"); }
	     | ArgumentList TCOMMA TSTRING { printf("ArgumentList -> ArgumentList , %s\n", $3); free($3); }
	     | AssignExpr { printf("ArgumentList -> AssignExpr\n"); }
	     | TSTRING { printf("ArgumentList -> %s\n", $1); free($1); }
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
