/*Increment, Decrement, Set to 0, and Reset Program with KEYS and HEX */
          .text                   // executable code follows
          .global _start                  
_start:     
            LDR R3, =50000000   //Delay number for the A9 private timer (0.25 seconds)
            //  R6              //hex values
            //  R7              //hex values
            LDR R8, =0xFF200020 //store HEX 3-0 address in R8
            LDR R9, =BIT_CODES
            LDR R10, =0xFFFEC600//Delay counter address of A9 private timer
            LDR R11, =0xFF20005C//Set edge capture register
            //  R12             //edge capture value

            MOV R4, #0          //R0 use as counter storage

            //Setup the A9 private timer
            STR R3, [R10]
            MOV R3, #0b011
            STR R3, [R10, #8]

MAIN:
            ADD R4, #1

            //Check edge capture
            LDR R12,[R11]       //Load edge capture value
            CMP R12,#0          //If edge capture register set to 1, a key pressed
            BGT RESETEDGECAPTURE//Stop counting when button pushed, edge capture greater than 0

            //Continue Counting
            CMP R4, #99
            MOVEQ R4, #0

            /*--------------------------------------------*/
            /*Split the ones and tens digits using divide*/
            MOV    R5, #DIGITS  // R5 points to the decimal digits storage location
            MOV    R0, R4       // parameter for DIVIDE goes in R0
            BL     DIVIDE
            STRB   R1, [R5, #1] // Tens digit is now in R1
            STRB   R0, [R5]     // Ones digit is in R0
            /*--------------------------------------------*/

            B DODELAY
            
            

//Reset the edge capture reg by writing 1 into the correspodsing position of the register 
RESETEDGECAPTURE:
            LDR R12, =0b1111
            STR R12, [R11]
            B WAITFORNEXTKEY

WAITFORNEXTKEY:
            LDR R12,[R11]       //Load edge capture value
            CMP R12,#0          //If edge capture register set to 0, a key not pressed
            BEQ WAITFORNEXTKEY  //Stop counting when button pushed, wait for next button press

            LDR R12, =0b1111     //Reset edge capture
            STR R12, [R11]
            B MAIN              //Continue counting after button pressed, start counting again

//Write to the hex using bit code conversion, using R7 as storage, R0 (counter) offset address for R9 bit codes
HEX:
            LDRB R6, [R9, R0]   //Ones digit

            LDRB R7, [R9, R1]
            LSL R7, #8          //Tens digit, R7 + 8, since HEX1 is offset by 8 bits compared to HEX0 (HEX address)

            ORR R6, R7          //Combine the two reg
            STR R6, [R8]        //Store R6 (combined reg) into R*, HEX3-0 address 

            B MAIN              //Branch back to main

//Delay Loop, using polled IO
DODELAY:    LDR R3, [R10, #0xC]  //read status reg
            CMP R3, #0
            BEQ DODELAY         //wait for F bit
            STR R3,[R10,#0xC]    //reset F bit
            B HEX

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0
*/
DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIVEND
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIVEND:     MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR


//Values for corresponding HEX lights
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
DIGITS:     .space  4      // storage space for the decimal digits