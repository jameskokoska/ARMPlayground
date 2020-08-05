


 int main(void) {
    volatile int * LEDptr = (int *) 0xFF200000;
    volatile int * intervalTimer = (int *) 0xFF202000;
    volatile int * KEYptr = (int *) 0xFF200050;

    
    volatile int binaryShift = 0b00000000010;
    
    //set the delay 25 million is 17D7840 in HEX (0.25 seconds)
    *(intervalTimer+2) = 0x7840;
    *(intervalTimer+3) = 0x017D;
    *(intervalTimer) = 0b1;
    *(intervalTimer+1) = 0b110;     //start the timer
    int state = 1;
    int keyPress = 0;
    int done = 0;


    while(1){
        *LEDptr = binaryShift >> 1;
        
        if(*KEYptr!=0){
            keyPress = 1;
        }else{
            keyPress = 0;
            done = 0;
        }

        if(keyPress == 1 && state == 1 && done == 0){
            state = 0;
            done = 1;
        }
        else if(keyPress == 1 && state == 0 && done == 0){
            state = 1;
            done = 1;
        }
        
        

        if(state){
            binaryShift = binaryShift << 1;
            
            if(binaryShift == 0b100000000000)
                binaryShift = 0b0000000010;
        }
        else{
            binaryShift = binaryShift >> 1;
            
            if(binaryShift == 0b000000000001)
                binaryShift = 0b10000000000;
        }
        
        
        
        while(1){       
            if (*intervalTimer & 0x1 == 1)  //check the value of TO
                break;
        }
        *intervalTimer = 0b0; //reset TO
    }
 }