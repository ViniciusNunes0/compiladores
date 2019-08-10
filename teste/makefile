all : aula6.l aula6.y
	clear
	flex -i aula6.l
	bison aula6.y
	gcc aula6.tab.c -o analisador -lfl -lm
	./analisador
