%{
#include <stdio.h>
#include <stdlib.h>

char* tokenType[] = {"Keyword", "Identifier", "Integer", "Real", "String", "Comment", "Operator", "Punctuation"};
enum tnumber {TEOF, TBREAK, TCASE, TCHAR, TDEFAULT, TDO, TELSE, TFLOAT, TFOR, TIF, TINT, TRETURN, TSWITCH, TVOID, TWHILE, TIDENTIFIER, TINTEGER, TREAL, TSTRING, TCOMMENT, TOPERATOR, TPUNCTUATION, TERROR};

// Declare additional variables or functions here if you need...

union{
	int iVal;
	float rVal;
	char* sVal;
} yylval;

%}

WS		[\t\n]+
DIGIT		[0-9]
LETTER_		[A-Za-z_]
ID		{LETTER_}({LETTER_}|{DIGIT})*
REAL		([0-9]+\.[0-9]*|\.[0-9]+)([Ee][\+\-]?[0-9]+)?[Ff]
PUNC		"("|")"|"{"|"}"|"["|"]"|;|:
OPER		[+\-*/%=<>]=?|!=|\+\+|--|,
CHAR		'[^\\'"\\n]'|'"\"['"?abfnrtv0\\]'
INT		[1-9]{DIGIT}*|0[0-7]*|0[Xx]({DIGIT}|[A-Fa-f])+
STR		\"([^\\'"\\n]|"\"['"?abfnrtv0\\])*\"
CMT		"/""/"[^\n]*\n|"/""*"([^*]|"*"+[^*/])*"*"+"/"

%%

{WS}		{}
break		{return TBREAK;}
case		{return TCASE;}
char		{return TCHAR;}
default		{return TDEFAULT;}
do		{return TDO;}
else		{return	TELSE;}
float		{return TFLOAT;}
for		{return TFOR;}
if		{return TIF;}
int		{return TINT;}
return		{return TRETURN;}
switch		{return TSWITCH;}
void		{return TVOID;}
while		{return TWHILE;}
{ID}		{return TIDENTIFIER;}
{CHAR}		{
    if (yytext[1] != '\\') {
        yylval.iVal = yytext[1];
    } else {
        switch (yytext[2]) {
            case '\'': yylval.iVal = '\''; break;
	    case '\"': yylval.iVal = '\"'; break;
            case '\\': yylval.iVal = '\\'; break;
	    case '?': yylval.iVal = '\?'; break;
	    case 'a': yylval.iVal = '\a'; break;
	    case 'b': yylval.iVal = '\b'; break;
	    case 'f': yylval.iVal = '\f'; break;
	    case 'n': yylval.iVal = '\n'; break;
            case 'r': yylval.iVal = '\r'; break;
	    case 't': yylval.iVal = '\t'; break;
            case 'v': yylval.iVal = '\v'; break;
            case '0': yylval.iVal = '\0'; break;
            default: yylval.iVal = yytext[1]; break;
        }
    }
    return TINTEGER;
}
{INT}		{ 
if (yytext[0] == '0') {
	int result = 0;
	if (yytext[1] == 'x' || yytext[1] == 'X') {
		for (int i = 2; i < yyleng; i++) {
			int value;
			char c = yytext[i];
			if (c >= '0' && c <= '9') value = c - '0';
			else if (c >= 'a' && c <= 'f') value = c - 'a' + 10;
			else if (c >= 'A' && c <= 'F') value = c - 'A' + 10;

			result = result * 16 + value;
		}
	}
	else {
		for (int i = 1; i <  yyleng; i++) {
			result = result * 8 + (yytext[i] - '0');
		}
	}
	yylval.iVal = result;
} else { yylval.iVal = atoi(yytext); } 
return TINTEGER; 
}
{REAL}		{ yylval.rVal = atof(yytext); return TREAL; }
{STR}		{return TSTRING;}
{CMT}		{return TCOMMENT;}
{OPER}		{return TOPERATOR;}
{PUNC}		{return TPUNCTUATION;}
.		{return TERROR;}

%%

int main(int argc, char *argv[]){
	enum tnumber tn;
	if(!argc)	exit(0);
	yyin = fopen(argv[1], "r");

// Insert source code here...
	while ((tn = yylex()) != TEOF) {
		switch(tn) {
		case TINTEGER:
			printf("%-15s:%19s,%5d\n", yytext, tokenType[2], yylval.iVal );
			break;
		case TREAL:
			printf("%-15s:%19s,%5.2f\n", yytext, tokenType[3], yylval.rVal );
			break;
		case TSTRING:
			printf("%-15s:%19s,%s\n", yytext, tokenType[4], yylval.sVal );
			break;
		case TBREAK: case TCASE: case TCHAR: case TDEFAULT: case TDO: case TELSE: case TFLOAT: case TFOR: case TIF: case TINT: case TRETURN: case TSWITCH: case TVOID: case TWHILE:
			printf("%-15s:%19s\n", yytext, tokenType[0]);
			break;
		case TIDENTIFIER:
			printf("%-15s:%19s\n", yytext, tokenType[1]);
			break;
		case TCOMMENT:
			printf("%-15s:%19s\n", yytext, tokenType[5]);
			break;
		case TOPERATOR:
			printf("%-15s:%19s\n", yytext, tokenType[6]);
			break;
		case TPUNCTUATION:
			printf("%-15s:%19s\n", yytext, tokenType[7]);
			break;
		case TERROR:
			printf("Error occurred\n");
			fclose(yyin);
			return 0;
		}
	}

	fclose(yyin);
	return 0;
}

// Define additional functions here if you need...
