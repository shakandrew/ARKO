CC=gcc
CFLAGS = -m32 -Wall

all:	main.o f.o
	$(CC) $(CFLAGS) main.o f.o -o fun

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o  main.o

f.o:	f.asm
	nasm -f elf f.asm

clean:
	rm -f *.o
