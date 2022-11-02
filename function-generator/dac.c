/*
 *
 * Evangeline Barruel and Lorenzo Benjamin Gardea
 *
 * This program interfaces the MSP432 with a keypad
 * and the MCP4921 DAC.
 *
 *
 */

#include "msp.h"
#include "keypad.h"
#include "clock.h"
#include "dac.h"

void DAC_init(void) {
    EUSCI_B0->CTLW0 |= (EUSCI_B_CTLW0_SWRST);       // software reset = 1
    EUSCI_B0->CTLW0 = (EUSCI_B_CTLW0_MSB |          // most significant bit first
                       EUSCI_B_CTLW0_MST |          // controller mode
                       EUSCI_B_CTLW0_MODE_0 |       // mode 0
                       EUSCI_B_CTLW0_SYNC |         // synchronous
                       EUSCI_B_CTLW0_SSEL__SMCLK |  // smclk
                       EUSCI_B_CTLW0_CKPH |         // phase: data read on rising edge
                       EUSCI_B_CTLW0_SWRST);
    EUSCI_B0->BRW = 0x01;

    /* smclock and copi */
    SPI_PORT->SEL0 |= (SPI_SCLK | SPI_COPI);
    SPI_PORT->SEL1 &= ~(SPI_SCLK | SPI_COPI);

    /* chip select */
    SPI_PORT->SEL0 &= ~(SPI_CS);
    SPI_PORT->SEL1 &= ~(SPI_CS);
    SPI_PORT->DIR |= (SPI_CS);
    SPI_PORT->OUT |= (SPI_CS);

    EUSCI_B0->CTLW0 &= ~(EUSCI_B_CTLW0_SWRST);      // software reset = 0
}

void DAC_write(uint16_t data) {
    uint8_t loByte = data & 0xFF, hiByte = (data >> 8) & 0xFF;

    /* set chip select before transmission (active low) */
    SPI_PORT->OUT &= ~(SPI_CS);

    /* wait for TXBUF empty, then write high byte */
    while (!(EUSCI_B0->IFG & EUSCI_B_IFG_TXIFG));
    EUSCI_B0->TXBUF = hiByte;
    /* wait for TXBUF empty, then write low byte */
    while (!(EUSCI_B0->IFG & EUSCI_B_IFG_TXIFG));
    EUSCI_B0->TXBUF = loByte;

    /* wait for transmission to finish (all data received) */
    while (!(EUSCI_B0->IFG & EUSCI_B_IFG_RXIFG));

    /* deselect chip (idle high) */
    SPI_PORT->OUT |= (SPI_CS);
    __delay_cycles(20);
}

uint16_t DAC_volt_conv(uint16_t volt) {
    uint16_t v = volt > 329 ? 329 : volt;
    return (v * (1 << SPI_BITRES)) / SPI_VREF;
}
