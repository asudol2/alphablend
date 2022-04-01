CC=gcc
CFLAGS=-Wall -rdynamic -g -no-pie

all:	main.o alphaBlend.o
	$(CC) $(CFLAGS) -lm main.o alphaBlend.o -o alphaBlend `pkg-config --cflags-only-other --libs gtk+-3.0`

main.o:	main.c
	$(CC) $(CFLAGS) -c main.c -o main.o `pkg-config --cflags-only-I --libs gtk+-3.0`

alphaBlend.o:	alphaBlend.asm
	nasm -f elf64 alphaBlend.asm

clean:
	rm -f *.o

