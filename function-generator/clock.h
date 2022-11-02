/*
 * clock.h
 *
 *  Created on: Apr 13, 2021
 *      Author: evangelinebarruel
 */

/* if CLOCK_H_ is not defined */
#ifndef CLOCK_H_
/* define it
 *      this helps make sure that if header files are included in multiple places
 *      the program as a whole doesn't actually try to compile
 *      it and its source file(s?) multiple times
 *      probably gets messy bc you can't define functions multiple times
 */
#define CLOCK_H_

/*!< Nominal DCO Frequency Range (MHz): 1 to 2 */
#define FREQ_1_5_MHz                        ((uint32_t)0x00000000)
/*!< Nominal DCO Frequency Range (MHz): 2 to 4 */
#define FREQ_3_MHz                          ((uint32_t)0x00010000)
/*!< Nominal DCO Frequency Range (MHz): 4 to 8 */
#define FREQ_6_MHz                          ((uint32_t)0x00020000)
/*!< Nominal DCO Frequency Range (MHz): 8 to 16 */
#define FREQ_12_MHz                         ((uint32_t)0x00030000)
/*!< Nominal DCO Frequency Range (MHz): 16 to 32 */
#define FREQ_24_MHz                         ((uint32_t)0x00040000)

/* to make a function visible to whichever file includes this header file
 *      return_type function_name(input_type [optional_input_name], ...);
 */
void set_DCO(uint32_t);

/* just the end of the if statement lol */
#endif /* CLOCK_H_ */
