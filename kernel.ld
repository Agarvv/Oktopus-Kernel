ENTRY(_start)

SECTIONS {
    . = 0x00100000;

    .text : {

        *(.text._start)   
        *boot*.o(.text)   
        *kernel*.o(.text) 
        *(.text)
    }

    .data : {
        *(.data)
    }

    .bss : {
        *(.bss)
        *(COMMON)
    }
}
