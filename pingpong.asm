%define ROW 100
%define ROW 100
%define WIDTH 320
%define HEIGHT 200

%define BALLSIZE 10

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

; ============================================== ;
; ROUTINE:      draw_ball                        ;
; PURPOSE:      Draws ball at position (si, di). ;
; INPUTS:       si - X coordinate.               ;
;               di - Y coordinate.               ;
;               dl - color.                      ;
; OUTPUT:       None                             ;
; MODIFIERS:    None                             ;
; ASSUMPTIONS:  None                             ;
; ============================================== ;
draw_ball:
        push bx
        push dx
        push cx

        push dx
        mov ax, WIDTH
        mul di
        add ax, si
        pop dx

        mov bx, ax
        push bx

        mov ch, BALLSIZE
.draw_row:
        mov cl, BALLSIZE
.draw_cell:
	mov byte [es:bx], dl

        dec cl
        jz .end_cell

        inc bx
        jmp .draw_cell

.end_cell:
        dec ch
        jz .end

        pop bx
        add bx, WIDTH
        push bx

        jmp .draw_row
.end:
        pop bx
        pop cx
        pop dx
        pop bx
        ret

sleep:
        push si
        push ax
        push dx
        push cx


        xor dx, dx

        mov dx, 0x0f42
        xor cx, cx


        mov ah, 86h
.loop:
        int 15h

        dec si
        jz .end
        jmp .loop
.end:
        pop cx
        pop dx
        pop ax
        pop si
        ret

clear:
        push di
        push cx
        push ax

        xor di, di
        mov cx, 320 * 200 / 2
        rep stosb


        pop ax
        pop cx
        pop di
        ret

main:
        ;; Setup stack
        mov ax, 0x900
        mov ss, ax
        mov sp, 0xfffe

        mov ax, 0xa000
        mov es, ax
        
	mov ah, 0h
	mov al, 13h
	int 10h

        mov cl, 5
        mov si, 10
.loop:
        mov al, 76h
        call clear
        
        mov di, 10
        mov dl, 0bh
        call draw_ball

        add si, 10
        push si
        mov si, 50
        call sleep
        pop si

        jmp .loop
.end:
	hlt

times 510 - ($-$$) db 0
dw 0xaa55
