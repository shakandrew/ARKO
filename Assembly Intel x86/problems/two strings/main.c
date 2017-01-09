#include <stdio.h>
#include "f.h"
int main(int argc, char *argv[])
{
	if(argc < 3)
	{
	printf("Argument missing.");
	return 0;	
	}	
	f(argv[1], argv[2]);
	printf(argv[1]);
	printf("\n");
	return 0;

}
