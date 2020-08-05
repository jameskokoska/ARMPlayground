/*Increment, Decrement, Set to 0, and Reset Program with KEYS and HEX */
          .text                   // executable code follows
          .global _start                  
_start:     
           


            LDR R10, =0xFFFEC600//Delay counter address of A9 private timer
            LDR R11, =0xFF20005C//Set edge capture register
            //  R12             //edge capture value

            MOV R0, #0          //R6 use as ones digit for (0-99)
            MOV R1, #0          //R7 use as tens digit for (0-99)
            MOV R2, #0          //R7 use as ones digit second counter (0-59)
            MOV R3, #0          //R7 use as tens digit second counter (0-59)


            //Setup the A9 private timer
            LDR R4, =2000000    //Delay number for the A9 private timer (0.01 seconds)
            STR R4, [R10]
            MOV R4, #0b011
            STR R4, [R10, #8]

MAIN:
            ADD R0, #1

            //Check edge capture
            LDR R12,[R11]       //Load edge capture value
            CMP R12,#0          //If edge capture register set to 1, a key pressed
            BGT RESETEDGECAPTURE//Stop counting when button pushed, edge capture greater than 0

            //Continue Counting
            CMP R0, #9
            MOVEQ R0, #0
            ADDEQ R1, #1

            CMP R1, #9
            MOVEQ R1, #0
            ADDEQ R2, #1

            CMP R2, #9
            MOVEQ R2, #0
            ADDEQ R3, #1

            CMP R3, #5
            MOVEQ R3, #0

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
HEX:        PUSH {R4, R5, R6, R7, R8, R9}

            //  R6              //hex values
            //  R7              //hex values
            LDR R8, =0xFF200020 //store HEX 3-0 address in R8
            LDR R9, =BIT_CODES

            LDRB R4, [R9, R0]   //Ones digit (R0)

            LDRB R5, [R9, R1]   //Tens (R1)
            LSL R5, #8          //Tens digit, R7 + 8, since HEX1 is offset by 8 bits compared to HEX0 (HEX address)

            LDRB R6, [R9, R2]   //Tens (R1)
            LSL R6, #16          //Tens digit, R7 + 8, since HEX1 is offset by 8 bits compared to HEX0 (HEX address)

            LDRB R7, [R9, R3]   //Tens (R1)
            LSL R7, #24          //Tens digit, R7 + 8, since HEX1 is offset by 8 bits compared to HEX0 (HEX address)


            ORR R6, R7          //Combine the reg
            ORR R5, R6          //Combine the reg
            ORR R4, R5          //Combine the reg
            STR R4, [R8]        //Store R6 (combined reg) into R*, HEX3-0 address 
            
            POP {R4, R5, R6, R7, R8, R9}
            B MAIN              //Branch back to main

//Delay Loop, using polled IO
DODELAY:    
            LDR R4, [R10, #0xC]  //read status reg
            CMP R4, #0
            BEQ DODELAY         //wait for F bit
            STR R4,[R10,#0xC]    //reset F bit
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