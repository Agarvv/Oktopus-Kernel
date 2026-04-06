 
#include<kernel/drivers/video/vga/vga.h>

int put(char str[], int lenstr); 

int putchar(int row, int col, char c, char f) {
    int offset = (row * VIDEO_ROWS) + col;

    unsigned short *addr = (unsigned short *)VGA_TEXT_VIDEO_MEMORY + offset;

    c = (unsigned short)c;

    f = (unsigned short)f;

    *addr = (f << 8) | c;

    return 0;
}

int puts(char str[], int lenstr) {
    int row = 0;
    int col = 0;
    lenstr = 2; 




    for(int i = 0; i < lenstr; i++) {
        putchar(row, col, str[i], 0x1F);
        col++;
    }
    
}
