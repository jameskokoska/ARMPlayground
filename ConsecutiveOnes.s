/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
        MOV     R4, #TEST_NUM   // load the words
        MOV     R5, #0          // R5 will hold the largest result
        MOV     R0, #0          // R0 will hold the current result

MAIN: 
        LDR     R1, [R4], #4    // load first,second,third... word into R1
        CMP     R1, #0          // done list? 0 at the end
        BEQ     END

        MOV     R0, #0          // R0 will hold the current result, set to 0

        B      LOOP            // Do loop

COMPARE:
        CMP     R5, R0          // is result bigger?
        MOVLT   R5, R0          // store new largest value

        B       MAIN


LOOP:   
        CMP     R1, #0          // loop until the data contains no more 1's, 0s left once all shifted
        BEQ     COMPARE         // end when done looping, compare values check for bigger
        BL      ONES            // call the subroutine, returns below after subroutine
        ADD     R0, #1          // count the string length so far
        B       LOOP         

ONES:               
        LSR     R2, R1, #1      // perform SHIFT R2 <- R1, shift R by 1 into R2, 0 added on left 
        AND     R1, R1, R2      // followed by bitwise AND, R1 <- R1 && R2
        MOV     PC, LR          //return to previous function call in loop

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
            .end                            
