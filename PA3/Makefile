parser : y.tab.o lex.yy.o ast.a
        gcc -o parser y.tab.o lex.yy.o ast.a -ll

y.tab.o : y.tab.c
        gcc -c -o y.tab.o y.tab.c

lex.yy.o : lex.yy.c
        gcc -c -o lex.yy.o lex.yy.c

y.tab.c : parser.y
        yacc -d parser.y

lex.yy.c : tokenizer.l
        flex tokenizer.l

clean :
        rm -f parser lex.yy.o lex.yy.c y.tab.o y.tab.c y.tab.h
