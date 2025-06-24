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
	char *lb1=0, *lb2=0;
	ASTNode *l=0, *r=0;
	if(!tac)	return;
	if(!node)	return;
//	printf("Node %d\n", getTkNum(node));

	switch(getTkNum(node)){
	case _PROG:
		break;
	case _FUNCDEF:
		l = getChild(node);  // TYPE
		ASTNode* idNode = getSibling(l);  // ID
		ASTNode* paramNode = getSibling(idNode);  // PARAMS
		ASTNode* bodyNode = getSibling(paramNode);  // CPNDSTMT
		char* funcName = getSVal(idNode);
		emit(tac, "%s:", funcName);
		emit(tac, "BeginFunc");
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
		lb1 = getLabel();
		emit(tac, "%s:", lb1);
		pushLabel(ls, getLabel());
		break;
	case _FORSTMT:
		ASTNode* exp1 = getChild(node);
		genTAC(tac, exp1);

		lb1 = getLabel();
		emit(tac, "%s:", lb1);

		ASTNode* exp2 = getSibling(exp1);
		genTAC(tac, exp2);

		lb2 = getLabel();
		emit(tac, "IFZ %n Goto %s", getChild(exp2), lb2);
		pushLabel(ls, lb2);

		ASTNode* exp3 = getSibling(exp2);
		ASTNode* body = getSibling(exp3);
		genTAC(tac, body);
		genTAC(tac, exp3);

		emit(tac, "Goto %s", lb1);
		emit(tac, "%s:", lb2);
		popLabel(ls);

		enterChildNode = 0;
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
		l = getChild(node); // ID node
		r = getSibling(l);  // ARGS node
		ASTNode* arg = getChild(r);
		int argCount = 0;
		while (arg) {
			genTAC(tac, arg);
			emit(tac, "PushParam %n", arg);
			argCount++;
			arg = getSibling(arg);
		}
		setName(node, getTmp());
		emit(tac, "%n = LCall %s", node, getSVal(l));
		emit(tac, "PopParam %d", argCount);
		enterChildNode = 0;
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
		emit(tac, "EndFunc");
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
		// ASTNode *c = getChild(node);
		// while(c){
		// 	c = getSibling(c);
		// }
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
		l = getChild(node);
		if (l)	emit(tac, "Return %n", l);
		else emit(tac, "Return");
		break;
	case _BRKSTMT:
		break;
	case _WHLSTMT:
		break;
	case _DOWHLSTMT:
		lb2 = popLabel(ls);
		r = getSibling(getChild(node));
		emit(tac, "IFZ %n Goto %s", r, lb2);
		emit(tac, "Goto %s", lb1);
		emit(tac, "%s:", lb2);
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
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n != %n", node, l, r);
			break;
		case ASSIGN_:
			l = getChild(node); r = getSibling(l);
			if (!declaration) {
				setName(node, getTmp());
				emit(tac, "%n = %n", l, r);         // 실행 시 대입
				emit(tac, "%n = %n", node, l);
			} else {
				emit(tac, "%n = %n", l, r);         // 선언 시 초기화
			}
			break;
		case MOD_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n %% %n", node, l, r);
			break;
		case EQ_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n == %n", node, l, r);
			break;
		case LT_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n < %n", node, l, r);
			break;
		case LE_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n <= %n", node, l, r);
			break;
		case GT_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n > %n", node, l, r);
			break;
		case GE_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n >= %n", node, l, r);
			break;
		case PLUS_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n + %n", node, l, r);
			break;
		case MINUS_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			if (!r) {
				// 단항 마이너스
				emit(tac, "%n = 0 - %n", node, l);
			} else {
				// 이항 마이너스
				emit(tac, "%n = %n - %n", node, l, r);
			}
			break;
		case MULT_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n * %n", node, l, r);
			break;
		case DIV_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n / %n", node, l, r);
			break;
		case AND_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n && %n", node, l, r);
			break;
		case OR_:
			setName(node, getTmp());
			l = getChild(node); r = getSibling(l);
			emit(tac, "%n = %n || %n", node, l, r);
			break;
		case COMMA_:
			l = getChild(node); r = getSibling(l);
			genTAC(tac, l);
			genTAC(tac, r);
			setName(node, getName(r));
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

