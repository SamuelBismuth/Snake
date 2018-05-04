SYSCRTL_RCGCGPIO_R	EQU 0x400FE608 ;+offset 0x608
GPIO_PORTF_DIR_R	EQU 0x40025400 ;+offset 0x400
GPIO_PROTF_DEN_R	EQU 0x4002551C ;+offset 0x51c
GPIO_PORTF_DATA_R  	EQU 0x400253fC ;+offset 0x3fc
	
GPIO_PORTF_PUR_R	EQU 0x40025510 ;+offset 0x510

GPIO_LOCK_R  	EQU 0x40025520 ;+offset 0x3fc
GPIO_LOCK_KEY  	EQU 0x4C4F434B ;
GPIO_OCR_R  	EQU 0x40025524

GPIO_PORTF_SW2_DATA_R  	EQU 0x40025004 ;Find THE DATA ADDRESS!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
GPIO_PORTF_SW1_DATA_R  	EQU 0x40025040
	
		AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT GPIOF_Init
        EXPORT RED_LED_OFF
        EXPORT RED_LED_ON
		EXPORT CHECK_SW2
		;new export sw1
		EXPORT CHECK_SW1
			
GPIOF_Init
		PUSH {LR}                       ; save current value of LR
		;Enable Clock Port F(0-4)- by default the clock is disabled on the GPIO for energy saving
		LDR R1,=SYSCRTL_RCGCGPIO_R 
		LDR R0,[R1]
		ORR R0,R0,#0x20 ;Bitwise OR, to not overide the existing values
		STR R0,[R1]
	
		;Unlock and enable SW#
		;IMPORTANT- READ "10.4 Register Map" (page 658) followd by (GPIOLOCK) page 668 to unlock (GPIOCR) 
		LDR R1,=GPIO_LOCK_R ;(GPIOLOCK) address
		LDR R0,=GPIO_LOCK_KEY ;from datasheet 0x4C4F434B
		STR R0,[R1]
	
		;READ (GPIOCR) (page 685) - Enables to configure (GPIOAFSEL, GPIOPUR, GPIOPDR, and GPIODEN) at coresponding pins
		LDR R1,=GPIO_OCR_R 
		MOV R0,#0x01
		STR R0,[R1]
		
		;Set input/output - PF1(output,ledR),PF0(input,switch)
		LDR R1,=GPIO_PORTF_DIR_R 
		MOV R0,#0x02
		STR R0,[R1]
		
		;Set the PORTF to operate as (digital)/not digital PF0,1,4(sw2,led_r,sw1)
		LDR R1,=GPIO_PROTF_DEN_R 
		MOV R0,#0x13
		STR R0,[R1]
		
		;Set pullup on sw2 ----- NEW for sw1 ------------------------------------------------------
		LDR R1,=GPIO_PORTF_PUR_R 
		MOV R0,#0x10
		STR R0,[R1]
		
		POP {PC}                        ; restore previous value of LR into PC (return)

RED_LED_ON
		PUSH {LR}                       ; save current value of LR
		LDR R1,=GPIO_PORTF_DATA_R 
		MOV R0,#0x02
		STR R0,[R1]
		;B loop
		POP {PC}                        ; restore previous value of LR into PC (return)

RED_LED_OFF
		PUSH {LR}                       ; save current value of LR
		LDR R1,=GPIO_PORTF_DATA_R 
		MOV R0,#0x00
		STR R0,[R1]
		;B loop
		POP {PC}   		; restore previous value of LR into PC (return)
		
CHECK_SW2
		PUSH {LR}                       ; save current value of LR
		LDR R1,=GPIO_PORTF_SW2_DATA_R ;Get SW data address
		LDR R5,[R1]	;Get SW data 
		POP {PC}                        ; restore previous value of LR into PC (return)	

CHECK_SW1;-------------------------------------------------------------------
		PUSH {LR}                       ; save current value of LR
		LDR R1,=GPIO_PORTF_SW1_DATA_R ;Get SW data address
		LDR R6,[R1]	;Get SW data 
		POP {PC}                        ; restore previous value of LR into PC (return)	
			
	ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file