            .text
            .global _start                  
_start:
        LDR R12, =0xFF203020
        B   MAIN

// Question 1(a)
WAIT_FOR_VSYNC: //Wait for VGA controller
                //Assume address is already in R12
                    PUSH {R0, R1, LR}
                    MOV R1, #1
                    STR R1, [R12]       //store 1 into the vga controller
         
         WHILESYNC: LDR R0, [R12, #12]   //increment by 4 x 3

                    AND R0, #0b1        //Check loop conditions
                    CMP R0, #0          //Check loop conditions
                    BNE WHILESYNC       //continue the loop
                    POP {R0, R1, LR}
                    MOV PC, LR          //return

// Question 1(b)
PLOT_PIXEL:     //Plot a pixel at given coordinates in a given colour
                //R0 has the x coordinate, R1 has the y coordinate, R2 has the color (16 bits)
                    PUSH {R4, R5, LR}
                    MOV R4, R0
                    MOV R5, R1

                    LDR R3, [R12, #4]   //get the location of the back buffer (4x1)
                    LSL R5, #10         //Shift y coordinate
                    LSL R4, #1          //Shift x coordinate
                    ADD R3, R4          //Sum up all values to get an address
                    ADD R3, R5          //Sum up all values to get an address
                    STRH R2, [R3]       //Store colour at that address (point on screen)
                    POP {R4, R5, LR}
                    MOV PC, LR

// Question 1(c)
CLEAR_SCREEN:   //Erase all the contents of the pixel buffer
                    PUSH {LR}

                    MOV R0, #0
                    MOV R1, #0
                    MOV R2, #0
     
     LOOPONECLEAR:  CMP R0, #320        //Check loop conditions
                    BGE RETURNSCREEN    //branch if done loop
                    ADD R0, #1          //increment loop
                    MOV R1, #0
     
     LOOPTWOCLEAR:  CMP R1, #240        //Check loop conditions
                    BGE LOOPONECLEAR    //repeat on next coordinate if done loop
                    ADD R1, #1          //increment loop
                    BL  PLOT_PIXEL      //call plot pixel subroutine
                    B   LOOPTWOCLEAR

     RETURNSCREEN:  POP {LR} //return
                    MOV PC,LR

// Question 1(d)
DRAW_LINE:      //Draw a horizontal line in the pixel buffer
                //R0 has the x0 coordinate, R1 has the x1 coordinate, R2 has the y coordinate, R3 has the color
                    PUSH {R1, R2, R3, R4, R5, R6, R7, LR}
                    MOV R4, R1
                    MOV R1, R2
                    MOV R2, R3

     LOOPDRAWLINE:  CMP R0, R4
                    BGE RETURNDRAW
                    ADD R0, #1
                    BL PLOT_PIXEL
                    B LOOPDRAWLINE
        
       RETURNDRAW:  POP {R1, R2, R3, R4, R5, R6, R7, LR}
                    MOV PC,LR

// Question 1(e)
MAIN:           //Horizontal line animation (100-220 pixels wide)
                    PUSH {R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, LR}
                    BL CLEAR_SCREEN     

                    //initial top bar clear
                    MOV R0, #0          //x_0
                    MOV R1, #320        //x_1
                    MOV R2, #0          //y
                    LDR R3, =#0x0000    //line colour (white)
                    BL DRAW_LINE
                    
                    MOV R0, #100        //x_0
                    MOV R1, #220        //x_1
                    MOV R2, #0          //y
                    LDR R3, =#0xFFFF    //line colour (white)
                    MOV R4, #1          //y_dir
                    BL DRAW_LINE


            WHILE:  
                    BL WAIT_FOR_VSYNC
                    MOV R0, #100
                    MOV R1, #220
                    LDR R3, =#0x0000     //erase the line
                    BL DRAW_LINE
                    
                    MOV R0, #100
                    MOV R1, #220
                    
                    CMP R2, #0          //determine direction
                    MOVEQ R4, #1
                    CMP R2, #239
                    MOVEQ R4, #2

                    CMP R4, #1          //determine direction
                    ADDEQ R2, #1
                    CMP R4, #2
                    SUBEQ R2,#1

                    LDR R3, =#0xFFFF    //draw the line
                    BL DRAW_LINE

                    B WHILE
                    
                    POP {R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, LR}

