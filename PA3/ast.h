#ifndef _UTIL_H_
#define _UTIL_H_
typedef enum {_PROG, _FUNCDEF, _VARDEC, _FUNCDEC, _ID, _ARRAY, _TYPE, _PARAMS, _PARAM, _CPNDSTMT, _LDECLIST, _STMTLIST, _IDDECLIST, _EXPRSTMT, _IFSTMT, _SWSTMT, _RTSTMT, _BRKSTMT, _WHLSTMT, _DOWHLSTMT, _FORSTMT, _CASE, _DEFAULT, _INCDECEXP, _OPER, _INTEGER, _REAL, _ARGS, _FUNCCALL} TKNUM;

typedef enum {NO_TYPE, TYPE_INT, TYPE_FLOAT, TYPE_VOID, TYPE_ERROR, TYPE_CHAR} TYPE;

enum {ERROR_, PLUS_, MINUS_, MULT_, DIV_, MOD_, INC_, DEC_, EQ_, NE_, GT_, LT_, GE_, LE_, AND_, OR_, ASSIGN_, ADDASSIGN_, SUBASSIGN_, MULTASSIGN_, DIVASSIGN_, MODASSIGN_, COMMA_};

typedef struct astNodeType ASTNode;
typedef struct stack_t STACK;

ASTNode* makeASTNode(TKNUM tknum);
ASTNode* makeASTNodeTYPE(TYPE t);
ASTNode* makeASTNodeID(char *id);
ASTNode* makeASTNodeOP(int op);
ASTNode* makeASTNodeINT(int n);
ASTNode* makeASTNodeREAL(float r);

ASTNode* getSibling(ASTNode* n);
ASTNode* getChild(ASTNode* n);

ASTNode* setSibling(ASTNode* l, ASTNode* r);
ASTNode* setLastSibling(ASTNode* l, ASTNode* r);
ASTNode* setChild(ASTNode* p, ASTNode* c);

TKNUM getTkNum(ASTNode *n);
TYPE getType(ASTNode *n);

void printAST(ASTNode* head);
void delAST(ASTNode *head);

STACK* initStack(void);
void delStack(STACK* s);
void push(STACK* s, ASTNode* n);
ASTNode* pop(STACK *s);
void printStack(STACK *s);

#endif
