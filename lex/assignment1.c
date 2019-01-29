%option noyywrap
%{
#include"tokens-manual.h"

enum num_types {
	_CHAR,
	_UCHAR,
	_SHORT,
	_USHORT,
	_INT,
	_UINT,
	_LONG,
	_ULONG,
	_LONGLONG,
	_ULONGLONG,
	_FLOAT,
	_DOUBLE,
	_LDOUBLE,
};

typedef struct {
	unsigned char type;
	union {
		char c; 
		short s;
		int i;
		long l;
		long long ll;
		unsigned char uc;
		unsigned short us;
		unsigned int ui;
		unsigned long ul;
		unsigned long long ull;
		float f;
		double d;
		long double ld;
	} value;
} NUM;

int stringlen;

typedef struct {
	unsigned int length;
	char * string;
} STR;

int store_num(char * text, NUM * number, unsigned char type, int base) {
	number->type = type;
	switch (type) {
		case _CHAR:
			number->value.c = strtol(text,NULL,base);
			break;
		case _UCHAR:
			number->value.uc = strtol(text,NULL,base);
			break;
		case _SHORT:
			number->value.s = strtol(text,NULL,base);
			break;
		case _USHORT:
			number->value.us = strtol(text,NULL,base);
			break;
		case _INT:
			number->value.i = strtol(text,NULL,base);
			break;
		case _UINT:
			number->value.ui = strtol(text,NULL,base);
			break;
		case _LONG:
			number->value.l = strtol(text,NULL,base);
			break;
		case _ULONG:
			number->value.ul = strtol(text,NULL,base);
			break;
		case _LONGLONG:
			number->value.ll = strtol(text,NULL,base);
			break;
		case _ULONGLONG:
			number->value.ull = strtol(text,NULL,base);
			break;
		case _FLOAT:
			number->value.f = strtof(text,NULL);
			break;
		case _DOUBLE:
			number->value.d = strtof(text,NULL);
			break;
		case _LDOUBLE:
			number->value.ld = strtof(text,NULL);
			break;
	}
	return 0;
}

typedef union {
	NUM number;
	STR string;
	char charlit;
	char * ident;
} YYSTYPE;

YYSTYPE yylval;

char strbuff[1024];

%}

%x instring
%x incomment

%%
	/* Keywords */
auto		return AUTO;
break		return BREAK;
case		return CASE;
char 		return CHAR;
continue	return CONTINUE;
do			return DO;
default		return DEFAULT;
const		return CONST;
double		return DOUBLE;
else		return ELSE;
enum		return ENUM;
extern		return EXTERN;
for			return FOR;
if			return IF;
inline		return INLINE;
goto		return GOTO;
float		return FLOAT;
int			return INT;
long		return LONG;
short 		return SHORT;
restrict	return RESTRICT;
register	return REGISTER;
return		return RETURN;
signed		return SIGNED;
sizeof		return SIZEOF;
static		return STATIC;
struct		return STRUCT;
switch		return SWITCH;
typedef		return TYPEDEF;
union		return UNION;
unsigned	return UNSIGNED;
void		return VOID;
volatile	return VOLATILE;
while		return WHILE;
_Bool		return _BOOL;
_Complex	return _COMPLEX;
_Imaginary	return _IMAGINARY;

	/* Special Characters */
\=			return '=';
\,			return ',';
\;			return ';';
\.			return '.';
\!			return '!';
\~			return '~';
\#			return '#';
\\			return '\\';
\&			return '&';
\*			return '*';
\+			return '+';
\-			return '-';
\/			return '/';
\^			return '^';
\|			return '|';
\_			return '_';
\%			return '%';
\>			return '>';
\<			return '<';
\{			return '{';
\}			return '}';
\(			return '(';
\)			return ')';
\[			return '[';
\]			return ']';

\=\=		return EQEQ;
\!\=		return NOTEQ;
\+\+		return PLUSPLUS;
\-\-		return MINUSMINUS;
\&\&		return LOGAND;
\|\|		return LOGOR;
\+\=		return PLUSEQ;
\-\=		return MINUSEQ;
\*\=		return TIMESEQ;
\/\=		return DIVEQ;
\%\=		return MODEQ;
\<\=		return LTEQ;
\>\=		return GTEQ;
\&\=		return ANDEQ;
\|\=		return OREQ;
\^\=		return XOREQ;
\<\<		return SHL;
\>\>		return SHR;
\-\>		return INDSEL;

\<\<\=		return SHLEQ;
\>\>\=		return SHREQ;
\.\.\.		return ELLIPSIS;

	/* Numeric Literals */

[0-9]+e[\-\+]?[0-9]+[fF] {
	store_num(yytext,&yylval.number,_FLOAT,10); return NUMBER;
}

