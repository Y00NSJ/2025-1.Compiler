%{
    #include <stdio.h>
    int yylex(void);
    int yyerror(char*);
%}

%token TINTEGER

%%

Expr : Expr '+' Term
     | Expr '-' Term
     | Term
     ;

Term : Term '*' Factor
      | Term '/' Factor
      | Factor
      ;

Factor : '(' Expr ')'
       | TINTEGER
       ;

%%
int main(void) {
    yyparse();
    return 0;
}
int yyerror(char* s) {
    printf("%s\n", s);
    return 0;
}
