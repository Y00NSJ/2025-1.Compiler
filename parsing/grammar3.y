%{
    #include <stdio.h>
    int yylex(void);
    int yyerror(char*);
%}

%token TINTEGER

%%

Expr : Expr '+' Term    {printf("E -> E + T\n");}
     | Expr '-' Term    {printf("E -> E - T\n");}
     | Term             {printf("E -> T\n");}
     ;

Term : Term '*' Factor  {printf("T -> T * F\n");}
      | Term '/' Factor {printf("T -> T / F\n");}
      | Factor          {printf("T -> F\n");}
      ;

Factor : '(' Expr ')'   {printf("F -> ( E )\n");}
       | TINTEGER       {printf("F -> num\n");}
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
