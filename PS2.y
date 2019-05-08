%{
  #include <stdlib.h>
  #include <stdio.h>
  
  int yyerror(char *s);
  int yylex(void);
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
  enum constant_types {
  	_NUM,
  	_CHARLIT,
  	_STRING,
  };
  struct NUM {
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
  };
  struct STR {
    unsigned int length;
    char * string;
  };
  int yyerror(char *s);
  int yylex(void);

  union constant {
	struct NUM number;
	struct STR string;
	char charlit;
  };

  struct astnode_binop {
  	int nodetype;
  	int operator;
  	union astnode *left,*right;
  };

  struct astnode_const {
  	int nodetype;
  	int type;
  	union constant value;
  };

  struct astnode_ident{
  	int nodetype;
  	char* name;
  };

  struct astnode_unop{
  	int nodetype;
  	int operator;
  	union astnode *middle;
  } ;

  struct astnode_triop{
  	int nodetype;
  	union astnode *left,*middle,*right;
  } ;

  union astnode {
  	struct astnode_generic {int nodetype;} generic;
  	struct astnode_binop binop;
  	struct astnode_const constant;
  	struct astnode_ident ident;
  	struct astnode_unop unop;
  	struct astnode_triop triop;
  };

  enum types {
  	_BINOP,
  	_CONSTANT,
  	_IDENT,
  	_POINTER,
  	_ARRAY,
  	_FUNCCALL,
  	_UNOP,
  	_TRIOP
  };


  union astnode * astnode_alloc(int type) {
  	union astnode * retval=malloc(sizeof(union astnode));
  	retval->generic.nodetype = type;
  	return retval;
  };

  union astnode * ast[1024];
  int length;

  void parse_ast(union astnode * ast,int depth) {
    char tabs[depth+1];
    for (int i=0;i<depth;++i) {
    	tabs[i] = '\t';
    }
    tabs[depth] = '\0';
  	switch (ast->generic.nodetype) {
  		case _CONSTANT:
  			switch (ast->constant.type) {
  				case _NUM:
  					switch (ast->constant.value.number.type) {
  						case _CHAR:
  							printf("%scharacter %hhd\n",tabs,ast->constant.value.number.value.c);
  							break;
  						case _UCHAR:
  							printf("%sunsigned character %hhu\n",tabs,ast->constant.value.number.value.c);
  							break;
  						case _SHORT:
  							printf("%sshort %hd\n",tabs,ast->constant.value.number.value.s);
  							break;
  						case _USHORT:
  							printf("%sunsigned short %hu\n",tabs,ast->constant.value.number.value.s);
  							break;
  						case _INT:
  							printf("%sint %d\n",tabs,ast->constant.value.number.value.i);
  							break;
						case _UINT:
							printf("%sunsigned int %u\n",tabs,ast->constant.value.number.value.i);
  							break;
						case _LONG:
							printf("%slong %ld\n",tabs,ast->constant.value.number.value.l);
  							break;
						case _ULONG:
							printf("%sunsigned long %lu\n",tabs,ast->constant.value.number.value.l);
  							break;
						case _LONGLONG:
							printf("%slong long %lld\n",tabs,ast->constant.value.number.value.ll);
  							break;
						case _ULONGLONG:
							printf("%sunsigned long long %llu\n",tabs,ast->constant.value.number.value.ll);
  							break;
						case _FLOAT:
							printf("%sfloat %f\n",tabs,ast->constant.value.number.value.f);
  							break;
						case _DOUBLE:
							printf("%sdouble %f\n",tabs,ast->constant.value.number.value.d);
  							break;
						case _LDOUBLE:
							printf("%sdouble %Lf\n",tabs,ast->constant.value.number.value.ld);
  							break;
  					}
  					break;
  				case _CHARLIT:
  					printf("%scharacter %hhd\n",tabs,ast->constant.value.charlit);
  					break;
  				case _STRING:
  					printf("%sstring ",tabs);
  					for (int i=0;i<ast->constant.value.string.length;++i)
  						printf("%c",ast->constant.value.string.string[i]);
  					printf("\n");
  					break;

  			}
  			break;
  		case _IDENT:
  			printf("%sident %s\n",tabs,ast->ident.name);
  			break;
  		case _UNOP:
  			printf("%sunary operator %d\n",tabs,ast->unop.operator);
  			parse_ast(ast->unop.middle,depth+1);
  			break;
  		case _BINOP:
  			printf("%sbinary operator %d\n",tabs,ast->binop.operator);
  			parse_ast(ast->binop.left,depth+1);
  			parse_ast(ast->binop.right,depth+1);
  			break;
  		case _TRIOP:
  			printf("%sternary operator\n",tabs);
  			parse_ast(ast->triop.left,depth+1);
  			parse_ast(ast->triop.middle,depth+1);
  			parse_ast(ast->triop.right,depth+1);		
  			break;
  	}
  }
%}

%union {
	union astnode * a;
	struct NUM number;
	struct STR string;
	char charlit;
	int token;
	char * ident;
}

%token IDENT CHARLIT STRING NUMBER SIZEOF
%token INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ
%token LOGAND LOGOR TIMESEQ DIVEQ MODEQ ADDEQ
%token SUBEQ SHLEQ SHREQ ANDEQ
%token XOREQ OREQ

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start ROOT

%type <token> '&' '*' '+' '-' '~' '!' '='
%type <ident> IDENT 
%type <number> NUMBER 
%type <charlit> CHARLIT 
%type <string> STRING 
%type <token> SIZEOF INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ
%type <token> LOGAND LOGOR TIMESEQ DIVEQ MODEQ ADDEQ
%type <token> SUBEQ SHLEQ SHREQ ANDEQ
%type <token> XOREQ OREQ
%type <token> TYPEDEF EXTERN STATIC AUTO REGISTER
%type <token> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%type <token> STRUCT UNION ENUM ELLIPSIS
%type <token> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%type <token> unary_operator assignment_operator
%type <a> primary_expression postfix_expression argument_expression_list unary_expression cast_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression and_expression exclusive_or_expression inclusive_or_expression logical_and_expression logical_or_expression conditional_expression assignment_expression expression ROOT

%%

primary_expression
	: IDENT 				{
								$$=astnode_alloc(_IDENT);
								union astnode *n=$$;
								n->ident.name = $1;
							}
	| NUMBER 				{
								$$=astnode_alloc(_CONSTANT);
								union astnode *n=$$;
								n->constant.type=_NUM;
								n->constant.value.number=$1;
							}
	| CHARLIT 				{
								$$=astnode_alloc(_CONSTANT);
								union astnode *n=$$;
								n->constant.type=_CHARLIT;
								n->constant.value.charlit=$1;	
							}
	| STRING 				{
								$$=astnode_alloc(_CONSTANT);
								union astnode *n=$$;
								n->constant.type=_STRING;
								n->constant.value.string=$1;
							}
	| '(' expression ')'	{
								$$=$2;
							}
	;

