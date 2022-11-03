# Function Generator

This was a project from my microcontrollers class in 2021, which interfaces a TI MSP 432P401R controller with a DAC using SPI.

This device operates as a function generator. It is capable of generating four types of waves: square, sine, triangle, and sawtooth. It is also capable of generating signals at five different frequencies, from 100 Hz to 500 Hz at increments of 100 Hz. Additionally, it is capable of outputting a square wave at different duty cycles, from 10% to 90% at increments of 10%.

It uses the 3x4 keypad to take input from the user to change the output. The numbers 1–5 change the frequency to 100–500 Hz, respectively. The numbers 6–9 change the type of wave to sine, triangle, sawtooth, and square, respectively. The number 0 sets the duty cycle to the default, 50%, and the asterisk key increments the duty cycle by 10% while the pound key decrements it by 10%. Only the square wave is affected by the duty cycle.

The default setting for the function generator upon startup is a 100 Hz square wave with a 50% duty cycle.