[0-9]+e[\-\+]?[0-9]+[lL] {
	store_num(yytext,&yylval.number,_LDOUBLE,10); return NUMBER;
}

[0-9]+e[\-\+]?[0-9]+	{
	store_num(yytext,&yylval.number,_DOUBLE,10); return NUMBER;
}

[0-9]+\.(e[\-\+]?[0-9])?+[fF] {
	store_num(yytext,&yylval.number,_FLOAT,10); return NUMBER;
}

[0-9]+\.(e[\-\+]?[0-9])?+[lL] {
	store_num(yytext,&yylval.number,_LDOUBLE,10); return NUMBER;
}

[0-9]+\.(e[\-\+]?[0-9])?+	{
	store_num(yytext,&yylval.number,_DOUBLE,10); return NUMBER;
}

[0-9]*\.[0-9]+(e[\-\+]?[0-9])?+[fF] {
	store_num(yytext,&yylval.number,_FLOAT,10); return NUMBER;
}

[0-9]*\.[0-9]+(e[\-\+]?[0-9])?+[lL] {
	store_num(yytext,&yylval.number,_LDOUBLE,10); return NUMBER;
}

[0-9]*\.[0-9]+(e[\-\+]?[0-9])?+	{
	store_num(yytext,&yylval.number,_DOUBLE,10); return NUMBER;
}

0[xX][0-9a-f]+((ul)|(lu)|(uL)|(Lu)|(Ul)|(lU)|(UL)|(LU)) {
	store_num(yytext,&yylval.number,_ULONG,16); return NUMBER;
}

0[xX][0-9a-f]+[uU]	{
	store_num(yytext,&yylval.number,_UINT,16); return NUMBER;
}

0[xX][0-9a-f]+[lL]	{
	store_num(yytext,&yylval.number,_LONG,16); return NUMBER;
}

0[xX][0-9a-f]+	{
	store_num(yytext,&yylval.number,_INT,16); return NUMBER;
}

0[0-7]+((ul)|(lu)|(uL)|(Lu)|(Ul)|(lU)|(UL)|(LU)) {
	store_num(yytext,&yylval.number,_ULONG,8); return NUMBER;
}

0[0-7]+[uU]	{
	store_num(yytext,&yylval.number,_UINT,8); return NUMBER;
}

0[0-7]+[lL]	{
	store_num(yytext,&yylval.number,_LONG,8); return NUMBER;
}

0[0-7]+ {
	store_num(yytext,&yylval.number,_INT,8); return NUMBER;
}

[0-9]+((ul)|(lu)|(uL)|(Lu)|(Ul)|(lU)|(UL)|(LU))	{
	store_num(yytext,&yylval.number,_ULONG,10); return NUMBER;
}

[1-9][0-9]*[uU]	{
	store_num(yytext,&yylval.number,_UINT,10); return NUMBER;
}

[1-9][0-9]*[lL]	{
	store_num(yytext,&yylval.number,_LONG,10); return NUMBER;
}

[1-9][0-9]*	{
	store_num(yytext,&yylval.number,_INT,10); return NUMBER;
}	

0 {
	store_num(yytext,&yylval.number,_INT,10); return NUMBER;
}

	/* Character Literals */
L?\'\\a.*\'						{
	yylval.charlit = '\a'; return CHARLIT;
}
L?\'\\b.*\'						{
	yylval.charlit = '\b'; return CHARLIT;
}
L?\'\\f.*\'						{
	yylval.charlit = '\f'; return CHARLIT;
}
L?\'\\n.*\'						{
	yylval.charlit = '\n'; return CHARLIT;
}
L?\'\\r.*\'						{
	yylval.charlit = '\r'; return CHARLIT;
}
L?\'\\t.*\'						{
	yylval.charlit = '\t'; return CHARLIT;
}
L?\'\\v.*\'						{
	yylval.charlit = '\v'; return CHARLIT;
}
L?\'\\\\.*\'					{
	yylval.charlit = '\\'; return CHARLIT;
}
L?\'\\\'.*\'					{
	yylval.charlit = '\''; return CHARLIT;
}
L?\'\\\".*\'					{
	yylval.charlit = '\"'; return CHARLIT;
}
L?\'\\\?.*\'					{
	yylval.charlit = '\?'; return CHARLIT;
}
L?\'\\x[0-9A-Fa-f]+.*\'			{
	if (yytext[0] == 'L') 
		yylval.charlit = strtol(yytext+2,NULL,16);
	else
		yylval.charlit = strtol(yytext+1,NULL,16);
	return CHARLIT;
}
L?\'\\[0-7][0-7][0-7].*\'		{
	if (yytext[0] == 'L')
		yylval.charlit = strtol(yytext+2,NULL,8);
	else
		yylval.charlit = strtol(yytext+1,NULL,8);
	return CHARLIT;
}
L?\'\\e.*\'						{
	yylval.charlit = '\e'; return CHARLIT;
}
L?\'[^\\\'\n].*\'				{
	if (yytext[0] == 'L') 
		yylval.charlit = yytext[2];
	else
		yylval.charlit = yytext[1]; 
	return CHARLIT;
}
L?\'.*\'						{
	return -1;
}

	/* String Literals */
