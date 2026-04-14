#include <kernel/drivers/video/vga/vga.h> 

void clear_terminal() {
    for(int rows = 0; rows < VIDEO_ROWS; rows++) 
    {
        
        for(int cols = 0; cols < VIDEO_COLS; cols++) 
        {
          putchar(rows, cols, ' ', 0x07); 
        }
        
    }
} 


