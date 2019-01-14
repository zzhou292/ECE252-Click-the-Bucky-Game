;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File:   TEST_BUCKY_CLICK - unit test for BUCKY_CLICK
; Description:  Sets BUCKY_X,BUCKY_Y to random values and then calls
;               BUCKY_CLICK near that X,Y location to test for proper
;               functionality.
; A total of twelve test cases are applied for each X,Y (3 at each corner).
; Here the t in the top left corner is at BUCKY_X,BUCKY_Y:
;
;    f         f
;   ft---------tf          t: test case should return 1
;    |         |           f: test case should return 0 (just outside)
;    |         |
;   ft---------tf
;    f         f
;
	.ORIG	x3000
TEST_BUCKY_CLICK
	LD R2,ITERATIONS        ; iteration count
	LD R3,DISP_BASE         ; display base value (xC000)
	NOT R3,R3               ; negate for subtraction
	ADD R3,R3,#1            ; negate for subtraction
AGAIN	; get random X
	TRAP x45
	ST R0, BUCKY_X
	; get random Y
	TRAP x45
	ST R0, BUCKY_Y
	LD R4,TEST_CASES
	NOT R4,R4
	ADD R4,R4,#1            ; negated to see if we are done
	AND R5,R5,#0            ; initialize loop count
TESTCASELOOP
	ADD R0,R5,R4            ; check test case loop bound
	BRzp GOAGAIN            ; move on to next random X,Y
	; otherwise apply current test case
	LD R0, BUCKY_X
	LEA R6, TESTOFFSET_X0   ; get X offset for this test case
	ADD R6,R6,R5            ; add loop offset to array base
	LDR R6, R6, #0          ; load nth entry from array
	ADD R0,R0,R6            ; add offset to BUCKY_X
	LD R1, BUCKY_Y
	LEA R6, TESTOFFSET_Y0   ; get Y offset for this test case
	ADD R6,R6,R5            ; add loop offset to array base
	LDR R6, R6, #0          ; load nth entry from array
	ADD R1,R1,R6            ; add offset to BUCKY_Y
	TRAP x47                ; compute pixel address for TEST_X,TEST_Y
	ADD R0,R0,R3            ; subtract DISP_BASE (xC000) to get MCDR value
	JSR BUCKY_CLICK         ; call BUCKY_CLICK
	LEA R6, TESTOUTCOME0    ; get expected outcome for this test case
	ADD R6,R6,R5            ; add loop offset to array base
	LDR R6, R6, #0          ; load nth entry from array, negated expected
	ADD R6,R0,R6            ; (actual-expected) should be zero
	BRz TEST_GOOD
	; print out error message, also good place for breakpoint
	LEA R6, TESTMESSAGE0    ; get expected outcome for this test case
	ADD R6,R6,R5            ; add loop offset to array base
	LDR R0, R6, #0          ; load nth entry from array, string address
	PUTS                    ; print string out
TEST_GOOD
	; move on to next test case
	ADD R5,R5,1
	BR TESTCASELOOP

GOAGAIN	ADD R2, R2, #-1         ; decrement iteration count
	BRp AGAIN               ; 
DONE
	HALT
ITERATIONS
	.FILL	#10
DISP_BASE
	.FILL	xC000
TEST_CASES
	.FILL	#12
;;; test vectors follow for 12 test cases:
;;;  TESTOFFSET_X: X offset for each of 12 test cases
;;;  TESTOFFSET_Y: Y offset for each of 12 test cases
;;;  TESTOUTCOME:  expected return value (0/1) from BUCKY_CLICK
;;;  TESTMESSAGE:  pointer to error message for failed test case
TESTOFFSET_X0   .FILL #0         ; top left offset=0
TESTOFFSET_X1   .FILL #-1        ; top left offset=-1
TESTOFFSET_X2   .FILL #0         ; top left offset=0
TESTOFFSET_X3   .FILL #39        ; top right offset=XDIM-1=39
TESTOFFSET_X4   .FILL #40        ; top right offset=XDIM-1+1=40
TESTOFFSET_X5   .FILL #39        ; top right offset=XDIM-1=39
TESTOFFSET_X6   .FILL #0         ; bottom left offset=0
TESTOFFSET_X7   .FILL #-1        ; bottom left offset=-1
TESTOFFSET_X8   .FILL #0         ; bottom left offset=0
TESTOFFSET_X9   .FILL #39        ; bottom right offset=XDIM-1=39
TESTOFFSET_X10  .FILL #40        ; bottom right offset=XDIM-1+1=40
TESTOFFSET_X11  .FILL #39        ; bottom right offset=XDIM-1=39
TESTOFFSET_Y0   .FILL #0         ; top left offset=0
TESTOFFSET_Y1   .FILL #0         ; top lef offset=-1
TESTOFFSET_Y2   .FILL #-1        ; top left offset=0
TESTOFFSET_Y3   .FILL #0         ; top right offset=0
TESTOFFSET_Y4   .FILL #0         ; top rightoffset=-1
TESTOFFSET_Y5   .FILL #-1        ; top right offset=0
TESTOFFSET_Y6   .FILL #26        ; bottom left offset=YDIM-1=26
TESTOFFSET_Y7   .FILL #26        ; bottom left offset=YDIM-1=26
TESTOFFSET_Y8   .FILL #28        ; bottom left offset=YDIM-1+1=28
TESTOFFSET_Y9   .FILL #26        ; bottom right offset=YDIM-1=26
TESTOFFSET_Y10  .FILL #26        ; bottom right offset=YDIM-1=26
TESTOFFSET_Y11  .FILL #28        ; bottom right offset=YDIM-1+1=28
TESTOUTCOME0    .FILL #-1        ; in bounds, negated 1 for subtraction check
TESTOUTCOME1    .FILL #0         ; out of bounds
TESTOUTCOME2    .FILL #0         ; out of bounds
TESTOUTCOME3    .FILL #-1        ; etc.
TESTOUTCOME4    .FILL #0
TESTOUTCOME5    .FILL #0
TESTOUTCOME6    .FILL #-1
TESTOUTCOME7    .FILL #0
TESTOUTCOME8    .FILL #0
TESTOUTCOME9    .FILL #-1
TESTOUTCOME10   .FILL #0
TESTOUTCOME11   .FILL #0
TESTMESSAGE0    .FILL XY_ERROR
TESTMESSAGE1    .FILL X1Y_ERROR
TESTMESSAGE2    .FILL XY1_ERROR
TESTMESSAGE3    .FILL XDY_ERROR
TESTMESSAGE4    .FILL XD1Y_ERROR
TESTMESSAGE5    .FILL XDY1_ERROR
TESTMESSAGE6    .FILL XYD_ERROR
TESTMESSAGE7    .FILL X1YD_ERROR
TESTMESSAGE8    .FILL XYD1_ERROR
TESTMESSAGE9    .FILL XDYD_ERROR
TESTMESSAGE10   .FILL XD1YD_ERROR
TESTMESSAGE11   .FILL XDYD1_ERROR
BUCKY_X		.BLKW 1
BUCKY_Y		.BLKW 1

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
	BRp TEST_FAIL                 ;;  FILL IN THE BR CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; check if X < BUCKY_X+BUCKY_XDIM
	LD R2, BUCKY_XDIM
	ADD R2, R2, R5
	ADD R1, R2, R3
	BRnz TEST_FAIL                ;;  FILL IN THE BR CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; check if Y >= BUCKY_Y
	ADD R1, R6, R4
	BRp TEST_FAIL               ;;  FILL IN THE BR CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; check if Y < BUCKY_Y+BUCKY_YDIM
	LD R2, BUCKY_YDIM
	ADD R2, R2, R6
	ADD R1, R2, R4
	BRnz TEST_FAIL              ;;  FILL IN THE BR CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; if all four tests passed return 1
	AND R0, R0, #0
	ADD R0, R0, #1
	BR BUCKY_CLICK_EXIT             ;;  FILL IN THE BR CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	AND R0,R0,R0            ; check sign bit
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

;;; String errors at end to avoid PC-relative offset errors
XY_ERROR        .STRINGZ "X,Y failed, should be true\n"
X1Y_ERROR       .STRINGZ "X-1,Y failed, should be false\n"
XY1_ERROR       .STRINGZ "X,Y-1 failed, should be false\n"
XDY_ERROR       .STRINGZ "(X+XDIM-1),Y failed, should be true\n"
XD1Y_ERROR      .STRINGZ "(X+XDIM-1)+1,Y failed, should be false\n"
XDY1_ERROR      .STRINGZ "(X+XDIM-1),Y-1 failed, should be false\n"
XYD_ERROR       .STRINGZ "X,(Y+YDIM-1) failed, should be true\n"
X1YD_ERROR      .STRINGZ "X-1,(Y+YDIM-1) failed, should be false\n"
XYD1_ERROR      .STRINGZ "X,(Y+YDIM-1)+1 failed, should be false\n"
XDYD_ERROR      .STRINGZ "(X+XDIM-1),(Y+YDIM-1) failed, should be true\n"
XD1YD_ERROR	.STRINGZ "(X+XDIM-1)+1,(Y+YDIM-1) failed, should be false\n"
XDYD1_ERROR	.STRINGZ "(X+XDIM-1),(Y+YDIM-1)+1 failed, should be false\n"
        .END
