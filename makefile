PS2.tab.o: PS2.y
	bison --debug PS2.y;
	gcc -c PS2.tab.c;

lex.yy.o: assignment1.l tokens-manual.h
	flex assignment1.l;
	gcc -c lex.yy.c;

test: PS2.tab.o lex.yy.o 
	gcc PS2.tab.o lex.yy.o -o test