

char characterString[] = {0b1111001, 0b0111001,0b1111001,0b01011011,0b01100110,0b01001111};
 int main(void) {
    volatile int * HEXptr1 = (int *) 0xFF200020;
    volatile int * HEXptr2 = (int *) 0xFF200030;
    int countActive = 0;

    while(1){
        countActive = 0;
        while(countActive < 300000){        //This value is just an estimation based on CPUlator, not based on De1 SoC board clock speed
            countActive++;
            *HEXptr1 = characterString[5] | characterString[4] << 8 | characterString[3] << 16 | characterString[2] << 24;
            *HEXptr2 = characterString[1] | characterString[0] << 8;
        }

        
        countActive = 0;
        while(countActive < 300000){
            countActive++;
            *HEXptr1 = 0 | 0 << 8 | 0 << 16 | 0 << 24;
            *HEXptr2 = 0 | 0 << 8;
        }

    }
 }