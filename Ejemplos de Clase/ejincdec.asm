title "Ejemplo INC y DEC" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definicion de variables
contador 	db 		0
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
;_______________________________________
;AQUI VA SU CODIGO

	mov ax,252d 	;AX = 252d = 00FCh
	inc ax 			;AX = AX + 1 = 00FDh
	inc ax 			;AX = AX + 1 = 00FEh
	inc ax 			;AX = AX + 1 = 00FFh
	inc al 			;AL = AL + 1 = 00h

	dec ax 			;AX = AX - 1 = 0000h - 1 = FFFFh
	dec al 			;AL = AL - 1 = FFh - 1 = FEh
	dec ah 			;AH = AH - 1 = FFh - 1 = FEh => AX = FEFEh

	inc [contador] 	;[contador] = [contador] + 1
	dec [contador] 	;[contador] = [contador] - 1
	
;_______________________________________
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa