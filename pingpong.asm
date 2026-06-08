org 0x7c00
bits 16

jmp main

msg     db 'Hello, world'
msg_len equ $ - msg

; ====================================================== ;
; ROUTINE:      putc                                     ;
; PURPOSE:      Print a character on the screen.         ;
; INPUTS:       al - character to be printed             ;
; OUTPUT:       None                                     ;
; MODIFIERS:    None                                     ;
; ASSUMPTIONS:  None                                     ;
; ====================================================== ;
putc:	
        push ax

	mov ah, 0eh
	int 10h

        pop ax
        ret

; ====================================================== ;
; ROUTINE:      putss                                    ;
; PURPOSE:      Print a string on the screen.            ;
; INPUTS:       SI - Pointer to the start of the string. ;
;               CX - Size ot the string.                 ;
; OUTPUT:       None                                     ;
; MODIFIERS:    None                                     ;
; ASSUMPTIONS:  None                                     ;
; ====================================================== ;
putss:	
	push ax
        push si
        push dx
.loop:
        or cx, 0
        jz .end
        lodsb
        call putc
        dec cx
        jmp .loop
.end:
        pop cx
        pop si
        pop ax
        ret
        
main:
	mov ah, 0h
	mov al, 13h
	int 10h

	mov ax, 0xa000
	mov es, ax

	mov bx, 0
loop:
	mov byte [es:bx], 0x0b
	inc bx
	cmp bx, 64000
	jb loop

	hlt

times 510 - ($-$$) db 0
dw 0xaa55
