
#include <bootloader/main/longmode.h>

__attribute__((section(".text.boot")))
void _start() {
    
    
    long_mode_start(); 

    while(1) {}   
}
