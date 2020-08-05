/*Increment, Decrement, Set to 0, and Reset Program with KEYS and HEX */
          .text                   // executable code follows
          .global _start                  
_start:         
            LDR R6, =0xFF200050 //store KEY address in R6
            //  R7              //used to hold the key value
            LDR R8, =0xFF200020 //store HEX 3-0 address in R8
            LDR R9, =BIT_CODES
            MOV R0, #0          //R0 use as counter storage
MAIN:
            LDR R7, [R6]        //Load the key value into R7 [Key0:0x01, Key1:0x02, Key2:0x04, Key3:0x08]
            
            CMP R7, #0x01       //If R7 (key value) is key0
            BEQ KEYA            //Branch to what key0 does

            CMP R7, #0x02       //If R7 (key value) is key1
            BEQ KEYB            //Branch to what key1 does

            CMP R7, #0x04       //If R7 (key value) is key2
            BEQ KEYC            //Branch to what key2 does

            CMP R7, #0x08       //If R7 (key value) is key3
            BEQ KEYD            //Branch to what key3 does


            B MAIN              //Branch back to main since no key was pressed


//Write to the hex using bit code conversion, using R5 as storage, R0 (counter) offset address for R9 bit codes
HEX:
            LDRB R5, [R9, R0]
            STR R5, [R8]        //Store R5 into R8 (HEX address)

            B MAIN              //Branch back to main


//Set counter to 0 if key0 pressed
KEYA:
            MOV R0, #0
            B WAITRELEASE
            
//Increment counter by 1 if key1 pressed
KEYB:
            CMP R0, #9         //Only add if number less than equal to 10
            ADDLT R0, #1
            B WAITRELEASE

//Decrement counter by 1 if key2 pressed
KEYC:
            CMP R0, #0         //Only decrement if number greater than qqual to 0
            SUBGT R0, #1
            B WAITRELEASE

//Wait for key to be released
WAITRELEASE:
            LDR R7, [R6]        //Load the key value into R7 [Key1:0x01, Key2:0x02, Key3:0x04, Key4:0x08]
            CMP R7, #0          //If R7 is 0, no keys are pressed
            BEQ HEX             //Set HEX when released
            B WAITRELEASE       //Key still pressed, loop


//Remove HEX display
KEYD:       
            LDR R5, =#0
            STR R5, [R8]       //Store R5 into R8 (HEX address)

            B WAITRELEASEZERO   //wait for thios key to be unpushed

//Wait for keyD to be released then set to 0 on next key push
WAITRELEASEZERO:
            LDR R7, [R6]        //Load the key value into R7 [Key1:0x01, Key2:0x02, Key3:0x04, Key4:0x08]
            CMP R7, #0          //If R7 is 0, no keys are pressed
            BEQ WAITFORNEXTZERO //Branch to wait for any key to be pushed next and set counter to 0
            B WAITRELEASEZERO   //Key still pressed, loop

//wait for next key to be pushed, then set to 0
WAITFORNEXTZERO:
            LDR R7, [R6]        //Load the key value into R7 [Key1:0x01, Key2:0x02, Key3:0x04, Key4:0x08]
            CMP R7, #0          //If R7 is 0, no keys are pressed
            MOVNE R0, #0        //Set counter to 0, if any key pressed
            BNE WAITRELEASE     //Wait for release of key, and set hex
            B WAITFORNEXTZERO   //Key not pressed, loop



//Values for corresponding HEX lights
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment