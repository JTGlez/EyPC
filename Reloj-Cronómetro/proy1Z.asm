title "Proyecto 1: Reloj-cronómetro" 
	.model small	
	.386			
	.stack 64 		
	.data			

;Definicion de cadenas usadas en el programa.
select			db 		0Ah,0Ah,"Seleccione una de las siguientes opciones presionando la tecla correspondiente:",0ah,"$"
opc_reloj 		db 		"(R) Reloj",0Ah,"$" 		
opc_crono 		db 		"(C) Cron",0A2h,"metro",0Ah,"$" 
opc_salir 		db 		"(S) Salir",0Ah,"$"
TIME			db 		"00:00:00 hrs es la hora actual.$" 	
presionar_sal	db 		0Ah,"Presione cualquier tecla para regresar al menu",0Ah,"$"
selectcrono	    db 		0Ah,0Ah,"Menu de opciones del cron",0A2h,"metro",0ah,"$"
opc_ini		    db 		"(I) Iniciar/Continuar",0Ah,"$" 		
opc_det		    db 		"(D) Detener",0Ah,"$" 
opc_rei 		db 	    "(R) Reiniciar",0Ah,"$"

;Definición de variables usadas en el programa.
t_inicial		dw 		0,0		;guarda números de ticks inicial
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
cien 			db 		100 	;dato de valor decimal 100 para operación DIV entre 100
diez			db 		10 		;dato de valor decimal 10 para operación DIV entre 10
sesenta 		db 		60		;dato de valor decimal 60 para operación DIV entre 60
milisegundos	dw		0		;variable para guardar la cantidad de milisegundos
segundos		db		0 		;variable para guardar la cantidad de segundos
minutos 		db		0		;variable para guardar la cantidad de minutos
t_inter		    dw 		0,0		;guarda números de ticks finales en el bucle de ejecución.

salt	        db	    0Dh,0Ah,"$"
dots  	        db	    ":"


	.code	

;___________________________________________________Definición de procedimientos del reloj___________________________________________________



GET_TIME PROC
;Este procedimiento obtiene la hora actual del sistema con int 21h/Op. 2Ch, la convierte a ASCII por medio de CONVERT y luego
;la almacena en una cadena que es apuntada por el registro BX que corresponde a la cadena TIME. 

    PUSH AX                       ;Inicio de operaciones con la pila.
    PUSH CX                       

    MOV AH, 2Ch                   ;Llama a la función int 21h, Op. 2Ch que captura la hora del sistema.
    INT 21h                       

    MOV AL, CH                    ; AL=CH, CH=Horas
    CALL CONVERT                  ; Llamada al procedimiento CONVERT
    MOV [BX], AX                  ; [BX]=hr, [BX] apunta a hr
                                  ; en la cadena TIME

    MOV AL, CL                    ; AL=CL, CL=Minutos
    CALL CONVERT                  ; Llamada al procedimiento CONVERT
    MOV [BX+3], AX                ; [BX+3]=min, [BX] apunta a min
                                  ; En la cadena TIME
                                           
    MOV AL, DH                    ; set AL=DH, DH=segundos
    CALL CONVERT                  ; Llamada al procedimiento CONVERT
    MOV [BX+6], AX                ; [BX+6]=seg, [BX] apunta a seg
                                  ; En la cadena TIME
                                                      
    POP CX                        ;Fin de operaciones con la pila.
    POP AX                         
                                 
    RET     					  ;Se resume el flujo de ejecución desde donde fue llamado el procedimiento.                      
GET_TIME ENDP  

CONVERT PROC 
;Este procedimiento es un convertidor de caracteres "raw" a su representación en ASCII que pueda ser 
;leible e imprimible en el reloj del programa. 

    PUSH DX           			  ;Inicio de operaciones con la pila.             

    MOV AH, 0                     ; AH=0
    MOV DL, 10                    ; DL=10
    DIV DL                        ; AX=AX/DL
    OR AX, 3030H                  ; Convierte los valores de la hora del sistema almacenados en AX en ASCII.

    POP DX                        ;Fin de operaciones con la pila.

    RET                           ;Se resume el flujo de ejecución desde donde fue llamado el procedimiento.   
CONVERT ENDP     

;___________________________________________________Definición de procedimientos del cronómetro___________________________________________________



println	macro loc_cadena	
;Esta macro permite imprimir una cadena enviada como parámetro.
	
	lea dx,[loc_cadena] 		  ;Se obtiene la localidad de memoria de la cadena y se almacena en DX.
	mov ax,0900h				  ;Op. 9 para interrupcion 21h. Imprime una cadena apuntada por el registro DX.
	int 21h						  ;interrupcion 21h, imprime la cadena.
