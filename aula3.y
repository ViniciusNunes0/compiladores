%{
    #include <stdio.h>
    #include <math.h>
    #include <stdlib.h>
    #include <string.h>
    
    int yylex();
    void yyerror(char *s){
        printf("Error: %s\n", s);
    }
    
    typedef struct vars {
        char nome[50];
        float valor;
        struct vars *next;
    }Vars;

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
		case '^': v = pow(eval(a->l) , eval(a->r)); break;
		case '@': v = sqrt(eval(a->l)); break;

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
			case'^':
			case '@':
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

    Vars *lista = NULL;
    
    int err = 0;
    
    Vars *buscaVars(Vars *l, char str[]){
        Vars *list;
        for(list = l; list != NULL; list = list->next){
            if(strcmp(list->nome, str) == 0){
                return list;
            }
        }
        return NULL;        
    }
    
    Vars *insereLista( Vars *l, char c[]){
        Vars *nova = (Vars*)malloc(sizeof(Vars));
        strcpy(nova->nome, c);
        nova->valor = 0;
        nova->next = l;
        return nova;      
    }

    Vars* l1;
    int OK;
    
%}
%union {
    float real;
    int inte;
    char str[50];
    
    Ast *a;
}

%token INICIO
%token FIM
%token OPERACAOARI
%token <real> REAL
%token <str>VAR
%token <str>TIPO
%token LEITURA
%token ESCRITA
%token IF
%token ELSE
%token MAIOR
%token MENOR
%token IGUAL
%token MAIORIGUAL
%token MENORIGUAL
%token IGUALIQUAL
%token DIFERENTE
%token E
%token OU
%left '+' '-'
%left '*' '/'
%right '^'
%right '@'
%right NEG
%type <a> exp
%type <real> valor
%type <inte> cond
%nonassoc IFX
%%

prog: INICIO cod FIM
    ;

cod: cod cmdos
    |
    ;
    
cmdos: ESCRITA '(' exp ')' {
        if(OK == 1){
            if (err != -1)
                printf ("%.2f \n",eval($3));
            err = 0;
        }
    }
	| TIPO VAR {
        if(OK == 1){
            Vars *aux = buscaVars(lista, $2);
            
            if(aux == NULL){
                lista = insereLista(lista, $2);   
            }else{
                printf("%s -> Variavel já Declarada!\n", $2);
            }
        }
    }    
    | TIPO VAR '=' exp {
         Vars *aux = buscaVars(lista, $2); 
        if(aux == NULL){
            lista = insereLista(lista, $2);  
            lista->valor = eval($4);
        }else{
            printf("%s -> Variavel já Declarada!\n", $2);
        }   
    }
    
    | VAR '=' exp {

       Vars *aux = buscaVars(lista, $1); 

       if(aux == NULL){
           printf("%s -> Variavel não está Declarada!\n", $1);
           
       }else{
            aux->valor = eval($3);
       }
    }
    | LEITURA '(' VAR ')' {
        
        Vars *busca = buscaVars(lista, $3); 

       if(busca == NULL){
           printf("%s -> Variavel não está Declarada!\n", $3);
       }else{
           scanf("%f", &busca->valor);
       }

    }
    | IF '(' cond ')' cmdos %prec IFX
							
	| IF '(' cond ')' cmdosif ELSE cmdos
							
	| '{' cmdos_lst '}'	{
							OK = 1;
						}
	
    ;

cmdosif:
	 '{' cmdos_lst '}' {
			if(OK==1) OK=0;
			else OK=1;
			}
	;
cmdos_lst:
		cmdos
	|	cmdos_lst cmdos
	;
	
    
exp: exp '+' exp {$$ = newast('+',$1,$3);}
    |exp '-' exp {$$ = newast('-',$1,$3);}
    |exp '*' exp {$$ = newast('*',$1,$3);}
	|exp '/' exp {$$ = newast('/',$1,$3);}
	|'(' exp ')' {$$ = $2;}
	|'-' exp %prec NEG {$$ = newast('M',$2,NULL);}  
    |exp '^' exp {$$ = newast('^',$1,$3);}
    |'@' exp {$$ = newast('@',$2,NULL);}
    |valor {$$ = newnum($1);}
    |VAR { 
            Vars *aux = buscaVars(lista, $1);

            if(aux == NULL){
                /*printf("%s -> Essa variável não existe!!\n", $1);*/
                printf("%s -> NullPointerException\n", $1);                
                err = -1;
            } else {
                Numval* nv = (Numval*)malloc(sizeof(Numval));
                nv->number = aux->valor; 
                nv-> nodetype = 'K';
                $$ = (Ast*)nv;
    
            }
        
        }
    ;
    
valor: REAL {$$ = $1;}
    ;

cond: exp MENOR exp {
			if ($1 < $3) $$=OK = 1;
			else $$=OK = 0;
			}
	| exp MAIOR exp {
            if ($1 > $3) $$=OK = 1;
			else $$=OK = 0;
            }
    |exp IGUAL exp {
            if ($1 == $3) $$=OK = 1;
			else $$=OK = 0;
            }
    |exp MAIORIGUAL exp {
            if ($1 >= $3) $$=OK = 1;
            else $$=OK = 0;
            }
    |exp MENORIGUAL exp {
            if ($1 <= $3) $$=OK = 1;
            else $$=OK = 0;
            }
    |exp IGUALIQUAL exp {
            if ($1 == $3) $$=OK = 1;
            else $$=OK = 0;
            }
    |exp DIFERENTE exp {
            if ($1 != $3) $$=OK = 1;
            else $$=OK = 0;
            }
    |cond E cond {
            if (($1 == 1) && ($3==1)) $$=OK = 1;
            else $$=OK = 0;
            }
    |cond OU cond {
            if (($1 == 0) && ($3==0)) $$=OK = 0;
            else $$=OK = 1;
            }
    ;

%%
#include "lex.yy.c"
int main(){
    OK = 1;
	l1 = NULL;

    yyin = fopen("javanunes","r");
    yyparse();
    yylex();
    fclose(yyin);

    return 0;
}
