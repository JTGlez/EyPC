
title "Ejercicio 2" 
;Elaborar un programa en lenguaje ensamblador para arquitectura Intel x86 que imprima, tal cual, (con saltos de línea) el siguiente mensaje en pantalla:
;c:\>ejer2.exe

;Hola!
;Este es un ejercicio de programacion en lenguaje ensamblador.
;Ahora puedo imprimir en pantalla! =)
;Fin.

;c:\>


	.model small	
	.386			
	.stack 64 		
	.data			
;________________________________________________________		

;Variables declaradas-------------------------------------------------------------------------------------------------

;//Aqui van las variables. 

	;0Dh, 0Ah, se utiliza para realizar saltos de linea al momento de imprimir la cadena en pantalla. El simbolo $ indica el fin de la cadena.
	hola 	db		"Hola!", 0Dh, 0Ah, "Este es un ejercicio de programacion en lenguaje ensamblador.", 0Dh, 0Ah, "Ahora puedo imprimir en pantalla! =)", 0Dh, 0Ah, "Fin.$"


	.code				
;________________________________________________________

inicio:					;Etiqueta de inicio.
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos. 
	mov ds,ax 			;DS = AX, inicializa segmento de datos.

;________________________________________________________Flujo principal del programa.

	;Uso de la instruccion lea y mov para imprimir una cadena en pantalla.

	lea dx,[hola]		;Obtiene posicion de memoria de la cadena que contiene la variable 'hola'
	mov ax, 0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.

;_______________________________________

salir:					
	mov ah,4Ch			
	mov al,0			
	int 21h				
	end inicio			