endm

crono proc

	;Vuelta de carro para la impresión del cronómetro.
    MOV AH, 0Dh
    INT 21H

	;Se vuelve a leer el contador de ticks para realiza el segundo muestreo.
	;Se lee para saber cuántos ticks pasaron entre la lectura inicial y ésta
	;De esa forma, se obtiene la diferencia de ticks.
	;Por cada incremento en el contador de ticks, transcurrieron 55 ms
	;En este momento se toma un muestreo de los ticks finales recuperándolos de DX y almacenándolos en t_inter.
	;Para retomar la ejecución del cronómetro si este se detiene en cualquier momento de su ejecución.
	mov ah,00h
	int 1Ah

	mov [t_inter], dx

	;Se recupera el valor de los ticks iniciales para poder hacer la diferencia entre
	;el valor inicial y el último recuperado.

	mov ax,[t_inicial]		;AX = parte baja de t_inicial
	mov bx,[t_inicial+2]	;BX = parte alta de t_inicial

	mov dx, [t_inter]


	;Se hace la resta de los valores para obtener la diferencia
	sub dx,ax  				;DX = DX - AX = t_final - t_inicial, DX guarda la parte baja del contador de ticks.
	sbb cx,bx 				;CX = CX - BX - C = t_final - t_inicial - C, CX guarda la parte alta del contador de ticks y se resta el acarreo si hubo en la resta anterior.

	;Se asume que el valor de CX es cronómetro
	;Significaría que la diferencia de ticks no es mayor a 65535d
	;Si la diferencia está entre 0d y 65535d, significa que hay un máximo de 65535 * 55ms =  3,604,425 milisegundos
	;Para fines prácticos se utiliza solo la parte baja (DX) para realizar las operaciones.
	mov ax,dx

	;Se multiplica la diferencia de ticks por 55ms para obtener 
	;la diferencia en milisegundos.
	mul [tick_ms]

	;El valor anterior se divide entre 1000 para calcular la cantidad de segundos 
	;y la cantidad de milisegundos del cronómetro (0d - 999d).
	div [mil]
	;Después de esta división, el cociente AX guarda el valor de segundos
	;el residuo DX tiene la cantidad de milisegundos del cronómetro (0- 999d).
	
	;Se guardan los milisegundos en una variable
	;Nota: este valor se guarda en hexadecimal.
	mov [milisegundos],dx

	;El valor de AX de la división anterior se divide entre 60
	;Segundos a minutos.
	div [sesenta]
	;Al final de la división, AH tiene el valor de los segundos (0 -59d) 
	;y AL los minutos (>=0)
	;Nota: ambos valores están en hexadecimal.
	
	;Se guardan los segundos en una variable.
	mov [segundos],ah

	;Se calcula el número de minutos para el cronómetro dividiendo nuevamente entre 60
	;Esto dará el número de horas, pero en este caso se ignorará.
	xor ah,ah
	div [sesenta]

	;Se guarda la cantidad de minutos en una variable.
	mov [minutos],ah

	;A continuación, se tomarán los valores de las variables minutos, segundos y milisegundos
	;y se imprimirán en formato de cronómetro MM:SS.mmm

;Imprime minutos
	xor ah,ah
	mov al,[minutos]
	aam
	or ax,3030h
	mov cl,al
	;Decenas
	mov dl,ah
	mov ah,02h
	int 21h
	;Unidades
	mov dl,cl
	int 21h
	;Separador ':'
	mov dl,':'
	int 21h

;Imprime segundos
	xor ah,ah
	mov al,[segundos]
	aam
	or ax,3030h
	mov cl,al
	;decenas
	mov dl,ah
	mov ah,02h
	int 21h
	;unidades
	mov dl,cl
	int 21h
	;Punto decimal '.'
	mov dl,'.'
	int 21h

;Imprime milisegundos
	mov ax,[milisegundos]
	div [cien]
	xor al,30h
	mov cl,ah
	;centenas
	mov dl,al
	mov ah,02h
	int 21h

	mov al,cl
	xor ah,ah
	aam
	or ax,3030h
	mov cl,al
	;decenas
	mov dl,ah
	mov ah,02h
	int 21h
	;unidades
	mov dl,cl
	int 21h

	;Vuelta de carro.
	mov AH, 0Dh
    int 21h

	ret ;Se resume el flujo de ejecución desde donde fue llamado el procedimiento. 

crono endp


inicio:					
	mov ax,@data 		
	mov ds,ax 			

menu_opciones:
;Menú principal del programa.

	mov ah,00h 					  ;AH = 00h, Opción de modo de video para int 10h.
	mov al,03h					  ;AL = 03h, Opción para modo de video, limpia la pantalla.
	int 10h                      

	xor ax,ax 					  ;Limpieza inicial de los registros. 
	xor bx,bx
	xor cx,cx
	xor dx,dx

	;Imprime menú de selección
	lea dx,[select]				  ;Imprime "Selecciona una de las siguientes opciones..."
	mov ah,09h
	int 21h						  ;Ejecuta int 21h con opción AH=09h. 
								  ;Imprime caracteres ASCII a partir de la localidad apuntada
								  ;por DX hasta encontrar el carácter '$' (fin de cadena).

	;Imprime opciones
	;Opción R - reloj
	lea dx,[opc_reloj]	;Imprime "(R) Reloj"
	int 21h 			;nótese que no se ha modifica AH desde la interrupción anterior.

	;Opción C - cronómetro
	lea dx,[opc_crono]	;Imprime "(C) Cronómetro"
	int 21h 			;nótese que no se ha modifica AH desde la interrupción anterior.
	
	;Opción S - salir
	lea dx,[opc_salir]	;Imprime "(S) Salir"
	int 21h 			;nótese que no se ha modifica AH desde la interrupción anterior.


lee_opcion:
;Lectura de las opciones del teclado.
	mov ah,01h			
	int 21h					;int 21h opcion AH=01h. Lectura de teclado CON ECO.

	cmp al,'R' 				;compara si la tecla presionada fue 'R'
	je et_reloj 			;Si tecla es 'R', salta a etiqueta et_reloj
	cmp al,'r'				;compara si la tecla presionada fue 'r'
	je et_reloj 			;Si tecla es 'r', salta a etiqueta et_reloj

	cmp al,'C'				;compara si la tecla presionada fue 'C'
	je et_cronometro		;Si tecla es 'C', salta a etiqueta et_cronometro
	cmp al,'c'				;compara si la tecla presionada fue 'c'
	je et_cronometro		;Si tecla es 'c', salta a etiqueta et_cronometro

	cmp al,'S'				;compara si la tecla presionada fue 'S'
	je salir				;Si tecla es 's', salta a etiqueta salir
	cmp al,'s'				;compara si la tecla presionada fue 's'
	je salir				;Si tecla es 's', salta a etiqueta salir

	jmp menu_opciones		;Si ninguna de las teclas coincidió, regresa a menu_opciones.


et_reloj:
;Código para leer el reloj del sistema e imprimirlo en pantalla.

	
	lea dx,[presionar_sal]  ;Imprime "Presione cualquier tecla para regresar al menu"
	mov ah,09h
	int 21h					;Ejecuta int 21h con opcion AH=09h 

	lea BX, TIME   			;Se ejecuta LEA BX, TIME para que BX apunte a TIME.              
    call GET_TIME           ;Se obtiene la primera impresión de la hora.     
                                  
    loopstart:
    ;Loop de impresión del reloj, el cual puede ser interrumpido presionando cualquier tecla.

     mov DL, 13             ;0Dh para imprimir en la misma línea
     mov AH, 02h
     int 21h

     call GET_TIME 
     lea DX, TIME                 
     mov AH, 09H            ;Imprime la hora convertida contínuamente.
     int 21H  

     mov AH, 0Dh
     int 21H

     mov ah, 01h            ;Rotura del bucle presionando cualquier tecla.   
     mov cx,2607h			
     int 16h
     jnz limpiar


     loop loopstart 

     limpiar: 
     ;Etiqueta de limpieza como paso previo a terminar la ejecución del reloj.

	 mov ah, 00h
	 int 16h
	 jmp menu_opciones

 
et_cronometro:
;Código para inicializar el cronómetro e imprimirlo en pantalla. 
                             
    lea dx,[selectcrono]	;Imprime "Menú de opciones del cronómetro"
	mov ah,09h
	int 21h					;ejecuta int 21h con opcion AH=09h 
							;Imprime caracteres ASCII a partir de la localidad apuntada
							;por DX hasta encontrar el carácter '$' (fin de cadena)

	;Imprime opciones
	;Opción I - Iniciar/Continuar
	lea dx,[opc_ini]		;Imprime "(I) Iniciar/Continuar"
	int 21h 				;nótese que no se ha modifica AH desde la interrupción anterior

	;Opción D - Detener
	lea dx,[opc_det]		;Imprime "(D) Detener"
	int 21h 				;nótese que no se ha modifica AH desde la interrupción anterior

	;Opción R - Reiniciar
	lea dx,[opc_rei]		;Imprime "(R) Reiniciar"
	int 21h 				;nótese que no se ha modifica AH desde la interrupción anterior

	lea dx,[presionar_sal]	;Imprime "Presione cualquier tecla para regresar al menu"
	mov ah,09h
	int 21h 

	xor al, al 				;Limpieza del búfer del teclado.
	mov ah, 0
	int 16h					;Lectura del teclado con int 16h.

	cmp al, 'I' 			;compara si la tecla presionada fue 'I'
	je startcrono			;Si tecla es 'I', salta a etiqueta startcrono

	cmp al, 'i'				;compara si la tecla presionada fue 'i'
	je startcrono			;Si tecla es 'i', salta a etiqueta startcrono

	jmp menu_opciones		;Si ninguna de las teclas coincidió, regresa a menu_opciones.


	salto:
	;Etiqueta de interrumpción del bucle de impresión del cronómetro al presionar cualquier tecla.

	xor ax,ax 				;Limpieza del búfer del teclado.
	int 16h					;Lectura del teclado.

	cmp al, 'I' 			;compara si la tecla presionada fue 'I'
	je restartcrono			;Si tecla es 'I', salta a etiqueta restartcrono

	cmp al, 'i'				;compara si la tecla presionada fue 'i'
	je restartcrono			;Si tecla es 'i', salta a etiqueta restartcrono

	cmp al, 'R' 			;compara si la tecla presionada fue 'R'
	je startcrono 			;Si tecla es 'R', salta a etiqueta startcrono

	cmp al, 'r' 			;compara si la tecla presionada fue 'r'
	je startcrono 			;Si tecla es 'r', salta a etiqueta startcrono

	cmp al, 'D' 			;compara si la tecla presionada fue 'D'
	je stopcrono 			;Si tecla es 'D', salta a etiqueta stopcrono

	cmp al, 'd' 			;compara si la tecla presionada fue 'd'
	je stopcrono 			;Si tecla es 'd', salta a etiqueta stopcrono

	cmp al, 'S' 			;compara si la tecla presionada fue 'S'
	je menu_opciones 		;Si tecla es 'S', salta a etiqueta menu_opciones

	cmp al, 's' 			;compara si la tecla presionada fue 's'
	je menu_opciones 		;Si tecla es 's', salta a etiqueta menu_opciones

	jmp menu_opciones 		;Si ninguna de las teclas coincidió, regresa a menu_opciones.

	stopcrono:
	;Muestreo de ticks del sistema tomado cuando el cronómetro es detenido.

	mov ah, 00h 			;Función 1Ah, Op. 00h para muestrear los ticks del sistema y almacenarlos en t_inter temporalmente. 
	int 1Ah

	mov [t_inter], dx
	mov [t_inter+2], cx


	jmp salto 				;Una vez realizado el muestreo, se salta de nuevo a la etiqueta salto. 

	restartcrono:
	;Etiqueta utilizada para retomar el curso del cronómetro cuando este es detenido.

	mov ah, 01h 			;Función 1Ah, Op. 01h para establecer los ticks del sistema como los ticks muestreados en stopcrono.
	mov dx,  [t_inter]
	mov cx, [t_inter +2]
	int 1Ah					;Ejecución del muestreo de reinicio para proseguir el cronómetro desde su último estado previo a la detención.

    jmp loopcrono 			;Salto al loop para continuar la impresión del cronómetro.


	startcrono:
	;Realiza el muestreo inicial del contador de ticks del sistema y lo guarda en variable t_inicial.

	mov ah,00h 				;Función 1Ah, Op. 00h para muestrear los ticks del sistema y almacenarlos en t_inicial.
	int 1Ah
	
	mov [t_inicial], dx
	mov [t_inicial+2], cx

	mov DL, 13; 			
    mov AH, 02h
    int 21h

	loopcrono:
	;Loop de cálculo de la diferencia de ticks a unidades de tiempo e impresión del cronómetro.

     mov DL, 13             ;0Dh para imprimir en la misma línea
     mov AH, 02h
     int 21h
     call crono 			;Llamada al procedimiento crono para el cálculo de la diferencia de ticks y la impresión. 

	 MOV AH, 0Dh
	 INT 21H

     mov ah, 01h 			 
     int 16h 			    ;Función 16h con Op. 01h para controlar el teclado e interrumpir el loop cuando se detecte una pulsación.

     jz loopcrono 			;Mientras no se detecte una pulsación, el loop prosigue.
     jmp salto 				;Cuando se detecte una pulsación, se interrumpe el loop y se envía a la etiqueta salto.

     loop loopcrono


salir:					;Inicia etiqueta salir.
	mov ax,4C00h		;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa.
	int 21h				;señal 21h de interrupción, pasa el control al sistema operativo.
	
end inicio			;Fin de etiqueta inicio, fin de programa.