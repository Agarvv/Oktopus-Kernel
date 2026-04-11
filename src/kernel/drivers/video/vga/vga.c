 
#include<kernel/drivers/video/vga/vga.h>

int put(char str[], int lenstr); 

void serial_putchar(char c) {
    __asm__ volatile (
        "mov $0x3F8, %%dx\n" 
        "mov %0, %%al\n"       
        "out %%al, %%dx"       
        : 
        : "r"(c)
        : "%al", "%dx", "memory"
    );
}


int putchar(unsigned int row, unsigned int col, char c, char f) {
	//serial_putchar(c);


   unsigned int offset = (unsigned int)(row * VIDEO_COLS) + col; 






    unsigned short *addr = (unsigned short *)VGA_TEXT_VIDEO_MEMORY + offset;



    c = (unsigned short)c;

    f = (unsigned short)f;


    *addr = (f << 8) | c;

    return 0;
}

int puts(char str[], unsigned int lenstr) {
 
   unsigned int row = 0;







   unsigned int col = 0;











    for(unsigned int i = 0; i < 8; i++) {  




	

	   serial_putchar(str[1]);

	





	






	


    putchar(row, col, str[i], 0x1F);  

    col++;

}
}
