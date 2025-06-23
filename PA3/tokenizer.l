%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

char* tokenType[] = {"Keyword", "Identifier", "Integer", "Real", "String", "Comment", "Operator", "Punctuation"};

// Declare additional variables or functions here if you need...


%}

WS		[ \t\n]+
DIGIT		[0-9]
LETTER_		[A-Za-z_]
ID		{LETTER_}({LETTER_}|{DIGIT})*
REAL		([0-9]+\.[0-9]*|\.[0-9]+)([Ee][\+\-]?[0-9]+)?[Ff]
PUNC		"("|")"|"{"|"}"|"["|"]"|";"|":"
OPER		[+\-*/%=<>]=?|!=|\+\+|--|,
CHAR		'([^\\'"\n]|\\[abfnrtv0\'\"\\?])'
INT		[1-9]{DIGIT}*|0[0-7]*|0[Xx]({DIGIT}|[A-Fa-f])+
STR		\"([^\\'"\n]|\\[abfnrtv0\'\"\\?])*\"
CMT		"/""/"[^\n]*\n|"/""*"([^"*"]|"*"+[^*/])*"*"+"/"

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
{ID}            { int i = 0; 
yylval.sVal = (char*)malloc(yyleng+1);
for(i = 0; i < yyleng; i++) yylval.sVal[i] = yytext[i];
yylval.sVal[yyleng] = '\0';
 return TIDENTIFIER;}
"+="              {return TPLUSASSIGN;}
"-="              {return TMINUSASSIGN;}
"*="              {return TMULASSIGN;}
"/="              {return TDIVASSIGN;}
"%="              {return TMODASSIGN;}
"=="              {return TEQ;}
"!="              {return TNE;}
"||"              {return TOR;}
"&&"              {return TAND;}
">="              {return TGE;}
"<="              {return TLE;}
"++"              {return TINC;}
"--"              {return TDEC;}
","		{return TCOMMA;}
"("		{return TLPAREN;}
")"		{return TRPAREN;}
";"		{return TSEMI;}
"{"		{return TLBRACE;}
"}"		{return TRBRACE;}
"["		{return TLBRACKET;}
"]"		{return TRBRACKET;}
":"		{return TCOLON;}
"+"		{return TPLUS;}
"-"		{return TMINUS;}
"*"		{return TMUL;}
"/"		{return TDIV;}
"%"		{return TMOD;}
"<"		{return TLT;}
">"		{return TGT;}
{OPER}          {return TOPERATOR;}
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
return TINTEGER; }
{REAL}		{ yylval.rVal = atof(yytext); return TREAL; }
{STR}		{     char* result = (char*)malloc(yyleng);  
    int ri = 0;

    for (int i = 1; i < yyleng - 1; ++i) { 
        if (yytext[i] == '\\') {
            i++; 
            switch (yytext[i]) {
                case 'n': result[ri++] = '\n'; break;
                case 't': result[ri++] = '\t'; break;
                case 'r': result[ri++] = '\r'; break;
                case 'b': result[ri++] = '\b'; break;
                case 'f': result[ri++] = '\f'; break;
                case 'a': result[ri++] = '\a'; break;
                case 'v': result[ri++] = '\v'; break;
                case '0': result[ri++] = '\0'; break;
                case '\\': result[ri++] = '\\'; break;
                case '\"': result[ri++] = '\"'; break;
                case '\'': result[ri++] = '\''; break;
                case '?': result[ri++] = '\?'; break;
                default:
                    result[ri++] = '\\';
                    result[ri++] = yytext[i];
                    break;
            }
        } else {
            result[ri++] = yytext[i];
        }
    }

    result[ri] = '\0'; 
    yylval.sVal = result;
return TSTRING; }
{CMT}		{ return TCOMMENT; }
{PUNC}		{return TPUNCTUATION;}
.		{return TERROR;}

%%

// Define additional functions here if you need...
