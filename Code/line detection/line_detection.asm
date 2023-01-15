;Program compiled by Great Cow BASIC (0.99.01 2022-01-27 (Windows 64 bit) : Build 1073) for Microchip MPASM
;Need help? See the GCBASIC forums at http://sourceforge.net/projects/gcbasic/forums,
;check the documentation or email w_cholmondeley at users dot sourceforge dot net.

;********************************************************************************

;Set up the assembler options (Chip type, clock source, other bits and pieces)
 LIST p=16F887, r=DEC
#include <P16F887.inc>
 __CONFIG _CONFIG1, _LVP_OFF & _FCMEN_ON & _CPD_OFF & _CP_OFF & _MCLRE_OFF & _WDTE_OFF & _INTOSCIO
 __CONFIG _CONFIG2, _WRT_OFF

;********************************************************************************

;Set aside memory locations for variables
ADREADPORT                       EQU 32
ADTEMP                           EQU 33
DELAYTEMP                        EQU 112
READAD                           EQU 34
SYSWAITTEMP10US                  EQU 117
VALUE                            EQU 35

;********************************************************************************

;Alias variables
ALLANSEL EQU 392
ALLANSEL_H EQU 393
SYSREADADBYTE EQU 34

;********************************************************************************

;Vectors
	ORG	0
	pagesel	BASPROGRAMSTART
	goto	BASPROGRAMSTART
	ORG	4
	retfie

;********************************************************************************

;Start of program memory page 0
	ORG	5
BASPROGRAMSTART
;Call initialisation routines
	call	INITSYS

;Start of the main program
;#define linePort AN7
;#define testLed PortD.1
;dir testLed out
	banksel	TRISD
	bcf	TRISD,1
;Do Forever
SysDoLoop_S1
;value = ReadAD(linePort)
	movlw	7
	banksel	ADREADPORT
	movwf	ADREADPORT
	call	FN_READAD4
	movf	SYSREADADBYTE,W
	movwf	VALUE
;if value>0 then
	sublw	0
	btfsc	STATUS, C
	goto	ELSE1_1
;set testLed on
	bsf	PORTD,1
;else
	goto	ENDIF1
ELSE1_1
;set testLed off
	bcf	PORTD,1
;end if
ENDIF1
;loop
	goto	SysDoLoop_S1
SysDoLoop_E1
;end
	goto	BASPROGRAMEND
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

Delay_10US
D10US_START
	movlw	5
	movwf	DELAYTEMP
DelayUS0
	decfsz	DELAYTEMP,F
	goto	DelayUS0
	nop
	decfsz	SysWaitTemp10US, F
	goto	D10US_START
	return

;********************************************************************************

;Source: system.h (156)
INITSYS
;asm showdebug This code block sets the internal oscillator to ChipMHz
;asm showdebug 'OSCCON type is 103 - This part does not have Bit HFIOFS @ ifndef Bit(HFIOFS)
;OSCCON = OSCCON OR b'01110000'
	movlw	112
	banksel	OSCCON
	iorwf	OSCCON,F
;OSCCON = OSCCON AND b'10001111'
	movlw	143
	andwf	OSCCON,F
;Address the two true tables for IRCF
;[canskip] IRCF2, IRCF1, IRCF0 = b'111'    ;111 = 8 MHz (INTOSC drives clock directly)
	bsf	OSCCON,IRCF2
	bsf	OSCCON,IRCF1
	bsf	OSCCON,IRCF0
;End of type 103 init
;asm showdebug _Complete_the_chip_setup_of_BSR,ADCs,ANSEL_and_other_key_setup_registers_or_register_bits
;Ensure all ports are set for digital I/O and, turn off A/D
;SET ADFM OFF
	bcf	ADCON1,ADFM
;Switch off A/D Var(ADCON0)
;SET ADCON0.ADON OFF
	banksel	ADCON0
	bcf	ADCON0,ADON
;ANSEL = 0
	banksel	ANSEL
	clrf	ANSEL
;ANSELH = 0
	clrf	ANSELH
;Set comparator register bits for many MCUs with register CM2CON0
;C2ON = 0
	banksel	CM2CON0
	bcf	CM2CON0,C2ON
;C1ON = 0
	bcf	CM1CON0,C1ON
;
;'Turn off all ports
;PORTA = 0
	banksel	PORTA
	clrf	PORTA
;PORTB = 0
	clrf	PORTB
;PORTC = 0
	clrf	PORTC
;PORTD = 0
	clrf	PORTD
;PORTE = 0
	clrf	PORTE
	return

;********************************************************************************

;Overloaded signature: BYTE:, Source: a-d.h (1748)
FN_READAD4
;ADFM should configured to ensure LEFT justified
;SET ADFM OFF
	banksel	ADCON1
	bcf	ADCON1,ADFM
;***************************************
;Perform conversion
;LLReadAD 1
;Macro Source: a-d.h (373)
;Code for PICs with with ANSEL register
;Dim AllANSEL As Word Alias ANSELH, ANSEL
;AllANSEL = 0
	banksel	ALLANSEL
	clrf	ALLANSEL
	clrf	ALLANSEL_H
;ADTemp = ADReadPort + 1
	banksel	ADREADPORT
	incf	ADREADPORT,W
	movwf	ADTEMP
;Set C On
	bsf	STATUS,C
;Do
SysDoLoop_S2
;Rotate AllANSEL Left
	banksel	ALLANSEL
	rlf	ALLANSEL,F
	rlf	ALLANSEL_H,F
;decfsz ADTemp,F
	banksel	ADTEMP
	decfsz	ADTEMP,F
;Loop
	goto	SysDoLoop_S2
SysDoLoop_E2
;SET ADCS1 OFF
	bcf	ADCON0,ADCS1
;SET ADCS0 ON
	bsf	ADCON0,ADCS0
;Choose port
;SET CHS0 OFF
	bcf	ADCON0,CHS0
;SET CHS1 OFF
	bcf	ADCON0,CHS1
;SET CHS2 OFF
	bcf	ADCON0,CHS2
;SET CHS3 OFF
	bcf	ADCON0,CHS3
;IF ADReadPort.0 On Then Set CHS0 On
	btfsc	ADREADPORT,0
	bsf	ADCON0,CHS0
;IF ADReadPort.1 On Then Set CHS1 On
	btfsc	ADREADPORT,1
	bsf	ADCON0,CHS1
;IF ADReadPort.2 On Then Set CHS2 On
	btfsc	ADREADPORT,2
	bsf	ADCON0,CHS2
;If ADReadPort.3 On Then Set CHS3 On
	btfsc	ADREADPORT,3
	bsf	ADCON0,CHS3
;Enable A/D
;SET ADON ON
	bsf	ADCON0,ADON
;Acquisition Delay
;Wait AD_Delay
	movlw	2
	movwf	SysWaitTemp10US
	call	Delay_10US
;Read A/D @1
;SET GO_NOT_DONE ON
	bsf	ADCON0,GO_NOT_DONE
;nop
	nop
;Wait While GO_NOT_DONE ON
SysWaitLoop1
	btfsc	ADCON0,GO_NOT_DONE
	goto	SysWaitLoop1
;Switch off A/D
;SET ADCON0.ADON OFF
	bcf	ADCON0,ADON
;ANSEL = 0
	banksel	ANSEL
	clrf	ANSEL
;ANSELH = 0
	clrf	ANSELH
;ReadAD = ADRESH
	banksel	ADRESH
	movf	ADRESH,W
	movwf	READAD
;SET ADFM OFF
	banksel	ADCON1
	bcf	ADCON1,ADFM
	banksel	STATUS
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
