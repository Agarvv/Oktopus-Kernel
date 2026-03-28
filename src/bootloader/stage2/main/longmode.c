#include <bootloader/main/longmode.h>
#include <bootloader/main/paging.h>
#define VGA_TEXT_VIDEO_MEMORY 0xB8000
#define VIDEO_ROWS 25
#define VIDEO_COLS 80

// 64 bit addr format example (0xB8000)
// 00000000 00000000 00000000 00000000 00000000 00001011 10000000 00000000

// bits 63-48: Bit Extension
// bits 47-39 PML4 Index (9 bits)
// bits 38-30 PDPT index (9 bits)
// bits 29-21 PD Index (9 bits)
// bits 20-12 PT Index (9 bits)
// bits 11-0 Offset (12 Bits)

// 000000000



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
        unsigned long long pd_addr = (unsigned long long)&page_directory;
   

        page_directory_pointer_table[0] = 0x0000000000000001 | pd_addr;
 
  unsigned long long pt_addr = (unsigned long long)&page_table;
        page_directory[0] = 0x0000000000000083;
        page_directory[1] = 0x0000000000200083;
        page_directory[2] = 0x0000000000400083;


 
 /*
        unsigned long long p_addr = 0x0000000000000000;

  for(int i = 0; i < 512; i++) {
    page_table[i] = 0x0000000000000001 | p_addr;
    p_addr += 0x1000;
  }
*/
  unsigned long long pdpt_addr = (unsigned long long)&page_directory_pointer_table;



        asm volatile(
    "mov %%eax, %%cr3\n\t"
    "or %%eax, %0\n\t"
    "mov %%cr3, %%eax"
    :
    : "r"(pdpt_addr)
    : "eax", "memory"
   );
   


  // to enable PAE, i have to set bit 5 of CR4 register to 1.
    asm volatile(
        "movl %%cr4, %%eax\n\t"
        "orl $0x20, %%eax\n\t"      
        "movl %%eax, %%cr4"
        ::: "eax", "memory"
    );

   
     asm volatile(
        "mov %%cr0, %%eax\n"
        "or $0x80000000, %%eax\n"   // Bit 31 = PG
        "mov %%eax, %%cr0\n"
        :
        :
        : "eax", "memory"
    );
    put("hola", 5);
}


void enable_long_mode() {
        for(int i = 0; i < 511; i++) {
                page_map_level_four[i] = 0;
        }
 
  unsigned long long pdpt_addr = (unsigned long long)&page_directory_pointer_table;

        page_map_level_four[0] = 0x0000000000000003 | pdpt_addr;




        asm volatile(
    "mov %%cr0, %%eax\n\t"
    "and $0x7FFFFFFF, %%eax\n\t"   // Clear PG bit (bit 31)
    "mov %%eax, %%cr0\n\t"
    :
    :
    : "eax", "memory"
);  

 
 unsigned long long pml4_addr = (unsigned long long)&page_map_level_four;  

   asm volatile(
    "mov %0, %%cr3\n\t"
    :
    : "r"(pml4_addr)  
    : "memory"
);

   asm volatile(
    "mov $0xC0000080, %%ecx\n"
    "rdmsr\n"
    "or $0x100, %%eax\n"
    "wrmsr\n"
    :
    :
    : "eax","ecx","edx","memory"
);





  asm volatile(
    "mov %%cr0, %%eax\n\t"
    "or $0x80000000, %%eax\n\t"   // Set PG bit (bit 31)
    "mov %%eax, %%cr0\n\t"
    :
    :
    : "eax", "memory"
);



  put("human", 6);
 
 
 


}

void long_mode_start() {
  enable_physical_addr_extension();
 enable_long_mode();
 load_kernel_64();

  put("pipo", 5);

}
