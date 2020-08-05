/* Program that counts consecutive 1's, 0's, and 1/0's */

          .text                   // executable code follows
          .global _start                  
_start:                             
        MOV     R4, #TEST_NUM   // load the words
        MOV     R5, #0          // R5 will hold the final result for 1s
        MOV     R6, #0          // R6 will hold the final result for 0s
        MOV     R7, #0          // R7 will hold the final result for 1/0s
        MOV     R8, #0          // R8 will hold the current result for 1/0s, 1 count
        MOV     R9, #0          // R9 will hold the current result for 1/0s, 0 count

MAINONES: 
        LDR     R1, [R4], #4    // load first,second,third... word into R1
        CMP     R1, #0          // done list? 0 at the end
        BEQ     ZEROESSTART

        MOV     R0, #0          // R0 will hold the current result, set to 0

        B      ONESLOOP         // Do LOOP to start everything

COMPAREONES:
        CMP     R5, R0          // is result bigger?
        MOVLT   R5, R0          // store new largest value

        B       MAINONES

ONESLOOP:   
        CMP     R1, #0          // loop until the data contains no more 1's, 0s left once all shifted
        BEQ     COMPAREONES     // end when done looping, compare values check for bigger

        BL      ONES            // call the subroutine, returns below after subroutine
        ADD     R0, #1          // count the 1s so far

        B       ONESLOOP

ONES:
        LSR     R2, R1, #1      // perform SHIFT R2 <- R1, shift R by 1 into R2, 0 added on left 
        AND     R1, R1, R2      // followed by bitwise AND, R1 <- R1 && R2
        MOV     PC, LR          // return to previous function call in loop

ZEROESSTART:        
        MOV     R4, #TEST_NUM   // load the words
MAINZEROES: 
        LDR     R1, [R4], #4    // load first,second,third... word into R1
        CMP     R1, #0          // done list? 0 at the end
        BEQ     ALTERNATESTART

        MOV     R0, #0          // R0 will hold the current result, set to 0

        MOV     R3, #ALLONES    // load 111111... pattern and invert
        LDR     R3, [R3]
        EOR     R1, R1, R3      //XOR with alternating 111111 pattern and count consecutive ones

        B      ZEROESLOOP       // Do LOOP to start everything

COMPAREZEROES:
        CMP     R6, R0          // is result bigger?
        MOVLT   R6, R0          // store new largest value

        B       MAINZEROES

ZEROESLOOP:   
        CMP     R1, #0          // loop until the data contains no more 1's, 0s left once all shifted
        BEQ     COMPAREZEROES   // end when done looping, compare values check for bigger

        BL      ZEROES          // call the subroutine, returns below after subroutine
        ADD     R0, #1          // count the 1s so far

        B       ZEROESLOOP

ZEROES:
        LSR     R2, R1, #1      // perform SHIFT R2 <- R1, shift R by 1 into R2, 0 added on left 
        AND     R1, R1, R2      // followed by bitwise AND, R1 <- R1 && R2
        MOV     PC, LR          // return to previous function call in loop

ALTERNATESTART:
        MOV     R4, #TEST_NUM   // load the words
MAINALTERNATE: 
        LDR     R1, [R4], #4    // load first,second,third... word into R1
        CMP     R1, #0          // done list? 0 at the end
        BEQ     END

        MOV     R0, #0          // R0 will hold the current result, set to 0

        MOV     R3, #ALLALTERNATE// load 0101... pattern and invert
        LDR     R3, [R3]
        EOR     R1, R1, R3      //XOR with alternating 01 pattern and count consecutive ones

        B      ALTERNATELOOP    // Do LOOP to start everything

COMPAREALTERNATE:
        CMP     R7, R0          // is result bigger?
        MOVLT   R7, R0          // store new largest value

        B       MAINALTERNATE


ALTERNATELOOP:   
        CMP     R1, #0          // loop until the data contains no more 1's, 0s left once all shifted
        BEQ     COMPAREALTERNATE// end when done looping, compare values check for bigger

        BL      ALTERNATE       // call the subroutine, returns below after subroutine
        ADD     R0, #1          // count the 1s so far

        B       ALTERNATELOOP

ALTERNATE:
        LSR     R2, R1, #1      // perform SHIFT R2 <- R1, shift R by 1 into R2, 0 added on left 
        AND     R1, R1, R2      // followed by bitwise AND, R1 <- R1 && R2
        MOV     PC, LR          // return to previous function call in loop

END:    B       END

TEST_NUM:   .word   0x11111111
            .word   0x00000001
            .word   0x00000001
            .word   0xDEADBEEF
            .word   0x00000001
            .word   0x10000000
            .word   0x20000000
            .word   0x30000000
            .word   0x40000000
            .word   0x50000000
            .word   0x42000000
            .word   0x12345678
            .word   0x00000000
ALLONES:    .word   0xFFFFFFFF
ALLALTERNATE:  .word   0x55555555
            .end                            
