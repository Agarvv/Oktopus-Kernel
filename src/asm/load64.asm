 global load_kernel_64 
; i'll leave here some important ports that i'll use 
; 0x1F0 Data R/W 
; 0x1F2 sectors to R/W 
; 0x1F3 Logical block address Low
; 0x1F4 – Logical block addres medium 
; 0x135  Logical block addres high 
; 0x1F6 flags, drive mode, last lba bits...
; 0x1F7 Status and commands
; 0x1F1 Error 

; when read 0x1F7 returns one byte: 
; bit 7   disk is busy
; bit 6  device is ready
; bit 5  device fault
; bit 4  seek completed
; bit 3  data request ready
; bit 2  data corrected
; bit 1  index pulse
; bit 0  error occurred

; those are the commands that go in port 0x1F7 

; 0x20 read sectors (LBA28, PIO)
; 0x30 write sectors (LBA28, PIO)

; 0x24 read sectors extended (LBA48)
; 0x34 write sectors extended (LBA48)

; 0xEC identify device
; used to detect the disk and its capabilities

; 0xEF set features
; enables or disables special disk features

; 0xC6 set multiple mode
; used for multi sector transfers

; in order to load the kernel that is in disk, 
; first, it will check BSY reading port 0x1F7, if BSY is not one,
; check if device is ready
; if ready, perform disk operation starting at LBA X (where the kernel is) using ports 0x1F3–0x1F5 and 0x1F6
; read Y sectors from the disk using port 0x1F2.
; set master disk using 0x1F6
; set 0x24 in port 0x1F7, meaning, read operation.
; then bussy disk will be set to 1, and when disk is ready to transfer data, will set bit 3 of port 0x1F7 to 1
; meaning data request is ready. i'll read data from port 0x1F0 and load it into memory. 
; and so on in loop until disk isnt bussy anymore.

test_ports:
    mov al, 'T' 
    mov dx, 0x3F8 
    out dx, al  

    mov dx, 0x1F7
    in al, dx
    call print_hex_byte 
    jmp $



load_kernel_64:
  
  
   
   ; check if disk can perform operations
    call disk_ok  
    

    ; load LBA
    ; LBA LOW 
    mov al, 0x21 
    out 0x1F3, al 
    call delay 

    ; LBA MEDIUM 
    mov al, 0x00 
    out 0x1F4, al  
    call delay 

    ; LBA HIGH
    out 0x1F5, al 
    call delay 

    ; set sectors to read
    mov al, 10 
    out 0x1F2, al 
    call delay

    ; set READ comand 
    mov al, 0x20 
    out 0x1F7, al 
   call delay
    
    ; now do polling and read data from port 0x1F0.
    call polling 
    
    mov al, 'f' 
    mov dx, 0x3F8 
    out dx, al



   

    jmp $

delay:
    mov dx, 0x3F6    
    in al, dx   

    mov dx, 0x3F6    
    in al, dx   

    mov dx, 0x3F6    
    in al, dx   

    mov dx, 0x3F6    
    in al, dx   

    ret







disk_ok: 
   ; 0x1F6 takes something like this:
    ; 00000000 
    ; ^ always one

    ; 00000000 
    ;  ^ LBA mode

    ; 00000000 
    ;   ^ reserved (always one)

    ; 00000000 
    ;    ^ drive select (0 master, 1 slave)

    ; 00000000 
    ;     ^^^^ last lba bits
    
    ; i'll use 11100000 (0xE0)
    mov al, 0xE0
   
   out 0x1F6, al
   call delay

   .disk_bussy: 
      mov al, 'E'
      mov dx, 0x3F8
      out dx, al
      call delay
 

      ; 00000000 
      ; ^ DISK BUSY 

      ; apply mask to leave only that bit, and if it is not zero it means the disk is bussy
      ; so jump until disk isnt bussy anymore. 
     .in:
      mov al, 'c'
      mov dx, 0x3F8 
      out dx, al


      call delay 
     mov dx, 0x1F7
      in al, dx 
     and al, 0x80 
     ; call print_hex_byte  
    
     ; jmp $ 
     
      jnz .in
       
   

   .disk_ready:
      ; 00000000 
      ;  ^ DISK READY 
      mov dx, 0x1F7
      in al, dx 

      and al, 0x40 
     ; call print_hex_byte 
     ; jmp $


      jz .disk_ready 
      ret 

   .err:
    in al, 0x1F1
    call print_hex_byte
    jmp $

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
     


polling: 
    
    ; read the DRQ bit 
    mov dx, 0x1F7 
    in al, dx 
    ; mask the drq bit
    and al, 0x08  
  

    jz .notread

    .read:
      in ax, 0x1F0 

      mov al, 'r' 
      mov dx, 0x3F8
      out dx, al
       
    
    
    .notread: 
      mov al, 'n' 
      mov dx, 0x3F8  
      out dx, al 
    

   
     mov dx, 0x1F7  
     in al, dx 
    and al, 0x80 
   call print_hex_byte 
    jmp $ 
    jnz polling


   
   ret  
