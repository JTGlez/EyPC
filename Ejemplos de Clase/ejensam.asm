title "Ejemplo para ensamblador"
	.model small
	.386
	.stack 64
	.data
tenter 	equ		0Dh
a		equ		'a'
e		equ		'e'
i		equ		'i'
o		db		'o'
u		db		'u'
	.code
inicio:
	mov ax,@data
	mov ds,ax
lee_teclado:
	mov ah,08h
	int 21h
	cmp al,tenter
	je salir
	or al,20h
	cmp al,a
	je imprime
	cmp al,e
	je imprime
	cmp al,i
	je imprime
	cmp al,[o]
	je imprime
	cmp al,[u]
	je imprime
	jmp lee_teclado
imprime:
	mov dl,al
 	mov ah,02h
 	int 21h
 	jmp lee_teclado
salir:
	mov ax,4C00h
	int 21h
	end inicio