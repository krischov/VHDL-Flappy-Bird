#
/* Compile: cc -ansi -pedantic -o ppm2tmap ppm2tmap.c */

/**
 * This program converts a .PPM image file (Portable PixMap) to the 
 * ModelSim Mobsters .MIF (Memory Initialization File) sprite transparancy map 
 * format.
 *
 * The sprite format is layed out in the following way:
 *
 * 16 bits of data per pixel (i.e. 2 bytes) with three colour channels and an 
 * extra 'pseudo-transparancy' nibble.
 *
 * The following is the order of the pixel data: zbgr
 *	where Z is the transparancy; b, g, and r are the 3 colour channels
 *	each field (Z, b, g, and r) are nibbles (i.e. 4 bits, half a byte/octet);
 * If Z is "0000" then the pixel is NOT transparent;
 * If Z is "1111" then the pixel is transparent (i.e. should NOT be shown).
 *
 * The output file has it's address and data in hexadecimal.
 *
 * The input file must have a size that is a power of two. 
 * The input file must be square (same width and height).
 * The input file must be in RAW (binary) PPM format NOT in ASCII/Plain-Text.
 *
 * The .PPM image format has no concept of transparancy 
 * (i.e. it has only 3 colour channels).
 * Fortunately this is not an issue for the Modelsim Mobsters sprites, as 
 * each channel is only a nibble (i.e. 4 bits). However, due to each channel
 * being limited to a nibble, you must be careful when creating the image file.
 * Most image minipulation programs will utilise 8 bits per channel
 * (i.e. each channel: R, G, B; is a byte in size).
 * Thus when selecting colours, you must ONLY USE THE UPPER 4 BITS 
 * of each channel. It is easy to do this with Hex colour codes:
 *	The typical RGB colour: 0x000000
 *	You must only use the hex digits 5, 3, and 1.
 *	This means white is: 0xF0F0F0 (IT IS NOT 0xFFFFFF)
 *	and pure red is: 0xF00000 (IT IS NOT 0xFF0000)
 *	and pure green is: 0x00F000 (IT IS NOT 0x00FF00)
 *	and pure blue is: 0x0000F0 (IT IS NOT 0x0000FF)
 *	and pure black is: 0x000000
 *
 * You must follow this rule when creating the sprite images.
 * Be careful to ensure you are only filling out single, whole pixels 
 *	as most image minipulation programs will anti-alias "brush strokes".
 *	Most image minipulation packages have a "pencil tool" that will not
 *	anti-alias (it will only fill in whole pixels with a solid colour).
 *
 * The above colour "limitations" provide us with an opportunity:
 *	as the lower 4 bits (low nibble) of each colour channel goes unused,
 *	and white is typically the "canvas background" in most 
 *	image minipulation packages, and we represent white as 0xF0F0F0
 *	we can use a 'true' 8bit white as transparanacy.
 *	Thus the colour 0xFFFFFF (i.e. the lower nibbles of each channel/byte
 *	have a value) represents transparancy, and any pixels with the colour
 *	0xFFFFFF will produce a "Z-value" of "1111" (i.e. transparent in sprite)
 *
 *
 * Program Useage:
 *	./ppm2sprite image.ppm [out_file.mif=sprite.mif]
 * Note outfile is optional, the default name is "sprite.mif".
 * The input and output file can not have the same name.
 *
 */ 


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


FILE *ppm;
FILE *sprite;


unsigned short magic;
unsigned short width, height;
unsigned short max_val_per_colour;

unsigned char r, g, b;

unsigned short address;

unsigned char transparent;

char read_buf[4096];
char out_buf[32];


bin(unsigned short x, char *buf)
{
	int i;
	buf += 15;
	for (i = 15; i >= 0; --i, x >>= 1) {
		*buf-- = (x & 1) + '0';
	}
	
	return (0);
}

main(argc, argv)
char *argv[];
{
	unsigned short i, scaned;

	if (argc < 2) {
		puts("Useage: ./ppm2sprite image.ppm [out_file.mif=sprite.mif]");
		return (1);
	}	
	if ((ppm = fopen(argv[1], "rb")) == NULL) {
		printf("Failed to open image file: %s\n", argv[1]);
		return (2);
	}

	if (argc > 2) {
		if (strcmp(argv[1], argv[2]) == 0) {
			puts("Error! input file has same name as output file!");
			fclose(ppm);
			return (9);
		}
		if ((sprite = fopen(argv[2], "w")) == NULL) {
			printf("Failed to open output sprite file: %s\n", argv[2]);
			return (3);
		}
	} else {
		
		if ((sprite = fopen("sprite.mif", "w")) == NULL) {
			printf("Failed to open output sprite file: %s\n", "sprite.mif");
			return (8);
		}
	}

	fread(&magic, sizeof (magic), 1, ppm);
	if (((unsigned char *) &magic)[0] != 'P') {
		puts("Wrong file format! Must be a .ppm image file (Portable PixMap)");
		return (4);
	}
	if (((unsigned char *) &magic)[1] != '6') {
		puts("ppm file must be in binary (raw) format NOT in ASCII (plain) format");
		return (5);
	}
	
	
	do { /* Skip Comments */
		fgets(read_buf, sizeof (read_buf), ppm);
	} while (read_buf[0] == '#' || read_buf[0] == '\n');

	sscanf(read_buf, "%hu %hu\n", &width, &height);
	if (width != height) {
		puts("Error! Image must have the same width and height");
		return (6);
	}
	if ((width & (width - 1)) != 0) {
		puts("Error: width and height must be a power of 2!");
		return (7);
	}

	fscanf(ppm, "%hu\n", &max_val_per_colour);
	

	/* write the output mif file */
	fprintf(sprite, "-- Sprite: %s; size: %hux%hu pixels (Transparancy Map)\n"
		"constant X : std_logic_vector(%hu downto 0) := (\n\tx\"", 
		argv[1], width, height, (unsigned short) (width * height - 1)
	);

	for (i = 0; i < width * height; ++i, address++) {
		fread(&r, sizeof (r), 1, ppm);
		fread(&g, sizeof (g), 1, ppm);
		fread(&b, sizeof (b), 1, ppm);

		/* 0x0F => 00001111 */
		if ((r & 0x0F) && (g & 0x0F) && (b & 0x0F)) {
			transparent |= 0x01 << (8 - (i % 8));
		} else {
			transparent |= 0x00 << (8 - (i % 8));
		}

		/* We have 8 transparancy values, write out the byte */

		if (i % 8 == 7) {
			fprintf(sprite, "%02hhx", transparent);
			transparent = 0x00;
		}
	}	

	fputs("\"\n);\n", sprite);

	fclose(ppm);
	fclose(sprite);
	printf("Done! \n");

	return (0);
}

