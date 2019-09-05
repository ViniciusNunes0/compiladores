all : aula7.l aula7.y
	clear
	flex -i aula7.l
	bison aula7.y
	gcc aula7.tab.c -o analisador -lfl -lm
	./analisador
