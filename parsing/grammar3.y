%{
    #include <stdio.h>
    int yylex(void);
    int yyerror(char*);
%}

%token TINTEGER

%%

Expr : Expr '+' Term    {
    $$ = $1 + $3;
    printf("%d -> %d + %d\n", $$, $1, $3);
    }
     | Expr '-' Term    {
        $$ = $1 - $3;
        printf("%d -> %d - %d\n", $$, $1, $3);
        }
     | Term             {
        $$ = $1;
        printf("%d -> %d\n", $$, $1);
        }
     ;

Term : Term '*' Factor  {
        $$ = $1 * $3;
        printf("%d -> %d * %d\n", $$, $1, $3);
        }
      | Term '/' Factor {
        $$ = $1 / $3;
        printf("%d -> %d / %d\n", $$, $1, $3);
        }
      | Factor          {
        $$ = $1;
        printf("%d -> %d\n", $$, $1);
        }
      ;

Factor : '(' Expr ')'   {
            $$ = $2;
            printf("%d -> ( %d )\n", $$, $2);
        }
       | TINTEGER       {
        $$ = $1;
        printf("%d -> %d\n", $$, $1);        
        } // 생성규칙 우측에 있는 1번째 요소
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
