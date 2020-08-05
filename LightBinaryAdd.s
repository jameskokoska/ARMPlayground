            .text
            .global _start                  
_start:     
            //Initially turn off all HEX
            LDR R0, =10
            LDR R1, =10    
            LDR R2, =10    
            LDR R3, =10    
            LDR R10, =10    
            LDR R11, =10      

MAIN:
            LDR R8, =0xFF200040
            LDR R9, [R8]
        
            CMP R9, #0
            LDREQ R0, =0
            BEQ HEX  

            CMP R9, #1
            LDREQ R1, =1
            BEQ HEX  

            CMP R9, #2
            LDREQ R2, =2
            BEQ HEX  

            CMP R9, #3
            LDREQ R3, =3
            BEQ HEX  

            CMP R9, #4
            LDREQ R10, =4
            BEQ HEX

            CMP R9, #5
            LDREQ R11, =5
            BEQ HEX  

              
            B MAIN

HEX:        //R0, R1, R2, R3, R10, R11 have the data
            PUSH {R4, R5, R6, R7, R8, R9, R10, R11}

            //  R6              //hex values
            //  R7              //hex values
            LDR R8, =0xFF200020 //store HEX 3-0 address in R8
            LDR R9, =BIT_CODES

            LDRB R4, [R9, R0]   //Ones digit (R0)

            LDRB R5, [R9, R1]   //Tens (R1)
            LSL R5, #8          //Tens digit, R7 + 8, since HEX1 is offset by 8 bits compared to HEX0 (HEX address)

            LDRB R6, [R9, R2]   //Hundreds (R2)
            LSL R6, #16         //Tens digit, R7 + 16, since HEX1 is offset by 16 bits compared to HEX0 (HEX address)

            LDRB R7, [R9, R3]   //Thousands (R3)
            LSL R7, #24         //Tens digit, R7 + 24, since HEX1 is offset by 24 bits compared to HEX0 (HEX address)


            ORR R6, R7          //Combine the reg
            ORR R5, R6          //Combine the reg
            ORR R4, R5          //Combine the reg
            STR R4, [R8]        //Store R6 (combined reg) into R*, HEX3-0 address
            
            LDR R8, =0xFF200030     //store HEX 5-6 address in R9

            LDRB R4, [R9, R10]      //Ones digit (R5)

            LDRB R5, [R9, R11]      //Tens (R6)
            LSL R5, #8              //Tens digit, R7 + 8, since HEX1 is offset by 8 bits compared to HEX0 (HEX address)

            ORR R4, R5              //Combine the reg
            STR R4, [R8]

            POP {R4, R5, R6, R7, R8, R9, R10, R11}
            B MAIN              //Branch back to main

STOP:       B STOP

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .byte   0b00000000
            .end