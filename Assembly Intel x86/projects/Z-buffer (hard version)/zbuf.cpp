


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

void zbufToRgb(unsigned int *source, unsigned char *dest, int size)
{
	for(int i=0; i<size; ++i)
	{
		uint32 tmp = source[i]>>24;
		uint8 val = 255 - tmp;
		dest[i*3] = dest[i*3+1] = dest[i*3+2] = val;
	}
}

int main(int argc, char* argv[])
{
	int xsize, ysize, bg[3];
	// Get X-size and Y-size.
	scanf("%d %d", &xsize, &ysize);
	scanf("%d %d %d", &bg[0], &bg[1], &bg[2]);
	// Allocate buffers.
	unsigned char *image = (unsigned char*) malloc(xsize*ysize*3);
	unsigned char *zbuf = (unsigned char*) malloc(xsize*ysize*sizeof(uint32));
	unsigned char *zbuf_rgb = (unsigned char*) malloc(xsize*ysize*3);
	
	
	// Initiate buffers and background.
	initBuffers(image, zbuf, xsize, ysize, bg);
	
	// Loop for drawing triangles.		
	while(1)
	{
		int vertices[9];
		int rgb[9];
		printf("Werszyna");
		if( scanf("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", 
			&vertices[0], &vertices[1], &vertices[2], &rgb[0], &rgb[1], &rgb[2],
			&vertices[3], &vertices[4], &vertices[5], &rgb[3], &rgb[4], &rgb[5],
			&vertices[6], &vertices[7], &vertices[8], &rgb[6], &rgb[7], &rgb[8])
			== EOF) break;	// reached end of file
		
		
		//****** Triangle filler. ************//
		drawTriangle(image, zbuf, xsize, ysize, vertices, rgb);
	}
	//image[0]=255; image[1]=255; image[2]=255;
	// Write to files
	writeBmp(image, xsize, ysize, "scena.bmp");
	zbufToRgb((unsigned int*)zbuf, zbuf_rgb, xsize*ysize);
	writeBmp(zbuf_rgb, xsize, ysize, "zbufor.bmp");
	
	free(image);
	free(zbuf);
	
	return 0;
}
