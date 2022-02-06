
title "Ejercicio 7" 
;Realizar un programa en lenguaje ensamblador para arquitectura x86 que resuelva la siguiente ecuación:
;z = 3*x*x + y/2 + 10*x - 1002
;Para x = 30, y=42. 

;Guardar el resultado de 'z' en memoria.
;'x' y 'y' deben ser variables definidas en memoria de datos.

	.model small	
	.386			
	.stack 64 		
	.data			
;________________________________________________________		

;Variables declaradas-------------------------------------------------------------------------------------------------

;//Aqui van las variables. 

	divY 		db 		02h
	x 			db 		30d		;1Eh
	y 			db 		42d		;2Ah
	producto    db 		?, ?
	cociente 	db 		?
	residuo 	db 		?
	resultado 	dw		0, 0
	z 			dw 		?

	.code				
;________________________________________________________

inicio:					;Etiqueta de inicio.
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos. 
	mov ds,ax 			;DS = AX, inicializa segmento de datos.

;________________________________________________________Flujo principal del programa.

	mov ax, 0
	mov dx, 0

	;Operacion: 3*x*x

	mov al, 03h 				;AL = 03h
	mul [x]						;AX = AL * [x] = 03h * 1Eh = 005Ah. AH = 00h, AL = 5Ah -> C=0, O=0.

	mov [producto], al 			;[producto] = 5Ah
	mov [producto + 1], ah 		;[producto + 1] = 00h

	mov al, [producto]			;AL = 5Ah
	mul [x]						;AX = AL * [x] = 5Ah * 1Eh = 0A8Ch. AH = 0Ah, AL = 8Ch. ->C=0. O=0.

	mov [producto], al 			;[producto] = 8Ch
	mov [producto + 1], ah 		;[producto + 1] = 0Ah

	mov ax, 0

	;3*x*x = 0A8Ch



	;Operacion: y/2

	mov al, [y] 				;AX = 002Ah
	div [divY]					;AL = AX / [var1] = 2Ah / 2h = 15h, Cociente
								;AH = AX % [var1] = 2Ah % 2h = 00h, Residuo con OP Módulo

	mov [cociente], al
	mov [residuo], ah
	mov ax, 0

	;y/2 = 0015h


	;Operacion: 3*x*x + y/2

	mov al, cociente
	mov ah, residuo 			;AX = 0015h

	mov bl, [producto]
	mov bh, [producto + 1] 		;BX = 0A8Ch

	add ax, bx 					;AX = AX + BX = 0015h + 0A8Ch = 0AA1h, C=0.
	mov [resultado], ax 		;[resultado] = 0AA1h

	mov ax, 0

	;Operacion: 10*x

	mov al, 0Ah 				;AX = 000Ah
	mul [x] 					;AX = AL * [x] = 000Ah * 1Eh = 012Ch. AL = 2Ch, AH = 01h. -> C=1, O=1.

	;Operacion: 3*x*x + y/2 + 10*x - 1002

	mov bx, [resultado]			;BX = 0AA1h
	add ax, bx 					;AX = 012Ch + 0AA1h = 0BCDh. C = 0.
	sub ax, 1002d				;AX = 0BCDh - 03EAh = 07E3h
	mov [z], ax 				;[z] = 07E3h



;_______________________________________

salir:					
	mov ah,4Ch			
	mov al,0			
	int 21h				
	end inicio			