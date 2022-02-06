
title "Ejercicio 3" 
;Realizar un programa en lenguaje ensamblador para arquitectura x86 que calcule la siguiente operación:

;resultado = X + Y + Z – 43d – 40d

;Tal que X, Y y Z, son variables de tipo byte almacenadas en memoria de datos, donde X=100d, Y=240d, Z=80d

;*La 'd' al final de los números indica que esos valores son decimales.
;*El resultado se debe almacenar en una variable de memoria de datos.
;*Se debe ejecutar operación por operación, no simplificar los términos (-43d-40d)

;Pista: el resultado es mayor a 255d y no cabe en una variable de tipo byte.

	.model small	
	.386			
	.stack 64 		
	.data			
;________________________________________________________		

;Variables declaradas-------------------------------------------------------------------------------------------------

;//Aqui van las variables. 

	X 	 db 	100d
	Y 	 db 	240d
	Z 	 db 	80d 	

	.code				
;________________________________________________________

inicio:					;Etiqueta de inicio.
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos. 
	mov ds,ax 			;DS = AX, inicializa segmento de datos.

;________________________________________________________Flujo principal del programa.

	mov al, X 		;AL = 100d = 64h
	mov bl, Y 		;BL = 240d = F0h
	add al, bl  	;AL = AL + BL = 64h + F0h = 54h      C=1
	add al, Z   	;AL = AL + BL = 54h + 50h = A4h      C=1
	sub al, 043d	;AL = AL - BL = A4h - 2Bh = 79h      C=1
	sub al, 040d	;AL = AL - BL = 79h - 28h = 51h      C=1


;_______________________________________

salir:					
	mov ah,4Ch			
	mov al,0			
	int 21h				
	end inicio			