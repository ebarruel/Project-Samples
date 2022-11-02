/*
 * Evangeline Barruel and Zarek Lazowski
 * EE 329: Assignment 2 (keypad)
 * Groups_A2 9
 *
 * This program is meant for the MSP432P401R to interface
 * with a simple 4x3 matrix membrane keyboard.
 *
 * This program uses Port 4
 * as the output on pins 4-7 (columns, 7 optional)
 * and as the input on pins 0-3 (rows).
 *
 * The port set up is as follows (C represent column, R for row):
 * XCCC_RRRR
 */

#include "msp.h"
#include "keypad.h"

/* initializes keypad ports
 *      columns and rows must be connected as CCCC_RRRR
 *      with C representing column on the top 4 bits
 *      and R representing row on the bottom 4 bits
 */
void key_init(void) {
    /* select row pins for input */
    P_KEY_ROW->SEL0 &= ~SEL_ROW;
    P_KEY_ROW->SEL1 &= ~SEL_ROW;
    P_KEY_ROW->DIR  &= ~SEL_ROW;

    /* select column pins for output */
    P_KEY_COL->SEL0 &= ~SEL_COL;
    P_KEY_COL->SEL1 &= ~SEL_COL;
    P_KEY_ROW->DIR  |= SEL_COL;

    /* enable pull-down resistor for inputs */
    P_KEY_ROW->REN |= SEL_ROW;

    /* initialize outputs high */
    P_KEY_COL->OUT |= SEL_COL;
}

/* reads a keypress from a 4x3 keypad
 *      returns an 8-bit number (col_row) where
 *      the column is in the 4 most significant bits
 *      and the row is in the 4 least significant bits
 */
uint8_t key_read(void) {
    /* row = Px->IN */
    uint8_t row = (P_KEY_ROW)->IN & SEL_ROW;
    /* get first column bit : 0x10 */
    uint8_t col = (COL0);

    /* if rows == 0 */
    if (!row) {
        /* return no key press */
        return (NOKEY);
    }

    /* set all columns to low: 0000_XXXX */
    (P_KEY_COL)->OUT &= ~(SEL_COL);

    /* iterate through every column */
    for (; col<=COL2; col = col<<1) {
        /* set col pin of Py to 1 */
        (P_KEY_COL)->OUT = (P_KEY_COL->OUT & ~(SEL_COL)) | col;
        /* delay cycles by 25 */
        __delay_cycles(25);
        /* row = Px->IN */
        row = (P_KEY_ROW)->IN & SEL_ROW;

        /* if row != 0 */
        if (row) {
            /* set all cols high */
            (P_KEY_COL)->OUT |= (SEL_COL);
            /* return key (calculated from rows and cols) */
            return (col | row);
        }
    }

    /* set all cols high */
    (P_KEY_COL)->OUT |= (SEL_COL);
    /* return no key press */
    return (NOKEY);
}

/* reads a keypress from a 4x3 keypad
 *      returns the ASCII value of that keypress
 */
uint8_t key_readASCII(void) {
    uint8_t key = key_read();

    switch (key) {
        case (KEY1):
            return '1';
        case (KEY2):
            return '2';
        case (KEY3):
            return '3';
        case (KEY4):
            return '4';
        case (KEY5):
            return '5';
        case (KEY6):
            return '6';
        case (KEY7):
            return '7';
        case (KEY8):
            return '8';
        case (KEY9):
            return '9';
        case (KEYS):
            return '*';
        case (KEY0):
            return '0';
        case (KEYP):
            return '#';
        case (KEYA):
            return 'A';
        case (KEYB):
            return 'B';
        case (KEYC):
            return 'C';
        case (KEYD):
            return 'D';
        default:
            return (NOKEY);
    }
}

/* reads a keypress from a 4x3 keypad
 *      calls key_read()
 *      returns numerical value of keypress
 *      (0x0A-0x0D for 'A'-'D')
 *      (0x0E for * and 0x0F for #)
 */
uint8_t key_readnum(void) {
    uint8_t key = key_read();

    switch (key) {
        case (KEY1):
            return 0x01;
        case (KEY2):
            return 0x02;
        case (KEY3):
            return 0x03;
        case (KEY4):
            return 0x04;
        case (KEY5):
            return 0x05;
        case (KEY6):
            return 0x06;
        case (KEY7):
            return 0x07;
        case (KEY8):
            return 0x08;
        case (KEY9):
            return 0x09;
        case (KEYS):
            return 0x0E;
        case (KEY0):
            return 0x00;
        case (KEYP):
            return 0x0F;
        case (KEYA):
            return 0x0A;
        case (KEYB):
            return 0x0B;
        case (KEYC):
            return 0x0C;
        case (KEYD):
            return 0x0D;
        default:
            return (NOKEY);
    }
}

/* returns a keypress from the keypad
 * blocks until keypress is received
 */
uint8_t getkey(void) {
    uint8_t key = NOKEY;

    /* loop while key is NOKEY */
    while (key == NOKEY) {
        key = key_readnum();
    }

    /* loop while key is not NOKEY */
    while (key_readnum() != NOKEY);

    return key;
}
