%{
#include <stdio.h>
#include "taclib.h"
int yylex(void);
int yyerror(char*);
STACK *stack;
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


Program : Program ExternalDec {
	ASTNode* edNode = pop(stack);
	ASTNode* pNode = pop(stack);
	if (pNode && edNode) {
		ASTNode* child = getChild(pNode);
		if (child) {
			setLastSibling(child, edNode);
			push(stack, pNode);
		} else {
			push(stack, setChild(pNode, edNode));
		}
	} else {
		yyerror("Program reduction에서 NULL 노드 발생");
		YYABORT;
	}
}
	| ExternalDec {
		ASTNode* edNode = pop(stack);
		push(stack, setChild(makeASTNode(_PROG), edNode));
		}
	;

ExternalDec : Dec {
	ASTNode* dNode = pop(stack);
	push(stack, dNode);
}
	    | FuncDef {
	ASTNode* fNode = pop(stack);
	push(stack, fNode);
}
	    ;

FuncDef : VarType TIDENTIFIER TLPAREN Params TRPAREN CpndStmt { 
	ASTNode* csNode = pop(stack);
	ASTNode* pNode = pop(stack);
	ASTNode* tNode = pop(stack);
	ASTNode* idNode = makeASTNodeID($2);
	ASTNode* fdNode = makeASTNode(_FUNCDEF);
	ASTNode* seq = setSibling(tNode, setSibling(idNode, setSibling(pNode, csNode)));
	push(stack, setChild(fdNode, seq));
}
	| TVOID TIDENTIFIER TLPAREN Params TRPAREN CpndStmt {
		ASTNode* csNode = pop(stack);
		ASTNode* pNode = pop(stack);
		ASTNode* voidNode = makeASTNodeTYPE(TYPE_VOID);
		ASTNode* idNode = makeASTNodeID($2);
		ASTNode* fdNode = makeASTNode(_FUNCDEF);
		ASTNode* seq = setSibling(voidNode, setSibling(idNode, setSibling(pNode, csNode)));
		push(stack, setChild(fdNode, seq));
	}
	;

Dec : VarType TIDENTIFIER TLPAREN Params TRPAREN TSEMI {
	ASTNode* pNode = pop(stack);
	ASTNode* tNode = pop(stack);
	ASTNode* idNode = makeASTNodeID($2);
	ASTNode* fdNode = setChild(makeASTNode(_FUNCDEC), setSibling(tNode, setSibling(idNode, pNode)));
	push(stack, fdNode);
}
	| TVOID TIDENTIFIER TLPAREN Params TRPAREN TSEMI {
		ASTNode* pNode = pop(stack);
		ASTNode* voidNode = makeASTNodeTYPE(TYPE_VOID);
		ASTNode* idNode = makeASTNodeID($2);
		ASTNode* fdNode = setChild(makeASTNode(_FUNCDEC), setSibling(voidNode, setSibling(idNode, pNode)));
		push(stack, fdNode);
	}
	| VarDec {}
	;

Params : ParamList {
	ASTNode* plNode = 0;
//	printStack(stack);
	plNode = pop(stack);
	push(stack, setChild(makeASTNode(_PARAMS), plNode));
}
	| TVOID {push(stack, makeASTNode(_PARAMS));}
	| {push(stack, makeASTNode(_PARAMS));}
	;

ParamList : ParamList TCOMMA Param {
	ASTNode* pNode = pop(stack);
	ASTNode* plistNode = pop(stack);
	push(stack, setLastSibling(plistNode, pNode));
}
	  | Param {}
	  ;

Param : VarType Declarator {
	ASTNode* dNode = 0;
	ASTNode* tNode = 0;
//	printStack(stack);
	dNode = pop(stack);
	tNode = pop(stack);
	push(stack, setChild(makeASTNode(_PARAM), setSibling(tNode, dNode)));
}
	;

CpndStmt : TLBRACE LDecList StmtList TRBRACE {
	ASTNode* slNode = 0;
	ASTNode* ldlNode = 0;
	ASTNode* cpnd = makeASTNode(_CPNDSTMT);
	ASTNode* seq = 0;

//	printStack(stack);
	slNode = pop(stack);
	ldlNode = pop(stack);
	seq = setSibling(ldlNode, slNode);
	push(stack, setChild(cpnd, seq));

//	printStack(stack);
}
	 ;

LDecList : LDecList VarDec {
	ASTNode* vdNode = pop(stack);
	ASTNode* ldlNode = pop(stack);
	ASTNode* child = getChild(ldlNode);
	if (child) {
		push(stack, setLastSibling(child, vdNode));
	} else {
		push(stack, setChild(ldlNode, vdNode));
	}
}
	 | {push(stack, makeASTNode(_LDECLIST));}

VarDec : VarType IDDecList TSEMI {
	ASTNode* idlNode = pop(stack);
	ASTNode* tNode = pop(stack);
	push(stack, setChild(makeASTNode(_VARDEC), setSibling(tNode, idlNode)));
}
	;

VarType : TINT	{push(stack, makeASTNodeTYPE(TYPE_INT));}
	| TCHAR {push(stack, makeASTNodeTYPE(TYPE_INT)); }
	| TFLOAT { push(stack, makeASTNodeTYPE(TYPE_FLOAT)); }
	;

IDDecList : IDDecList TCOMMA IDDec {
	ASTNode* iddNode = pop(stack);
	ASTNode* iddListNode = pop(stack);
	ASTNode* child = getChild(iddListNode);
	if (child) {
		setLastSibling(child, iddNode);
		push(stack, iddListNode);
	} else {
		push(stack, setChild(iddListNode, iddNode));
	}
 }
	  | IDDec {
		ASTNode* iddNode = pop(stack);
		push(stack, setChild(makeASTNode(_IDDECLIST), iddNode));
	  }
	  ;

IDDec: Declarator TOPERATOR Initializer {
	ASTNode* iNode = pop(stack);
	ASTNode* dNode = pop(stack);
	push(stack, setChild(dNode, iNode));
}
	| Declarator {}
	;

Declarator : TIDENTIFIER { push(stack, makeASTNodeID($1)); }
	   ;

Initializer : AssignExpr {}
	    ;

StmtList : StmtList Stmt {
	ASTNode* stmtNode = pop(stack);
	ASTNode* slNode = pop(stack);
	ASTNode* child = getChild(slNode);
	if (child) {
		setLastSibling(child, stmtNode);
		push(stack, slNode);
	} else {
		push(stack, setChild(slNode, stmtNode));
	}
}
	 | {push(stack, makeASTNode(_STMTLIST));}
	 ;

Stmt : MatchedStmt {}
     | OpenStmt {}
     ;

MatchedStmt : ExprStmt		{}
	    | ForMatchedStmt	{}
	    | WhileMatchedStmt	{}
	    | DoWhileStmt	{}
	    | ReturnStmt	{}
	    | CpndStmt		{}
	    | BreakStmt		{}
	    | SwitchStmt	{}
	    | TIF TLPAREN Expr TRPAREN MatchedStmt TELSE MatchedStmt {
			ASTNode* stmtNode = pop(stack);
			ASTNode* mStmtNode = pop(stack);
			ASTNode* exprNode = pop(stack);
			push(stack, setChild(makeASTNode(_IFSTMT), setSibling(exprNode, setSibling(mStmtNode, stmtNode))));
		}
	    ;

OpenStmt : ForOpenStmt {}
	 | WhileOpenStmt {}
	 | TIF TLPAREN Expr TRPAREN Stmt {
		ASTNode* stmtNode = pop(stack);
		ASTNode* exprNode = pop(stack);
		push(stack, setChild(makeASTNode(_IFSTMT), setSibling(exprNode, stmtNode)));
	 }
	 | TIF TLPAREN Expr TRPAREN MatchedStmt TELSE OpenStmt	{
			ASTNode* stmtNode = pop(stack);
			ASTNode* mStmtNode = pop(stack);
			ASTNode* exprNode = pop(stack);
			push(stack, setChild(makeASTNode(_IFSTMT), setSibling(exprNode, setSibling(mStmtNode, stmtNode))));
	 }
	 ;

SwitchStmt : TSWITCH TLPAREN Expr TRPAREN TLBRACE CaseList DefaultCase TRBRACE {
	ASTNode* defaultNode = pop(stack);
	ASTNode* caseNode = pop(stack);
	ASTNode* exprNode = pop(stack);
	push(stack, setChild(makeASTNode(_SWSTMT), setSibling(exprNode, setLastSibling(caseNode, defaultNode))));
}
	   ;

CaseList : CaseList TCASE TINTEGER TCOLON StmtList {
	ASTNode* slNode = pop(stack);
	ASTNode* intNode = makeASTNodeINT($3);
	ASTNode* clNode = pop(stack);
	ASTNode* caseGroup = setChild(makeASTNode(_CASE), setSibling(intNode, slNode));
	if (clNode) {
		push(stack, setLastSibling(clNode, caseGroup));
	} else {
		push(stack, caseGroup);
	}
}
	 | TCASE TINTEGER TCOLON StmtList {
		ASTNode* slNode = pop(stack);
		ASTNode* intNode = makeASTNodeINT($2);
		push(stack, setChild(makeASTNode(_CASE), setSibling(intNode, slNode)));
	 }
	 ;

DefaultCase : TDEFAULT TCOLON StmtList {
	ASTNode* slNode = pop(stack);
	push(stack, setChild(makeASTNode(_DEFAULT), slNode));
}
	    | {push(stack, makeASTNode(_DEFAULT));}
	    ;

ReturnStmt : TRETURN Expr TSEMI {
	ASTNode* eNode = pop(stack);
	push(stack, setChild(makeASTNode(_RTSTMT), eNode));
}
	   | TRETURN TSEMI {push(stack, makeASTNode(_RTSTMT));}
	   ;

BreakStmt : TBREAK TSEMI {
/*	ASTNode* context = pop(stack);
	ASTNode* cur = getChild(context);
	int valid = 0;

	while (cur) {
		TKNUM tk = getTkNum(cur);
		if (tk == _WHLSTMT || tk == _FORSTMT || tk == _DOWHLSTMT || tk == _SWSTMT) {
			valid = 1;
			break;
		}
		cur = getSibling(cur);
	}
	push(stack, context);

	if (!valid) {
		yyerror("break문은 반복문이나 switch문 내에서만 사용할 수 있습니다.");
		YYABORT;
	}
*/
	push(stack, makeASTNode(_BRKSTMT));
}
	  ;

ExprStmt : Expr TSEMI {
	ASTNode* eNode = pop(stack);
	push(stack, setChild(makeASTNode(_EXPRSTMT), eNode));
}
	 | TSEMI {push(stack, makeASTNode(_EXPRSTMT));}
	 ;

Expr : Expr TCOMMA AssignExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* eNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(COMMA_), setSibling(eNode, aeNode)));
}
     | AssignExpr {}
     ;

