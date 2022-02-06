title "Ejemplo ADC" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definicion de variables
num1	dw 		6542h,0ABCDh
;num1    dd 		0ABCD6542h
num2	dw 		0F9BCh,7542h
suma 	dw 		0,0,0
	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
;_______________________________________
;AQUI VA SU CODIGO
	mov ax,[num1] 		;AX = [num1]
	add ax,[num2] 		;AX = AX + [num2] => AX=6542h+F9BCh=5EFEh => C=1
	mov [suma],ax 		;[suma] = AX = 5EFEh

	mov ax,[num1+2] 	;AX=[num1+2] = 0ABCDh
	adc ax,[num2+2] 	;AX=AX+[num2+2]+C=ABCDh+7542h+1=2110h, C=1
	mov [suma+2],ax 	;[suma+2]=AX=2110h

	adc [suma+4],0	 	;[suma+4]=[suma+4]+0000h+C=0001h
	;adc [000Ch],0 		;[suma+4]=[suma+4]+0000h+C=0001h
;_______________________________________
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa