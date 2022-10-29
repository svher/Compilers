%{
/* Lab2 Attention: You are only allowed to add code in this file and start at Line 26.*/
#include <string.h>
#include "util.h"
#include "symbol.h"
#include "errormsg.h"
#include "absyn.h"
#include "y.tab.h"

int charPos=1;

int yywrap(void)
{
 charPos=1;
 return 1;
}

void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

/*
* Please don't modify the lines above.
* You can add C declarations of your own below.
*/

/* @function: getstr
 * @input: a string literal
 * @output: the string value for the input which has all the escape sequences 
 * translated into their meaning.
 */
char *getstr(const char *str)
{
	//optional: implement this function if you need it
	return NULL;
}

static int input(void);
static void yyunput (int, char *);

static int isDigital(char c) {
	return (c >= 0x30 && c <= 0x39);
}

char *stringToken() {
	yyleng = 1;
	int maxlen = 128;
	char *s = (char *)malloc(maxlen);
	int pos = 0;
	char c;
	while((c = (char)input()) != EOF) {
		++yyleng;
		if(c == '\"') {
			break;
		}
		if(c == '\n') {
			break;
		}
		if(c == '\\') {
			c = (char)input();
			++yyleng;
			switch(c) {    // still have other conditions
			case 'n':
				c = '\n';
				break;
			case 't':
				c = '\t';
				break;
			default:
				if(isDigital(c)) {
					char c1 = (char)input();
					char c2 = (char)input();
					if(isDigital(c1) && isDigital(c2)) {
						c = c*100 + c1*10 + c2;
						yyleng += 2;
					}
					else {
						unput(c2);
						unput(c1);
					}
				}
				break;
			}
		}
		if(pos >= maxlen) {
			s = (char *)realloc(s, maxlen * 2);
			maxlen = maxlen * 2;
		}
		s[pos] = (char)c;
		++pos;
	}
	s[pos] = '\0';
	char *tigerStr = (char *)malloc(sizeof(int) + pos + 1);
	*((int *)tigerStr) = pos;
	memcpy(tigerStr + sizeof(int), s, pos + 1);
	free(s);
	return tigerStr;
}

int commentStartCount = 0;

%}
  /* You can add lex definitions here. */

%Start COMMENT
%%
  /* 
  * Below is an example, which you can wipe out
  * and write reguler expressions and actions of your own.
  */ 

"\n" {adjust(); EM_newline(); continue;}
<INITIAL>(" "|"\t"|"\r")+ {adjust();}

<INITIAL>while {adjust(); return WHILE;}
<INITIAL>for {adjust(); return FOR;}
<INITIAL>to {adjust(); return TO;}
<INITIAL>break {adjust(); return BREAK;}
<INITIAL>let {adjust(); return LET;}
<INITIAL>in {adjust(); return IN;}
<INITIAL>end {adjust(); return END;}
<INITIAL>function {adjust(); return FUNCTION;}
<INITIAL>var {adjust(); return VAR;}
<INITIAL>type {adjust(); return TYPE;}
<INITIAL>array {adjust(); return ARRAY;}
<INITIAL>if {adjust(); return IF;}
<INITIAL>then {adjust(); return THEN;}
<INITIAL>else {adjust(); return ELSE;}
<INITIAL>do {adjust(); return DO;}
<INITIAL>of {adjust(); return OF;}
<INITIAL>nil {adjust(); return NIL;}

<INITIAL>\x22 {yylval.sval=stringToken(); adjust(); return STRING;}
<INITIAL>"/*" {adjust(); ++commentStartCount; BEGIN COMMENT;}

<INITIAL>":=" {adjust(); return ASSIGN;}
<INITIAL>"," {adjust(); return COMMA;}
<INITIAL>":" {adjust(); return COLON;}
<INITIAL>";" {adjust(); return SEMICOLON;}
<INITIAL>"(" {adjust(); return LPAREN;}
<INITIAL>")" {adjust(); return RPAREN;}
<INITIAL>"[" {adjust(); return LBRACK;}
<INITIAL>"]" {adjust(); return RBRACK;}
<INITIAL>"{" {adjust(); return LBRACE;}
<INITIAL>"}" {adjust(); return RBRACE;}
<INITIAL>"." {adjust(); return DOT;}
<INITIAL>"+" {adjust(); return PLUS;}
<INITIAL>"-" {adjust(); return MINUS;}
<INITIAL>"*" {adjust(); return TIMES;}
<INITIAL>"/" {adjust(); return DIVIDE;}
<INITIAL>"=" {adjust(); return EQ;}
<INITIAL>"!="|"<>" {adjust(); return NEQ;}
<INITIAL>"<=" {adjust(); return LE;}
<INITIAL>"<" {adjust(); return LT;}
<INITIAL>">=" {adjust(); return GE;}
<INITIAL>">" {adjust(); return GT;}
<INITIAL>"&" {adjust(); return AND;}
<INITIAL>"|" {adjust(); return OR;}

<INITIAL>[A-Za-z][A-Za-z0-9_]* {adjust(); yylval.sval=String(yytext); return ID;}
<INITIAL>[0-9]+ {adjust(); yylval.ival=atoi(yytext); return INT;}

<INITIAL>. {adjust(); EM_error(charPos, "illegal character");}

<COMMENT>"/*" {adjust(); ++commentStartCount;}
<COMMENT>"*/" {adjust(); --commentStartCount; if(commentStartCount==0) {BEGIN INITIAL;}}
<COMMENT>(" "|"\t")+ {adjust();}
<COMMENT>. {adjust();}