postfix_expression
	: primary_expression									{
																$$=$1;
															}
	| postfix_expression '[' expression ']'					{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='+';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| postfix_expression '(' ')'							

	| postfix_expression '(' argument_expression_list ')'	/* get this working later */

	| postfix_expression '.' IDENT 							{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='.';
																n->binop.left=$1;
																n->binop.right=astnode_alloc(_IDENT);
																n->binop.right->ident.name=$3;
															}
	| postfix_expression INDSEL IDENT 						{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=INDSEL;
																n->binop.left=$1;
																n->binop.right=astnode_alloc(_IDENT);
																n->binop.right->ident.name=$3;
															}
	| postfix_expression PLUSPLUS							{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='=';
																n->binop.left=$1;
																n->binop.right=astnode_alloc(_BINOP);
																n->binop.right->binop.operator='+';
																n->binop.right->binop.left=$1;
																n->binop.right->binop.right=astnode_alloc(_CONSTANT);
																n->binop.right->binop.right->constant.type=_NUM;
																n->binop.right->binop.right->constant.value.number.type=_INT;
																n->binop.right->binop.right->constant.value.number.value.i=1;

															}
	| postfix_expression MINUSMINUS							{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='=';
																n->binop.left=$1;
																n->binop.right=astnode_alloc(_BINOP);
																n->binop.right->binop.operator='-';
																n->binop.right->binop.left=$1;
																n->binop.right->binop.right=astnode_alloc(_CONSTANT);
																n->binop.right->binop.right->constant.type=_NUM;
																n->binop.right->binop.right->constant.value.number.type=_INT;
																n->binop.right->binop.right->constant.value.number.value.i=1;

															}
	;

argument_expression_list
	: assignment_expression									{
																$$=$1;
															}
	| argument_expression_list ',' assignment_expression	{
																$$=$1;
															}
	;

unary_expression
	: postfix_expression
	| PLUSPLUS unary_expression								{
																$$=astnode_alloc(_UNOP);
																union astnode *n=$$;
																n->unop.operator=PLUSPLUS;
																n->unop.middle=$2;
															}
	| MINUSMINUS unary_expression							{
																$$=astnode_alloc(_UNOP);
																union astnode *n=$$;
																n->unop.operator=MINUSMINUS;
																n->unop.middle=$2;
															}
	| unary_operator cast_expression 						{
																$$=astnode_alloc(_UNOP);
																union astnode *n=$$;
																n->unop.operator=$1;
																n->unop.middle=$2;
															}
	| SIZEOF unary_expression 								{
																$$=astnode_alloc(_UNOP);
																union astnode *n=$$;
																n->unop.operator=SIZEOF;
																n->unop.middle=$2;
															}
	/*| SIZEOF '(' type_name ')'								{
																$$=astnode_alloc(_UNOP);
																union astnode *n=$$;
																n->unop.operator=SIZEOF;
																n->unop.middle=$3;
															}*/
	;

unary_operator
	: '&'													{$$='&';}
	| '*'													{$$='*';}
	| '+'													{$$='+';}
	| '-'													{$$='-';}
	| '~'													{$$='~';}
	| '!'													{$$='!';}
	;

cast_expression
	: unary_expression										{$$=$1;}
	/*| '(' type_name ')' cast_expression 					{
																$$=astnode_alloc(_UNOP);
																union astnode *n=$$;
																n->unop.operator=$2;
																n->unop.middle=$4;
															}*/
	;

multiplicative_expression
	: cast_expression 										{$$=$1;}
	| multiplicative_expression '*' cast_expression 		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='*';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| multiplicative_expression '/' cast_expression 		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='*';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| multiplicative_expression '%' cast_expression 		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='%';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

additive_expression
	: multiplicative_expression								{$$=$1;}
	| additive_expression '+' multiplicative_expression		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='+';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| additive_expression '-' multiplicative_expression		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='-';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

shift_expression
	: additive_expression									{$$=$1;}
	| shift_expression SHL additive_expression				{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=SHL;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| shift_expression SHR additive_expression				{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=SHR;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

relational_expression	
	: shift_expression										{$$=$1;}
	| relational_expression '<' shift_expression			{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='<';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| relational_expression '>' shift_expression			{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='>';
																n->binop.left=$1;
																n->binop.right=$3;
															}	
	| relational_expression LTEQ shift_expression			{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=LTEQ;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| relational_expression GTEQ shift_expression			{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=GTEQ;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

equality_expression
	: relational_expression									{$$=$1;}
	| equality_expression EQEQ relational_expression		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=EQEQ;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	| equality_expression NOTEQ relational_expression		{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=NOTEQ;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

and_expression
	: equality_expression									{$$=$1;}
	| and_expression '&' equality_expression				{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='&';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

exclusive_or_expression
	: and_expression  										{$$=$1;}
	| exclusive_or_expression '^' and_expression 			{
																$$=astnode_alloc(_BINOP);
																union astnode*n=$$;
																n->binop.operator='^';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

inclusive_or_expression
	: exclusive_or_expression								{$$=$1;}
	| inclusive_or_expression '|' exclusive_or_expression	{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator='|';
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

logical_and_expression
	: inclusive_or_expression								{$$=$1;}
	| logical_and_expression LOGAND inclusive_or_expression	{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=LOGAND;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

logical_or_expression
	: logical_and_expression								{$$=$1;}
	| logical_or_expression LOGOR logical_and_expression	{
																$$=astnode_alloc(_BINOP);
																union astnode *n=$$;
																n->binop.operator=LOGOR;
																n->binop.left=$1;
																n->binop.right=$3;
															}
	;

conditional_expression
	: logical_or_expression												{$$=$1;}
	| logical_or_expression '?' expression ':' conditional_expression	{
																			$$=astnode_alloc(_TRIOP);
																			union astnode *n=$$;
																			n->triop.left=$1;
																			n->triop.middle=$3;
																			n->triop.right=$5;
																		}
	;

assignment_expression
	: conditional_expression											{$$=$1;}
	| unary_expression assignment_operator assignment_expression		{
																			$$=astnode_alloc(_BINOP);
																			union astnode *n=$$;
																			n->binop.operator=$2;
																			n->binop.left=$1;
																			n->binop.right=$3;
																		}
	;

assignment_operator
	: '='																{$$='=';}
	| TIMESEQ															{$$=TIMESEQ;}
	| DIVEQ																{$$=DIVEQ;}
	| MODEQ																{$$=MODEQ;}
	| ADDEQ																{$$=ADDEQ;}
	| SUBEQ																{$$=SUBEQ;}
	| SHLEQ																{$$=SHLEQ;}
	| SHREQ																{$$=SHREQ;}
	| ANDEQ																{$$=ANDEQ;}
	| XOREQ																{$$=XOREQ;}
	| OREQ																{$$=OREQ;}
	;

expression
	: assignment_expression												{	
																			$$=$1;
																		}
	| expression ',' assignment_expression								{
																			$$=astnode_alloc(_BINOP);
																			union astnode *n=$$;
																			n->binop.operator=',';
																			n->binop.left=$1;
																			n->binop.right=$3;
																		}
	;

ROOT
	: expression ';'			{
								ast[length++] = $1;
							}
	| ROOT expression ';'	{	 
								ast[length++] = $2;
							}
	;



%%
#include <stdio.h>

extern char yytext[];
extern int column;

int yyerror(s)
char *s;
{
	fflush(stdout);
	printf("error\n");
	return 0;
}

int main() {
	yyparse();
	for (int i=0;i<length;++i) {
		parse_ast(ast[i],0);
		printf("==============\n");
	}
	

}
