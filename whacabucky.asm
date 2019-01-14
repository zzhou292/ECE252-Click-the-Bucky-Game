; Filename:     whacabucky.asm
; Author: <Avinash Narisetty, Jason (Zhenhao) Zhou> <9078188563, 9076128074>
; Description: Whac-a-Bucky is an interactive game based on Whac-a-Mole.
;              Bucky will appear at pseudo-random locations on the display,
;              and the player must "whack" Bucky (by clicking it with 
;              the mouse).
;
; The program consists of the main loop, which:
;   1) keeps track of BUCKYTIMER, the time since bucky was last drawn
;   2) when BUCKYTIMER reaches zero, it erases and redraws 
;        bucky at a random new location and resets BUCKYTIMER
;   3) checks for mouse clicks, and if the mouse click hits bucky it also
;      erases and redraws bucky and resets BUCKYTIMER
;
; The main loop is provided for you. You should study it carefully to
; understand what it is doing.
;
; HOWEVER, DO NOT MODIFY THE MAIN LOOP until all required functionality
; is working correctly.
;
; To support the main loop, you will need to implement three subroutines:
;   1) BUCKY_DRAW: picks a random location and draws Bucky there
;   2) BUCKY_ERASE: erases Bucky
;   3) BUCKY_CLICK: check to see if a mouse click landed on Bucky
;
; These routines are detailed below in the headers for each subroutine.
;
        	.ORIG x3000
BUCKY_START
	; initialize BUCKYTIMER in R4
	LD R4,BUCKY_TIMEOUT_VAL
	; draw initial bucky
	JSR BUCKY_DRAW
BUCKY_LOOP
	ADD R4, R4, #-1         ; decrement BUCKYTIMER
	BRzp BUCKY_NOTIMEOUT    
	; erase & redraw BUCKY
	JSR BUCKY_ERASE
	JSR BUCKY_DRAW
	; initialize BUCKYTIMER
	LD R4,BUCKY_TIMEOUT_VAL
BUCKY_NOTIMEOUT
	; check for mouse click
	TRAP x44
	BRn BUCKY_NOCLICK
	; process mouse click, R0=0 if fail, R0=1 if success
	JSR BUCKY_CLICK         ; R0 contains MCDR
	AND R0,R0,R0            ; set condition codes based on R0
	BRz BUCKY_NOCLICK       ; bad click is the same as no click
	; erase & redraw BUCKY
	JSR BUCKY_ERASE
	JSR BUCKY_DRAW
	; initialize BUCKYTIMER
	LD R4,BUCKY_TIMEOUT_VAL
BUCKY_NOCLICK
	TRAP x45                ; always call random to increase randomness
	; back to the top
	BR BUCKY_LOOP
DONE	HALT
	
BUCKY_TIMEOUT_VAL
	.FILL x7FFF             ; smaller number makes game more difficult

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subroutine:   BUCKY_DRAW
; Description:  Picks a random X,Y location and draws bucky there.
;               Old frame buffer pixels are saved in BUCKY_BUFFER
;               Random X,Y are found using TRAP_RANDOM (x45)
;               Bucky is drawn by calling TRAP_BITBLT (x46)
; Assumes:      None; no parameters
; Returns:      None; but location of bucky must be saved in BUCKY_X
;               and BUCKY_Y
; Hints and suggestions:
;   This is a very simple subroutine, so don't overthink it.
;   My implementation is only 9 LC-3 instructions, plus save/restore
;   of 5 registers.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BUCKY_DRAW
	; save registers
	ST R1,BUCKY_DRAW_R1	
	ST R2,BUCKY_DRAW_R2
	ST R3,BUCKY_DRAW_R3
	ST R0,BUCKY_DRAW_R0
	ST R7,BUCKY_DRAW_R7			

	; get random X
	
	TRAP x45
	ST R0,BUCKY_X

	; get random Y
	
	TRAP x45	
	ST R0,BUCKY_Y

	; set up parameters to BITBLT TRAP
	LD R0,BUCKY_X
	LD R1,BUCKY_Y
	LD R2,BUCKY_PIXELS
	LEA R3,BUCKY_BUFFER
	

	; invoke BITBLT TRAP
	
	TRAP x46

	; restore registers and return
	LD R1,BUCKY_DRAW_R1	
	LD R2,BUCKY_DRAW_R2
	LD R3,BUCKY_DRAW_R3
	LD R0,BUCKY_DRAW_R0
	LD R7,BUCKY_DRAW_R7
	RET
BUCKY_X		.BLKW 1         ; saved X location of bucky (for BUCKY_ERASE)
BUCKY_Y		.BLKW 1         ; saved Y location of bucky
BUCKY_DRAW_R1	.BLKW 1         ; declare space here for saved registers
BUCKY_DRAW_R2	.BLKW 1   
BUCKY_DRAW_R3	.BLKW 1   
BUCKY_DRAW_R0	.BLKW 1   
BUCKY_DRAW_R7	.BLKW 1   

BUCKY_PIXELS	.FILL x4000	; address of bucky pixel data, see bucky_pixels.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subroutine:   BUCKY_ERASE
; Description:  Erases bucky from BUCKY_X, BUCKY_Y
;               Bucky is erased by calling TRAP_BITBLT (x46)
; Assumes:      None; but assumes BUCKY_BUFFER contains saved pixels and
;               BUCKY_X and BUCKY_Y contain current location of bucky.
; Returns:      None;
; Hints and suggestions:
;   This is a very simple subroutine, so don't overthink it.
;   My implementation is only 5 LC-3 instructions, plus save/restore
;   of 5 registers.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BUCKY_ERASE
	; save registers
	ST R1,BUCKY_ERASE_R1	
	ST R2,BUCKY_ERASE_R2
	ST R3,BUCKY_ERASE_R3
	ST R0,BUCKY_ERASE_R0
	ST R7,BUCKY_ERASE_R7
	; set up parameters to BITBLT TRAP
	LD R0,BUCKY_X
	LD R1,BUCKY_Y
	LEA R2,BUCKY_BUFFER
	LD R3,BUCKY_PIXELS
	; invoke BITBLT TRAP
	TRAP x46
	; restore registers and return
	LD R1,BUCKY_ERASE_R1	
	LD R2,BUCKY_ERASE_R2
	LD R3,BUCKY_ERASE_R3
	LD R0,BUCKY_ERASE_R0
	LD R7,BUCKY_ERASE_R7
	RET
BUCKY_ERASE_R1	.BLKW 1         ; declare space here for saved registers
BUCKY_ERASE_R2	.BLKW 1   
BUCKY_ERASE_R3	.BLKW 1   
BUCKY_ERASE_R0	.BLKW 1   
BUCKY_ERASE_R7	.BLKW 1   



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subroutine:   BUCKY_CLICK
; Description:  Checks to see if mouse click falls within 40x27 Bucky
;               Uses provided BUCKY_ROL subroutine to extract Y
;               coordinate from MCDR.
; Assumes:      R0 contains MCDR
;               BUCKY_X and BUCKY_Y contain current location of bucky
; Returns:      R0 contains 1 if click lands on bucky, otherwise 0
; Hints and suggestions:
;   This routine is a bit tricky, as it requires masking and rotating
;   to extract the X and Y coordinates from the MCDR value. You should
;   use the provided BUCKY_ROL (rotate left) subroutine to get at the
;   Y bits in MCDR[13:7].
;
;   The implementation below is a _STUB_ which is useful for testing
;   the rest of your code before you have implemented this routine.
;   In this case, the stub always returns 0 to indicate that the
;   click failed (i.e. did not land on bucky).
;
;   My implementation is 25 LC-3 instructions, plus save/restore
;   of 5 registers. If your implementations has many fewer  
;   instructions, you are probably missing something. If your
;   implementation has more instructions, but works correctly, don't
;   worry, you will get full points for it.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subroutine:   BUCKY_CLICK
; Description:  Checks to see if mouse click falls within 40x27 Bucky
;               Uses provided BUCKY_ROL subroutine to extract Y
;               coordinate from MCDR.
; Assumes:      R0 contains MCDR
;               BUCKY_X and BUCKY_Y contain current location of bucky
; Returns:      R0 contains 1 if click lands on bucky, otherwise 0
; Hints and suggestions:
;   This routine is a bit tricky, as it requires masking and rotating
;   to extract the X and Y coordinates from the MCDR value. You should
;   use the provided BUCKY_ROL (rotate left) subroutine to get at the
;   Y bits in MCDR[13:7].
;
;   The implementation below is a _STUB_ which is useful for testing
;   the rest of your code before you have implemented this routine.
;   In this case, the stub always returns 0 to indicate that the
;   click failed (i.e. did not land on bucky).
;
;   My implementation is 25 LC-3 instructions, plus save/restore
;   of 5 registers. If your implementations has many fewer  
;   instructions, you are probably missing something. If your
;   implementation has more instructions, but works correctly, don't
;   worry, you will get full points for it.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BUCKY_CLICK
	; save registers
	ST R1,BUCKY_CLICK_R1	
	ST R2,BUCKY_CLICK_R2
	ST R3,BUCKY_CLICK_R3
	ST R4,BUCKY_CLICK_R4
	ST R5,BUCKY_CLICK_R5

	LD R2, BUCKY_CLICK_MASK
	LD R1, BUCKY_CLICK_ROT
	LD R5, BUCKY_X
	LD R6, BUCKY_Y

	; extract X from MCDR[6:0]
	AND R3, R0, R2

	; extract Y from MCDR[13:7]
	ST R7,BUCKY_CLICK_RET
	JSR BUCKY_ROL
	LD R7,BUCKY_CLICK_RET
	AND R4, R0, R2

	; now have X,Y in registers, negate them for subtraction
	NOT R3, R3
	ADD R3, R3, #1

	NOT R4, R4
	ADD R4, R4, #1

	; check if X >= BUCKY_X
	ADD R1, R5, R3
	BRp TEST_FAIL                 

	; check if X < BUCKY_X+BUCKY_XDIM
	LD R2, BUCKY_XDIM
	ADD R2, R2, R5
	ADD R1, R2, R3
	BRnz TEST_FAIL                


	; check if Y >= BUCKY_Y
	ADD R1, R6, R4
	BRp TEST_FAIL               

	; check if Y < BUCKY_Y+BUCKY_YDIM
	LD R2, BUCKY_YDIM
	ADD R2, R2, R6
	ADD R1, R2, R4
	BRnz TEST_FAIL              

	; if all four tests passed return 1
	AND R0, R0, #0
	ADD R0, R0, #1
	BR BUCKY_CLICK_EXIT            

	; if any of the four tests failed return 0
TEST_FAIL
	AND R0,R0,#0
BUCKY_CLICK_EXIT
	; restore registers and return
	LD R1,BUCKY_CLICK_R1
	LD R2,BUCKY_CLICK_R2
	LD R3,BUCKY_CLICK_R3
	LD R4,BUCKY_CLICK_R4
	LD R5,BUCKY_CLICK_R5
	RET


; declare space here for saved registers
BUCKY_CLICK_R1	.BLKW 1  
BUCKY_CLICK_R2	.BLKW 1  
BUCKY_CLICK_R3	.BLKW 1  
BUCKY_CLICK_R4	.BLKW 1  
BUCKY_CLICK_R5	.BLKW 1  

BUCKY_CLICK_MASK .FILL x007F    ; what mask value do you need?
BUCKY_CLICK_ROT  .FILL #9      ; how many bits should you rotate MCDR left?
BUCKY_XDIM .FILL #40            ; size of bucky in X dimension
BUCKY_YDIM .FILL #27            ; size of bucky in Y dimension
BUCKY_CLICK_RET .BLKW 1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subroutine:   BUCKY_ROL (rotate left)
; Description:  Rotates R0 to the left by R1 bit positions
; Assumes:      R0 contains value to be rotated
;               R1 contains rotation amount (0-15)
; Returns:      R0 contains rotated value, R1 is callee-saved
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BUCKY_ROL
	; save registers
	ST R1,BUCKY_ROL_R1
	ST R4,BUCKY_ROL_R4
	; initialize result R4, set up rotate count
	AND R4,R4,#0            ; initialize R4 to 0
	AND R1,R1,#15           ; make sure rotate count is 0-15
	; start rotate loop by testing for zero case
	BRz BUCKY_ROL_EXIT
BUCKY_ROL_LOOP
	ADD R4,R4,R4            ; shift result left
	AND R0,R0,R0            ; check sign bit of input
	BRzp BUCKY_ROL_ZEROBIT
	ADD R4,R4,#1            ; set low bit to one, otherwise zero
BUCKY_ROL_ZEROBIT
	ADD R0,R0,R0            ; shift input left
	; decrement shift count and continue if needed
	ADD R1,R1,#-1
	BRp BUCKY_ROL_LOOP
	; finished shifting R1 bits      
	; now have result in R4, copy to R0
	AND R0,R4,R4
BUCKY_ROL_EXIT
	; restore registers and return
	LD R1,BUCKY_ROL_R1
	LD R4,BUCKY_ROL_R4
	RET
BUCKY_ROL_R1	.BLKW 1
BUCKY_ROL_R4	.BLKW 1

	; BUCKY_BUFFER placed at end to get it out of the way 
BUCKY_BUFFER    .BLKW #1080     ; need space for 40x27 pixels

	.END
