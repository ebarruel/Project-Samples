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

.EQU BG_COLOR       = 0x00             ; Background Color:  Black
.EQU WALL_COLOR     = 0x1C	           ; Wall Color:        Green
.EQU HELI_COLOR     = 0x03             ; Helicopter Color:  Blue


.EQU short_time_OUTSIDE_FOR_COUNT  = 0x20
.EQU time_INSIDE_FOR_COUNT    = 0x88
.EQU time_MIDDLE_FOR_COUNT    = 0x88
.EQU time_OUTSIDE_FOR_COUNT   = 0x88



;r6 is used for color
;r7 is used for Y
;r8 is used for X

;---------------------------------------------------------------------
init:
         ;CALL   draw_background         ; draw using default color
CALL   pause
CALL   pause
CALL   pause
CALL   pause
CALL   pause
CALL   pause
CALL   pause
CALL   pause
		
		 MOV    r8,0x24			        ; starting x coordinate
		 MOV    r7,0x00                 ; start y coordinate
         MOV    r9,0x0A                 ; ending y coordinate
		 MOV    r10, 0x04               ; starting width of wall                 
move:      
		 MOV    r6, WALL_COLOR
		 CALL   draw_wall

	 
CALL   short_pause



		 MOV    r6, BG_COLOR
		 CALL   draw_wall

		
		 ;MOV    r6, WALL_COLOR
		 SUB r8, 0x01
		 CMP r8, 0xFF
		 BRNE move
		 ;MOV    r7,0x00                 ; start y coordinate
         ;MOV    r9,0x0A                 ; ending y coordinate
		 ;MOV    r10, 0x04               ; starting width of wall

		;CALL   draw_wall

      
main:    AND    r0, r0                  ; nop
         BRN    main                    ; continuous loop 
;--------------------------------------------------------------------



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
draw_wall:
		Call draw_vertical_line
		SUB r9, 0x01
		ADD r8, 0x01
		MOV r7, 0x00
		SUB r10, 0x01
		CMP r10, 0x00
		BRNE draw_wall
		SUB r8, 0x04
		MOV    r10, 0x04
		RET


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

