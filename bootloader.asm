extern main                     ; Our C main

section .text
bits 16
    mov si, 0                   ; si needs to be 0 as we will use it to print the string

print:
    mov ah, 0x0e                ; ah at 0x0e will allow for output to the terminal/teletype output
    mov al, [string + si]       ; get the si'th character of string
    int 0x10                    ; video services interrupt 10 (teletype)
    add si, 1
    cmp byte [string + si], 0   ; test if we're at the end of the string
    jne print                   ; if we have more characters in the string repeat print
    ret

string:
    db "Loading kernel!", 0

    times 510 - ($ - $$) db 0       ; fit this inside of the 512 bit sector, by filling with zeroes
    dw 0xaa55                       ; last two bytes of a boot sector, magic number. hence 510 vs 512

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
    mov bx, 0x1000
    mov es, bx                  ; moving to 0x10000 physical
    mov bx, 0x0
    int 0x13                    ; bios interrupt for kernel
    call main
    
