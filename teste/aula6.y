%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int yylex();
void yyerror (char *s){
	printf("%s\n", s);
}

	typedef struct vars{
		char name[50];
		int valor;
		struct vars * prox;
	}VARS;
	
	//insere uma nova variável na lista de variáveis
	VARS * ins(VARS*l,char n[]){
		VARS*new =(VARS*)malloc(sizeof(VARS));
		strcpy(new->name,n);
		new->prox = l;
		return new;
	}
	
	//busca uma variável na lista de variáveis
	VARS *srch(VARS*l,char n[]){
		VARS*aux = l;
		while(aux != NULL){
			if(strcmp(n,aux->name)==0)
				return aux;
			aux = aux->prox;
		}
		return aux;
	}
	
	VARS*l1;
	int OK;
%}

%union{
	int inter;
	float flo;
	char str[50];
	}

%token <flo>NUM
%token <str>VAR
%token IF
%token ELSE
%token DECL
%token PRINT
%token FIM
%token INI
%left '+' '-'
%left '*' '/'
%right '^'
%right NEG
%type <flo> exp
%type <flo> valor
%type <inter> teste
%nonassoc IFX

%%
prog: INI cod FIM
	;

cod: cod cmdos
	|
	;

cmdos: DECL VAR	{
					VARS * aux = srch(l1,$2);
					if (aux == NULL)
						l1 = ins(l1,$2);
					else
						printf ("Redeclaração de variável: %s\n",$2);
				 	 }
	|
	PRINT '(' exp ')' {
						if (OK == 1){ //regra só executada com permissão (true)
						printf ("%.2f \n",$3);
						}}
	| VAR '=' exp {
					if (OK == 1){ //regra só executada com permissão (true)
					VARS * aux = srch(l1,$1);
					if (aux == NULL)
						printf ("Variável não declarada: %s\n",$1);
					else
						aux -> valor = $3;
					}
		}
	| IF '(' teste ')' cmdos %prec IFX
							
	| IF '(' teste ')' cmdosif ELSE cmdos
							
	| '{' cmdos_lst '}'	{
							OK = 1;//voltando a true após lista de comandos
						}
	;
	
cmdosif:
	 '{' cmdos_lst '}' {
			if(OK==1) OK=0; //controlando true/false para o ELSE
			else OK=1;
			}
	;
cmdos_lst:
		cmdos
	|	cmdos_lst cmdos
	;
	
exp: exp '+' exp {$$ = $1 + $3;}
	|exp '-' exp {$$ = $1 - $3;}
	|exp '*' exp {$$ = $1 * $3;}
	|exp '/' exp {$$ = $1 / $3;}
	|'(' exp ')' {$$ = $2;}
	|exp '^' exp {$$ = pow($1,$3);}
	|'-' exp %prec NEG {$$ = -$2;}
	|valor {$$ = $1;}
	|VAR {
			VARS * aux = srch (l1,$1);
			if (aux == NULL)
				printf ("Variável não declarada: %s\n",$1);
			else
				$$ = aux->valor;
			}
	;

valor: NUM {$$ = $1;}
	;

teste: exp '<' exp {
					if ($1 < $3) OK = 1;//true
					else OK = 0;//false
					}
	;

%%

#include "lex.yy.c"

int main(){
	OK = 1; //para marvar true ou false
	l1 = NULL;
	yyin=fopen("entrada.txt","r");
	yyparse();
	yylex();
	fclose(yyin);
return 0;
}
