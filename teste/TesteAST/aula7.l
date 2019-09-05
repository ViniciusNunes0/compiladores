%{

%}

NUM [0-9]+\.?[0-9]*
INI "INICIO"
FIM "FIM"
%%
{NUM} {
	yylval.flo = atof(yytext);
	return NUM;
	}
[-+()=/*^] {return *yytext;
			}
{INI} {return FIM;
	}			
{FIM} {return FIM;
	}			
[\ \n\t]*	{;}
. {printf("(%s) Ingonrado\n",yytext);}
%%