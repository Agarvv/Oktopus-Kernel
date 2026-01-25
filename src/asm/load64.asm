global load_kernel_64 
%define KERNEL_ADDR 0x100000 
 

section .bss 
counter: resb 1 


section .tect 
print_hex_byte:
    mov bl, al
    shr al, 4
    call .nibble
    mov al, bl
    and al, 0x0F
    call .nibble
    ret
.nibble:
    cmp al, 9
    jg .letter
    add al, '0'
    jmp .print
.letter:
    add al, 'A' - 10
.print:
    mov dx, 0x3F8
    out dx, al
    ret


load_kernel_64: 
    .ata_wait:
         .busy: 
   		 mov dx, 0x1F7 ;status 
   		 in al, dx  
      	         test al, 0x80 
      	         jnz .busy 
         .ready: 
                 mov dx, 0x1F7
                 in al, dx 
                 test al, 0x40 
                 jz .ready 
    
    ; mov al, 'R'  
    ; mov dx, 0x3F8  
    ; out dx, al 

    mov al, 0xE0     
    mov dx, 0x1F6
    out dx, al
    
    ; load LBA
    ; LBA LOW 
    mov al, 0x21 
    mov dx, 0x1F3 
    out dx, al 
  

    ; LBA MEDIUM 
    mov al, 0x00 
    mov dx, 0x1F4 
    out dx, al  
   

    ; LBA HIGH
    mov al, 0x00 
    mov dx, 0x1F5 
    out dx, al 
   

    ; set sectors to read
    mov al, 10 
    mov dx, 0x1F2 
    out dx, al 
   

    ; set READ comand 
    mov al, 0x20 
    mov dx, 0x1F7 
    out dx, al 
    mov si, KERNEL_ADDR
    
    .polling:
           .bsy:
          	 mov dx, 0x1F7 
        	 in al, dx
   		 test al, 0x80 
	 	 jnz .bsy
	   .drq:
	 	 mov dx, 0x1F7 
		 in al, dx 
		 test al, 0x08 
		 jz .drq 

     mov bx, 256 
     mov dx, 0x1F0 
     
     .read:
    	  in ax, dx 
 	  mov [si], ax
	  add si, 2
 	  dec bx 
  	  jnz .read  

      jmp .polling 
   



    jmp $
       
