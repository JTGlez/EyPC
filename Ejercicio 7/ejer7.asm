title "Ejercicio7" ;directiva 'title' opcional
	.model small		;model small (segmentos de datos y codigo limitado hasta 64 KB cada uno)
	.386		;directiva para indicar version procesador
	.stack 64		;tamano de stack/pila, define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos

var1 db 02h
num_byte_x	db	30d		;variable num_byte_x de tipo byte 
num_byte_y	db	42d		;variable num_byte_y de tipo byte 
productoB	db	?,?		;variable productoB de tipo byte (ocupa 2 bytes), almacena el resultado de una multiplicacion sin signo de dos numeros de 8 bits
cocienteB	db	?		;variable cocienteB de tipo byte, almacena el cociente de una division sin signo de un dividendo de 16 bits con un divisor de 8 bits
residuoB	db	?		;variable residuoB de tipo byte, almacena el residuo de una division sin signo de un dividendo de 16 bits con un divisor de 8 bits
resultado   dw 0,0
z dw ?					; varible guardará el resultado final


	.code				;segmento de codigo
inicio:					;etiqueta start
	mov ax,@data 		;AX = directiva @data
	mov ds,ax 			;DS = AX, inicializa registro de segmento de datos


;Limpiar registro AX y DX (para evitar confusiones)
	mov ax,0
	mov dx,0

;Instruccion mul 8 bits
	mov al, 03h				;AL = 03h
	mul [num_byte_x]		;AX = AL * [num_byte] = 03h * 1Eh  = 005Ah. AH igual a 00h => C=0, O=0
	
;Guarda resultado en memoria (variable productoB)
	mov [productoB],al 		;[productoB] = AL = 5Ah
	mov [productoB+1],ah 	;[productoB+1] = AH = 00h



;Multiplicacion numero 2
	mov aL, [productoB]		;AX = 5Ah
	mul [num_byte_x]		;AX = AL * [num_byte] = 5Ah * 1Eh = 0A8Ch. AH igual a 00h => C=1, O=1
	
;Guarda resultado en memoria (variable productoB)
	mov [productoB],al 		;[productoB] = AL = 8Ch
	mov [productoB+1],ah 	;[productoB+1] = AH = 0Ah

;Limpiar registro AX 
	mov ax,0




;Division
	;Instruccion div 8 bits
	mov al,num_byte_y		;AX = 2Ah
	div [var1]				;AL = AX / [var1] = 2Ah / 2h = 15h, Cociente
							;AH = AX % [var1] = 2Ah % 2h = 00h, Residuo

	;Guarda resultado en memoria (variables cocienteB y residuoB)
	mov [cocienteb],al 		;[cocienteb] = AL = 15h
	mov [residuoB],ah 		;[residuoB] = AH = 00h

;Limpiar registro AX 
	mov ax,0




; tenemos 3*x*x = 0A8Ch
; tenemos y/2   = 0015h
; Sumamos estos 2 datos

	;Regresamos los valores del resultado de la division en Ax = 0015h
	mov al, cocienteB 		;AL = [cocienteb] = 15h
	mov ah, residuoB 		;AH = [residuob] = 00h
	
	;Regresamos los valores del resultado de la division en Bx = 0A8Ch
	mov bl, productoB 		;BL = [productoB] = 8Ch
	mov bh, [productoB+1]	;BH = [productoB+1] = 0Ah

	;Realizamos la suma y guardamos el resultado
	add ax, bx			;AX = AX + BX => AX= 0015h + 0A8Ch = 0AA1h => C=0
	mov [resultado], ax ;[resultado] = AX = 0AA1h



;Limpiar registro AX, bx
	mov ax,0
	mov bx,0

;Instruccion mul 8 bits
	mov al, 10d				;AL = 0Ah
	mul [num_byte_x]		;AX = AL * [num_byte] = 0Ah * 1Eh = 012Ch. AH igual a 01h => C=1, O=1

;Regresamos los valores del resultado de la suma anterior en Bx = 0AA1h
	mov bx, resultado

;Realizamos la suma  = (3*x*x + y/2) + (10*x)
	add ax, bx				;AX = AX + BX => AX= 012Ch + 0AA1h = 0BCDh => C=0

;Realizamos la resta = (3*x*x + y/2 + 10*x) - 1002
	sub ax, 1002d 	; AX = AX - 03EAh = 0BCDh - 03EAh = 07E3h

	mov [z], ax		; [z] = AX = 07E3h
	


salir:					;inicia etiqueta Salir
	mov ah,4Ch			;AH = 4Ch, opcion para terminar programa
	mov al,00h			;AL = 0 exit Code, codigo devuelto al finalizar el programa
	int 21h				;senal 21h de interrupcion, pasa el control al sistema operativo
	end inicio			;fin de etiqueta inicio, fin de programa