%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
 
typedef struct ast {
	int nodetype;
	struct ast *l;
	struct ast *r;
}Ast; 

typedef struct numval {
	int nodetype;
	double number;
}Numval;

Ast * newast(int nodetype, Ast *l, Ast *r){

	Ast *a = (Ast*) malloc(sizeof(Ast));
	if(!a) {
		printf("out of space");
		exit(0);
	}
	a->nodetype = nodetype;
	a->l = l;
	a->r = r;
	return a;
}
 
Ast * newnum(double d) {
	Numval *a = (Numval*) malloc(sizeof(Numval));
	if(!a) {
		printf("out of space");
		exit(0);
	}
	a->nodetype = 'K';
	a->number = d;
	return (Ast*)a;
}

double eval(Ast *a) {
	double v; 
	switch(a->nodetype) {
		case 'K': v = ((struct numval *)a)->number; break;
		case '+': v = eval(a->l) + eval(a->r); break;
		case '-': v = eval(a->l) - eval(a->r); break;
		case '*': v = eval(a->l) * eval(a->r); break;
		case '/': v = eval(a->l) / eval(a->r); break;
		case '|': v = eval(a->l); if(v < 0) v = -v; break;
		case 'M': v = -eval(a->l); break;
		default: printf("internal error: bad node %c\n", a->nodetype);
	}
	return v;
}

void treefree(Ast *a) {
		switch(a->nodetype) {
		/* two subtrees */
			case '+':
			case '-':
			case '*':
			case '/':
			treefree(a->r);
		/* one subtree */
			case '|':
			case 'M':
			treefree(a->l);
		/* no subtree */
			case 'K':
				free(a);
				break;
	}
}

int yylex();
void yyerror (char *s){
	printf("%s\n", s);
}

%}

%union{
	float flo;
	Ast *a;
	}

%token <flo>NUM
%token FIM
%left '+' '-'
%left '*' '/'
%right '^'
%right NEG
%type <a> exp

%%



val: exp FIM {
		printf ("Resultado: %.2f \n",eval($1));
	}
	;

exp: exp '+' exp {$$ = newast('+',$1,$3);}
	|exp '-' exp {$$ = newast('-',$1,$3);}
	|exp '*' exp {$$ = newast('*',$1,$3);}
	|exp '/' exp {$$ = newast('/',$1,$3);}
	|'(' exp ')' {$$ = $2;}
	|'-' exp %prec NEG {$$ = newast('M',$2,NULL);}
	|NUM {$$ = newnum($1);}
	;

%%

#include "lex.yy.c"

int main(){
	yyin=fopen("entrada.txt","r");
	yyparse();
	yylex();
	fclose(yyin);
return 0;
}
