 ;---------------------------------------------------------------------
; An expanded "draw_dot" program that includes subroutines to draw
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

; outputs
.EQU VGA_HADD = 0x90
.EQU VGA_LADD = 0x91
.EQU VGA_COLOR = 0x92

;inputs
.EQU BTN = 0x42
.EQU SSEG = 0x81
.EQU LEDS = 0x40
.EQU VGA_IN = 0x93

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
		 CALL start_screen

		 MOV    r8,0x0A			        ; starting x coordinate
		 MOV    r7,0x00                 ; start y coordinate
         MOV    r9,0x0A                 ; ending y coordinate
		 MOV    r10, 0x04               ; starting width of wall                 
move:      
		 MOV    r6, WALL_COLOR
		 CALL   draw_wall

	 
;CALL   short_pause



		 ;MOV    r6, BG_COLOR
		 ;CALL   draw_wall

		
		 ;MOV    r6, WALL_COLOR
		 ;SUB r8, 0x01
		 ;CMP r8, 0xFF
		 ;BRNE move
		 ;MOV    r7,0x00                ; start y coordinate
         ;MOV    r9,0x0A                ; ending y coordinate
		 ;MOV    r10, 0x04              ; starting width of wall

		;CALL   draw_wall

heli: 
		 MOV    r7, 0x0F                ; starting y coordinate
		 MOV    r8, 0x0A                ; x coordinate
move_heli:
		 ;OUT r7, SSEG
		 CALL if_collision              ; determines if heli has collided with a wall
		 CALL draw_heli                 ; draws helicopter at new position
		 BRN move_heli

      
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

thic_pause:
		 ;OUT r8, SSEG
		 CALL   pause
		 CALL   pause
		 CALL   pause
		 CALL   pause
		 CALL   pause
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


;---------------------------------------------------------------------
;- Subroutine: draw_heli
;- 
;- This subroutine draws the helicopter on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- and moves it based on input from the button (r11)
;- 
;- Tweaked registers: r7
;---------------------------------------------------------------------

draw_heli:
			MOV r6, HELI_COLOR
			CALL draw_copter            ; draw helicopter
			MOV r6, BG_COLOR            ; removes copter
			CALL draw_copter
			IN r11, BTN                 ; take input from button
			CMP r11, 0x01               ; if input is high, move heli up
                                        ; if input is low, move heli down
			BRNE heli_down

heli_up:    SUB r7, 0x01                ; move heli up by one pixel
			BRN end_heli

heli_down:  ADD r7, 0x01                ; move heli down by one pixel

end_heli:   MOV r1, r7
			RET



;---------------------------------------------------------------------
;- Subroutine: draw_copter
;- 
;- This subroutine draws the helicopter on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6
;- 
;- Tweaked registers: r7, r8
;---------------------------------------------------------------------

draw_copter:
			MOV r0, r8                  ; copy X coordinate
			MOV r1, r7                  ; copy Y coordinate

draw_body:
			SUB r8, 0x06
			MOV r9, r8
			ADD r9, 0x09
			CALL draw_horizontal_line   ; draws hor line through center
			CALL copy_coords            ; resets coords to center
			SUB r7, 0x04
			MOV r9, r7
			ADD r9, 0x06
			CALL draw_vertical_line     ; draws vert line through center
			CALL copy_coords            ; resets coords to center
			SUB r7, 0x01
			SUB r8, 0x03
			MOV r9, r8
			ADD r9, 0x05
			CALL draw_horizontal_line   ; draws hor line one above center
			ADD r7, 0x02
			SUB r8, 0x06
			SUB r9, 0x01
			CALL draw_horizontal_line   ; draws hor line one below center
			CALL copy_coords            ; resets coords to center
			SUB r8, 0x01
			SUB r7, 0x02
			MOV r9, r7
			ADD r9, 0x04
			CALL draw_vertical_line     ; draws vert line one left of center
			ADD r8, 0x02
			SUB r7, 0x05
			SUB r9, 0x01
			CALL draw_vertical_line     ; draws vert line one right of center
			ADD r8, 0x01
			SUB r7, 0x04
			SUB r9, 0x02
			CALL draw_vertical_line     ; draws vert line two right of center
			CALL copy_coords            ; resets coords to center
			SUB r8, 0x06
			SUB r7, 0x01
			MOV r9, r7
			ADD r9, 0x02
			CALL draw_vertical_line     ; draws back propellor

