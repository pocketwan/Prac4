/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

   STR R2, [R1, #0x14]       @ Write the value of 0 to GPIOB (LEDs)
   BL delay_long

main_loop:

check_sw_3:                   @ Checking SW3
    LDR R3, [R0, #0x10]       @ Read SW3 input
    MOVS R4, #0x08            @ Load 0x08 into R4
    ANDS R4, R4, R3           @ Check if SW2 is pressed
    BNE check_sw_2            @ If SW3 not pressed, check other switches

    STR R2, [R1, #0x14]        @ Display and freeze the current pattern
    BL delay_long
    B main_loop

check_sw_2:                   @ Checking SW2
    LDR R3, [R0, #0x10]       @ Read SW2 input
    MOVS R4, #0x04            @ Load 0x04 into R4
    ANDS R4, R4, R3           @ Check if SW2 is pressed
    BNE check_sw_0            @ If SW2 not pressed, check other switches

    MOVS R2, #0xAA 			  @ Display 0xAA if SW2 pressed
    STR R2, [R1, #0x14]        @ Write the value of R2 to GPIOB (LEDs)
    BL delay_long
    B main_loop

check_sw_0:                   @ Checking SW0
    LDR R3, [R0, #0x10]       @ Read SW0 input
    MOVS R4, #0x01            @ Load 0x01 into R4
    ANDS R4, R4, R3           @ Check if SW0 is pressed (bit 0)
    BNE increment_by_1        @ If SW0 not pressed, increment by 1

increment_by_2:
    ADDS R2, R2, #2           @ Increment by 2 if SW0 is pressed

check_sw_1:                   @ Checking SW1
    LDR R3, [R0, #0x10]       @ Read SW1 input
    MOVS R4, #0x02            @ Load 0x02 into R4
    ANDS R4, R4, R3           @ Check if SW1 is pressed
    BNE leds_long             @ If SW1 not pressed, continue with 0.7s delay
    BL leds_short             @ If SW1 is pressed, change to 0.3s delay

increment_by_1:
    ADDS R2, R2, #1            @ Increment by 1
    BL check_sw_1              @ Check switch 1

leds_long:
    CMP R2, #255               @ Check if counter reached 255
    BNE write_leds_long             @ If not 255, continue
    STR R2, [R1, #0x14]       @ Write the value of R2 to GPIOB (LEDs)
    BL delay_long
    MOVS R2, #0                @ If equal to 255, reset to 0

write_leds_long:
    STR R2, [R1, #0x14]        @ Write the value of R2 to GPIOB (LEDs)
    BL delay_long
    B main_loop                @ Repeat the loop

delay_long:
	LDR R5, LONG_DELAY_CNT      @ Load delay value

delay_long_loop:
	SUBS R5, R5, #1             @ Decrement delay counter
	BNE delay_long_loop              @ If not zero, continue delaying
	BX LR         

leds_short:
    CMP R2, #255               @ Check if counter reached 255
    BNE write_leds_short             @ If not 255, continue
    STR R2, [R1, #0x14]       @ Write the value of R2 to GPIOB (LEDs)
    BL delay_short
    MOVS R2, #0                @ If equal to 255, reset to 0

write_leds_short:
    STR R2, [R1, #0x14]        @ Write the value of R2 to GPIOB (LEDs)
    BL delay_short
    B main_loop                @ Repeat the loop

delay_short:				@ Change dealy to 0.3 seconds if SW1 pressed
	LDR R5, SHORT_DELAY_CNT

delay_short_loop:
	SUBS R5, R5, #1             @ Decrement delay counter
	BNE delay_short_loop              @ If not zero, continue delaying
	BX LR

@ LITERALS; DO NOT EDIT
.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 600000
