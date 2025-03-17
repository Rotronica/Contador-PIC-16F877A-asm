;EJERCICIO 1
;Realizar un programa en ensamblador, que cuando se presione un pulsador 
;pull-down incremente un contador, este contador se tiene que visualizar 
;por un display de cátodo común, el pulsador esta conectado al pin RA0, 
;El display está conectado al puerto B.

		__CONFIG _XT_OSC & _WDTE_OFF & _PWRTE_OFF & _CP_OFF & _LVP_OFF & _BOREN_OFF
		LIST	P=16F877A
		INCLUDE	<P16F877A.INC>


		CBLOCK 0X20			;Bloque de variables
		INCREMENTAR
		CONT1
		CONT2
		CONT3
		ENDC
		#DEFINE	BUTTON	PORTA,RA0

			ORG		0X00		;El programa inicia en estadirección
			GOTO	CONFIGURAR	;Ir a etiqueta CONFIGURAR
CONFIGURAR:
			BSF		STATUS,RP0	;Ingresar al banco 1
			MOVLW	0X06		;Cargarel dato 0x06 al registro de trabajo
			MOVWF	ADCON1		;Mover el registro de trabajo al registro ADCON1
			BSF		TRISA,RA0	;Configura el bit en especifico  RA0 como entrada de señal
			CLRF	TRISB		;Todo el pueto B se configura como salida
			BCF		STATUS,RP0	;Volver al banco 0
			CLRF	PORTB		;Limpiar el puerto B
			CLRF	INCREMENTAR	;Limpiar el registro auxiliar 
;--------PROGRAMA_PRINCIPAL----------------
;------------------------------------------
MAIN:
		CALL	VISUALIZAR		;Subrutina para visualizar los valores en el display
		BTFSS	BUTTON			;Pregunta si se presionó el pulsador para luego realizar el salto
		GOTO	MAIN			;No se presiono ejecuta GOTO MAIN
		CALL	RETARDO_20MS	;Salta aqui si se prsiono el pulsador ejecuta Retardo de antirrebote
		BTFSS	BUTTON			;Vuelve a preguntar si esta pulsado o solo fue rebote
		GOTO	MAIN			;Fue rebote y ejecuta GOTO MAIN
		CALL	CONTADOR		;Salta aquí por que se presionó el pulsador y no fue rebote, ejecuta CALL CONTADOR 
ESPERA_DEJA_PULSAR:
		BTFSC	BUTTON			;Si se dejo de pulsar realiza un salto
		GOTO	ESPERA_DEJA_PULSAR	;Sigue presionado ejecuta GOTO	ESPERA_DEJA_PULSAR
		GOTO	MAIN			;Se dejo de presionar realiza el salto y ejecuta GOTO MAIN
;-----------------------------------------

;+--------------MÓDULO_PARA_VISUALIZAR----------------------------------+
VISUALIZAR:
			MOVF	INCREMENTAR,W	;Mover el contenido del registro INCEMENTAR a 'W' 
			CALL	TABLA_DEC		;Realiza el llamado a la subrutina TABLA_DEC
			MOVWF	PORTB			;Vuelve con un valor en el registro de trabajo y lo mueve al PORTB
			RETURN					;Retorno de subrutina
;+----------------------------------------------------------------------+

;+-------------MÓDULO_PARA_INCREMENTAR_UN_CONTADOR_AUXILIAR-------------+
CONTADOR:
			INCF	INCREMENTAR,F	;INCREMENTAR=INCREMENTAR+1
			MOVLW	.10				;Límite del incremento
			SUBWF	INCREMENTAR,W	;W=INCREMENTAR-W
			BTFSS	STATUS,Z		;Verifica la bandera 'z'
			RETURN					;Retorno de Subrutina
			CLRF	INCREMENTAR		;Limpiar el registro INCREMENTAR
			RETURN					;Retorno de Subrutina
;+----------------------------------------------------------------------+
			
;Tabla de los numeros a visualizar por el puerto B en el display 7 segentos
TABLA_DEC:
			ADDWF	PCL,F	;PCL=PCL+W
			RETLW	0X3F	;0
			RETLW	0X06	;1
			RETLW	0X5B	;2
			RETLW	0X4F	;3
			RETLW	0X66	;4
			RETLW	0X6D	;5
			RETLW	0X7D	;6
			RETLW	0X07	;7
			RETLW	0X7F	;8
			RETLW	0X6F	;9
;Subrutina de Retardo de 20ms
RETARDO_20MS:
			MOVLW	.13		;P
			MOVWF	CONT1
BUCLE3:
			MOVLW	.10		;M
			MOVWF	CONT2
BUCLE2:
			MOVLW	.50		;N
			MOVWF	CONT1
BUCLE1:
			DECFSZ	CONT1,F	
			GOTO	BUCLE1
			DECFSZ	CONT2,F
			GOTO	BUCLE2
			DECFSZ	CONT3,F
			GOTO	BUCLE3
			RETURN
			END