draw_long_prop:
			CALL copy_coords            ; resets coords to center
			SUB r7, 0x04
			SUB r8, 0x04
			MOV r9, r8
			ADD r9, 0x08
			CALL draw_horizontal_line   ; draws longer top prop
			CALL short_pause
			CMP r6, HELI_COLOR
			BRNE draw_short_prop
			MOV r6, BG_COLOR
			BRN draw_long_prop          ; erases longer top prop

draw_short_prop:
			MOV r6, HELI_COLOR
short_prop_loop:
			CALL copy_coords            ; resets coords to center
			SUB r7, 0x04
			SUB r8, 0x02
			MOV r9, r8
			ADD r9, 0x04
			CALL draw_horizontal_line   ; draws shorter top prop
			CMP r6, HELI_COLOR
			BRNE end_copter
			MOV r6, BG_COLOR
			CALL short_pause
			BRN short_prop_loop         ; erases shorter top prop

end_copter: CALL copy_coords            ; reset coords to center
			RET



;---------------------------------------------------------------------
;- Subroutine: copy_coords
;- 
;- This subroutine copies saved coordinates back into the original registers :
;- 
;- X coordinate: r0 => r8
;- Y coordinate: r1 => r7
;---------------------------------------------------------------------

copy_coords:
			MOV r8, r0                  ; copies X coordinate
			MOV r7, r1                  ; copies Y coordinate
			RET


;------------------- INCOMPLETE --------------------------------------
;---------------------------------------------------------------------
;- Subroutine: if_collision
;- 
;- This subroutine determines whether the heli at coordinates (r8, r7)
;-     has crashed into a wall
;-     To see if the heli has crashed into the top wall,
;-         compares the color of the top heli pixel (r8, r7 - 4) to the bottom pixel of the top wall
;-     To see if the heli has crashed into the bottoom wall,
;-         compares the color of top heli pixel (r8, r7 + 2) to the top pixel of the bottom wall
;- 
;- VGA color: r4
;---------------------------------------------------------------------

if_collision:
top_collision:
			CALL copy_coords            ; reads in center coords of heli
			SUB r7, 0x04                ; returns pixel above heli
			OUT r7, VGA_HADD           ; outputs y coordinate
			OUT r8, VGA_LADD           ; outputs x coordinate
			IN r4, VGA_IN               ; input from VGA
			CMP r4, WALL_COLOR
			BREQ end_screen             ; ends game if pixel is part of the wall
bottom_collision:
			CALL copy_coords            ; reads in center coords of heli
			ADD r7, 0x02                ; returns bottom pixel of heli
			OUT r7, VGA_HADD           ; outputs y coordinate
			OUT r8, VGA_LADD           ; outputs x coordinate
			IN r4, VGA_IN               ; input from VGA
			CMP r4, WALL_COLOR
			BREQ end_screen             ; ends game if pixel is part of the wall

			CALL copy_coords
			RET


;---------------------------------------------------------------------
;- Subroutine: multiply_64
;-
;- This subroutine multiplies the y-coordinate by 64
;-
;- tweaked registers: r7
;---------------------------------------------------------------------

multiply_64:
			MOV r27, 0x06
multiply_loop:
			SUB r27, 0x01
			



;---------------------------------------------------------------------
;- Subroutine: start_screen
;- 
;- This subroutine displays a start screen until the player presses the button
;- 
;- (to write START)
;- X coordinate: r8
;- Y coordinate: r7
;- draw color: r6
;---------------------------------------------------------------------

start_screen:
			CALL draw_background
			MOV r6, WALL_COLOR
start_draw_S:
			MOV r7, 0x0B
			MOV r8, 0x08
			MOV r9, 0x0B
			CALL draw_horizontal_line   ; draws top h line of S
			MOV r8, 0x08
			MOV r9, 0x0E
			CALL draw_vertical_line     ; draws top left v line of S
			MOV r7, 0x0E
			MOV r8, 0x08
			MOV r9, 0x0B
			CALL draw_horizontal_line   ; draws center h line of S
			MOV r8, 0x0B
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws bottom right v line of S
			MOV r7, 0x11
			MOV r8, 0x08
			MOV r9, 0x0B
			CALL draw_horizontal_line   ; draws bottom h line of S
			MOV r8, 0x0B
			MOV r7, 0x0C
			CALL draw_dot               ; draws top right dot of S (for curl)
			MOV r8, 0x08
			MOV r7, 0x10
			CALL draw_dot               ; draws bottom left dot of S
start_draw_T_1:
			MOV r8, 0x0D
			MOV r7, 0x0B
			MOV r9, 0x10
			CALL draw_horizontal_line   ; draws top h line of T
			MOV r8, 0x0D
			MOV r7, 0x0C
			MOV r9, 0x10
			CALL draw_horizontal_line   ; draws second h line of T
			MOV r8, 0x0E
			MOV r7, 0x0D
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of T
			MOV r8, 0x0F
			MOV r7, 0x0D
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws right v line of T
start_draw_A:
			MOV r8, 0x12
			MOV r7, 0x0C
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of A
			MOV r8, 0x15
			MOV r7, 0x0C
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws right v line of A
			MOV r8, 0x13
			MOV r7, 0x0B
			MOV r9, 0x14
			CALL draw_horizontal_line   ; draws top h line of A
			MOV r8, 0x13
			MOV r7, 0x0E
			MOV r9, 0x14
			CALL draw_horizontal_line   ; draws center h line of A
start_draw_R:
			MOV r8, 0x17
			MOV r7, 0x0B
			MOV r9, 0x19
			CALL draw_horizontal_line   ; draws top h line of R
			MOV r8, 0x17
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of R
			MOV r7, 0x0E
			MOV r9, 0x19
			CALL draw_horizontal_line   ; draws center h line of R
			MOV r8, 0x1A
			MOV r7, 0x0C
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws right v line of R
			MOV r6, BG_COLOR
			MOV r7, 0x0E
			CALL draw_dot               ; erases center dot of right v line of R
start_draw_T_2:
			MOV r6, WALL_COLOR
			MOV r8, 0x1C
			MOV r7, 0x0B
			MOV r9, 0x1F
			CALL draw_horizontal_line   ; draws top h line of T
			MOV r8, 0x1C
			MOV r7, 0x0C
			MOV r9, 0x1F
			CALL draw_horizontal_line   ; draws second h line of T
			MOV r8, 0x1D
			MOV r7, 0x0D
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of T
			MOV r8, 0x1E
			MOV r7, 0x0D
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws right v line of T

start_wait:
			IN r11, BTN                 ; input from button
			CMP r11, 0x01
			BRNE start_wait             ; only start game when button is pressed
			CALL draw_background        ; reset screen
			RET


;---------------------------------------------------------------------
;- Subroutine: end_screen
;- 
;- This subroutine displays an end screen when the player crashes
;- 
;- (to write DEAD)
;- X coordinate: r8
;- Y coordinate: r7
;- draw color: r6
;---------------------------------------------------------------------

end_screen:
			CALL draw_background
			MOV r6, 0xE0                ; makes text red
end_draw_D_1:
			MOV r8, 0x09
			MOV r7, 0x0B
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of D
			MOV r7, 0x0B
			MOV r9, 0x0B
			CALL draw_horizontal_line   ; draws top h line of D
			MOV r8, 0x0A
			MOV r7, 0x11
			MOV r9, 0x0B
			CALL draw_horizontal_line   ; draws bottom h line of D
			MOV r8, 0x0C
			MOV r7, 0x0C
			MOV r9, 0x10
			CALL draw_vertical_line     ; draws right v line of D
end_draw_E:
			MOV r8, 0x0F
			MOV r7, 0x0B
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of E
			MOV r7, 0x0B
			MOV r9, 0x12
			CALL draw_horizontal_line   ; draws top h line of E
			MOV r8, 0x10
			MOV r7, 0x0E
			MOV R9, 0x11
			CALL draw_horizontal_line   ; draws center h line of E
			MOV r8, 0x10
			MOV r7, 0x11
			MOV r9, 0x12
			CALL draw_horizontal_line   ; draws bottom h line of E
end_draw_A:
			MOV r8, 0x15
			MOV r7, 0x0C
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of A
			MOV r8, 0x18
			MOV r7, 0x0C
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws right v line of A
			MOV r8, 0x16
			MOV r7, 0x0B
			MOV r9, 0x17
			CALL draw_horizontal_line   ; draws top h line of A
			MOV r8, 0x16
			MOV r7, 0x0E
			MOV r9, 0x17
			CALL draw_horizontal_line   ; draws center h line of A
end_draw_D_2:
			MOV r8, 0x1B
			MOV r7, 0x0B
			MOV r9, 0x11
			CALL draw_vertical_line     ; draws left v line of D
			MOV r7, 0x0B
			MOV r9, 0x1D
			CALL draw_horizontal_line   ; draws top h line of D
			MOV r8, 0x1C
			MOV r7, 0x11
			MOV r9, 0x1D
			CALL draw_horizontal_line   ; draws bottom h line of D
			MOV r8, 0x1E
			MOV r7, 0x0C
			MOV r9, 0x10
			CALL draw_vertical_line     ; draws right v line of D


end:
