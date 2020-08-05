char characterString[] = {0b0,0b0,0b0,0b0,0b0,0b0,0b0111110,0b0,0b1011100,0b1110001,0b0,0b1111000,0b0,0b1111001, 0b0111001,0b1111001,0b1000000,0b1011011,0b1100110,0b1001111,0b0,0b0,0b0,0b0,0b0,0b0};

int main(void) {
    volatile int * HEXptr1 = (int *) 0xFF200020;
    volatile int * HEXptr2 = (int *) 0xFF200030;
    volatile int * KEYptr = (int *) 0xFF200050;
    volatile int * intervalTimer = (int *) 0xFF202000;
    int countActive = 0;
    int rotatingIndex = 0;

    int state0 = 1;
    int keyPress0 = 0;
    int done0 = 0;

    int state1 = 1;
    int keyPress1 = 0;
    int done1 = 0;

    int state2 = 1;
    int keyPress2 = 0;
    int done2 = 0;

    int state3 = 1;
    int keyPress3 = 0;
    int done3 = 0;

    //set the delay 50 million is 2FAF080 in HEX (0.5 seconds)
    int delay = 0x2FAF080;
    *(intervalTimer+2) = delay & 0xFFFF;
    *(intervalTimer+3) = (delay >> 16) & 0xFFFF;
    *(intervalTimer) = 0b1;
    *(intervalTimer+1) = 0b110;     //start the timer

    while(1){
        
        *HEXptr1 = characterString[rotatingIndex+5] | characterString[rotatingIndex+4] << 8 | characterString[rotatingIndex+3] << 16 | characterString[rotatingIndex+2] << 24;
        *HEXptr2 = characterString[rotatingIndex+1] | characterString[rotatingIndex] << 8;
        
        if(*KEYptr==0b0001){
            keyPress0 = 1;
        } else {
            keyPress0 = 0;
            done0 = 0;
        } if(keyPress0 == 1 && state0 == 1 && done0 == 0){
            state0 = 0;
            done0 = 1;
        } else if(keyPress0 == 1 && state0 == 0 && done0 == 0){
            state0 = 1;
            done0 = 1;
        }


        if(*KEYptr==0b0010){
            keyPress1 = 1;
        } else{
            keyPress1 = 0;
            done1 = 0;
        } if(keyPress1 == 1 && state1 == 1 && done1 == 0){
            state1 = 0;
            done1 = 1;
        } else if(keyPress1 == 1 && state1 == 0 && done1 == 0){
            state1 = 1;
            done1 = 1;
        }


        if(*KEYptr==0b0100){
            keyPress2 = 1;
        } else{
            keyPress2 = 0;
            done2 = 0;
        } if(keyPress2 == 1 && state2 == 1 && done2 == 0){
            state2 = 0;
            done2 = 1;
        } else if(keyPress2 == 1 && state2 == 0 && done2 == 0){
            state2 = 1;
            done2 = 1;
        }


        if(*KEYptr==0b1000){
            keyPress3 = 1;
        } else{
            keyPress3 = 0;
            done3 = 0;
        } if(keyPress3 == 1 && state3 == 1 && done3 == 0){
            state3 = 0;
            done3 = 1;
        } else if(keyPress3 == 1 && state3 == 0 && done3 == 0){
            state3 = 1;
            done3 = 1;
        }
        
        if (rotatingIndex==20 && state3 ==1)
            rotatingIndex = 0;
        else if (rotatingIndex==0 && state3 ==0)
            rotatingIndex = 20;
        else if (state0==1)
            if(state3==1)
                rotatingIndex++;
            else
                rotatingIndex--;

        while(1){       
            if (*intervalTimer & 0x1 == 1)  //check the value of TO
                break;
        }

        *intervalTimer = 0b0; //reset TO

        if(state1==1){
            delay = delay/2;
            *(intervalTimer+2) = delay & 0xFFFF;
            *(intervalTimer+3) = (delay >> 16) & 0xFFFF;
            state1=0;
            *(intervalTimer+1) = 0b110;     //start the timer
        }
        if(state2==1){
            delay = delay*2;
            *(intervalTimer+2) = delay & 0xFFFF;
            *(intervalTimer+3) = (delay >> 16) & 0xFFFF;
            state2=0;
            *(intervalTimer+1) = 0b110;     //start the timer
        }
        
    }
 }