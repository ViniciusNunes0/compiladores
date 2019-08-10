%{

%}

NUM [0-9]+\.?[0-9]*
VAR [a-z]+[0-9]*
DECL "var"
PRINT "exibir"
INI "INICIO"
FIM "FIM"
IF "SE"
ELSE "ELSE"
%%

{IF} {return IF;}

{ELSE} {return ELSE;}

{DECL} {return DECL;}

{PRINT} {return PRINT;}

{INI} {return INI;}			
	
{FIM} {return FIM;}

{NUM} {
	yylval.flo = atof(yytext);
	return NUM;
	}
	
{VAR} {
	strcpy (yylval.str,yytext);
	return VAR;
	}
	
[-+()=/*^<>{}] {return *yytext;}
	
[\ \n\t]*	{;}

. {printf("(%s) Ingonrado\n",yytext);}
%%