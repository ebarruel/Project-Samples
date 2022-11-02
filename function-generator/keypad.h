/*
 * keypad.h
 *
 *  Created on: Apr 20, 2021
 *      Author: evangelinebarruel
 *
 * This library is meant for the MSP432P401R to interface
 * with a simple 4x3 matrix membrane keyboard.
 *
 * This library uses Port 4 as the output (columns)
 * and as the input (rows).
 *
 * The port set up is as follows (C represent column, R for row):
 *      CCCC_RRRR
 */

#ifndef KEYPAD_H_
#define KEYPAD_H_

#include <stdint.h>

    /* port macros */
    #define P_KEY_COL P4
    #define P_KEY_ROW P4

    /* keypad macros */
    #define NOKEY 0xFF
    #define KEY_USABLE 0x7F     // bit 7 optional for 4x4 keypad

    /* column macros */
    #define COL0 BIT4
    #define COL1 BIT5
    #define COL2 BIT6
    #define COL3 BIT7
    #define COLHIGH (COL0 | COL1 | COL2 | COL3 )
    #define SEL_COL ((COL0 | COL1 | COL2 | COL3 ) & KEY_USABLE)

    /* row macros */
    #define ROW0 BIT0
    #define ROW1 BIT1
    #define ROW2 BIT2
    #define ROW3 BIT3
    #define SEL_ROW (ROW0 | ROW1 | ROW2 | ROW3)

    #define KEY1 (ROW0 | COL0)
    #define KEY2 (ROW0 | COL1)
    #define KEY3 (ROW0 | COL2)
    #define KEYA (ROW0 | COL3)
    #define KEY4 (ROW1 | COL0)
    #define KEY5 (ROW1 | COL1)
    #define KEY6 (ROW1 | COL2)
    #define KEYB (ROW1 | COL3)
    #define KEY7 (ROW2 | COL0)
    #define KEY8 (ROW2 | COL1)
    #define KEY9 (ROW2 | COL2)
    #define KEYC (ROW2 | COL3)
    #define KEYS (ROW3 | COL0)       // asterisk/star
    #define KEY0 (ROW3 | COL1)
    #define KEYP (ROW3 | COL2)       // pound
    #define KEYD (ROW3 | COL3)

    #define NUM_POUND 0x0F
    #define NUM_STAR 0x0E

    /* initializes keypad ports
     *      columns and rows must be connected as CCCC_RRRR
     *      with C representing column on the top 4 bits
     *      and R representing row on the bottom 4 bits
     */
    void key_init(void);

    /* reads a keypress from a 4x3 keypad
     *      returns an 8-bit number (col_row) where
     *      the column is in the 4 most significant bits
     *      and the row is in the 4 least significant bits
     */
    uint8_t key_read(void);

    /* reads a keypress from a 4x3 keypad
     *      calls key_read()
     *      returns the ASCII value of that keypress
     */
    uint8_t key_readASCII(void);

    /* reads a keypress from a 4x3 keypad
     *      calls key_read()
     *      returns numerical value of keypress
     *      (0x0A-0x0D for 'A'-'D')
     *      (0x0E for * and 0x0F for #)
     */
    uint8_t key_readnum(void);

    /* returns a keypress from the keypad
     * blocks until keypress is received
     * currently returns keypress in numerical format
     */
    uint8_t getkey(void);

#endif /* KEYPAD_H_ */
