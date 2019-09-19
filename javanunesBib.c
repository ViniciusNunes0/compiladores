  #include <math.h>

    typedef struct estr{
        char nome[50];
        double valor;
        struct estr *prox;
    } Estr;


    int err = 0;
	Estr  *com_list;
	

    Estr *buscaEstr(Estr *i, char estr[]){
        Estr *com_lista;
        for(com_lista = i; com_lista != NULL; com_lista = com_lista->prox) {
            if(strcmp(com_lista->nome, estr) == 0){
                return com_lista;
            }
        }
        return NULL;
    }

    Estr *insertList(Estr *i, char b[]){
        Estr *novo = (Estr*)malloc(sizeof(Estr));
        strcpy(novo->nome, b);
        novo->valor = 0;
        novo->prox = i;
        return novo;
    }


    typedef struct ast { 
	int nodetype;
	struct ast *l; 
	struct ast *r; 
}Ast; 

typedef struct numval { 
	int nodetype;
	double number;
}Numval;

typedef struct varval { 
	int nodetype;
	char var[50];
}Varval;

typedef struct flow {
	int nodetype;
	Ast *cond;		
	Ast *tl;		
	Ast *el;		
}Flow;

typedef struct symasgn { 
	int nodetype;
	char s[50];
	Ast *v;
}Symasgn;


double var[26]; 
int aux;
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

Ast * newflow(int nodetype, Ast *cond, Ast *tl, Ast *el){
	Flow *a = (Flow*)malloc(sizeof(Flow));
	if(!a) {
		printf("out of space");
	exit(0);
	}
	a->nodetype = nodetype;
	a->cond = cond;
	a->tl = tl;
	a->el = el;
	return (Ast *)a;
}

Ast * newcmp(int cmptype, Ast *l, Ast *r){
	Ast *a = (Ast*)malloc(sizeof(Ast));
	if(!a) {
		printf("out of space");
	exit(0);
	}
	a->nodetype = '0' + cmptype; 
	a->l = l;
	a->r = r;
	return a;
}



Ast * newValorVal(char s[]) { 
	
	Varval *a = (Varval*) malloc(sizeof(Varval));
	if(!a) {
		printf("out of space");
		exit(0);
	}
	a->nodetype = 'N';
	strcpy (a->var, s);
	return (Ast*)a;
	
}

double eval(Ast *a) {
	double v; 
	if(!a) {
		printf("erro interno, valor null");
		return 0.0;
	}
	switch(a->nodetype) {
		case 'K': v = ((Numval *)a)->number; break; 	
		case 'N': v = buscaEstr(com_list, ((Varval *)a)->var)->valor; break;	
		case '+': v = eval(a->l) + eval(a->r); break;	
		case '-': v = eval(a->l) - eval(a->r); break;	
		case '*': v = eval(a->l) * eval(a->r); break;	
		case '/': v = eval(a->l) / eval(a->r); break; 
		case '@': v = sqrt(eval(a->l)); break;
		case '^': v = pow(eval(a->l), eval(a->r)); break;
		case 'M': v = -eval(a->l); break;		

		case '1': v = (eval(a->l) > eval(a->r))? 1 : 0; break;
		case '2': v = (eval(a->l) < eval(a->r))? 1 : 0; break;
		case '3': v = (eval(a->l) != eval(a->r))? 1 : 0; break;
		case '4': v = (eval(a->l) == eval(a->r))? 1 : 0; break;
		case '5': v = (eval(a->l) >= eval(a->r))? 1 : 0; break;
		case '6': v = (eval(a->l) <= eval(a->r))? 1 : 0; break;
		
		case '=':
				v = eval(((Symasgn *)a)->v);
				Estr *aux = buscaEstr(com_list, ((Varval *)a)->var);	
				aux->valor = v;			
				break;
		
		case 'I':						
			if (eval(((Flow *)a)->cond) != 0) {	
				if (((Flow *)a)->tl)		
					v = eval(((Flow *)a)->tl); 
				else
					v = 0.0;
			} else {
				if( ((Flow *)a)->el) {
					v = eval(((Flow *)a)->el);
				} else
					v = 0.0;
				}
			break;
			
		case 'W':
			v = 0.0;
			if( ((Flow *)a)->tl) {
				while( eval(((Flow *)a)->cond) != 0){
					v = eval(((Flow *)a)->tl);
				}
			}
		break;
			
		case 'L': eval(a->l); v = eval(a->r); break; 
		
		case 'P': v = eval(a->l);
				  printf ("%.2f\n",v); break; 

		case 'V': scanf ("%lf", &(buscaEstr(com_list, ((Varval *)a)->var)->valor)); break;

		default: printf("erro interno: %c\n", a->nodetype);
				
	}
	return v;
}

Ast * newasgn(char s[], Ast *v) {
	Symasgn *a = (Symasgn*)malloc(sizeof(Symasgn));
	if(!a) {
		printf("out of space");
	exit(0);
	}
	if(buscaEstr(com_list, s) == NULL){
		com_list = insertList(com_list, s);
	}

	Estr *aux = buscaEstr(com_list, s);
	aux->valor = eval(v);
	a->nodetype = '=';
    strcpy (a->s, s); 
	a->v = v; 
	return (Ast *)a;
}

Ast * newLeitura(char s[]) {
	Symasgn *a = (Symasgn*)malloc(sizeof(Symasgn));
	if(!a) {
		printf("out of space");
	exit(0);
	}
	if(buscaEstr(com_list, s) == NULL){
		com_list = insertList(com_list, s);
	}

	Estr *aux = buscaEstr(com_list, s);
	a->nodetype = 'V';
    strcpy (a->s, s); 
	
	return (Ast *)a;
}