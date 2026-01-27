#include <bootloader/main/longmode.h>
#include <bootloader/main/paging.h>
#define VGA_TEXT_VIDEO_MEMORY 0xB8000
#define VIDEO_ROWS 25 
#define VIDEO_COLS 80


extern void load_kernel_64(); 

int putcha(int row, int col, char c, char f) {

    int offset = (row * VIDEO_ROWS) + col;

    unsigned short *addr = (unsigned short *)VGA_TEXT_VIDEO_MEMORY + offset;

    c = (unsigned short)c;

    f = (unsigned short)f;

    *addr = (f << 8) | c;

    return 0;
}

int put(char str[], int lenstr) {
    int row = 0;
    int col = 0;

    for(int i = 0; i < lenstr; i++) {
        putcha(row, col, str[i], 0x1F);
        col++;
    }
}


void enable_physical_addr_extension() {
    

  unsigned long long pd_addr = (unsigned long long)&page_directory << 12; 
	page_directory_pointer_table[0] = 0x0000000000000001 | pd_addr;
  
  unsigned long long pt_addr = (unsigned long long)&page_table << 12; 
	page_directory[0] = 0x0000000000000001 | pt_addr;
  
	unsigned long long p_addr = 0x0000000000010000; 
	page_table[0] = 0x0000000000000001 | p_addr; 
	
	asm volatile(
    "mov %%eax, %%cr3\n\t"
    "or %%eax, %0\n\t"
    "mov %%cr3, %%eax"
    :
    : "r"(&page_directory_pointer_table)
    : "eax", "memory"
   );
   


  // to enable PAE, i have to set bit 5 of CR4 register to 1. 
    asm volatile(
        "movl %%cr4, %%eax\n\t"
        "orl $0x20, %%eax\n\t"      
        "movl %%eax, %%cr4"
        ::: "eax", "memory"
    );
}


void enable_long_mode() {
 // puts("human", 6); 
  unsigned long long pdpt_addr = (unsigned long long)&page_directory_pointer_table << 12; 
	page_map_level_four[0] = 0x0000000000000001 | pdpt_addr;  
	
	asm volatile(
    "mov %%eax, %%cr3\n\t"
    "or %%eax, %0\n\t"
    "mov %%cr3, %%eax"
    :
    : "r"(&page_map_level_four)
    : "eax", "memory"
   );
	
  // in order to activate long mode, i have to set bit eigth (Long mode enable) of EFER msr to 1
  asm volatile(
    "movl $0xC0000080, %%ecx\n\t" // EFER model speciific register number
    "rdmsr\n\t"                  // puts EFER high bits in edx and low bits in eax 
    "orl  $0x00000100, %%eax\n\t" // set bit 8 of low bits to 1 (Long mode enable)
    "wrmsr\n\t"                  // write model specific register
    :
    :
    : "eax", "edx", "ecx"
  );
}

void long_mode_start() { 
  enable_physical_addr_extension(); 
  enable_long_mode(); 
  load_kernel_64(); 

  put("Tado es gei", 12);
}
