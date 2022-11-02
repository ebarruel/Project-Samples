;---------------------------------------------------------------------
; An expanded "draw_dot" program that includes subrountines to draw
; vertical lines, horizontal lines, and a full background. 
; 
; As written, this programs does the following: 
;   1) draws a the background blue (draws all the tiles)
;   2) draws a red dot
;   3) draws a red horizontal lines
;   4) draws a red vertical line
;
; Author: Bridget Benson 
; Modifications: bryan mealy
;---------------------------------------------------------------------

.CSEG
.ORG 0x10

.EQU VGA_HADD = 0x90
.EQU VGA_LADD = 0x91
.EQU VGA_COLOR = 0x92
.EQU SSEG = 0x81
.EQU LEDS = 0x40

.EQU BUTTON = 0x42


.EQU RAND = 0x94

.EQU BG_COLOR       = 0x00             ; Background Color:  Black
.EQU WALL_COLOR     = 0x1C	           ; Wall Color:        Green
.EQU HELI_COLOR     = 0x03             ; Helicopter Color:  Blue
.EQU RED_COLOR      = 0xE0

.EQU short_time_OUTSIDE_FOR_COUNT  = 0x20
.EQU time_INSIDE_FOR_COUNT    = 0x88
.EQU time_MIDDLE_FOR_COUNT    = 0x88
.EQU time_OUTSIDE_FOR_COUNT   = 0x88



;r6 is used for color
;r7 is used for Y
;r8 is used for X

;---------------------------------------------------------------------
init:
CALL   draw_background         ; draw using default color
CALL thic_pause
CALL thic_pause

MOV r6, RED_COLOR
MOV r8, 0x27
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x25
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x23
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x21
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x1F
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x1D
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x1B
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x19
MOV r7, 0x0B
CALL draw_dot

MOV r8, 0x17
MOV r7, 0x0B
CALL draw_dot
; Reg 8 first wall x
; Reg 11 second wall x
; Reg 17 array index


start_loop:
		IN r16, BUTTON
		CMP r16, 0x01
		BRNE start_loop


		MOV r17, 0x30
		MOV r20, 0x24

		CALL draw_wall
		CALL thic_pause
		CALL thic_pause

		CALL move_wall_one
		CALL thic_pause

		CALL move_wall_one
		CALL thic_pause

		CALL move_wall_one
		CALL thic_pause
	
		CALL move_wall_one
		CALL thic_pause
;------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_two
		CALL thic_pause

		CALL move_wall_two
		CALL thic_pause

		CALL move_wall_two
		CALL thic_pause

		CALL move_wall_two
		CALL thic_pause
;-----------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_three
		CALL thic_pause

		CALL move_wall_three
		CALL thic_pause

		CALL move_wall_three
		CALL thic_pause

		CALL move_wall_three
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_four
		CALL thic_pause

		CALL move_wall_four
		CALL thic_pause

		CALL move_wall_four
		CALL thic_pause

		CALL move_wall_four
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_five
		CALL thic_pause

		CALL move_wall_five
		CALL thic_pause

		CALL move_wall_five
		CALL thic_pause

		CALL move_wall_five
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_six
		CALL thic_pause

		CALL move_wall_six
		CALL thic_pause

		CALL move_wall_six
		CALL thic_pause

		CALL move_wall_six
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_seven
		CALL thic_pause

		CALL move_wall_seven
		CALL thic_pause

		CALL move_wall_seven
		CALL thic_pause

		CALL move_wall_seven
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_eight
		CALL thic_pause

		CALL move_wall_eight
		CALL thic_pause

		CALL move_wall_eight
		CALL thic_pause

		CALL move_wall_eight
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_nine
		CALL thic_pause

		CALL move_wall_nine
		CALL thic_pause

		CALL move_wall_nine
		CALL thic_pause

		CALL move_wall_nine
		CALL thic_pause
;--------------------------------------------------------
		CALL draw_wall
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause
;--------------------------------------------------------
		
		;BRN top_walls
new_wall_set:
		MOV r19, 0x00
		MOV r17, 0x30
		MOV r20, 0x24

update_walls:
		ADD r19, 0x01
		CALL draw_wall

		CALL move_wall_ten
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause

		CALL move_wall_ten
		CALL thic_pause
	
		CMP r19, 0x0A
		BRNE update_walls
		BRN new_wall_set
		
		

main:    AND    r0, r0                  ; nop
         BRN    main                    ; continuous loop 


draw_wall:
		MOV r7, 0x00
		MOV r6, WALL_COLOR
		CALL get_wall_height	
		MOV r8, 0x24
draw_wall_inner:		
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		ADD r8, 0x01
		CMP r8, 0x28
		BRNE draw_wall_inner
		;SUB r8, 0x01
		RET


