CC=g++
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o draw.o -f elf draw.asm
	$(ASMBIN) -o init.o -f elf init.asm

cc :
	$(CC) -m32 -c -g -O0 zbuf.cpp
link :
	$(CC) -m32 -o test -lstdc++ zbuf.o draw.o init.o
clean :
	rm *.o
	rm test
	rm errors.txt	
	rm *.lst
