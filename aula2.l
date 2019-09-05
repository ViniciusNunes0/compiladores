%{
  #include <string.h>  
%}
INICIO ("JavaNunes{")
FIM ("}FimJavaNunes")

ESCRITA ("system")
LEITURA ("scanner")

INT [0-9]+
REAL {INT}|[0-9]+\.?[0-9]+
STR [A-Za-z]+

TIPO ("int"|"float"|"double")
VAR [A-Za-z]+[0-9A-Za-z]*

OPERACAOARI ("+"|"-"|"*"|"/")
POT "^"
RAIZ "@"

ATRIBUICAO ("=")

IF ("if")
ELSE ("else")

REPETICAO ("while"|"for")

MAIOR (">")
MENOR ("<")
IGUAL ("==")
MAIORIGUAL (">=")
MENORIGUAL ("<=")
IGUALIQUAL (==)
DIFERENTE (!=)
E ("and")
OU ("or")

COMENTARIO ["#"](.)+
COMENTARIOMULT ("/*")((.)*|[\ \n\t])*("*/")

INVALIDO (.)
IGNORE [\ \n\t]

%%

{REAL} {
	yylval.real = atof(yytext);
	return REAL;
	}
	
IF {return IF;}
ELSE {return ELSE;}

{LEITURA} { return LEITURA; }
{ESCRITA} { return ESCRITA; } 

[-+()=/*{}^@] {return *yytext;}

{MAIOR} {return MAIOR; }
{MENOR} {return MENOR; }
{IGUAL} {return IGUAL; }
{MAIORIGUAL} { return MAIORIGUAL; }
{MENORIGUAL} { return MENORIGUAL; }
{IGUALIQUAL} { return IGUALIQUAL; }
{DIFERENTE} { return DIFERENTE; }
{E} { return E; }
{OU} { return OU; }


{INICIO} {return INICIO;}
{FIM} {return FIM;}
	
{TIPO} {
    strcpy(yylval.str, yytext);  
    return TIPO;
    }
	
{VAR} {
    strcpy(yylval.str, yytext);  
	return VAR;
	}


{IGNORE} {;}
{INVALIDO} {printf("Caractere Inválido: %s\n",yytext);}

%%
