char characterString[] = {0b0,0b0,0b0,0b0,0b0,0b0,0b0111110,0b0,0b1011100,0b1110001,0b0,0b1111000,0b0,0b1111001, 0b0111001,0b1111001,0b1000000,0b1011011,0b1100110,0b1001111,0b0,0b0,0b0,0b0,0b0,0b0};

int main(void) {
    volatile int * HEXptr1 = (int *) 0xFF200020;
    volatile int * HEXptr2 = (int *) 0xFF200030;
    volatile int * KEYptr = (int *) 0xFF200050;
    volatile int * intervalTimer = (int *) 0xFF202000;
    int countActive = 0;
    int rotatingIndex = 0;

    int state = 1;
    int keyPress = 0;
    int done = 0;

    //set the delay 50 million is 2FAF080 in HEX (0.5 seconds)
    *(intervalTimer+2) = 0xF080;
    *(intervalTimer+3) = 0x02FA;
    *(intervalTimer) = 0b1;
    *(intervalTimer+1) = 0b110;     //start the timer

    while(1){
        
        *HEXptr1 = characterString[rotatingIndex+5] | characterString[rotatingIndex+4] << 8 | characterString[rotatingIndex+3] << 16 | characterString[rotatingIndex+2] << 24;
        *HEXptr2 = characterString[rotatingIndex+1] | characterString[rotatingIndex] << 8;
        
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
        
        while(1){       
            if (*intervalTimer & 0x1 == 1)  //check the value of TO
                break;
        }
        *intervalTimer = 0b0; //reset TO


        if (rotatingIndex==20)
            rotatingIndex = 0;
        else if (state==1)
            rotatingIndex++;

    }
 }