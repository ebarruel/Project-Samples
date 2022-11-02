#include "msp.h"
#include "clock.h"

/**
 * main.c
 */
void set_DCO(uint32_t FREQ){
    CS->KEY = CS_KEY_VAL;                           // Unlocks CS registers
    CS->CTL0 = FREQ;                                // Sets DCO frequency
    CS->CTL1 = (CS_CTL1_DIVM_0 |                    // Sets clock division to 0
                CS_CTL1_SELM__DCOCLK);              // Outputs DCO to MCLK
    CS->KEY = 0;                                    // Locks CS registers
}
