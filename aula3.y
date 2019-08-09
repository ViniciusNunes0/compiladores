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
    
%}
%union {
    float real;
    int inte;
    char str[50];
}

%token INICIO
%token FIM
%token OPERACAOARI
%token <real> REAL
%token <str>VAR
%token <str>TIPO
%token LEITURA
%token ESCRITA
%left '+' '-'
%left '*' '/'
%right POT
%right RAIZ
%right NEG
%type <real> exp
%type <real> valor
%%

prog: INICIO cod FIM
    ;

cod: cod cmdos
    |
    ;
    
cmdos: ESCRITA '(' exp ')' {
        if (err != -1)
            printf ("%.2f \n",$3);
            err = 0;
        }
	| TIPO VAR {
        Vars *aux = buscaVars(lista, $2);
       if(aux == NULL){
           lista = insereLista(lista, $2);   
       }else{
           printf("%s -> Variavel já Declarada!\n", $2);
       }
    }    
    | TIPO VAR '=' exp {
         Vars *aux = buscaVars(lista, $2); 
        if(aux == NULL){
            lista = insereLista(lista, $2);  
            lista->valor = $4;
        }else{
            printf("%s -> Variavel já Declarada!\n", $2);
        }   
    }
    
    | VAR '=' exp {

       Vars *aux = buscaVars(lista, $1); 

       if(aux == NULL){
           printf("%s -> Variavel não está Declarada!\n", $1);
           
       }else{
            aux->valor = $3;
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
    ;
    
exp: exp '+' exp {$$ = $1 + $3; }
    |exp '-' exp {$$ = $1 - $3; }
    |exp '*' exp {$$ = $1 * $3; }
    |exp '/' exp {$$ = $1 / $3; }
    |'(' exp ')' {$$ = $2;}
    |exp POT exp {$$ = pow($1,$3); }
    |RAIZ exp {$$ = sqrt($2);}
    |'-' exp %prec NEG {$$ = -$2;}
    |valor { $$ = $1; }
    |VAR { 
            Vars *aux = buscaVars(lista, $1);

            if(aux == NULL){
                /*printf("%s -> Essa variável não existe!!\n", $1);*/
                printf("%s -> NullPointerException\n", $1);                
                err = -1;
            } else {
                $$ = aux->valor;
            }
        
        }
    ;
    
valor: REAL {$$ = $1;}
    ;

%%
#include "lex.yy.c"
int main(){
    yyin = fopen("javanunes","r");
    yyparse();
    yylex();
    fclose(yyin);

    return 0;
}
