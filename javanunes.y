%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "javanunesBib.c"

int yylex();
void yyerror (char *s){
	printf("%s\n", s);
}


%}
%union{
	float flo;
	int fn;
	int inter;
	Ast *a;
	char str[50];
	}

%token <flo>NUM
%token <str>VAR

%token INICIO
%token FIM 
%token IF 
%token ELSE
%token WHILE
%token ESCRITA
%token LEITURA
%token <fn> COMP
%right RAIZ
%right '='
%left '+' '-'
%left '*' '/'
%left '^'

%type <a> exp com_list comandos prog

%nonassoc IFX NEG

%%

val: INICIO prog FIM
	;

prog: comandos 		{eval($1);}  
	| prog comandos {eval($2);}	
	;
	
comandos: IF '(' exp ')' '{' com_list '}' %prec IFX {$$ = newflow('I', $3, $6, NULL);}
		| IF '(' exp ')' '{' com_list '}' ELSE '{' com_list '}' {$$ = newflow('I', $3, $6, $10);}
		| WHILE '(' exp ')' '{' com_list '}' {$$ = newflow('W', $3, $6, NULL);}
		| VAR '=' exp {insertList(com_list, $1); $$ = newasgn($1,$3);}
		| ESCRITA '(' exp ')' { $$ = newast('P',$3,NULL);}	
		| LEITURA '(' VAR ')' { $$ = newLeitura($3);}	
		;

com_list: comandos{$$ = $1;}
		| com_list comandos { $$ = newast('L', $1, $2);	}
		;
	
exp: 
	 exp '+' exp {$$ = newast('+',$1,$3);}		
	|exp '-' exp {$$ = newast('-',$1,$3);}
	|exp '*' exp {$$ = newast('*',$1,$3);}
	|exp '/' exp {$$ = newast('/',$1,$3);}
	|exp '^' exp {$$ = newast('^',$1,$3);}
	|RAIZ exp {$$ = newast('@', $2,NULL);}
	|exp COMP exp {$$ = newcmp($2,$1,$3);}		
	|'(' exp ')' {$$ = $2;}
	|'-' exp %prec NEG {$$ = newast('M',$2,NULL);}
	|NUM {$$ = newnum($1);}						
	|VAR {$$ = newValorVal($1);}		
	;

%%

#include "lex.yy.c"

int main(){
	com_list = malloc(sizeof(struct estr));
	yyin=fopen("javanunes","r");
	yyparse();
	yylex();
	fclose(yyin);
return 0;
}

