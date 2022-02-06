title "Ejemplo ADD y SUB" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definicion de variables
suma	db 		?
resta	db 		?
X db 100d
Y db 240d
Z db 080d
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
;_______________________________________
;AQUI VA SU CODIGO
	
	mov al,X 			;AL = 100d = 64h
	mov bl,Y 			;BL = 240d = F0h
	add al,bl			;AL = AL + BL = 64h + F0h = 54h      C=1
	add al,Z			;AL = AL + BL = 54h + 50h = A4h      C=1
	sub al,043d 		;AL = AL - BL = A4h - 2Bh = 79h      C=1
	sub al,040d			;AL = AL - BL = 79h - 28h = 51h      C=1
;_______________________________________
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa