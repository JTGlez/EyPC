
title "Ejercicio 1" 
;Elaborar un programa en lenguaje ensamblador para arquitectura Intel x86 que inicialice los registros AX, BX, CX y DX, con los valores siguientes:
;AX = 1111h
;BX = 1212h
;CX = ABCDh
;DX = FFFFh

;Posteriormente, sin utilizar direccionamiento inmediato, el programa debe hacer operaciones para que el contenido del registro AX pase a DX, el de BX a CX, 
;el CX a BX y el de DX a AX; de manera que el resultado sea el siguiente:

;AX = 0FFFFh
;BX = 0ABCDh
;CX = 1212h
;DX = 1111h

	.model small	
	.386			
	.stack 64 		
	.data			
;________________________________________________________		

;Variables declaradas-------------------------------------------------------------------------------------------------

;//Aqui van las variables. 

	.code				

;________________________________________________________
inicio:					;Etiqueta de inicio.
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos. 
	mov ds,ax 			;DS = AX, inicializa segmento de datos.

;________________________________________________________Flujo principal del programa.

	mov ax, 1111h ; Inicializa el registro AX con el valor 1111h,  tal que AX=1111h.
	mov bx, 1212h ; Inicializa el registro BX con el valor 1212h,  tal que BX=1212h.
	mov cx, 0ABCDh; Inicializa el registro CX con el valor 0ABCDh, tal que CX=0ABCDh.
	mov dx, 0FFFFh; Inicializa el registro DX con el valor 0FFFFh, tal que DX=0FFFFh.


	;Para realizar las operaciones de traslado con mov, se usara el registro SI como registro de almacenamiento temporal para intercambiar valores entre AX/DX y BX/CX. 
	;1111h se movera desde AX hasta DX
	;1212h se movera desde BX hasta CX
	;ABCDh se movera desde CX hasta BX
	;FFFFh se movera desde DX hasta AX

	mov si, ax; Se traslada el contenido de AX al registro SI como paso intermedio. SI=1111h.
	mov ax, dx; Movemos 0FFFFh desde DX hacia AX directamente con direccionamiento entre registros. AX=0FFFFh.
	mov dx, si; Ahora, movemos 1111h hacia DX desde SI. DX=1111h.

	;AX=0FFFFh.
	;DX=1111h.

	mov si, bx; Se usa de nuevo SI como almacenamiento temporal del valor almacenado en BX. SI=1212h.
	mov bx, cx; Se traslada directamente el contenido de CX a BX. BX=0ABCDh.
	mov cx, si; Finalmente, se traslada el valor 1212h a CX. CX=1212h. 

	;BX=0ABCDh.
	;CX=1212h.
	
;_______________________________________

salir:					
	mov ah,4Ch			
	mov al,0			
	int 21h				
	end inicio			