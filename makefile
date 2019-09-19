all : javanunes.l javanunes.y
	clear
	flex -i javanunes.l
	bison javanunes.y
	gcc javanunes.tab.c -o analisador -ll -lm
	./analisador
