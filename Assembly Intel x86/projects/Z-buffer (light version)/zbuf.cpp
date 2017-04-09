#include <iostream>
#include <fstream>
#include <stdlib.h>
using namespace std;

extern "C" int drawTriangle(unsigned char *image, unsigned char *zbuf, int xsize, int ysize, int *vertices, int *rgb);
extern "C" int initBuffers(unsigned char *image, unsigned char *zbuf, int xsize, int ysize, int *rgb);

typedef unsigned short uint16;
typedef unsigned int uint32;
typedef unsigned char uint8;
typedef char BYTE;


void writeBmp(uint8* buff, int xsize, int ysize, const char* name)
{
	fstream bm;
	bm.open(name, ios::out | ios::binary);
	
	// BitmapFileHeader - 14 bytes
	uint8 bfType1 = 'B';
	uint8 bfType2 = 'M';
	uint32 bfSize =  54 +xsize*ysize*3; // file size - 54 bytes of headers + 3 bytes for each pixel
	uint32 bfReserved = 0;
	uint32 bfOffBits = 54; 	// 14+40 bytes of headers
	bm.write((BYTE*)&bfType1, sizeof(bfType1));
	bm.write((BYTE*)&bfType2, sizeof(bfType2));
	bm.write((BYTE*)&bfSize, sizeof(bfSize));
	bm.write((BYTE*)&bfReserved, sizeof(bfReserved));
	bm.write((BYTE*)&bfOffBits, sizeof(bfOffBits));
	
	// BitmapInfoHeader - 40 bytes
	uint32 biSize = 40;
	uint32 biWidth = xsize;
	uint32 biHeight = ysize;
	uint16 biPlanes = 1;
	uint16 biBitCount = 24;
	uint32 biCompression = 0;
	uint32 biSizeImage = 0;
	uint32 biXPelsPerMeter = 0;
	uint32 biYPelsPerMeter = 0;
	uint32 biClrUsed = 0;
	uint32 biClrImportant = 0;
	bm.write((BYTE*)&biSize, sizeof(biSize));
	bm.write((BYTE*)&biWidth, sizeof(biWidth));
	bm.write((BYTE*)&biHeight, sizeof(biHeight));
	bm.write((BYTE*)&biPlanes, sizeof(biPlanes));
	bm.write((BYTE*)&biBitCount, sizeof(biBitCount));
	bm.write((BYTE*)&biCompression, sizeof(biCompression));
	bm.write((BYTE*)&biSizeImage, sizeof(biSizeImage));
	bm.write((BYTE*)&biXPelsPerMeter, sizeof(biXPelsPerMeter));
	bm.write((BYTE*)&biYPelsPerMeter, sizeof(biYPelsPerMeter));
	bm.write((BYTE*)&biClrUsed, sizeof(biClrUsed));
	bm.write((BYTE*)&biClrImportant, sizeof(biClrImportant));
	
	// Write image buffer
	if(xsize*3%4 == 0) bm.write((BYTE*)buff, xsize*ysize*3); //BMP padding to 32b(=4B) multiple check
	else
	{
		char anything[4];
		for(int i=0; i<ysize; ++i, buff+=xsize*3)
		{
			bm.write((BYTE*)buff, xsize*3);
			bm.write(anything, 4-(xsize*3%4));		// just fill with anything(=rubbish) to 32b(=4B) multiple
		}
	}
	
	bm.close();
}

int main(int argc, char* argv[])
{
	while(true)
	{
		int loop;
		printf("1 - program works, 0 - doesn't, make a right decision :");
		scanf("%d", &loop);
		if (!loop)
		{
			printf("It was wonderful and great work, thanks for using it!\n");
			return 0;	
		}
		int xsize, ysize, bg[3], i;
	// Get X-size and Y-size.
		printf("BMP file sizes :");
		printf("Width (xsize) = "); scanf("%d", &xsize);
		printf("Height (ysize) = "); scanf("%d", &ysize);

		printf("Set the background color in RGB\nR (0..255) = ");scanf("%d", &bg[0]);
		printf("G (0..255) = "); scanf("%d", &bg[1]);
		printf("B (0..255) = "); scanf("%d", &bg[2]);
	// Allocate buffers.
		unsigned char *image = (unsigned char*) malloc(xsize*ysize*3);
		unsigned char *zbuf = (unsigned char*) malloc(xsize*ysize*sizeof(uint32));
		unsigned char *zbuf_rgb = (unsigned char*) malloc(xsize*ysize*3);
		
		
	// Initiate buffers and background.
		initBuffers(image, zbuf, xsize, ysize, bg);
		
		for(i = 0;i<2;i++)
		{
			int vertex[9], rgb[3] = {20+i*100, 20+i*100, 20+i*100};
			printf("Triangle N %d :\nPlease set the vetices values:\n", i);
			printf("First vertex : x = "); scanf("%d", &vertex[0]);
			printf(" y = "); scanf("%d", &vertex[1]);
			printf(" z = "); scanf("%d", &vertex[2]);

			printf("Second vertex : x = "); scanf("%d", &vertex[3]);
			printf(" y = "); scanf("%d", &vertex[4]);
			printf(" z = "); scanf("%d", &vertex[5]);

			printf("Third vertex : x = "); scanf("%d", &vertex[6]);
			printf(" y = "); scanf("%d", &vertex[7]);
			printf(" z = "); scanf("%d", &vertex[8]);
			drawTriangle(image, zbuf, xsize, ysize, vertex, rgb);
		}
		writeBmp(image, xsize, ysize, "Magic.bmp");
		
		free(image);
		free(zbuf);
		system("eog Magic.bmp");	
	}
	
}
