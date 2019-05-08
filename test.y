%{
    #include <iostream>
    int yylex();
    void yyerror(const char*);
%}


%union
{
    char    name[100];
    int     val;
}

%token NUM ID
%right '='
%left '+' '-'
%left '*'

%type<val> exp NUM
%type<name> ID

%%

exp :   NUM     {$$ = $1;}
    | ID        {$$ = vars[$1];}
    | exp '+' exp   {$$ = $1 + $3;}
    | ID '=' exp    {$$ = vars[$1] = $3;}
;

%%