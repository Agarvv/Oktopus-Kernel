org 0x7C00

section .text 
start:

; mov dx, 0x3F8
; mov al, 'D'
; out dx, al

mov al, 0xFF    
out 0x21, al    
out 0xA1, al    ; desactivate pic 

mov si, dap ; bios uses dap data structure to perform disk operations
mov ah, 0x42 ; extended read fn 
mov dl, 0x80 ; first disk 
int 0x13 ; disk int 
jc disk_err ; if error bios sets the carry flag to one



mov ax, 2401h
int 15h ; enable a20

cli ; clear interruptions
lgdt [gdt_des] ; load gdt descriptor 



mov eax, cr0
or eax, 1 ; mask protected mode bit
mov cr0, eax

jmp 0x08:protected_mode_start


disk_err: 
    mov ah, bl
    mov dx, 0x3F8
    mov al, 'E'
    out dx, al

    dec bl 
    jnz disk_err
    jmp $
      


bits 32
protected_mode_start:

; prepare segment registers 
mov ax, 0x10
mov ds, ax ; data segment
mov es, ax ; extra segment
mov fs, ax ; fs segment
mov gs, ax ; gs segment
mov ss, ax ; stack segment
mov esp, 0x400000 ; stack poitner 






mov edi, 0xB8000
mov byte [edi], 'U'
mov byte [edi+1], 0x07 

mov edi, 0xB8000
mov byte [edi+2], 'f'
mov byte [edi+3], 0x07


mov esi, 0x10000

mov ecx, 16          
mov edi, 0xB8000+160  

.debug_loop:
    mov al, [esi]    
    mov bl, al     
    shr bl, 4
    and bl, 0x0F
    add bl, '0'
    cmp bl, '9'
    jle .ok1
    add bl, 7
.ok1:
    mov byte [edi], bl
    mov byte [edi+1], 0x07

    mov bl, al
    and bl, 0x0F
    add bl, '0'
    cmp bl, '9'
    jle .ok2
    add bl, 7
.ok2:
    mov byte [edi+2], bl
    mov byte [edi+3], 0x07

    add esi, 1
    add edi, 4
    loop .debug_loop  

    ; before enabling paging, i have to 
    ; configure cr3 register so this 
    ; can point to the page directory base addr. 

    ; cr3 register may look sort of: 
    ; 00000000 00000000 00000000 00000000 
    ; ^^^^^^^^ ^^^^^^^^ ^^^^ 
    ; Those are the bits that contain the PDBA. 
    ;push eax 
    ;mov eax, cr3 
     

    ;pop eax 
    

    ; in order to enable paging, i need to  
    ; set bit 31 "paging enable" to 1. 
    ; 00000000 00000000 00000000 00000000 
    ; ^ 
    ; PG (paging enable) 

    ; mask: OR with 10000000 00000000 00000000 00000000
    ; (0x80000000)

    ;push eax 
    ;mov eax, cr0 
    ;OR eax, 0x80000000 
    ;mov cr0, eax 
    ;pop eax 

    sti 
    jmp 0x08:0x10000

paging_init:
    








times ($$-$) & 1 db 0  
dap:
    db 0x10       ; size
    db 0x00       ; reserved
    dw 50          ; number of sectors
    dw 0x0000     ; offset = 0
    dw 0x1000     ; segment = 0x1000 → REAL MODE addr = 0x10000
    dd 1          ; LBA low
    dd 0          ; LBA high



gdt_start:
dq 0

; code   
dw 0xFFFF  
dw 0x0000  
db 0x00  
db 10011010b      
db 11001111b      
db 0x00  

  ; data  
dw 0xFFFF  
dw 0x0000  
db 0x00  
db 10010010b      
db 11001111b     
db 0x00
 
; 64 bit code 
dw 0xFFFF
dw 0x0000
db 0x00
db 10011010b
db 11001111b
db 0x00
gdt_end:

gdt_des:
dw gdt_end - gdt_start - 1
dd gdt_start
 
   



times 510 - ($-$$) db 0

dw 0xAA55 
