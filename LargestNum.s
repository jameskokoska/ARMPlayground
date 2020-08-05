/* Program that finds the largest number in a list of integers	*/

            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #RESULT     // R4 points to result location
            LDR     R2, [R4, #4]    // R0 holds the number of elements in the list
            MOV     R1, #NUMBERS    // R1 points to the start of the list
            BL      LARGE           
            STR     R0, [R4]        // R0 holds the subroutine return value, the largest value
            B       END

/* Subroutine to find the largest integer in a list
 * Parameters: R0 has the number of elements in the lisst
 *             R1 has the address of the start of the list
 * Returns: R0 returns the largest item in the list
 */
LARGE:      SUBS    R2, #1      //decrement loop
            MOVEQ   R15, R14    //ends subroutine if equal to 0
            LDR     R5, [R1]    //load the next number from list (r1) into r5 storage
			ADD     R1, #4      //points to next data, add after to see compare first value
            CMP     R0, R5      //compare to see if larger number just loaded
            BGE     LARGE       //branch if r0 greater than or equal to r5
            MOV     R0, R5      //update largest number held in r5 if greater than stored value
            B       LARGE

END:        B       END           

RESULT:     .word   0           
N:          .word   7           // number of entries in the list
NUMBERS:    .word   4, 5, 3, 6  // the data
            .word   1, 8, 2                 

            .end                            

