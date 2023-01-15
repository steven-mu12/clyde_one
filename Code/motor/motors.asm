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
DELAYTEMP                        EQU 112
DELAYTEMP2                       EQU 113
SYSWAITTEMPMS                    EQU 114
SYSWAITTEMPMS_H                  EQU 115

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
;simple code to spin the motors
;#define left_positive PortC.7
;#define left_negative PortC.6
;#define right_positive PortC.5
;#define right_negative PortC.4
;dir left_positive out
	banksel	TRISC
	bcf	TRISC,7
;dir left_negative out
	bcf	TRISC,6
;dir right_positive out
	bcf	TRISC,5
;dir right_negative out
	bcf	TRISC,4
;---------------------
;These are the subroutines for movement
;---------------------
;----------------------
;the main loop
;----------------------
;do forever
SysDoLoop_S1
;forward()
	banksel	STATUS
	call	FORWARD
;wait 2000 ms
	movlw	208
	movwf	SysWaitTempMS
	movlw	7
	movwf	SysWaitTempMS_H
	call	Delay_MS
;backward()
	call	BACKWARD
;wait 2000 ms
	movlw	208
	movwf	SysWaitTempMS
	movlw	7
	movwf	SysWaitTempMS_H
	call	Delay_MS
;leftTurn()
	call	LEFTTURN
;wait 2000 ms
	movlw	208
	movwf	SysWaitTempMS
	movlw	7
	movwf	SysWaitTempMS_H
	call	Delay_MS
;rightTurn()
	call	RIGHTTURN
;wait 2000 ms
	movlw	208
	movwf	SysWaitTempMS
	movlw	7
	movwf	SysWaitTempMS_H
	call	Delay_MS
;loop
	goto	SysDoLoop_S1
SysDoLoop_E1
;end
	goto	BASPROGRAMEND
BASPROGRAMEND
	sleep
	goto	BASPROGRAMEND

;********************************************************************************

;Source: motors.gcb (27)
BACKWARD
;set left_positive off
	bcf	PORTC,7
;set left_negative on
	bsf	PORTC,6
;set right_positive off
	bcf	PORTC,5
;set right_negative on
	bsf	PORTC,4
	return

;********************************************************************************

Delay_MS
	incf	SysWaitTempMS_H, F
DMS_START
	movlw	4
	movwf	DELAYTEMP2
DMS_OUTER
	movlw	165
	movwf	DELAYTEMP
DMS_INNER
	decfsz	DELAYTEMP, F
	goto	DMS_INNER
	decfsz	DELAYTEMP2, F
	goto	DMS_OUTER
	decfsz	SysWaitTempMS, F
	goto	DMS_START
	decfsz	SysWaitTempMS_H, F
	goto	DMS_START
	return

;********************************************************************************

;Source: motors.gcb (19)
FORWARD
;set left_positive on
	bsf	PORTC,7
;set left_negative off
	bcf	PORTC,6
;set right_positive on
	bsf	PORTC,5
;set right_negative off
	bcf	PORTC,4
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

;Source: motors.gcb (35)
LEFTTURN
;set left_positive off
	bcf	PORTC,7
;set left_negative on
	bsf	PORTC,6
;set right_positive on
	bsf	PORTC,5
;set right_negative off
	bcf	PORTC,4
	return

;********************************************************************************

;Source: motors.gcb (43)
RIGHTTURN
;set left_positive on
	bsf	PORTC,7
;set left_negative off
	bcf	PORTC,6
;set right_positive off
	bcf	PORTC,5
;set right_negative on
	bsf	PORTC,4
	return

;********************************************************************************

;Start of program memory page 1
	ORG	2048
;Start of program memory page 2
	ORG	4096
;Start of program memory page 3
	ORG	6144

 END
