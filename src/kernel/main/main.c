#include<kernel/drivers/video/vga/vga.h>
#include<kernel/terminal/terminal.h>
#include<kernel/int/idt.c>

int _start() {
 clear_terminal();
 idt_start();


  puts("PLVS VLTRA KERNEL (PRE ALPHA)", 31);
  








    while(1);
}
