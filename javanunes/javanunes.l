%{

%}

INICIO ("javanunes{")
FIM ("}fimjavanunes")

IF "if"
ELSE "else"
WHILE "while"

ESCRITA "system"
LEITURA "scanner"

TIPO ("int"|"double"|"float"|"string")
INT [0-9]+
VAR [A-Za-z]+[0-9A-Za-z]*
CARACTER ("&")
STR ["].*["]
NUM [0-9]+\.?[0-9]*

RAIZ "@"
MAIOR (">")
MENOR ("<")
IGUAL ("==")
MAIORIGUAL (">=")
MENORIGUAL ("<=")
IGUALIQUAL ("==")
DIFERENTE ("<>")
E ("and")
OU ("or")

COMENTARIO ("#")((.)|{IGNORE})*("/#")
IGNORE ("\t"|"\n"|" ")
INVALIDO (.)
%%

{FIM} {return FIM;}
{IF} {return IF;}
{ELSE} {return ELSE;}
{WHILE} {return WHILE;}
{ESCRITA} {return ESCRITA;}
{LEITURA} {return LEITURA;}
{VAR} {
	strcpy(yylval.str, yytext);
	return VAR;
	}
{NUM} {
	yylval.flo = atof(yytext);
	return NUM;
	}
{RAIZ} {
    return RAIZ;
}

{INICIO} {
    return INICIO;
}

[-+()=/*^{};] { return *yytext; }

{MAIOR}		 {yylval.fn = 1; return COMP; }
{MENOR} 	 {yylval.fn = 2; return COMP; }
{DIFERENTE}  {yylval.fn = 3; return COMP; }
{IGUAL}		 {yylval.fn = 4; return COMP; }
{MAIORIGUAL} {yylval.fn = 5; return COMP; }
{MENORIGUAL} {yylval.fn = 6; return COMP; }

[\ \n\t]*	{;}
%%