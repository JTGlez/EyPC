
title "Tarea 4: Instruccion ADC" 
;Utilizando la instrucción ADC, entre otras, realizar un programa en lenguaje ensamblador para arquitectura x86 que calcule la suma de los siguientes 2 números hexadecimales:
;1.- ADBC 45BD CF97 DCB3 26C4 89D7 0452 FE13
;2.- BDF3  96AC 435F E163  E307 417B FDE1 87CD

;Almacenar el resultado en memoria de datos.

	.model small 
	.386		
	.stack 64 	
	.data	
;________________________________________________________		

;Datos de una word/palabra (16 bits)-------------------------------------------------------------------------------------------------
hexNumber1		dw 		0FE13h, 0452h, 89D7h, 26C4h, 0DCB3h, 0CF97h, 45BDh, 0ADBCh 	;Variable del primer numero hexadecimal que almacena el número en segmentos contiguos en memoria (pasos de 2 en 2).
hexNumber2		dw 		87CDh, 0FDE1h, 417Bh, 0E307h, 0E163h, 435Fh, 96ACh, 0BDF3h	;Variable del segundo numero hexadecimal.
hexTotal        dw      0, 0, 0, 0, 0, 0, 0, 0, 0; Variable declarada donde será almacenado el resultado de operar hexNumber1 + hexNumber2. Se añade un 0 adicional ante un eventual acarreo.

;Variables miscelaneas ocupadas en el programa.
exCode			db 		0

	.code
;________________________________________________________				
inicio:					
	mov ax,@data 		
	mov ds,ax 			

