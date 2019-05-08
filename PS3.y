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

  enum stgClass {
  	_AUTO,
  	_STATIC,
  	_EXTERN,
  	_STATIC
  };

  enum typeQual {
  	_CONST,
  	_VOLATILE
  };

  enum types {
  	_SCALAR,
  	_POINTER,
  	_ARRAY,
  };

  struct astnode_variable {
  	int nodetype;
  	union astnode * next;
  	char * name;
  	int stgclass;
  	int type_qual;
  	int type;
  	union astnode * type;
  };

  struct astnode_pointer {
  	int nodetype;
  	union astnode * next;
  	union astnode * deref;
  };

  struct astnode_func {
    int nodetype;
    union astnode * next;
    char * name;
    struct symtab * s;
    struct symtab * inputs;
  };

  struct astnode_ary {
  	int nodetype;
  	union astnode * next;
  	int size;
  	struct astnode_pointer * self; //pointer to self; use for pointer casts
  	union astnode * stg;
  };

  struct astnode_scalar {
  	int nodetype;
  	union astnode * next;
  	int type;
  };

  struct astnode_ident{
  	int nodetype;
  	union astnode * next;
  	char* name;
  };

  union astnode {
  	struct astnode_generic {int nodetype;union astnode * next;} generic;
  	struct astnode_ident ident;
  	struct astnode_variable var;
  	struct astnode_pointer ptr;
  	struct astnode_func fn;
  	struct astnode_array ary;
  	struct astnode_scalar scalar;
  };

  enum types {
  	_IDENT,
  	_VAR,
  	_PTR,
  	_FN,
  	_ARY,
  	_SCALAR;
  };


  union astnode * astnode_alloc(int type) {
  	union astnode * retval=malloc(sizeof(union astnode));
  	retval->generic.nodetype = type;
  	retval->next = NULL;
  	return retval;
  };

  union astnode * global = NULL;
  union astnode * currentScope = NULL;
  union astnode * head = NULL;
  union astnode * tail = NULL;
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

%token IDENT NUMBER CHARLIT STRING SIZEOF
%token INDSEL PLUSPLUS MINUSMINUS SHL SHR LTEQ GTEQ EQEQ NOTEQ
%token LOGAND LOGOR TIMESEQ DIVEQ MODEQ ADDEQ
%token SUBEQ SHLEQ SHREQ ANDEQ
%token XOREQ OREQ

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start declaration;

%type<token> storage_class_specifier type_specifier
%type<a> declaration declaration_specifiers init_declarator_list init_declarator struct_or_union_specifier struct_declaration_list struct_declaration specifier_qualifier_list struct_declarator_list  enum_specifier enumerator_list enumerator declarator direct_declarator pointer type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name abstract_declarator direct_abstract_declarator initializer initializer_list statement labeled_statement compound_statement declaration_list statement_list selection_statement iteration_statement jump_statement translation_unit external_declaration function_definition

%%


declaration
	: declaration_specifiers ';'						{ast[length++]=$1;}				
	| declaration_specifiers init_declarator_list ';'	{ast[length++]=$2;}					
	;

declaration_specifiers
	: storage_class_specifier							{$$=$1;}
	| storage_class_specifier declaration_specifiers	{$$}
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
	: declarator 											{$$=$1;}
	;

storage_class_specifier
	: EXTERN 												{$$=EXTERN;}
	| STATIC												{$$=STATIC;}
	| AUTO													{$$=AUTO;}
	| REGISTER												{$$=REGISTER;}
	;

type_specifier
	: VOID 													{$$=VOID;}
	| CHAR 													{$$=CHAR;}
	| SHORT 												{$$=SHORT;}
	| INT 													{$$=INT;}
	| LONG 													{$$=LONG;}
	| FLOAT 												{$$=FLOAT;}
	| DOUBLE 												{$$=DOUBLE;}
	| SIGNED 												{$$=SIGNED;}
	| UNSIGNED 												{$$=UNSIGNED;}
	;


specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

type_qualifier
	: CONST 												{$$=CONST;}
	| VOLATILE 												{$$=VOLATILE;}
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

direct_declarator
	: IDENT 												{
																$$=astnode_alloc(_IDENT);
																union astnode *n=$$;
																n->ident.name = $1;
															}						
	| '(' declarator ')'									{$$=$2;}				
	| direct_declarator '[' ']'								{

															}
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

yyerror(s)
char *s;
{
	fflush(stdout);
}
