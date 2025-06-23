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
}
