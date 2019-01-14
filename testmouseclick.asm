;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; File:   TestMouseClick
; Description:  Calls TRAP x44 (TRAP_MOUSE) to check for mouse clicks
;               and then inverts pixel values at the click location
	.ORIG	x3000
TESTMOUSECLICK
	LD R2,ITERATIONS        ; iteration count
	LD R1,DISP_BASE         ; display base value (xC000)
AGAIN	TRAP x44                ; check for mouse click
	BRn AGAIN               ; if negative, poll mouse device again
	ADD R3,R1,R0            ; add click location to display base
	LDR R4,R3,#0            ; load pixel value
	NOT R4,R4               ; invert it
	STR R4,R3,#0            ; write inverted pixel value
	ADD R2, R2, #-1         ; decrement iteration count
	BRp AGAIN               ; 
DONE
	HALT
ITERATIONS
	.FILL	#1000
DISP_BASE
	.FILL	xC000
        .END
