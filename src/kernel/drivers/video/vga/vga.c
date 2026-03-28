#include <kernel/drivers/video/vga/vga.h> 


int putchar(int row, int col, char c, char f) {
    
    int offset = (row * VIDEO_COLS) + col;
    offset = 2;
   char *addr = (char*)0xB8000 + offset;

    while(1);
    addr[1] = 0x1F; 
    addr[0] = c; 


    return 0; 
}

int puts(char str[], int lenstr) {
	int row = 0;
	int col = 0; 

 	putchar(0, 2, str[0], 0x1F); 


	putchar(0, 4, str[1], 0x1F); 
	putchar(0, 6, str[2], 0x1F);
 	putchar(0, 8, str[3], 0x1F);
   	putchar(0, 10, str[4], 0x1F); 

        putchar(0, 12, str[5], 0x1F); 


         /*
	for(int i = 0; i < lenstr; i++) {
         //  putchar(row, col, str[i], 0x1F); 
          char a = *(str + i);
         //  col++;
	}
	*/

    /*int row = 0;
    int col = 0;
    
    for(int i = 0; i < lenstr; i++) {
        putchar(row, col, str[i], 0x1F); 
        col++; 
    }
    */
}
