%{
  #include "tokens_manual.h"
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
  typedef struct {
    unsigned int length;
    char * string;
  } STR;
  int yyerror(char *s);
  int yylex(void);

  typedef union {
	NUM number;
	STR string;
	char charlit;
} constant;

  union astnode {
  	struct astnode_generic {int nodetype;} generic;
  	struct astnode_binop binop;
  	struct astnode_const constant;
  	struct astnode_ident ident;
  	struct astnode_pointer pointer;
  	struct astnode_array array;
  	struct astnode_function funccall;
  	struct astnode_unop unop;
  	struct astnode_triop triop;
  }

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

  enum constanttypess {
  	_NUM;
  	_CHARLIT;
  	_STRING;
  };

  typedef struct {
  	int nodetype;
  	int operator;
  	union astnode *left,*right;
  } astnode_binop;

  typdef struct {
  	int nodetype;
  	int type;
  	union constant value;
  } astnode_const;

  typedef struct {
  	int nodetype;
  	char* name;
  } astnode_ident;

  typedef struct {
  	int nodetype;
  	int type;
  	union astnode * pointsTo;
  } astnode_pointer;

  typedef struct {
  	int nodetype;
  	int type;
  	int size;
  	union astnode * pointsTo;
  } astnode_array;

  typedef struct {
  	int nodetype;
  	int argc;
  	union astnode * argv; 
  } astnode_funccall;

  typedef struct {
  	int nodetype;
  	int operator;
  	union astnode *middle;
  } astnode_unop;

  typedef struct {
  	int nodetype;
  	union astnode *left,*middle,*right;
  } astnode_triop;

  astnode * astnode_alloc(int type) {
  	union astnode * retval=malloc(sizeof(union astnode));
  	retval.nodetype = type;
  	return retval;
  }

  astnode ast[1024];
  int length;
%}

%union {
	union astnode * a;
	struct NUM number;
	struct STR string;
	char charlit;
	int token;
}

%token IDENT NUMBER CHARLIT STRING SIZEOF
%token INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ
%token LOGAND LOGOR TIMESEQ DIVEQ MODEQ ADDEQ
%token SUBEQ SHLEQ SHREQ ANDEQ
%token XOREQ OREQ

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit
%%

primary_expression
	: IDENT 				{
								$$=astnode_alloc(_IDENT);
								struct astnode_ident *n=$$;
								n->name = $1;
							}
	| NUMBER 				{
								$$=astnode_alloc(_CONSTANT);
								struct astnode_ident *n=$$;
								n->type=_NUM;
								n->value=$1;
							}
	| CHARLIT 				{
								$$=astnode_alloc(_CONSTANT);
								struct astnode_ident *n=$$;
								n->type=_CHARLIT;
								n->value=$1;	
							}
	| STRING 				{
								$$=astnode_alloc(_CONSTANT);
								struct astnode_ident *n=$$;
								n->type=_STRING;
								n->value=$1;	
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
																struct astnode_binop *n=$$;
																n->operator='+';
																n->left=$1;
																n->right=$3
															}
	| postfix_expression '(' ')'							{
																$$=astnode_alloc(_FUNCCALL);
																struct astnode_funccall *n=$$;
																n->argc=0;																	
															}
	| postfix_expression '(' argument_expression_list ')'	{
																$$=astnode_alloc(_FUNCCALL);
																struct astnode_funccall *n=$$;
																n->argc=0;
																/* get this working later */
															}
	| postfix_expression '.' IDENT 							{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='.';
																n->left=$1;
																n->right=$3;
															}
	| postfix_expression INDSEL IDENT 						{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=INDSEL;
																n->left=$1;
																n->right=$3;
															}
	| postfix_expression PLUSPLUS							{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='=';
																n->left=$1;
																n->right=astnode_alloc(_BINOP);
																n->right->operator='+';
																n->right->left=$1;
																n->right->right=1;
															}
	| postfix_expression MINUSMINUS							{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='=';
																n->left=$1;
																n->right=astnode_alloc(_BINOP);
																n->right->operator='-';
																n->right->left=$1;
																n->right->right=1;
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
																struct astnode_unop *n=$$;
																n->operator=PLUPLUS;
																n->middle=$2;
															}
	| MINUSMINUS unary_expression							{
																$$=astnode_alloc(_UNOP);
																struct astnode_unop *n=$$;
																n->operator=MINUSMINUS;
																n->middle=$2;
															}
	| unary_operator cast_expression 						{
																$$=astnode_alloc(_UNOP);
																struct astnode_unop *n=$$;
																n->operator=$1;
																n->middle=$2;
															}
	| SIZEOF unary_expression 								{
																$$=astnode_alloc(_UNOP);
																struct astnode_unop *n=$$;
																n->operator=SIZEOF;
																n->middle=$2;
															}
	| SIZEOF '(' type_name ')'								{
																$$=astnode_alloc(_UNOP);
																struct astnode_unop *n=$$;
																n->operator=SIZEOF;
																n->middle=$3;
															}
	;

unary_operator
	: '&'													{$$=$1;}
	| '*'													{$$=$1;}
	| '+'													{$$=$1;}
	| '-'													{$$=$1;}
	| '~'													{$$=$1;}
	| '!'													{$$=$1;}
	;

cast_expression
	: unary_expression										{$$=$1;}
	| '(' type_name ')' cast_expression 					{
																$$=astnode_alloc(_UNOP);
																struct astnode_unop *n=$$;
																n->operator=$2;
																n->middle=$4;
															}
	;

