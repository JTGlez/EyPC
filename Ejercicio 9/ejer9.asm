title "Ejercicio 9" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small ;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386		;directiva para indicar version del procesador
	.stack 64 	;Define el tamaño del segmento de stack, se mide en bytes
	.data		;Definicion del segmento de datos
num1 	db 		1
num2	db 		15
mayor 	db		"El primer numero es mayor al segundo",0Ah,"$"
menor 	db		"El segundo numero es mayor al primero",0Ah,"$"
igual 	db		"Los dos numeros son iguales",0Ah,"$"
; ja,jg 	mayor que
; je 		igual que
; jb,jl 	menor que
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos

	mov al,[num1]
	cmp al,[num2]
	ja mayorque
	je igualque
	jb menorque 


igualque:
	lea dx,[igual]
	jmp imprime

mayorque:
	lea dx,[mayor]
	jmp imprime

menorque:
	lea dx,[menor]
	jmp imprime

imprime:
	mov ax,0900h		;opcion 9 para interrupcion 21h
	int 21h				;interrupcion 21h. Imprime cadena.

salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0, Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa