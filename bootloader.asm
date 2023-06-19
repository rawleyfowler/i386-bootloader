extern main                     ; Our C main

section .text
global _start
global print

bits 16

kernel_msg:
    db "Loading Kernel", 0
    
loading_msg:
    db "Loading kernel!", 0

mov si, [loading_msg]
call print

print:
    mov ah, 0x0e                ; ah at 0x0e will allow for output to the terminal/teletype output
    mov al, byte [si]           ; get the si'th character of string
    int 0x10                    ; video services interrupt 10 (teletype)
    inc si
    cmp byte [si], 0            ; test if we're at the end of the string
    jne print                   ; if we have more characters in the string repeat print
    popa
    ret

times 510 - ($ - $$) db 0 ; fit this inside of the 512 bit sector, by filling with zeroes
dw 0xaa55 ; last two bytes of a boot sector, magic number. hence 510 vs 512

;;; Kernel loading segment
bits 32

;;; The following code enables A20, a pre-requisite for kernel loading
;;; https://wiki.osdev.org/A20_Line
enable_A20:
    cli
    
    call    a20wait
    mov     al, 0xAD
    out     0x64,al
    
    call    a20wait
    mov     al, 0xD0
    out     0x64,al
    
    call    a20wait2
    in      al, 0x60
    push    eax
    
    call    a20wait
    mov     al, 0xD1
    out     0x64, al
    
    call    a20wait
    pop     eax
    or      al, 2
    out     0x60, al
    
    call    a20wait
    mov     al, 0xAE
    out     0x64, al
    
    call    a20wait
    sti
    ret
    
a20wait:
    in      al, 0x64
    test    al, 2
    jnz     a20wait
    ret

a20wait2:
    in      al, 0x64
    test    al, 1
    jz      a20wait2
    ret

kernel:
    ; bx = 0, es:bx = 0x1000:0
    mov si, [kernel_msg]
    call print
    mov bx, 0x1000
    mov es, bx                  ; moving to 0x10000 physical
    mov bx, 0x0
    int 0x13                    ; bios interrupt for kernel
    call main
    