AssignExpr : Variable TOPERATOR AssignExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* vNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(ASSIGN_), setSibling(vNode, aeNode)));
}
	   | Variable TPLUSASSIGN AssignExpr {
			ASTNode* aeNode = pop(stack);
			ASTNode* vNode = pop(stack);
			push(stack, setChild(makeASTNodeOP(ADDASSIGN_), setSibling(vNode, aeNode)));
	   }
	   | Variable TMINUSASSIGN AssignExpr {
			ASTNode* aeNode = pop(stack);
			ASTNode* vNode = pop(stack);
			push(stack, setChild(makeASTNodeOP(SUBASSIGN_), setSibling(vNode, aeNode)));
	   }
	   | Variable TMULASSIGN AssignExpr {
			ASTNode* aeNode = pop(stack);
			ASTNode* vNode = pop(stack);
			push(stack, setChild(makeASTNodeOP(MULTASSIGN_), setSibling(vNode, aeNode)));
	   }
	   | Variable TDIVASSIGN AssignExpr {
			ASTNode* aeNode = pop(stack);
			ASTNode* vNode = pop(stack);
			push(stack, setChild(makeASTNodeOP(DIVASSIGN_), setSibling(vNode, aeNode)));
	   }
	   | Variable TMODASSIGN AssignExpr {
			ASTNode* aeNode = pop(stack);
			ASTNode* vNode = pop(stack);
			push(stack, setChild(makeASTNodeOP(MODASSIGN_), setSibling(vNode, aeNode)));
	   }
	   | SimpleExpr {}
	   ;

Variable : TIDENTIFIER {push(stack, makeASTNodeID($1));}
	 ;

SimpleExpr : SimpleExpr TOR AndExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(OR_), setSibling(seNode, aeNode)));
}
	   | AndExpr {}
	   ;

AndExpr : AndExpr TAND EqualityExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(AND_), setSibling(seNode, aeNode)));
}
	| EqualityExpr {}
	;

EqualityExpr : EqualityExpr TEQ RelExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(EQ_), setSibling(seNode, aeNode)));
}
	     | EqualityExpr TNE RelExpr {
			ASTNode* aeNode = pop(stack);
		ASTNode* seNode = pop(stack);
		push(stack, setChild(makeASTNodeOP(NE_), setSibling(seNode, aeNode)));
		 }
	     | RelExpr {}
	     ;

RelExpr : RelExpr TLT AddExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(LT_), setSibling(seNode, aeNode)));
}
	| RelExpr TLE AddExpr {
		ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(LE_), setSibling(seNode, aeNode)));
	}
	| RelExpr TGT AddExpr {
		ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(GT_), setSibling(seNode, aeNode)));
	}
	| RelExpr TGE AddExpr {
		ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(GE_), setSibling(seNode, aeNode)));
	}
	| AddExpr {}
	;

AddExpr : AddExpr TPLUS Term {
	ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(PLUS_), setSibling(seNode, aeNode)));
}
	| AddExpr TMINUS Term {
			ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(MINUS_), setSibling(seNode, aeNode)));
	}
	| Term		   {}
	;

Term : Term TMUL Factor {
	ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(MULT_), setSibling(seNode, aeNode)));
}
	| Term TDIV Factor {
			ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(DIV_), setSibling(seNode, aeNode)));
	}
	| Term TMOD Factor {
					ASTNode* aeNode = pop(stack);
	ASTNode* seNode = pop(stack);
	push(stack, setChild(makeASTNodeOP(MOD_), setSibling(seNode, aeNode)));
	}
	| Factor {}
	;

Factor : TLPAREN Expr TRPAREN {}
	| FuncCall {}
	| TMINUS Factor {
		ASTNode* fNode = pop(stack);
		push(stack, setChild(makeASTNodeOP(MINUS_), fNode));
	}
	| Variable {}
	| Variable IncDec {
		ASTNode* incDecNode = pop(stack);
		ASTNode* vNode = pop(stack);
		push(stack, setChild(makeASTNode(_INCDECEXP), setSibling(vNode, incDecNode)));
	}
	| IncDec Variable {
		ASTNode* vNode = pop(stack);
		ASTNode* incDecNode = pop(stack);
		push(stack, setChild(makeASTNode(_INCDECEXP), setSibling(incDecNode, vNode)));
	}
	| NumberLiteral {}
	;

NumberLiteral : TINTEGER {push(stack, makeASTNodeINT($1));}
		| TREAL {push(stack, makeASTNodeREAL($1));}
		;

IncDec : TINC {push(stack, makeASTNodeOP(INC_));}
	| TDEC {push(stack, makeASTNodeOP(DEC_));}
	;

WhileMatchedStmt : TWHILE TLPAREN Expr TRPAREN MatchedStmt {
	ASTNode* stmtNode = pop(stack);
	ASTNode* exprNode = pop(stack);
	push(stack, setChild(makeASTNode(_WHLSTMT), setSibling(exprNode, stmtNode)));
}
		 ;

WhileOpenStmt : TWHILE TLPAREN Expr TRPAREN OpenStmt {
		ASTNode* stmtNode = pop(stack);
	ASTNode* exprNode = pop(stack);
	push(stack, setChild(makeASTNode(_WHLSTMT), setSibling(exprNode, stmtNode)));
}
		;

DoWhileStmt : TDO Stmt TWHILE TLPAREN Expr TRPAREN TSEMI {
		ASTNode* stmtNode = pop(stack);
	ASTNode* exprNode = pop(stack);
	push(stack, setChild(makeASTNode(_DOWHLSTMT), setSibling(exprNode, stmtNode)));
}
		;

ForMatchedStmt : TFOR TLPAREN ExprStmt ExprStmt Expr TRPAREN MatchedStmt {
	ASTNode* msNode = pop(stack);
	ASTNode* eNode = pop(stack);
	ASTNode* esNode = pop(stack);
	ASTNode* initialEsNode = pop(stack);
	push(stack, setChild(makeASTNode(_FORSTMT), setSibling(initialEsNode, setSibling(esNode, setSibling(eNode, msNode)))));
}
		;

ForOpenStmt : TFOR TLPAREN ExprStmt ExprStmt Expr TRPAREN OpenStmt {
	ASTNode* msNode = pop(stack);
	ASTNode* eNode = pop(stack);
	ASTNode* esNode = pop(stack);
	ASTNode* initialEsNode = pop(stack);
	push(stack, setChild(makeASTNode(_FORSTMT), setSibling(initialEsNode, setSibling(esNode, setSibling(eNode, msNode)))));
}
		;

FuncCall : TIDENTIFIER TLPAREN Arguments TRPAREN {
	ASTNode* argsNode = pop(stack);
	push(stack, setChild(makeASTNode(_FUNCCALL), setSibling(makeASTNodeID($1), argsNode)));
}
	 ;

Arguments : ArgumentList {
	ASTNode* alNode = pop(stack);
	push(stack, setChild(makeASTNode(_ARGS), alNode));
}
	  | {push(stack, makeASTNode(_ARGS));}
	  ;

ArgumentList : ArgumentList TCOMMA AssignExpr {
	ASTNode* aeNode = pop(stack);
	ASTNode* argsListNode = pop(stack);
	if (argsListNode) {
		push(stack, setLastSibling(argsListNode, aeNode));
	} else {
		push(stack, aeNode);
	}
}
	     | ArgumentList TCOMMA TSTRING {}
	     | AssignExpr {}
	     | TSTRING {}
	     ;


%%

int main(int argc, char* argv[]){
	ASTNode* root;
	extern FILE *yyin;
	stack = initStack();
	yyin = fopen(argv[1], "r");
	yyparse();
	fclose(yyin);
	root = pop(stack);
	delStack(stack);
	generate(root, argv[1]);
	delAST(root);
	return 0;
}

int yyerror(char* s){
	printf("%s\n", s);
	return 0;
}
