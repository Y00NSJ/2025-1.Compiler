#include <stdio.h>
#include <stdlib.h>
#include "taclib.h"

LABELSTACK* ls;

void generate(ASTNode* root, char* filename){
	int len;
	char *tacfile = 0;
	FILE *fp;
	TAC* tac = initTAC();

	for(len=0;filename[len];len++);
	tacfile = (char*)malloc(len+1);
	tacfile[len--] = '\0';
	tacfile[len--] = 't';
	for(;len>=0;len--)	tacfile[len] = filename[len];
	fp = fopen(tacfile, "w");

//	checkSymbols(root);
	ls = initLabelStack();
	genTAC(tac, root);

	printTAC(tac, fp);
	fclose(fp);
	free(tacfile);
	delLabelStack(ls);
	delTAC(tac);
	return;
}

void genTAC(TAC* tac, ASTNode* node){
	static int declaration = 0;
	int enterChildNode = 1;
	int i=0, tint = 0;
	ASTNode *l=0, *r=0;
	if(!tac)	return;
	if(!node)	return;
//	printf("Node %d\n", getTkNum(node));

	switch(getTkNum(node)){
	case _PROG:
		break;
	case _FUNCDEF:
		break;
	case _VARDEC:
		declaration = 1;
		break;
	case _FUNCDEC:
		break;
	case _ID:
		break;
	case _ARRAY:
		break;
	case _TYPE:
		break;
	case _PARAMS:
		declaration = 1;
		break;
	case _PARAM:
		break;
	case _CPNDSTMT:
		break;
	case _LDECLIST:
		declaration = 1;
		break;
	case _STMTLIST:
		break;
	case _IDDECLIST:
		break;
	case _EXPRSTMT:
		break;
	case _IFSTMT:
		l = getChild(node);               // 조건식
		ASTNode* thenStmt = getSibling(l);

		genTAC(tac, l);                   // 먼저 조건식 실행
		lb1 = getLabel();
		emit(tac, "IFZ %n Goto %s", l, lb1);  // 조건식 결과로 분기

		genTAC(tac, thenStmt);            // then 블록 실행

		ASTNode* elseStmt = getSibling(thenStmt);

		if (elseStmt) {
			lb2 = getLabel();
			emit(tac, "Goto %s", lb2);
		}
		emit(tac, "%s:", lb1);            // 라벨 출력
		if (elseStmt) {
			genTAC(tac, elseStmt);
			emit(tac, "%s:", lb2);
		}

		enterChildNode = 0;              // 자식 다시 방문하지 않도록
		break;
	case _SWSTMT:
		break;
	case _RTSTMT:
		break;
	case _BRKSTMT:
		emit(tac, "Goto %s", topLabel(ls));
		break;
	case _WHLSTMT:
		lb1 = getLabel();
		emit(tac, "%s:", lb1);
		l = getChild(node);               // 조건식
		genTAC(tac, l);                   // 먼저 조건식 실행

		lb2 = getLabel();
		emit(tac, "IFZ %n Goto %s", l, lb2);  // 조건식 결과로 분기
		pushLabel(ls, lb2);

		ASTNode* cpndStmt = getSibling(l);	// 실행문
		if (cpndStmt)	genTAC(tac, cpndStmt);

		emit(tac, "Goto %s", lb1);		// loop
		emit(tac, "%s:", lb2);			// escape 후 실행문
		popLabel(ls);
		enterChildNode = 0;
		break;
	case _DOWHLSTMT:
		break;
	case _FORSTMT:
		break;
	case _CASE:
		break;
	case _DEFAULT:
		break;
	case _INCDECEXP:
		break;
	case _OPER:
		break;
	case _INTEGER:
		break;
	case _REAL:
		break;
	case _ARGS:
		break;
	case _FUNCCALL:
		break;
	}

	if(enterChildNode){
		ASTNode *c = getChild(node);
		enterChildNode = 1;
		while(c){
			genTAC(tac, c);
			c = getSibling(c);
		}
	}

	switch(getTkNum(node)){
	case _PROG:
		break;
	case _FUNCDEF:
		break;
	case _VARDEC:
		declaration = 0;
		break;
	case _FUNCDEC:
		break;
	case _ID:
		setName(node, getSVal(node));
		break;
	case _ARRAY:
		break;
	case _TYPE:
		break;
	case _PARAMS:
		declaration = 0;
		break;
	case _PARAM:
		break;
	case _CPNDSTMT:
		break;
	case _LDECLIST:
		declaration = 0;
		break;
	case _STMTLIST:
		ASTNode *c = getChild(node);
		while(c){
			genTAC(tac, c);
			c = getSibling(c);
		}
		break;
	case _IDDECLIST:
		break;
	case _EXPRSTMT:
		break;
	case _IFSTMT:
		break;
	case _SWSTMT:
		break;
	case _RTSTMT:
		break;
	case _BRKSTMT:
		break;
	case _WHLSTMT:
		break;
	case _DOWHLSTMT:
		break;
	case _FORSTMT:
		break;
	case _CASE:
		break;
	case _DEFAULT:
		break;
	case _INCDECEXP:
		l = getChild(node);
		r = getSibling(l);
		if (getTkNum(r) == _ID) {
			setName(node, getName(r));
			if (getOperator(l) == INC_) emit(tac, "%n = %n + 1", node, r);
			else emit(tac, "%n = %n - 1", node, r);
		}
		else {
			setName(node, getTmp());
			emit(tac, "%n = %n", node, l);
			if (getOperator(r) == INC_) emit(tac, "%n = %n + 1", l, l);
			else emit(tac, "%n = %n - 1", l, l);
		}
		break;
	case _OPER:
		switch (getOperator(node)) {
		case NE_:
			setName(node, getTmp());
			l = getChild(node);
			r = getSibling(l);
			emit(tac, "%n = %n != %n", node, l, r);
			break;
		case ASSIGN_:
			setName(node, getTmp());
			l = getChild(node);
			r = getSibling(l);
			emit(tac, "%n = %n", l, r);
			emit(tac, "%n = %n", node, l);
			break;
		case MOD_:
			setName(node, getTmp());
			l = getChild(node);
			r = getSibling(l);
			emit(tac, "%n = %n %% %n", node, l, r);
			break;
		}
		break;
	case _INTEGER:
		break;
	case _REAL:
		break;
	case _ARGS:
		break;
	case _FUNCCALL:
		break;
	}
}