L?\"							{
	BEGIN(instring); stringlen=0;
}

<instring>\\a					strbuff[stringlen++] = '\a';
<instring>\\b					strbuff[stringlen++] = '\b';
<instring>\\f					strbuff[stringlen++] = '\f';
<instring>\\n					strbuff[stringlen++] = '\n';
<instring>\\r					strbuff[stringlen++] = '\r';
<instring>\\t					strbuff[stringlen++] = '\t';
<instring>\\v					strbuff[stringlen++] = '\v';
<instring>\\0					strbuff[stringlen++] = '\0';
<instring>\\\\					strbuff[stringlen++] = '\\';
<instring>\\\'					strbuff[stringlen++] = '\'';
<instring>\\\"					strbuff[stringlen++] = '\"';
<instring>\\\?					strbuff[stringlen++] = '\?';
<instring>\\[0-7][0-7][0-7]		yytext[0] = '0'; strbuff[stringlen++] = strtol(yytext,NULL,8);
<instring>\\x[0-9A-Fa-f]+		yytext[0] = '0'; strbuff[stringlen++] = strtol(yytext,NULL,16);
<instring>\\e					strbuff[stringlen++] = '\e';
<instring>\\\n[ \n\t]*			/* Do nothing */
<instring>[^\\\"\n]				strbuff[stringlen++] = yytext[0];
<instring>\"					{
	strbuff[stringlen++] = '\0';
	yylval.string.string = malloc(stringlen);
	yylval.string.length = stringlen;
	memcpy(yylval.string.string,strbuff,stringlen);
	BEGIN(0);
	return STRING;
}
<instring>\n					BEGIN(0); return -1;
<instring><<EOF>>				BEGIN(0); return -1;
<instring>.						BEGIN(0); return -1;
	
	/* Identifiers */
[A-Za-z\_][A-Za-z0-9\_]*		{
	yylval.ident = malloc(strlen(yytext));
	memcpy(yylval.ident,yytext,strlen(yytext)+1);
	return IDENT;
}

[ \n\t]+						/* eat up whitespace */
.								return -1;
%%

#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

void main() {
	int yyret;
	yyin = fopen("kw.c","r");
	while ((yyret = yylex()) != TOKEOF) {
		if (yyret == NUMBER) {
			printf("NUMBER\t");
			switch (yylval.number.type) {
				case _CHAR:
					printf("char %hhd\n",yylval.number.value.c);
					break;
				case _UCHAR:
					printf("unsigned char%hhu\n",yylval.number.value.uc);
					break;
				case _SHORT:
					printf("short %hd\n",yylval.number.value.s);
					break;
				case _USHORT:
					printf("unsigned short%hu\n",yylval.number.value.us);
					break;
				case _INT:
					printf("int %d\n",yylval.number.value.i);
					break;
				case _UINT:
					printf("unsigned int %u\n",yylval.number.value.ui);
					break;
				case _LONG:
					printf("long %ld\n",yylval.number.value.l);
					break;
				case _ULONG:
					printf("unsigned long%lu\n",yylval.number.value.ul);
					break;
				case _LONGLONG:
					printf("long long %lld\n",yylval.number.value.ll);
					break;
				case _ULONGLONG:
					printf("unsigned long long %llu\n",yylval.number.value.ull);
					break;
				case _FLOAT:
					printf("float %f\n",yylval.number.value.f);
					break;
				case _DOUBLE:
					printf("double %f\n",yylval.number.value.d);
					break;
				case _LDOUBLE:
					printf("long double %Lf\n",yylval.number.value.ld);
					break;
			}
		}
		else if (yyret == CHARLIT) {
			printf("%c\n",yylval.charlit);
		}
		else if (yyret == STRING) {
			printf("%s\n",yylval.string.string);
		}
		else if (yyret == IDENT) {
			printf("IDENT\t%s\n",yylval.ident);
		}
		else if (yyret < 257 && yyret >= 0) {
			printf("%c\n",yyret);
		}
		else if (yyret == -1) {
			fprintf(stderr,"somethings wrong\n");
		}
		
		else
			printf("%d\n",yyret);
	}
}