move_wall_one:
		MOV r6, BG_COLOR
		
		MOV r8, r20
		ADD r8, 0x03
		CALL get_real_index
		MOV r9, 0x0A
		
	    CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x30
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		SUB r20, 0x01
		RET

move_wall_two:
		CALL move_wall_one
		
		MOV r6, BG_COLOR
		
		MOV r8, r20
		ADD r8, 0x08
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x31
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_three:
		CALL move_wall_two
		
		MOV r6, BG_COLOR
		
		
		MOV r8, r20

		ADD r8, 0x0C
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x32
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_four:
		CALL move_wall_three
		
		MOV r6, BG_COLOR

		
		MOV r8, r20
		ADD r8, 0x10
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x33
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_five:
		CALL move_wall_four
		
		MOV r6, BG_COLOR

		MOV r8, r20
		ADD r8, 0x14

		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x34
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_six:
		CALL move_wall_five
		
		MOV r6, BG_COLOR

		MOV r8, r20
		ADD r8, 0x18
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x35
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_seven:
		CALL move_wall_six
		
		MOV r6, BG_COLOR


		MOV r8, r20
		ADD r8, 0x1C
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x36
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_eight:
		CALL move_wall_seven
		
		MOV r6, BG_COLOR

		MOV r8, r20
		ADD r8, 0x20
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x37
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_nine:
		CALL move_wall_eight
		
		MOV r6, BG_COLOR

		
		MOV r8, r20
		ADD r8, 0x24
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x38
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET

move_wall_ten:
		CALL move_wall_nine
		
		MOV r6, BG_COLOR

		MOV r8, r20
		ADD r8, 0x28
		CALL get_real_index

		MOV r9, 0x0A

		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01

		MOV r6, WALL_COLOR
		SUB r8, 0x04
		LD r9, 0x39
		CALL draw_vertical_line
		MOV r7, 0x00
		SUB r9, 0x01
		
		ADD r8, 0x04
		RET




thic_pause:
		 OUT r20, SSEG
		 CALL   pause
		 ;CALL   pause
		 ;CALL   pause
		 ;CALL   pause
		 ;CALL   short_pause
		 RET

;draw_second:
;		 MOV r31, r8
;		 ADD r31, 0x04
;		 IN r15, RAND
;		 CALL get_wall_height
;		 MOV r9, r30
;		 CALL   draw_wall
;		 BRN draw_sec_ret
	    
 
get_wall_height:
		 IN r15, RAND
		 MOV r27, r15 ; random in as numerator
		 MOV r28, 0x2A ; 255 / 42 = 6 different wall heights
		 CALL divide
		 MOV r31, r30
		 ST r31, (r17)
		 ADD r17, 0x01
		 MOV r9, r30
		 RET

get_real_index:
		 MOV r27, r8 ; move wall index into numerator
		 MOV r28, 0x28 ; move 40 into denominator
		 CALL divide
		 MOV r8, r27 ; updating index mod 40
		 RET


;--------------------------------------------------------------------
;-  Subroutine: div_random
;-
;-  Parameters: 
;- 
;-  Tweaked registers: ;--------------------------------------------------------------------
divide:
		
	; R30 is counter register
	;MOV r27, r15 ; Takes in first input, numerator
	;MOV r28, 0x2A ; Takes in second input, denominator
	mov r29, 0x00
	MOV r30, 0x00

	CMP r28, 0x00 ; Checking to see if denominator is zero
	BREQ exactWholeNumEnd ; Skip to end if divide by zero

	findWholeNumberQuotient:
			CMP r27, r29 ; Comparing numerator and multiple of denominator
			BRCS endWholeNumLoop ; End loop if multiple of denominator >  numerator
			BREQ exactWholeNumEnd
			ADD r29, r28 ; Multiplying denominator by itself
			CMP R29, r28 ; If the multiple of denominator is < original 
	 ; denominator then whole number multiple found
			BRCS endWholeNumLoop 
			ADD r30, 0x01 ; Adding one to counter of denominator self 
	  ; multiplies 
			BRN findWholeNumberQuotient

	endWholeNumLoop:
			SUB R29, R28 ; Subtract last denominator Multiply to get largest
					 ; less than numerator
			SUB R30, 0x01 ; Subtract 1 from counter to get accurate number 
	  ; of loops

	exactWholeNumEnd:
			SUB R27, R29 ; Subtracting largest whole number multiple
					 ; of denominator less than numerator from numerator
					; to find remainder
	
	ADD r30, 0x04 ; Min wall height is 4
	RET
	; R30 holds whole number
	; R27 holds remainder



	




;--------------------------------------------------------------------
;-  Subroutine: move_walls
;-
;-  Draws a wall width 4 from (r8,r7) to (r8 + r10,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;-   r10 = width of wall
;- 
;- Tweaked registers: r7, r9, r10
;--------------------------------------------------------------------
move_walls:
	








;--------------------------------------------------------------------
;-  Subroutine: draw_wall
;-
;-  Draws a wall width 4 from (r8,r7) to (r8 + r10,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;-   r10 = width of wall
;- 
;- Tweaked registers: r7, r9, r10
;--------------------------------------------------------------------
;draw_wall:
;		Call draw_vertical_line
;		SUB r9, 0x01
;		ADD r8, 0x01
;		MOV r7, 0x00
;		SUB r10, 0x01
;		CMP r10, 0x00
;		BRNE draw_wall
;		SUB r8, 0x04
;		MOV    r10, 0x04
;		RET


;--------------------------------------------------------------------
;-  Subroutine: pause
;-
;-  delay of SOME AMOUNT OF SECONDS
;-
;-  Parameters:
;-  
;- 
;- Tweaked registers: r27, r28, r29
;--------------------------------------------------------------------
	

pause:	     
	MOV     R29, time_OUTSIDE_FOR_COUNT  ;set outside for loop count
	outside_for: 
		SUB     R29, 0x01
		MOV     R28, time_MIDDLE_FOR_COUNT   ;set middle for loop count
		
		middle_for: 
			SUB     R28, 0x01				 
			MOV     R27, time_INSIDE_FOR_COUNT   ;set inside for loop count
			
			inside_for: 
				SUB     R27, 0x01
				BRNE    inside_for		 
			    
				OR      R28, 0x00               ;load flags for middle for counter
				BRNE    middle_for
				 
				OR      R29, 0x00               ;load flags for outsde for counter value
				BRNE    outside_for
	RET

short_pause:	     
	MOV     R29, short_time_OUTSIDE_FOR_COUNT  ;set outside for loop count
	s_outside_for: 
		SUB     R29, 0x01
		MOV     R28, time_MIDDLE_FOR_COUNT   ;set middle for loop count
		
		s_middle_for: 
			SUB     R28, 0x01				 
			MOV     R27, time_INSIDE_FOR_COUNT   ;set inside for loop count
			
			s_inside_for: 
				SUB     R27, 0x01
				BRNE    s_inside_for		 
			    
				OR      R28, 0x00               ;load flags for middle for counter
				BRNE    s_middle_for
				 
				OR      R29, 0x00               ;load flags for outsde for counter value
				BRNE    s_outside_for
	RET


		

 
;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  Parameters:
;-   r8  = starting x-coordinate
;-   r7  = y-coordinate
;-   r9  = ending x-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r8, r9
;--------------------------------------------------------------------
draw_horizontal_line:
        ADD    r9,0x01          ; go from r8 to r15 inclusive

draw_horiz1:
        CALL   draw_dot         ; 
        ADD    r8,0x01
        CMP    r8,r9
        BRNE   draw_horiz1
        RET
;--------------------------------------------------------------------


;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r7, r9
;--------------------------------------------------------------------
draw_vertical_line:
         ADD    r9,0x01

draw_vert1:          
         CALL   draw_dot
         ADD    r7,0x01
         CMP    r7,R9
         BRNE   draw_vert1
         RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 30x40 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r13, r7, r8, r9
;----------------------------------------------------------------------
draw_background: 
         MOV   r6,BG_COLOR              ; use default color
         MOV   r13,0x00                 ; r13 keeps track of rows
start:   MOV   r7,r13                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x27 
 
         CALL  draw_horizontal_line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x1D                 ; see if more rows to draw
         BRNE  start                    ; branch to draw more rows
         RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: r4, r5
;---------------------------------------------------------------------
draw_dot: 
           MOV   r4,r7         ; copy Y coordinate
           MOV   r5,r8         ; copy X coordinate

           AND   r5,0x3F       ; make sure top 2 bits cleared
           AND   r4,0x1F       ; make sure top 3 bits cleared
           LSR   r4             ; need to get the bot 2 bits of r4 into sA
           BRCS  dd_add40
t1:        LSR   r4
           BRCS  dd_add80

dd_out:    OUT   r5,VGA_LADD   ; write bot 8 address bits to register
           OUT   r4,VGA_HADD   ; write top 3 address bits to register
           OUT   r6,VGA_COLOR  ; write data to frame buffer
           RET

dd_add40:  OR    r5,0x40       ; set bit if needed
           CLC                  ; freshen bit
           BRN   t1             

dd_add80:  OR    r5,0x80       ; set bit if needed
           BRN   dd_out
; --------------------------------------------------------------------

end:

