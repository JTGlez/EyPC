title "Ejemplo ADD y SUB" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definicion de variables
suma	db 		?
resta	db 		?
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
;_______________________________________
;AQUI VA SU CODIGO

	mov al,100d 		;AL = 100d = 64h
	mov bl,140d 		;BL = 140d = 8Ch
	add al,bl			;AL = AL + BL = 64h + 8Ch = F0h
	mov [suma],al 		;[suma] = AL = F0h
	add [suma],bl		;[suma] = [suma] + BL = F0h + 8Ch = 170h => [suma]=70h, C=1

	mov al,100d 		;AL = 100d = 64h
	mov bl,140d 		;BL = 140d = 8Ch
	sub bl,al 			;BL = BL - AL = 8Ch - 64h = 28h

	mov [resta],bl 		;[resta] = BL = 28h

	mov al,100d 		;AL = 100d = 64h
	mov bl,140d 		;BL = 140d = 8Ch
	sub al,bl 			;AL = 64h - 8Ch = D8h
;_______________________________________
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa