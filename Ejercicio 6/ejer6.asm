title "SBB" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada pagina de codigo
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;Definicion de variables

; Utilizando la instruccion ADC, suma de los sig. num naturales:
; ABCD 6542
; 7542 F9BC

num1 dw 0EDCBh, 234Fh, 6301h, 0F563h 		 
num2 dw 05FBh, 2165h, 0BCF0h, 4921h 		
resta dw 0,0,0,0,0

	.code				;segmento de codigo
inicio:					;etiqueta inicio
	mov ax,@data 		;AX = directiva @data, @data es una variable de sistema que contiene la direccion del segmento de datos 
	mov ds,ax 			;DS = AX, inicializa segmento de datos
;_______________________________________
;AQUI VA SU CODIGO
	mov ax,[num1] 		
	sub ax,[num2] 		
	Mov [resta],ax 		

	mov ax,[num1+2] 	
	sbb ax,[num2+2] 	
	mov [resta+2],ax 	

	mov ax,[num1+4] 	
	sbb ax,[num2+4] 	
	mov [resta+4],ax 	
	
	mov ax,[num1+6] 	
	sbb ax,[num2+6] 
	mov [resta+6],ax 	


	;_______________________________________
salir:					;inicia etiqueta salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,0			;AL = 0 Exit Code, codigo devuelto al finalizar el programa
						;AX es un argumento necesario para interrupciones
	int 21h				;señal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa