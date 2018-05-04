; UARTIntTestMain.s
; Runs on LM4F120/TM4C123
; Tests the UART0 to implement bidirectional data transfer to and from a
; computer running PuTTY.  This time, interrupts and FIFOs
; are used.
; This file is named "UART2" because it is the second UART example.
; It is not related to the UART2 module on the microcontroller.
; Daniel Valvano
; September 12, 2013

;  This example accompanies the book
;  "Embedded Systems: Real Time Interfacing to Arm Cortex M Microcontrollers",
;  ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2015
;  Program 5.11 Section 5.6, Program 3.10
;
;Copyright 2015 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/

; U0Rx (VCP receive) connected to PA0
; U0Tx (VCP transmit) connected to PA1

; standard ASCII symbols
CR                 EQU 0x0D ;/r
LF                 EQU 0x0A ;/n
BS                 EQU 0x08 ;backspace
ESC                EQU 0x1B ;escape
SPA                EQU 0x20 ;space
DEL                EQU 0x7F ;delete

; functions in PLL.s
        IMPORT PLL_Init ;import label PLL_Init but EXPORT must be declared in PLL.s file

; functions UART.s
        IMPORT UART_Init
        IMPORT UART_InChar
        IMPORT UART_OutChar
			;functions in portFConfiguration.s
		IMPORT GPIOF_Init
		IMPORT RED_LED_OFF
		IMPORT RED_LED_ON
		IMPORT CHECK_SW2
		;new import sw1
        IMPORT CHECK_SW1
		IMPORT   RxFifo_Init
        IMPORT   RxFifo_Put
        IMPORT   RxFifo_Get
        IMPORT  RxFifo_Size
			
		AREA    DATA, ALIGN=2

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT Start

    ALIGN                           ; make sure the end of this section is aligned

;---------------------OutCRLF---------------------
; Output a CR,LF to UART to go to a new line
; Input: none
; Output: none

CHECK2SW
    PUSH{LR}
    MOV R0, #0x4E 						; R0 = 'N'
    BL CHECK_SW2
    CMP R5, #0x00
    BLNE UART_OutChar
    POP{PC}
   
CHECKBITE
	PUSH{LR}
    BL RxFifo_Get
    BL RxFifo_Size
	POP{PC}
	
ZERO_R9
	PUSH{LR}
	MOV R9, #0x00 
	POP{PC}
   
OutCRLF ;perform /r/n
    PUSH {LR}                       ; save current value of LR
    MOV R0, #CR                     ; R0 = CR (<carriage return>);/r
    BL  UART_OutChar                ; send <carriage return> to the UART`
    MOV R0, #LF                     ; R0 = LF (<line feed>)/n
    BL  UART_OutChar                ; send <line feed> to the UART
    POP {PC}                        ; restore previous value of LR into PC (return)

Start
    BL  PLL_Init                    ; set system clock to 50 MHz
    BL  UART_Init                   ; initialize UART
	BL	GPIOF_Init
    BL  OutCRLF                     ; go to a new line
	
loop

	MOV R0, #0x4C                     ; R0 = 'L'
	BL	CHECK_SW1
	CMP R6,#0x00
	;Do reg-arg if 0 then set zero-flag to 1 else to 0
	BLEQ  UART_OutChar            ; echo the character back to the UART
	BLNE CHECK2SW
	
	MOV R0, #0x52                    ; R0 = 'R'
	BL	CHECK_SW2
	CMP R5,#0x00 
	;Do reg-arg if 0 then set zero-flag to 1 else to 0
	BLEQ  UART_OutChar   	; echo the character back to the UART
	
	BL CHECKBITE
	CMP R0, #0x01
	BLEQ RED_LED_ON
	
	ADD R9, #0x01
	CMP R9, #0x60
	BLEQ RED_LED_OFF
	
	CMP R9, #0xFF
	BLEQ ZERO_R9
	
    B   loop   
	
    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file