multiplicative_expression
	: cast_expression 										{$$=$1;}
	| multiplicative_expression '*' cast_expression 		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='*';
																n->left=$1;
																n->right=$3;
															}
	| multiplicative_expression '/' cast_expression 		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='*';
																n->left=$1;
																n->right=$3;
															}
	| multiplicative_expression '%' cast_expression 		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='%';
																n->left=$1;
																n->right=$3;
															}
	;

additive_expression
	: multiplicative_expression								{$$=$1;}
	| additive_expression '+' multiplicative_expression		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='+';
																n->left=$1;
																n->right=$3;
															}
	| additive_expression '-' multiplicative_expression		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='-';
																n->left=$1;
																n->right=$3;
															}
	;

shift_expression
	: additive_expression									{$$=$1;}
	| shift_expression SHL additive_expression				{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=SHL;
																n->left=$1;
																n->right=$3;
															}
	| shift_expression SHR additive_expression				{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=SHR;
																n->left=$1;
																n->right=$3;
															}
	;

relational_expression	
	: shift_expression										{$$=$1;}
	| relational_expression '<' shift_expression			{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='<';
																n->left=$1;
																n->right=$3;
															}
	| relational_expression '>' shift_expression			{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='>';
																n->left=$1;
																n->right=$3;
															}	
	| relational_expression LTEQ shift_expression			{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=LTEQ;
																n->left=$1;
																n->right=$3;
															}
	| relational_expression GTEQ shift_expression			{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=GTEQ;
																n->left=$1;
																n->right=$3;
															}
	;

equality_expression
	: relational_expression									{$$=$1;}
	| equality_expression EQEQ relational_expression		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=EQEQ;
																n->left=$1;
																n->right=$3;
															}
	| equality_expression NOTEQ relational_expression		{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=NOTEQ;
																n->left=$1;
																n->right=$3;
															}
	;

and_expression
	: equality_expression									{$$=$1;}
	| and_expression '&' equality_expression				{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='&';
																n->left=$1;
																n->right=$3;
															}
	;

exclusive_or_expression
	: and_expression  										{$$=$1;}
	| exclusive_or_expression '^' and_expression 			{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='^';
																n->left=$1;
																n->right=$3;
															}
	;

inclusive_or_expression
	: exclusive_or_expression								{$$=$1;}
	| inclusive_or_expression '|' exclusive_or_expression	{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator='|';
																n->left=$1;
																n->right=$3;
															}
	;

logical_and_expression
	: inclusive_or_expression								{$$=$1;}
	| logical_and_expression LOGAND inclusive_or_expression	{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=LOGAND;
																n->left=$1;
																n->right=$3;
															}
	;

logical_or_expression
	: logical_and_expression								{$$=$1;}
	| logical_or_expression LOGOR logical_and_expression	{
																$$=astnode_alloc(_BINOP);
																struct astnode_binop *n=$$;
																n->operator=LOGOR;
																n->left=$1;
																n->right=$3;
															}
	;

conditional_expression
	: logical_or_expression												{$$=$1;}
	| logical_or_expression '?' expression ':' conditional_expression	{
																			$$=astnode_alloc(_TRIOP);
																			struct astnode_triop *n=$$;
																			n->left=$1;
																			n->middle=$3;
																			n->right=$5;
																		}
	;

assignment_expression
	: conditional_expression											{$$=$1;}
	| unary_expression assignment_operator assignment_expression		{
																			$$=astnode_alloc(_BINOP);
																			struct astnode_binop *n=$$;
																			n->operator=$2;
																			n->left=$1;
																			n->right=$3;
																		}
	;

assignment_operator
	: '='																{$$=$1;}
	| TIMESEQ															{$$=$1;}
	| DIVEQ																{$$=$1;}
	| MODEQ																{$$=$1;}
	| ADDEQ																{$$=$1;}
	| SUBEQ																{$$=$1;}
	| SHLEQ																{$$=$1;}
	| SHREQ																{$$=$1;}
	| ANDEQ																{$$=$1;}
	| XOREQ																{$$=$1;}
	| OREQ																{$$=$1;}
	;

expression
	: assignment_expression												{$$=$1;}
	| expression ',' assignment_expression								{
																			$$=astnode_alloc(_BINOP);
																			struct astnode_binop *n=$$;
																			n->operator=',';
																			n->left=$1;
																			n->right=$3;
																		}
	;

constant_expression
	: conditional_expression											{$$=$1;}
	;

declaration
	: declaration_specifiers ';'										
	| declaration_specifiers init_declarator_list ';'					
	;

declaration_specifiers
	: storage_class_specifier
	| storage_class_specifier declaration_specifiers
	| type_specifier
	| type_specifier declaration_specifiers
	| type_qualifier
	| type_qualifier declaration_specifiers
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

storage_class_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| struct_or_union_specifier
	| enum_specifier
	;

struct_or_union_specifier
	: struct_or_union IDENT '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENT
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENT '{' enumerator_list '}'
	| ENUM IDENT
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENT
	| IDENT '=' constant_expression
	;

type_qualifier
	: CONST
	| VOLATILE
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

direct_declarator
	: IDENT
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;

pointer
	: '*'
	| '*' type_qualifier_list
	| '*' pointer
	| '*' type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENT
	| identifier_list ',' IDENT
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENT ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;


statement
	: expression_statement;
	;
expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENT ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration						{ast[length++]=$1;}
	| translation_unit external_declaration		{
													ast[length++]=$1;
													ast[length++]=$2;
												}
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement
	;

%%
#include <stdio.h>

extern char yytext[];
extern int column;

yyerror(s)
char *s;
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
}
