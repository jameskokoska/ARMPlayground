# ARMPlayground
Various programs written in ARM
These programs can be tested in an online simulator found here: https://cpulator.01xz.net/?sys=arm-de1soc
or using a DE1-SoC FPGA board
## LargestNum.s
* Finds the largest number from a list of numbers
## ConsecutiveOnes.s
* Calculates the number of consecutive ones in from a list of numbers in a subroutine
## Longest.s
* Longest string of 1's in a word of data - result into R5
* Longest string of 0's in a word of data - result into R6
* Longest string of alternating 1's and 0's in a word of data — result into R7
## DecimalDigit.s
* Displays a decimal digit on the seven-segment display HEX0
* If KEY0 is pressed the number displayed on HEX0 is 0
* If KEY1 is pressed increment the displayed number
* If KEY2 is pressed then decrement the number
* If KEY3 is pressed the display goes blank
* Any other KEY after that returns the display to 0
## Delay.s
* Displays a two-digit decimal counter on the seven-segment displays HEX1-0
* Counter increments approximately every 0.25 seconds
* Uses the edge capture register to avoid missed presses during delay loop
## A9Timer.s
* Similar to Delay.s but the A9 private timer is used to achieve an accurate 0.25 second delay
## ClockTimer.s
* Uses HEX3-0 to display a timer in the format 00:00
## CorrespondingKey.s
* Shows number 0 to 3 on HEX0 to HEX3 respectively when the corresponding KEY is pushed
* Uses processor interrupts and GIC (Generic Interrupt Controller)
## LightTimer.s
* Uses the interrupt service routine for the Interval Timer
* Counts up, shown on LEDR, and can be stopped/started with any KEY
## LightTimerVariable.s
* Similar to LightTimer.s but KEY0 toggles RUN, KEY1 doubles the increase rate, KEY2 halves the increase rate
## AnimateLine.s
* Animates a line down and up on the screen
* Incorporates the VGA addresses and waits for V-sync
## LightBinaryAdd.s
* Lights up the corresponding numbers on HEX to the total binary number indicated by the switches
## FlashLED.s
* Flashes LEDR0 every 0.5 seconds using the A9 Private Timer
## FlashHEXAdd.s
* A combination of LightBinaryAdd.s and FlashLED.s but the number will stay on after done flashing

# ARM with C Playground
Various programs written in C for an ARM processor
These programs can be tested in an online simulator found here: https://cpulator.01xz.net/?sys=arm-de1soc using the C option, 
or using a DE1-SoC FPGA board
## DrawLine.c
* Implements Bresenham’s line-drawing algorithm to draw a few lines on the screen
## AnimateLine.c
* Moves a line down and up a screen and uses V-sync
* A pixel buffer "swap" is used as a way of synchronizing with the VGA controller via the S bit in the Status register
## AnimateDotsLines.c
* Creates an animation of eight small rectangles that "bounce" around on screen
* Each is connected by a line
## FlashHEXCharacters.c
* Flashed characters displayed on the HEX, written in C, using correct addresses of each
* Does not use hardware timer
## MovingLED.c
* Turns on one light at a time across all LEDRs
* Clicking any button will change the direction 
## MovingCharacters.c
* Displays a scrolling message across the HEX displays
* Pressing any KEY will toggle the scrolling animation
## MovingCharactersVariable.c
* Similar to MovingCharacters.c but KEY0 Starts/Stops animation, KEY1 doubles the increase rate, KEY2 halves the increase rate, KEY3 reverses the direction
