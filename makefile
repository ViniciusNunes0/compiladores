all: aula2.l aula3.y
	clear
	flex -i aula2.l
	bison aula3.y
	gcc aula3.tab.c -o analisador -lfl -lm
	./analisador
	
