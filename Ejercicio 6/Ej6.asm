
title "Ejercicio 6" 
;Utilizando la instrucción SBB, realice un programa en lenguaje ensamblador para arquitectura x86 que calcule la resta de los siguientes números hexadecimales:

;1.- F563 6301 234F EDCB 
;2.- 4921 BCF0 2165 05FB
;El resultado se debe almacenar en memoria de datos. 

;Pista: el resultado de la resta es AC 41 A6 11 01 EA E7 D0

	.model small	
	.386			
	.stack 64 		
	.data			
;________________________________________________________		

;Variables declaradas-------------------------------------------------------------------------------------------------

;//Aqui van las variables. 

	num1 	 dw 	0EDCBh, 234Fh, 6301h, 0F563h 
	num2 	 dw 	05FBh, 2165h, 0BCF0h, 4921h
	resta 	 dw		0, 0, 0, 0, 0

	.code				
;________________________________________________________

inicio:					;Etiqueta de inicio.
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos. 
	mov ds,ax 			;DS = AX, inicializa segmento de datos.

;________________________________________________________Flujo principal del programa.

	mov ax, [num1]		;AX = 0EDCBh
	sub ax, [num2]		;AX = 0EDCBh - 05FBh = E7D0h, C=0.
	mov [resta], ax 	;[resta] = E7D0h

	;Estado actual: E7D0h, 0, 0, 0, 0

	mov ax, [num1 + 2]	;AX = 234Fh
	adc ax, [num2 + 2]	;AX = 234Fh - 2165h = 01EAh, C=0.
	mov [resta + 2], ax ;[resta + 2] = 01EAh

	;Estado actual: E7D0h, 01EAh, 0, 0, 0

	mov ax, [num1 + 4]	;AX = 6301h
	adc ax, [num2 + 4]	;AX = 6301h - 0BCF0h = A611h, C=1.
	mov [resta + 4], ax ;[resta + 4] = A611h

	;Estado actual: E7D0h, 01EAh, A611h, 0, 0

	mov ax, [num1 + 6] 	;AX = 0F563h
	adc ax, [num2 + 6]	;AX = 0F563h - 4921h - 1 = AC41h, C=0.
	mov [resta + 6], ax ;[resta + 6] = AC41h

	;Estado final: E7D0h, 01EAh, A611h, AC41h, 0

;_______________________________________

salir:					
	mov ah,4Ch			
	mov al,0			
	int 21h				
	end inicio			