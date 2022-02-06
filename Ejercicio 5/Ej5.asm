
title "Ejercicio 5" 
;Utilizando la instrucción ADC, realice un programa en lenguaje ensamblador para arquitectura x86 que calcule la suma de los siguientes números hexadecimales:

;1.- F563 6301 234F EDCB 
;2.- 4921 BCF0 2165 05FB
;El resultado se debe almacenar en memoria de datos. 

;Pista: el resultado de la suma es 00 01 3E 85 1F F1 44 B4 F3 C6

	.model small	
	.386			
	.stack 64 		
	.data			
;________________________________________________________		

;Variables declaradas-------------------------------------------------------------------------------------------------

;//Aqui van las variables. 

	num1 	 dw 	0EDCBh, 234Fh, 6301h, 0F563h 
	num2 	 dw 	05FBh, 2165h, 0BCF0h, 4921h
	suma 	 dw		0, 0, 0, 0, 0

	.code				
;________________________________________________________

inicio:					;Etiqueta de inicio.
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos. 
	mov ds,ax 			;DS = AX, inicializa segmento de datos.

;________________________________________________________Flujo principal del programa.

	mov ax, [num1]		;AX = 0EDCBh
	add ax, [num2]		;AX = 0EDCBh + 05FBh = F3C6h, C=0.
	mov [suma], ax 		;[suma] = F3C6h

	;Estado actual: F3C6h, 0, 0, 0, 0

	mov ax, [num1 + 2]	;AX = 234Fh
	adc ax, [num2 + 2]	;AX = 234Fh + 2165h = 44B4h, C=0.
	mov [suma + 2], ax 	;[suma + 2] = 44B4h

	;Estado actual: F3C6h, 44B4h, 0, 0, 0

	mov ax, [num1 + 4]	;AX = 6301h
	adc ax, [num2 + 4]	;AX = 6301h + 0BCF0h = 1FF1h, C=1.
	mov [suma + 4], ax 	;[suma + 4] = 1FF1h

	;Estado actual: F3C6h, 44B4h, 1FF1h, 0, 0

	mov ax, [num1 + 6] 	;AX = 0F563h
	adc ax, [num2 + 6]	;AX = 0F563h + 4921h + 1 = 3E85h, C=1.
	mov [suma + 6], ax 	;[suma + 6] = 3E85h

	;Estado actual: F3C6h, 44B4h, 1FF1h, 3E85h, 0

	adc [suma + 8], 0 	;[suma + 8]  = 0000h + 1 = 0001h

	;Estado final: F3C6h, 44B4h, 1FF1h, 3E85h, 0001h

;_______________________________________

salir:					
	mov ah,4Ch			
	mov al,0			
	int 21h				
	end inicio			