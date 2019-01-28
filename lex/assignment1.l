import "tokens-manual.h"

typedef union {
	long integer;
	double real;
	char * string;
	char charlit;
	char * ident;
	_Bool bool;
	_Complex complex;
} YYSTYPE;

extern YYSTYPE yylval;

%%

