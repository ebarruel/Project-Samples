/*
 * funcgen.c
 *
 * Author: evangelinebarruel
 *
 * This program operates the MSP432P401R as a
 * function generator.
 *
 */

#include "msp.h"
#include <math.h>
#include "util.h"
#include "keypad.h"
#include "dac.h"

#define MAX_VPP 300

#define MAX_RES 540
#define HALF_RES (MAX_RES / 2)
#define MIN_RES 120
#define DUTY_STEP 54
#define DUTY_DEF (DUTY_STEP * 5)
#define MAX_DUTY (MAX_RES)
#define MIN_DUTY (DUTY_STEP)

#define TA0_COUNT 224

uint16_t sinV[MAX_RES];
uint16_t squV[MAX_RES];
uint16_t triV[HALF_RES];
uint16_t sawV[MAX_RES];

typedef enum {
    SQU,
    SIN,
    TRI,
    SAW
} wavType;
typedef enum {UP, DOWN} dirType;

void initTimerA(void);

void initSin(void);
void initTri(void);
void initSaw(void);

/* default period: 10 ms
 * use all samples in array
 */
static int freq = 1;                // steps in array
static int duty = DUTY_DEF;
static wavType wav = SQU;
volatile static dirType dir = UP;

/**
 * main.c
 */
void main(void)
{
    uint8_t key = NOKEY;

	WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;		// stop watchdog timer

	// init stuff
	initTimerA();
	initSin();
	initTri();
	initSaw();

	key = getkey();

	while (1) {
	    switch (key) {
            case 1:
                freq = 1;
                break;
            case 2:
                freq = 2;
                break;
            case 3:
                freq = 3;
                break;
            case 4:
                freq = 4;
                break;
            case 5:
                freq = 5;
                break;
            case 6:
                wav = SIN;
                break;
            case 7:
                wav = TRI;
                break;
            case 8:
                wav = SAW;
                break;
            case 9:
                wav = SQU;
                break;
            case 0:
                duty = 5;
                break;
            case NUM_STAR:
                duty = MAX(duty-DUTY_STEP, MIN_DUTY);
                break;
            case NUM_POUND:
                duty = MIN(duty+DUTY_STEP, MAX_DUTY);
                break;
            default:
                freq = 1;
                duty = DUTY_DEF;
                wav = SQU;
                dir = UP;
        }

        while (key == NOKEY) {
            key = getkey();
        }
	}
}

void TA0_0_IRQHandler(void) {
    volatile static int pos = 0;

    /* clear flag */
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;

    switch (wav) {
        case SIN:
            DAC_write(sinV[pos]);
            pos += freq % MAX_RES;
            break;
        case TRI:
            DAC_write(triV[pos]);
            if (dir == UP) {
                if ((pos + freq) > HALF_RES) {
                    dir = DOWN;
                }
                else {
                    pos += freq;
                }
            }
            else {
                if ((pos - freq) < 0) {
                    dir = UP;
                }
                else {
                    pos -= freq;
                }
            }
            break;
        case SAW:
            DAC_write(sawV[pos]);
            pos += freq % MAX_RES;
            break;
        default: // SQU
            (pos < duty) ?
                DAC_write(DAC_volt_conv(330) | MASK_UPPER) :
                DAC_write(0x0000);
            pos += freq % MAX_RES;
    }

    TIMER_A0->CCR[0] += TA0_COUNT;
}

void initTimerA(void){
    /* enable interrupt in timer */
    TIMER_A0->CCTL[0] = (TIMER_A_CCTLN_CCIE);

    TIMER_A0->CCR[0] = TA0_COUNT;

    TIMER_A0->CTL = (TIMER_A_CTL_SSEL__SMCLK |      // select SMCLK
                     TIMER_A_CTL_MC__CONTINUOUS |   // set counting mode to continuous
                     TIMER_A_CTL_ID__1 |            // set clock div to 1 (no div)
                     TIMER_A_CTL_CLR);

    /* enable interrupts in NVIC */
    NVIC->ISER[0] = (1 << TA0_0_IRQn) | (1 << TA0_N_IRQn);

    /* enable interrupts globally */
    __enable_irq();
}

void initSin(void) {
    /* y(t) = a*sin(w*t + theta) + dc_offset */
    int i = 0;
    double a = 1.5, w = (2*M_PI)/10, dc = 1.5;
    double val = 0;
    uint16_t volt = 0;

    for (; i < MAX_RES; i++) {
        val = (a * sin(w * i) + dc) * 100;
        volt = DAC_volt_conv((uint16_t) val);
        sinV[i] = (volt | MASK_UPPER);
    }
}

void initTri(void) {
    int i = 0, step = MAX_VPP / MAX_RES;
    uint16_t volt = 0;

    for (; i < HALF_RES; i++) {
        volt = (step * i) * 100;
        volt = (DAC_volt_conv(volt) | MASK_UPPER);
        triV[i] = volt;
        triV[MAX_RES - i - 1] = volt;
    }
}

void initSaw(void) {
    int i = 0, step = MAX_VPP / MAX_RES;
    uint16_t volt = 0;

    for (; i < MAX_RES; i++) {
        volt = (step * i) * 100;
        volt = (DAC_volt_conv(volt) | MASK_UPPER);
        triV[i] = volt;
    }
}
