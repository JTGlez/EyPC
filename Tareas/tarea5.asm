
title "Tarea 5: Sucesión de Fibonacci" 
;Desarrollar un programa en lenguaje ensamblador para arquitectura Intel x86 que calcule los primeros
;22 terminos de la sucesión de Fibonacci y los imprima en pantalla.

	.model small 
	.386		
	.stack 64 	
	.data	
;________________________________________________________		

;Datos declarados-------------------------------------------------------------------------------------------------

num1 dw 0
num2 dw 1 
resultado dw 0
acumResiduo dw 0

;Variables miscelaneas ocupadas en el programa.
exCode			 db 	0
fibonacci1       db		0Ah, 0Dh, 'El primer valor es: 00000'
				 db		0Ah, 0Dh, 'El valor es: 00001$'
fibonacci2       db		0Ah, 0Dh, 'El valor es: $'

	.code

;________________________________________________________Procedimientos.

;El procedimiento proc se encarga de imprimir los digitos en pantalla de cada uno de los valores de la sucesion
;de Fibonacci calculados por el programa durante el flujo principal.
impresion proc

	;Para obtener el quinto dígito a imprimir, se realiza una division sobre 10,000.
	mov ax, resultado; El termino calculado se envia a AX para dividirlo sobre 10,000.
	mov bx, 10000; BX sera utilizado como el divisor para AX.
	xor dx, dx; Se realiza una limpieza de DX ya que la operacion anterior requiere DX:AX
	div bx; El cociente se almacena en AX y el residuo en DX, siendo el cociente el digito deseado y el residuo
		  ; el elemento requerido para obtener el resto de digitos a imprimir.
	mov acumResiduo, dx; Se utiliza la variable acumResiduo para almacenar temporalmente el residuo obtenido
					   ; de la operacion anterior. 

    
    ;Se imprime el quinto digito con las siguientes instrucciones. AL es utilizado asumiendo que el valor
    ;obtenido de la division se trata de un digito almacenable en unicamente la parte baja. 
     
	mov ah, 02h
	mov dl, al
	add dl, 30h
	int 21h

	;Para obtener el cuarto dígito a imprimir, se realiza una division sobre 1000.
	mov ax, acumResiduo
	mov bx, 1000
	xor dx, dx
	div bx

	mov acumResiduo, dx

	;Se imprime el cuarto digito con las siguientes instrucciones.
	mov ah, 02h
	mov dl, al
	add dl, 30h
	int 21h


	;Para obtener el tercer dígito a imprimir, se realiza una division sobre 100.
	mov ax, acumResiduo
	mov bx, 100
	xor dx, dx
	div bx

	mov acumResiduo, dx

	;Se imprime el tercer digito con las siguientes instrucciones.
	mov ah, 02h
	mov dl, al
	add dl, 30h
	int 21h

	;Para obtener el segundo dígito a imprimir, se realiza una division sobre 10.
	mov ax, acumResiduo
	mov bx, 10
	xor dx, dx
	div bx

	mov acumResiduo, dx

	;Se imprime el segundo digito con las siguientes instrucciones.
	mov ah, 02h
	mov dl, al
	add dl, 30h
	int 21h

	;Para obtener el el primer digito no se requiere realizar mas operaciones, ya que el residuo necesariamente
	;se trata de un digito y es imprimible directamente. 
	mov ax, acumResiduo

	;Se imprime el primer digito con las siguientes instrucciones.
	mov ah, 02h
	mov dl, al
	add dl, 30h
	int 21h

ret
endp

;________________________________________________________				
inicio:					
	mov ax, @data 		
	mov ds, ax 			

;________________________________________________________Flujo principal del programa.

	;Se imprimen UNICAMENTE los valores iniciales f(0) y f(1) para proceder a establecer en CX el contador
	;para el ciclo de calculo de los 20 terminos de la sucesion de Fibonacci. 
	mov ah, 09h
	lea dx, fibonacci1
	int 21h

	mov cx, 20

	;Algoritmo principal de calculo de la sucesion. 
	ciclo:

		mov ax, num1; num1 = 0.
		mov bx, num2; num2 = 0.
		add ax, bx; Se suman ambos valores. 
		mov resultado, ax; La suma se almacena en la variable resultado.

		;Se imprime en pantalla el mensaje "El valor es: " y se llama al procedimiento impresion para que los 
		;digitos del termino calculado salgan a continuacion del mensaje. 
		mov ah, 09h
		lea dx, fibonacci2
		int 21h

		call impresion

		;Se modifican los registros para que ahora la suma se realize entre F(n-1) + F(n-2).
		mov ax, [num2]; El contenido de num2 se mueve a AX.
		mov [num1], ax; Luego, el contenido de AX se envia al contenido de lo que apunta num1 para que ahora sea
					  ; el termino F(n-1) en la suma.

		mov ax, [resultado]; El contenido de resultado se envia a AX como paso intermedio.
		mov [num2], ax; Finalmente, se traslada a num2 para que sea el termino F(n-2) y se repita el ciclo de
					  ; calculo de los terminos hasta n = 20.

	loop ciclo

;________________________________________________________Fin del flujo principal. 

salir:					
	mov ah,4Ch			
	mov al, [exCode]				
	int 21h				
	end inicio			

	