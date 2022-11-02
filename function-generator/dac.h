/*
 * dac.h
 *
 *  Created on: Jun 11, 2022
 *      Author: evangelinebarruel
 */

#ifndef DAC_H_
#define DAC_H_


/* given delay macro */
#define CPU_FREQ 3000000
#define __delay_us(t_us) (__delay_cycles((((uint64_t)t_us)*CPU_FREQ) / 1000000))

#define SPI_PORT P1
#define SPI_CS BIT7
#define SPI_SCLK BIT5
#define SPI_COPI BIT6

#define SPI_BITRES 12
#define SPI_VREF 330

#define BADVOLT 0xFFFF

#define MASK_LOWER 0x0FFF
#define MASK_UPPER 0x3000

void DAC_init(void);
void DAC_write(uint16_t data);
uint16_t DAC_volt_conv(uint16_t volt);


#endif /* DAC_H_ */
