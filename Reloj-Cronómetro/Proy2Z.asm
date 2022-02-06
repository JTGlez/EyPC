title "Proyecto 2: Reloj-cronómetro 'gráfico'" 
	.model small	
	.386			
	.stack 64 		
	.data			

;___________________________________________________Definición de constantes___________________________________________________

;Valores ASCII de caracteres para el marco del programa.
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'

;Atributos de color de BIOS.
;Valores de color para carácter.
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter.
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
	
;___________________________________________________Definición de variables___________________________________________________

titulo 			db 		"Reloj - Cron",162,"metro"
reloj_str 		db 		"RELOJ"
crono_str 		db 		"CRON",224,"metro"
reloj			db 		"00:00:00"
crono			db		"00:00.000"
t_inicial		dw 		0,0
t_final			dw		0,0
t_dif 			dw		0,0
tick_ms			dw 		55
mil				dw		1000
cien 			db 		100
diez			db 		10
sesenta 		db 		60
crono_ms		dw 		0
crono_s 		db 		0
crono_m 		db 		0
col_aux 		db 		0
ren_aux 		db 		0
renglon_inicio  db 		0
pestana1		db 		"INICIO"
pestana2		db 		"RELOJ"
pestana3		db 		"CRONOMETRO"
nombre1			db 		"Esquivel Razo Israel"
nombre2			db 		"Tellez Gonzalez Jorge Luis"
equipo 			db  	"Equipo 17"
integrantes     db   	"Integrantes"
TIME			db 		"00:00:00 hrs es la hora actual.$" 
crono_boton1	db		"Iniciar"
crono_boton2	db		"Continuar"
crono_boton3	db		"Pausar"
crono_boton4	db		"Reiniciar"
milisegundos	dw		0		;variable para guardar la cantidad de milisegundos.
segundos		db		0 		;variable para guardar la cantidad de segundos.
minutos 		db		0		;variable para guardar la cantidad de minutos.
t_inter		    dw 		0,0		;guarda números de ticks finales en el bucle de ejecución.
aux				db 		0		;variable auxiliar de operacion.
ocho			db 		8		;Auxiliar para calculo de coordenadas del mouse.
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$' ;Indica cuando el driver del mouse no esta disponible.


;___________________________________________________Definición de macros para el ratón y las cadenas___________________________________________________


clear macro
;clear - Limpia la pantalla.

	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h			;Llama interrupcion 10h con opcion 00h. 
					;Establece modo de video limpiando pantalla
endm


posiciona_cursor macro renglon,columna
;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 

	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 


inicializa_ds_es 	macro
;inicializa_ds_es - Inicializa el valor del registro DS y ES

	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm


muestra_cursor_mouse	macro
;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser

	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm


oculta_cursor_teclado	macro
;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado

	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm


apaga_cursor_parpadeo	macro
;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color. Habilita 16 colores de fondo.
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm


imprime_caracter_color macro caracter,color,bg_color
;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter

	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;DL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or  bl,bg_color 		;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm


imprime_cadena_color macro cadena,long_cadena,color,bg_color
;imprime_cadena_color - Imprime una cadena de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena

	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=13h, imprime la cadena en AL con el color BL
endm


lee_mouse	macro
;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)

	mov ax,0003h
	int 33h
endm


comprueba_mouse 	macro
;comprueba_mouse - Revisa si el driver del mouse existe

	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm


;___________________________________________________Definición de macros para la interfaz grafica___________________________________________________


dibuja_rectan_color  macro renglon_inicio, columna_inicio, renglon_fin, columna_fin, color_Texto, color_Fondo
	LOCAL renglon_2, columna_2, siguiente_1, siguiente_2
;dibuja_rectan_color - Dibuja un rectangulo de color en pantalla indicando la posicion del renglon de inicio y final, la columna inicial
;y final así como el color del texto y el fondo.

	mov [ren_aux], renglon_inicio
	renglon_2:
	mov [col_aux], columna_inicio
	columna_2:
	posiciona_cursor [ren_aux], [col_aux]
	imprime_caracter_color " ", color_Texto, color_Fondo
	inc [col_aux]
	cmp [col_aux], columna_fin
	jb columna_2
	je columna_2
	jg siguiente_1
	siguiente_1:
	inc [ren_aux]
	cmp [ren_aux], renglon_fin
	jb renglon_2
	je renglon_2
	jg siguiente_2
	siguiente_2:
endm 


dibuja_humo_color  macro renglon_inicio, columna_inicio,  color_Texto, color_Fondo
	LOCAL renglon_2_humo, columna_2_humo, siguiente_1_humo, siguiente_2_humo
;dibuja_humo_color - Utilizado para dibujar un patron de colores en la interfaz grafica.
	mov [ren_aux], renglon_inicio
	renglon_2_humo:
	mov [col_aux], columna_inicio
	inc [ren_aux]
	inc [ren_aux] 
	posiciona_cursor [ren_aux], [col_aux]
	imprime_caracter_color " ", color_Texto, color_Fondo
	cmp [ren_aux], renglon_inicio + 4 ;Salto alternado de 4 unidades para imprimir el recuadro en los tres botones "propulsores"
	jb renglon_2_humo 				  ;Se imprimen tres cuadros por cada boton propulsor. 
	je renglon_2_humo
	jg siguiente_2_humo
	siguiente_2_humo:
endm 

dibuja_humo_color_2  macro renglon_inicio, columna_inicio,  color_Texto, color_Fondo
	LOCAL renglon_2_humo, columna_2_humo, siguiente_1_humo, siguiente_2_humo
;dibuja_humo_color_2 - Utilizado para dibujar un patron de colores en la interfaz grafica. Complementa a la macro anterior para realizar un
;efecto de "humo" de un cohete.
	mov [ren_aux], renglon_inicio
	renglon_2_humo:
	mov [col_aux], columna_inicio
	inc [ren_aux]
	inc [ren_aux] 
	posiciona_cursor [ren_aux], [col_aux]
	imprime_caracter_color " ", color_Texto, color_Fondo
	cmp [ren_aux], renglon_inicio + 3 ;Salto alternado de 3 unidades para imprimir el recuadro en los tres botones "propulsores"
	jb renglon_2_humo				  ;Se imprimen dos cuadros por cada boton propulsor. 
	je renglon_2_humo
	jg siguiente_2_humo
	siguiente_2_humo:
endm 

;___________________________________________________Segmento de código del programa___________________________________________________


	.code				;segmento de codigo
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp teclado		;salta a 'teclado'
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_MARCO_EXT 	;procedimiento que dibuja marco de la interfaz

	
	;Dibuja la IU principal con los botones iniciales de seleccion y el footer con los datos de los desarrolladores.
	dibuja_rectan_color 4, 14, 18, 66, cBlanco, bgAmarillo
	dibuja_rectan_color 4, 4, 6, 13, cBlanco, bgRojo
	dibuja_rectan_color 10, 4, 12, 13, cBlanco, bgMagenta
	dibuja_rectan_color 16, 4, 18, 13, cBlanco, bgMagentaClaro
	dibuja_humo_color 1,2, cBlanco, bgBlanco
	dibuja_humo_color 7,2, cBlanco, bgBlanco
	dibuja_humo_color 13,2, cBlanco, bgBlanco
	dibuja_humo_color_2 2,3, cBlanco, bgBlanco
	dibuja_humo_color_2 8,3, cBlanco, bgBlanco
	dibuja_humo_color_2 14,3, cBlanco, bgBlanco
	call palabra_hola
	posiciona_cursor 5, 6
	imprime_cadena_color pestana1,6,cBlanco,bgRojo
	posiciona_cursor 11, 6
	imprime_cadena_color pestana2,5,cBlanco,bgMagenta
	posiciona_cursor 17, 4
	imprime_cadena_color pestana3,10,cBlanco,bgMagentaClaro

	posiciona_cursor 14, 17
	imprime_cadena_color integrantes,11,cNegro,bgAmarillo
	posiciona_cursor 15, 19
	imprime_cadena_color nombre1,20,cNegro,bgAmarillo
	posiciona_cursor 16, 19
	imprime_cadena_color nombre2,26,cNegro,bgAmarillo
	posiciona_cursor 14, 50
	imprime_cadena_color equipo,9,cNegro,bgAmarillo
	call marco_2
	muestra_cursor_mouse 	;hace visible el cursor del mouse
;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón no está suelto, no continúa
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
	call espacios_que_no_hacen_nada
	jmp mouse_no_clic

;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo

et_inicio:
	jmp imprime_ui


et_reloj:

	dibuja_rectan_color 4, 14, 18, 66, cBlanco, bgAmarillo
	call marco_2_2

    loopstart:
    ;Loop de impresión del reloj, el cual puede ser interrumpido presionando cualquier tecla.
		lea BX, TIME
		call GET_TIME

		mov ah, 2ch 			;Llama a la función int 21h, Op. 2Ch que captura la hora del sistema.
		int 21h 

	    call GET_TIME 
	    lea DX, TIME     

     posiciona_cursor 8, 20							;Coloca el cursor en la posicion deseada
	 imprime_cadena_color TIME,31,cAzul,bgAmarillo	;Imprime la cadena de tiempo del reloj
     
	
     ;mov ah, 01h            ;Rotura del bucle presionando cualquier tecla.   
     lee_mouse 				;lee el mouse
     test bx, 0001h			;Si BX = 0001h, boton izquierdo presionado
     jz loopstart           
     jmp metodo_espacio_blancos  ;Se llama a la etiqueta, conectada a los botones
    metodo_espacio_blancos:
    	call espacios_que_no_hacen_nada
     jmp loopstart



et_cronometro:
	call opciones_botones_dibujo
	dibuja_rectan_color 7, 33, 9, 45, cBlanco, bgAzul
	xor al, al 				;Limpieza del búfer del teclado.

	cronometro:
			stopcrono:
			;Muestreo de ticks del sistema tomado cuando el cronómetro es detenido.
			mov ah, 00h 			;Función 1Ah, Op. 00h para muestrear los ticks del sistema y almacenarlos en t_inter temporalmente. 
			int 1Ah

			mov [t_inter], dx
			mov [t_inter+2], cx
									;Una vez realizado el muestreo, se espera de nuevo un click izquierdo.
		    call espacios_que_no_hacen_nada_2


			restartcrono:
			xor al, al 	

			mov ah, 01h 			;Función 1Ah, Op. 01h para establecer los ticks del sistema como los ticks muestreados en stopcrono.
			mov dx,  [t_inter]
			mov cx, [t_inter +2]
			int 1Ah					;Ejecución del muestreo de reinicio para proseguir el cronómetro desde su último estado previo a la detención.
		    jmp loopcrono			;Salto al loop para continuar la impresión del cronómetro.
			startcrono:
			mov ah,00h 				;Función 1Ah, Op. 00h para muestrear los ticks del sistema y almacenarlos en t_inicial.
			int 1Ah
			mov [t_inicial], dx
			mov [t_inicial+2], cx
		    startcrono_2:
			loopcrono:
			;Loop de cálculo de la diferencia de ticks a unidades de tiempo e impresión del cronómetro.
			posiciona_cursor 8, 35
		     call crono_proc 			;Llamada al procedimiento crono para el cálculo de la diferencia de ticks y la impresión. 
		     lee_mouse 
     		 test bx, 0001h
		     jz loopcrono 			;Mientras no se detecte un click izquierdo en algun boton, el loop prosigue.
		     jmp metodo_espacio_blancos_3
		     metodo_espacio_blancos_3:
		    	call espacios_que_no_hacen_nada_2

		     jmp loopcrono		

	 validar: 
     lee_mouse 
     test bx, 0001h
     jz cronometro
     jmp metodo_espacio_blancos_2
     metodo_espacio_blancos_2:
    	call espacios_que_no_hacen_nada_2
    jmp cronometro

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo


;___________________________________________________Definición de procedimientos de la interfaz gráfica___________________________________________________


DIBUJA_MARCO_EXT proc
;Dibuja el marco exterior de la interfaz grafica del programa junto con el caracter X para indicar la opcion de salir del programa.

	;imprimir esquina superior izquierda del marco
	posiciona_cursor 0,0
	imprime_caracter_color marcoEsqSupIzq,cBlanco,bgNegro
	
	;imprimir esquina superior derecha del marco
	posiciona_cursor 0,79
	imprime_caracter_color marcoEsqSupDer,cBlanco,bgNegro
	
	;imprimir esquina inferior izquierda del marco
	posiciona_cursor 24,0
	imprime_caracter_color marcoEsqInfIzq,cBlanco,bgNegro
	
	;imprimir esquina inferior derecha del marco
	posiciona_cursor 24,79
	imprime_caracter_color marcoEsqInfDer,cBlanco,bgNegro
	
	;imprimir marcos horizontales, superior e inferior
	mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
marco_sup_e_inf:
	mov [col_aux],cl
	;Superior
	posiciona_cursor 0,[col_aux]
	imprime_caracter_color marcoHor,cBlanco,bgNegro
	;Inferior
	posiciona_cursor 24,[col_aux]
	imprime_caracter_color marcoHor,cBlanco,bgNegro
	mov cl,[col_aux]
	loop marco_sup_e_inf

	;imprimir marcos verticales, derecho e izquierdo
	mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
marco_der_e_izq:
	mov [ren_aux],cl
	;Izquierdo
	posiciona_cursor [ren_aux],0
	imprime_caracter_color marcoVer,cBlanco,bgNegro
	;Inferior
	posiciona_cursor [ren_aux],79
	imprime_caracter_color marcoVer,cBlanco,bgNegro
	mov cl,[ren_aux]
	loop marco_der_e_izq

	;imprimir [X] para cerrar programa
	posiciona_cursor 0,76
	imprime_caracter_color '[',cBlanco,bgNegro
	posiciona_cursor 0,77
	imprime_caracter_color 'X',cRojoClaro,bgNegro
	posiciona_cursor 0,78
	imprime_caracter_color ']',cBlanco,bgNegro

	;imprimir título
	posiciona_cursor 0,31
	imprime_cadena_color [titulo],18,cBlanco,bgNegro
	ret
	endp

;___________________________________________________Definición de procedimientos___________________________________________________


convierte_reloj	proc	    
;Convierte los valores hexadecimales recuperdos a su representacion en ASCII.

    push dx			;Inserta el valor del registro DX en la pila.
    mov ah, 0		;AH=0
    mov dl, 10h		;DL=10h
    div dl			;AX=AX/DL
    or ax, 3030H	;Pasa los valores BCD a su representación en ASCII ('0' - 30h en ASCII a '9' - 39h en ASCII).
    pop dx          ;Saca un valor de la pila y lo coloca en DX.
    ret             ;Retorna el control al procedimiento en el que fue llamado.
endp 


GET_TIME PROC
;Este procedimiento obtiene la hora actual del sistema con int 21h/Op. 2Ch, la convierte a ASCII por medio de CONVERT y luego
;la almacena en una cadena que es apuntada por el registro BX que corresponde a la cadena TIME. 

    PUSH AX                       ;Inicio de operaciones con la pila.
    PUSH CX                       

    MOV AH, 02h                   ; Se obtiene la hora del sistema
    INT 1Ah                       

    MOV AL, CH                    ; AL=CH, CH=Horas
    CALL convierte_reloj                  ; Llamada al procedimiento CONVERT
    MOV [BX], AX                  ; [BX]=hr, [BX] apunta a hr
                                  ; en la cadena TIME

    MOV AL, CL                    ; AL=CL, CL=Minutos
    CALL convierte_reloj                  ; Llamada al procedimiento CONVERT
    MOV [BX+3], AX                ; [BX+3]=min, [BX] apunta a min
                                  ; En la cadena TIME
                                           
    MOV AL, DH                    ; set AL=DH, DH=segundos
    CALL convierte_reloj                  ; Llamada al procedimiento CONVERT
    MOV [BX+6], AX                ; [BX+6]=seg, [BX] apunta a seg
                                  ; En la cadena TIME
                                                      
    POP CX                        ;Fin de operaciones con la pila.
    POP AX                         
                                 
    RET     					  ;Se resume el flujo de ejecución desde donde fue llamado el procedimiento.                      
GET_TIME ENDP  


espacios_que_no_hacen_nada proc
;Procedimiento especial utilizado para implementar la funcionalidad de los botones dibujados en el menu principal del programa. Para verificar que se esta presionando
;un boton, se utiliza una metodologia similar al codigo base proporcionado, revisando en qué renglón y columna se realizo un click izquierdo para modificar el flujo de ejecucion.

	mouse:
		lee_mouse
		test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
		jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

		;Leer la posicion del mouse y hacer la conversion a resolucion
		;80x25 (columnas x renglones) en modo texto
		mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
		div [ocho] 			;Division de 8 bits
							;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
							;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah 			;Descartar el residuo de la division anterior
		mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

		mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
		div [ocho] 			;Division de 8 bits
							;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
							;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah 			;Descartar el residuo de la division anterior
		mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Lógica de la posicion del mouse;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	botones_logica:
		;Si el mouse fue presionado en el renglon 0
		;se va a revisar si fue dentro del boton [X]
		cmp dx,0
		je boton_x
		jmp boton_inicio0
	boton_x:
		jmp boton_x1
	;Lógica para revisar si el mouse fue presionado en [X]
	;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	boton_x1:
		cmp cx,76
		jge boton_x2 			;Se verifica el boton despues de las columnas
		jmp boton_inicio0      	;Se verifica al siguiente boton
	boton_x2:
		cmp cx,78 				
		jbe boton_x3         	;Se verifica el boton antes de las columnas
		jmp boton_inicio0		;Se verifica al siguiente boton
	boton_x3:
		;Se cumplieron todas las condiciones
		jmp salir 				;Va a la etiqueta salir


	;Se establece el flujo al que dirigira el boton de INICIO en el menu principal.
	boton_inicio0: 
		cmp dx, 4
		jge boton_inicio1 	;Se verifica el boton despues de los renglones
		jmp boton_reloj0 	;Se verifica al siguiente boton

	boton_inicio1: 
		cmp dx, 6
		jbe boton_inicio2 	;Se verifica el boton antes de los renglones
		jmp boton_reloj0 	;Se verifica al siguiente boton

	boton_inicio2:
		cmp cx,4
		jge boton_inicio3 	;Se verifica el boton despues de las columnas
		jmp boton_reloj0 	;Se verifica al siguiente boton

	boton_inicio3:
		cmp cx,13
		jbe boton_inicio4 	;Se verifica el boton antes de las columnas
		jmp boton_reloj0 	;Se verifica al siguiente boton
		
	boton_inicio4:
		jmp et_inicio 		;Va a la etiqueta et_inicio si todas las condiciones se cumplen.


	;Se establece el flujo al que dirigira el boton de RELOJ en el menu principal.
	boton_reloj0: 
		cmp dx, 10
		jge boton_reloj1 	;Se verifica el boton despues de los renglones
		jmp boton_crono0 	;Se verifica al siguiente boton

	boton_reloj1: 
		cmp dx, 12
		jbe boton_reloj2 	;Se verifica el boton antes de los renglones
		jmp boton_crono0 	;Se verifica al siguiente boton

	boton_reloj2:
		cmp cx,4
		jge boton_reloj3 	;Se verifica el boton despues de las columnas
		jmp boton_crono0 	;Se verifica al siguiente boton

	boton_reloj3:
		cmp cx,13
		jbe boton_reloj4 	;Se verifica el boton antes de las columnas
		jmp boton_crono0 	;Se verifica al siguiente boton
		
	boton_reloj4:
		jmp et_reloj 		;Va a la etiqueta et_reloj si todas las condiciones se cumplen.


	;Se establece el flujo al que dirigira el boton de CRONOMETRO en el menu principal.
	boton_crono0: 
		cmp dx, 16
		jge boton_crono1 	;Se verifica el boton despues de los renglones
		jmp extra			;No se cumplieron, por lo cual retornará

	boton_crono1: 
		cmp dx, 18
		jbe boton_crono2 	;Se verifica el boton antes de los renglones
		jmp extra 			;No se cumplieron, por lo cual retornará

	boton_crono2:
		cmp cx,4
		jge boton_crono3 	;Se verifica el boton despues de las columnas
		jmp extra 			;No se cumplieron, por lo cual retornará

	boton_crono3:
		cmp cx,13
		jbe boton_crono4 	;Se verifica el boton antes de las columnas
		jmp extra 			;No se cumplieron, por lo cual retornará
		
	boton_crono4:
		jmp et_cronometro  	;Va a la etiqueta et_cronometro si todas las condiciones se cumplen.
extra:
	ret
endp

espacios_que_no_hacen_nada_2 proc
;Procedimiento especial utilizado para implementar la funcionalidad de los botones dibujados en el menu principal del programa. Para verificar que se esta presionando
;un boton, se utiliza una metodologia similar al codigo base proporcionado, revisando en qué renglón y columna se realizo un click izquierdo para modificar el flujo de ejecucion.
;Este procedimiento se implementa para evitar traslapes al pasar del menu de inicio al cronometro y viceversa y que no se presente persistencia de elementos graficos.

	mouse_2:
		lee_mouse
		test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
		jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

		;Leer la posicion del mouse y hacer la conversion a resolucion
		;80x25 (columnas x renglones) en modo texto
		mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
		div [ocho] 			;Division de 8 bits
							;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
							;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah 			;Descartar el residuo de la division anterior
		mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

		mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
		div [ocho] 			;Division de 8 bits
							;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
							;para obtener el valor correspondiente en resolucion 80x25
		xor ah,ah 			;Descartar el residuo de la division anterior
		mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Lógica de la posicion del mouse;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	botones_logica_2:
		;Si el mouse fue presionado en el renglon 0
		;se va a revisar si fue dentro del boton [X]
		cmp dx,0
		je boton_x_2 			;Se verifica el boton despues de los renglones
		jmp boton_inicio0_2  	;Se verifica al siguiente boton
	boton_x_2:
		jmp boton_x1_2
	;Lógica para revisar si el mouse fue presionado en [X]
	;[X] se encuentra en renglon 0 y entre columnas 76 y 78
	boton_x1_2:
		cmp cx,76
		jge boton_x2_2 			;Se verifica el boton despues de las columnas
		jmp boton_inicio0_2  	;Se verifica al siguiente boton
	boton_x2_2:
		cmp cx,78
		jbe boton_x3_2 			;Se verifica el boton antes de las columnas
		jmp boton_inicio0_2  	;Se verifica al siguiente boton
	boton_x3_2:
		;Se cumplieron todas las condiciones
		jmp salir 				;Va a la etiqueta salir


	;Se establece el flujo al que dirigira el boton de INICIO al estar en el menu del cronometro.
	boton_inicio0_2: 
		cmp dx, 4
		jge boton_inicio1_2 	;Se verifica el boton despues de los renglones
		jmp boton_reloj0_2  	;Se verifica al siguiente boton

	boton_inicio1_2: 
		cmp dx, 6
		jbe boton_inicio2_2 	;Se verifica el boton antes de los renglones
		jmp boton_reloj0_2  	;Se verifica al siguiente boton

	boton_inicio2_2:
		cmp cx,4
		jge boton_inicio3_2 	;Se verifica el boton despues de las columnas
		jmp boton_reloj0_2  	;Se verifica al siguiente boton

	boton_inicio3_2:
		cmp cx,13
		jbe boton_inicio4_2 	;Se verifica el boton antes de las columnas
		jmp boton_reloj0_2  	;Se verifica al siguiente boton
		
	boton_inicio4_2:
		jmp et_inicio 			;Va a la etiqueta et_inicio si todas las condiciones se cumplen.


	;Se establece el flujo al que dirigira el boton de RELOJ al estar en el menu del cronometro.
	boton_reloj0_2: 
		cmp dx, 10
		jge boton_reloj1_2 		;Se verifica el boton despues de los renglones
		jmp boton_crono0_2  	;Se verifica al siguiente boton

	boton_reloj1_2: 
		cmp dx, 12
		jbe boton_reloj2_2 		;Se verifica el boton antes de los renglones
		jmp boton_crono0_2  	;Se verifica al siguiente boton

	boton_reloj2_2:
		cmp cx,4
		jge boton_reloj3_2 		;Se verifica el boton despues de las columnas
		jmp boton_crono0_2  	;Se verifica al siguiente boton

	boton_reloj3_2:
		cmp cx,13
		jbe boton_reloj4_2 		;Se verifica el boton antes de las columnas
		jmp boton_crono0_2  	;Se verifica al siguiente boton
		
	boton_reloj4_2:
		jmp et_reloj 			;Va a la etiqueta et_reloj si todas las condiciones se cumplen.


	;Se establece el flujo al que dirigira el boton de CRONOMETRO al estar en el menu del cronometro.
	boton_crono0_2: 
		cmp dx, 16
		jge boton_crono1_2 			;Se verifica el boton despues de los renglones
		jmp boton_continuar0_2  	;Se verifica al siguiente boton

	boton_crono1_2: 
		cmp dx, 18
		jbe boton_crono2_2  		;Se verifica el boton antes de los renglones
		jmp boton_continuar0_2  	;Se verifica al siguiente boton

	boton_crono2_2:
		cmp cx,4
		jge boton_crono3_2 			;Se verifica el boton despues de las columnas
		jmp boton_continuar0_2  	;Se verifica al siguiente boton

	boton_crono3_2:
		cmp cx,13
		jbe boton_crono4_2  		;Se verifica el boton antes de las columnas
		jmp boton_continuar0_2  	;Se verifica al siguiente boton
		
	boton_crono4_2:
		jmp et_cronometro 			;Va a la etiqueta et_cronometro si todas las condiciones se cumplen.

	;Se establece el flujo al que dirigira el boton de Iniciar al estar en el submenu del cronometro.
	boton_continuar0_2: 
		cmp dx, 11
		jge boton_continuar1  		;Se verifica el boton despues de los renglones
		jmp boton_continuar0_2_2  	;Se verifica al siguiente boton

	boton_continuar1: 
		cmp dx, 13
		jbe boton_continuar2 		;Se verifica el boton antes de los renglones
		jmp boton_continuar0_2_2  	;Se verifica al siguiente boton

	boton_continuar2:
		cmp cx,19
		jge boton_continuar3 		;Se verifica el boton despues de las columnas
		jmp boton_continuar0_2_2  	;Se verifica al siguiente boton

	boton_continuar3:
		cmp cx,29
		jbe boton_continuar4 		;Se verifica el boton antes de las columnas
		jmp boton_continuar0_2_2  	;Se verifica al siguiente boton
		
	boton_continuar4:
		jmp startcrono 				;Va a la etiqueta startcrono si todas las condiciones se cumplen.


	;Se establece el flujo al que dirigira el boton de Continuar al estar en el submenu del cronometro.
	boton_continuar0_2_2: 
		cmp dx, 14
		jge boton_continuar1_2 		;Se verifica el boton despues de los renglones
		jmp boton_pausar0  			;Se verifica al siguiente boton

	boton_continuar1_2: 
		cmp dx, 16
		jbe boton_continuar2_2 		;Se verifica el boton antes de los renglones
		jmp boton_pausar0  			;Se verifica al siguiente boton

	boton_continuar2_2:
		cmp cx,19
		jge boton_continuar3_2 		;Se verifica el boton despues de las columnas
		jmp boton_pausar0  			;Se verifica al siguiente boton

	boton_continuar3_2:
		cmp cx,29
		jbe boton_continuar4_2  	;Se verifica el boton antes de las columnas
		jmp boton_pausar0 			;Se verifica al siguiente boton
		
	boton_continuar4_2:
		jmp restartcrono 			;;Va a la etiqueta restartcrono si todas las condiciones se cumplen.


	;Se establece el flujo al que dirigira el boton de Pausar al estar en el submenu del cronometro.
	boton_pausar0: 
		cmp dx, 14
		jge boton_pausar1 			;Se verifica el boton despues de los renglones
		jmp boton_reiniciar0  		;Se verifica al siguiente boton

	boton_pausar1: 
		cmp dx, 16
		jbe boton_pausar2  			;Se verifica el boton antes de los renglones
		jmp boton_reiniciar0  		;Se verifica al siguiente boton

	boton_pausar2:
		cmp cx,35
		jge boton_pausar3 			;Se verifica el boton despues de las columnas
		jmp boton_reiniciar0 		;Se verifica al siguiente boton

	boton_pausar3:
		cmp cx,44
		jbe boton_pausar4 			;Se verifica el boton antes de las columnas
		jmp boton_reiniciar0  		;Se verifica al siguiente boton
		
	boton_pausar4:
		jmp stopcrono 				;Va a la etiqueta stopcrono si todas las condiciones se cumplen.
	

	;Se establece el flujo al que dirigira el boton de Reiniciar al estar en el submenu del cronometro.
	boton_reiniciar0: 
		cmp dx, 14
		jge boton_reiniciar1  		;Se verifica el boton despues de los renglones
		jmp extra_2  				;No se cumplieron, por lo cual retornará

	boton_reiniciar1: 
		cmp dx, 16
		jbe boton_reiniciar2  		;Se verifica el boton antes de los renglones
		jmp extra_2  				;No se cumplieron, por lo cual retornará

	boton_reiniciar2:
		cmp cx,50
		jge boton_reiniciar3 		;Se verifica el boton despues de las columnas
		jmp extra_2  				;No se cumplieron, por lo cual retornará

	boton_reiniciar3:
		cmp cx,60
		jbe boton_reiniciar4 		;Se verifica el boton antes de las columnas
		jmp extra_2   				;No se cumplieron, por lo cual retornará
		
	boton_reiniciar4:
		jmp startcrono 				;Va a la etiqueta startcrono si todas las condiciones se cumplen.
extra_2:
	ret
endp


palabra_hola proc
;Dibuja la palabra "HOLA" en el menu principal del programa utilizando la macro dibuja_rectan_color.

	dibuja_rectan_color 6, 18,11,19, cBlanco, bgAzul
	dibuja_rectan_color 6, 23,11,24, cBlanco, bgAzul
	dibuja_rectan_color 8, 20,9, 22, cBlanco, bgAzul
	dibuja_rectan_color 8, 28,9, 28, cBlanco, bgAzul
	dibuja_rectan_color 7, 29, 7, 29, cBlanco, bgAzul
	dibuja_rectan_color 6, 30, 6, 32, cBlanco, bgAzul
	dibuja_rectan_color 7, 33, 7, 33, cBlanco, bgAzul
	dibuja_rectan_color 8, 34, 9, 34, cBlanco, bgAzul
	dibuja_rectan_color 10, 29, 10, 29, cBlanco, bgAzul
	dibuja_rectan_color 11, 30, 11, 32, cBlanco, bgAzul
	dibuja_rectan_color 10, 33, 10, 33, cBlanco, bgAzul
	dibuja_rectan_color 6, 38, 11, 39, cBlanco, bgAzul
	dibuja_rectan_color 11, 40, 11, 45, cBlanco, bgAzul
	dibuja_rectan_color 11, 48, 11, 49, cBlanco, bgAzul
	dibuja_rectan_color 10, 49, 10, 50, cBlanco, bgAzul
	dibuja_rectan_color 9, 50, 9, 56, cBlanco, bgAzul
	dibuja_rectan_color 8, 50, 8, 51, cBlanco, bgAzul
	dibuja_rectan_color 7, 51, 7, 52, cBlanco, bgAzul
	dibuja_rectan_color 6, 52, 6, 54, cBlanco, bgAzul
	dibuja_rectan_color 11, 57, 11, 58, cBlanco, bgAzul
	dibuja_rectan_color 10, 56, 10, 57, cBlanco, bgAzul
	dibuja_rectan_color 8, 55, 8, 56, cBlanco, bgAzul
	dibuja_rectan_color 7, 54, 7, 55, cBlanco, bgAzul
	ret

endp


marco_2 proc
;Dibuja elemento graficos del marco del menu principal del programa.

	call marco_2_2
	dibuja_rectan_color 4, 67, 18, 67, cBlanco, bgBlanco
	dibuja_rectan_color 5, 68, 17, 68, cBlanco, bgBlanco
	dibuja_rectan_color 6, 69, 16, 69, cBlanco, bgBlanco
	dibuja_rectan_color 7, 70, 15, 70, cBlanco, bgBlanco
	dibuja_rectan_color 8, 71, 14, 71, cBlanco, bgBlanco
	dibuja_rectan_color 9, 72, 13, 72, cBlanco, bgBlanco
	dibuja_rectan_color 10, 73, 12, 73, cBlanco, bgBlanco
	dibuja_rectan_color 11, 74, 11, 74, cBlanco, bgBlanco
	dibuja_rectan_color 19, 14, 21, 14, cBlanco, bgVerde
	dibuja_rectan_color 19, 17, 19, 17, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 20, 21, 20, cBlanco, bgVerde
	dibuja_rectan_color 19, 23, 19, 23, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 26, 21, 26, cBlanco, bgVerde
	dibuja_rectan_color 19, 29, 19, 29, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 32, 21, 32, cBlanco, bgVerde
	dibuja_rectan_color 19, 35, 19, 35, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 38, 21, 38, cBlanco, bgVerde
	dibuja_rectan_color 19, 41, 19, 41, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 44, 21, 44, cBlanco, bgVerde
	dibuja_rectan_color 19, 47, 19, 47, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 50, 21, 50, cBlanco, bgVerde
	dibuja_rectan_color 19, 53, 19, 53, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 56, 21, 56, cBlanco, bgVerde
	dibuja_rectan_color 19, 59, 19, 59, cBlanco, bgVerdeClaro
	dibuja_rectan_color 19, 62, 21, 62, cBlanco, bgVerde
	dibuja_rectan_color 19, 65, 19, 65, cBlanco, bgVerdeClaro
	ret
endp

marco_2_2 proc
;Dibuja el borde exterior del menu principal.

	dibuja_rectan_color 4, 14, 4, 66, cBlanco, bgCafe
	dibuja_rectan_color 18, 14, 18, 66, cBlanco, bgCafe
	dibuja_rectan_color 5, 14, 17, 14, cBlanco, bgCafe
	dibuja_rectan_color 5, 66, 17, 66, cBlanco, bgCafe
	ret
endp

opciones_botones_dibujo proc
;Dibuja los botones del submenu del cronometro y el texto dentro de ellos. 

	dibuja_rectan_color 4, 14, 18, 66, cBlanco, bgAmarillo
	dibuja_rectan_color 11, 19, 13, 29, cBlanco, bgVerde
	dibuja_rectan_color 14, 19, 16, 29, cBlanco, bgVerdeClaro
	dibuja_rectan_color 14, 35, 16, 44, cBlanco, bgCyanClaro
	dibuja_rectan_color 14, 50, 16, 60, cBlanco, bgCyan
	posiciona_cursor 12, 21
	imprime_cadena_color crono_boton1,7,cNegro,bgVerde
	posiciona_cursor 15, 20
	imprime_cadena_color crono_boton2,9,cNegro,bgVerdeClaro
	posiciona_cursor 15, 37
	imprime_cadena_color crono_boton3,6,cNegro,bgCyanClaro
	posiciona_cursor 15, 51
	imprime_cadena_color crono_boton4,9,cNegro,bgCyan
	call marco_2_2
ret
endp


crono_proc proc
;Empleado para realizar el calculo de la diferencia entre ticks iniciales y finales para imprimir el cronometro en pantalla. Toma un muestreo de ticks para retomar el curso
;del cronometro en caso de que sea interrumpida su ejecucion.

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

crono_proc endp

	end inicio			;Fin de etiqueta inicio, fin de programa.