;________________________________________________________Flujo principal del programa.

	mov ax, [hexNumber1]; El contenido de la primera seccion se traslada a AX, tal que: AX = [hexNumber1] = 0FE13h.
	add ax, [hexNumber2]; Se realiza la suma del primer segmento entre hexNumber1 y hexNumber2, con: AX = 0FE13h + 87CDh = 85E0h, con C=1.
	mov [hexTotal], ax  ; El contenido de AX se traslada a hexTotal, con: [hexTotal] = 85E0h.

	;Vista actual: 85E0h, 0, 0, 0, 0, 0, 0, 0, 0 

	mov ax, [hexNumber1 + 2]; Ahora, realizamos un desplazamiento de dos ubicaciones para llegar a 0452h. Entonces: AX = [hexNumber1 + 2] = 0452h.
	adc ax, [hexNumber2 + 2]; Se realiza la suma con el contenido de AX y el segundo "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 2] + [hexNumber2 + 2] + C = 0452h + 0FDE1h + 1 = 0234h, con C=1.  
	mov [hexTotal + 2], ax 	; El contenido de AX se traslada a [hexTotal + 2] en la segunda ubicación declarada, entonces: [hexTotal + 2] = 0234h. 

	;Vista actual: 85E0h, 0234h, 0, 0, 0, 0, 0, 0, 0 

	mov ax, [hexNumber1 + 4]; Ahora, realizamos un desplazamiento de 4 ubicaciones para llegar a 89D7h. Entonces: AX = [hexNumber1 + 4] = 89D7h.
	adc ax, [hexNumber2 + 4]; Se realiza la suma con el contenido de AX y el tercer "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 4] + [hexNumber2 + 4] + C = 89D7h + 417Bh + 1 = 0CB53h, con C=0.  
	mov [hexTotal + 4], ax 	; El contenido de AX se traslada a [hexTotal + 4] en la tercera ubicación declarada, entonces: [hexTotal + 4] = 0CB53h. 

	;Vista actual: 85E0h, 0234h, 0CB53h, 0, 0, 0, 0, 0, 0 

	mov ax, [hexNumber1 + 6]; Ahora, realizamos un desplazamiento de 6 ubicaciones para llegar a 26C4h. Entonces: AX = [hexNumber1 + 6] = 26C4h.
	adc ax, [hexNumber2 + 6]; Se realiza la suma con el contenido de AX y el cuarto "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 6] + [hexNumber2 + 6] = 26C4h + 0E307h = 09CBh, con C=1.  
	mov [hexTotal + 6], ax 	; El contenido de AX se traslada a [hexTotal + 6] en la cuarta ubicación declarada, entonces: [hexTotal + 6] = 09CBh. 

	;Vista actual: 85E0h, 0234h, 0CB53h, 09CBh, 0, 0, 0, 0, 0 

	mov ax, [hexNumber1 + 8]; Ahora, realizamos un desplazamiento de 8 ubicaciones para llegar a 0DCB3h. Entonces: AX = [hexNumber1 + 8] = 0DCB3h.
	adc ax, [hexNumber2 + 8]; Se realiza la suma con el contenido de AX y el quinto "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 8] + [hexNumber2 + 8] = 0DCB3h + 0E163h + 1 = 0BE17h, con C=1.  
	mov [hexTotal + 8], ax 	; El contenido de AX se traslada a [hexTotal + 8] en la quinta ubicación declarada, entonces: [hexTotal + 8] = 0BE17h. 

	;Vista actual: 85E0h, 0234h, 0CB53h, 09CBh, 0BE17h, 0, 0, 0, 0 

	mov ax, [hexNumber1 + 10]; Ahora, realizamos un desplazamiento de 10 ubicaciones para llegar a 0CF97h. Entonces: AX = [hexNumber1 + 10] = 0CF97h.
	adc ax, [hexNumber2 + 10]; Se realiza la suma con el contenido de AX y el sexto "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 10] + [hexNumber2 + 10] = 0CF97h + 435Fh + 1 = 12F7h, con C=1.  
	mov [hexTotal + 10], ax  ; El contenido de AX se traslada a [hexTotal + 10] en la sexta ubicación declarada, entonces: [hexTotal + 10] = 12F7h. 

	;Vista actual: 85E0h, 0234h, 0CB53h, 09CBh, 0BE17h, 12F7h, 0, 0, 0 

	mov ax, [hexNumber1 + 12]; Ahora, realizamos un desplazamiento de 12 ubicaciones para llegar a 45BDh. Entonces: AX = [hexNumber1 + 12] = 45BDh.
	adc ax, [hexNumber2 + 12]; Se realiza la suma con el contenido de AX y el septimo "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 12] + [hexNumber2 + 12] = 45BDh + 96ACh + 1 = DC6Ah, con C=0.  
	mov [hexTotal + 12], ax  ; El contenido de AX se traslada a [hexTotal + 12] en la septima ubicación declarada, entonces: [hexTotal + 12] = DC6Ah. 

	;Vista actual: 85E0h, 0234h, 0CB53h, 09CBh, 0BE17h, 12F7h, DC6Ah, 0, 0 

	mov ax, [hexNumber1 + 14]; Ahora, realizamos un desplazamiento de 14 ubicaciones para llegar a 0ADBCh. Entonces: AX = [hexNumber1 + 14] = 0ADBCh.
	adc ax, [hexNumber2 + 14]; Se realiza la suma con el contenido de AX y el octavo "segmento" de hexNumber2, de allí: AX = [hexNumber1 + 14] + [hexNumber2 + 14] = 0ADBCh + 0BDF3h = 6BAF, con C=1.  
	mov [hexTotal + 14], ax  ; El contenido de AX se traslada a [hexTotal + 14] en la octava ubicación declarada, entonces: [hexTotal + 14] = 6BAFh. 

	;Vista actual: 85E0h, 0234h, 0CB53h, 09CBh, 0BE17h, 12F7h, DC6Ah, 6BAFh, 0 

	adc [hexTotal + 16], 0   ; Se suma el acarreo obtenido de la suma anterior, entonces: [hexTotal + 16] + 0000h + 1 = 0001h

	;Vista actual: 85E0h, 0234h, 0CB53h, 09CBh, 0BE17h, 12F7h, DC6Ah, 6BAFh, 0001h 

;________________________________________________________Fin del flujo principal. 

salir:					
	mov ah,4Ch			
	mov al, [exCode]				
	int 21h				
	end inicio			

	