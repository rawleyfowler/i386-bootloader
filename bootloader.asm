    bits 16
    org 0x7c00

    mov si, 0                   ; si needs to be 0 as we will use it to print the string
    mov bl, 0xa                 ; set color of teletype to green

print:
    mov ah, 0x0e                ; ah at 0x0e will allow for output to the terminal/teletype output
    mov al, [string + si]       ; get the si'th character of string
    int 0x10                    ; video services interrupt 10 (teletype)
    add si, 1
    cmp byte [string + si], 0   ; test if we're at the end of the string
    jne print                   ; if we have more characters in the string repeat print

string:
    db "Hello world from bootloader!", 0

times 510 - ($ - $$) db 0       ; fit this inside of the 512 bit sector, by filling with zeroes
dw 0xaa55                       ; last two bytes of a boot sector, magic number. hence 510 vs 512
