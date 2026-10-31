%define ROW 100
%define ROW 100
%define WIDTH 320
%define HEIGHT 200

%define BALLSIZE 10

org 0x7c00
bits 16

jmp 0x0000:main

msg     db 'Hello, world'
msg_len equ $ - msg
counter db 0


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

handler:
    pusha
    push ds
    push cs
    pop ds

    xor cx, cx
    mov byte cl, [counter]
    inc cl
    mov byte [counter], cl

    pop ds
    popa
    iret

main:
    push cs
    pop ds

    ;; Setup stack
    mov ax, 0x900
    mov ss, ax
    mov sp, 0xfffe

    ;; VRAM (vga frame buffer) starts in base 0xa0000
    mov ax, 0xa000
    mov es, ax
        
    ;; Enable VGA mode
	mov ah, 0h
	mov al, 13h
	int 10h

    ;; Setup interrupt handler
    push es
    xor ax, ax
    mov es, ax

    mov al, 1ch
    mov bl, 4h
    mul bl

    mov bx, ax

    pushf
    cli
    mov word [es:bx], handler
    mov word [es:bx+2], cs
    popf

    pop es

    mov cl, 5
    mov si, 10
    xor bx, bx
    mov byte bl, [counter]
.loop:
    mov al, 76h
    call clear
        
    mov di, 10
    mov dl, 0bh
    call draw_ball

    add si, 10

.wait_counter:
    cmp byte bl, [counter]
    je .wait_counter
    mov byte bl, [counter]
    jmp .loop
.end:
	hlt

times 510 - ($-$$) db 0
dw 0xaa55
