/*ASSUMPTION: IN CONFIG_PRIV_TIMER: LDR R1, =100000000      assume 0.5s delay */				
				
				.section .vectors, "ax"

				B 	_start						// reset vector
				B 	SERVICE_UND					// undefined instruction vector
				B 	SERVICE_SVC					// software interrrupt vector
				B	SERVICE_ABT_INST			// aborted prefetch vector
				B 	SERVICE_ABT_DATA			// aborted data vector
				B 	0							// unused vector
				B	IRQ_HANDLER					// IRQ interrupt vector
				B	SERVICE_FIQ 				// FIQ interrupt vector

                  .text 
                  .global  _start
_start:	
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #0b11010010		// interrupts masked, MODE = IRQ
				MSR		CPSR_c, R1			// change to IRQ mode
				LDR		SP, =0x20000        // set IRQ stack pointer
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b10011		// interrupts masked, MODE = SVC
				MSR		CPSR, R1			// change to supervisor mode
				LDR		SP, =0x40000		// set SVC stack 

                BL      CONFIG_GIC       	// configure the ARM generic
                                            // interrupt controller
                BL 	    CONFIG_PRIV_TIMER

/* Enable IRQ interrupts in the ARM processor */



/*PART A CODE */
//Initially turn off all HEX
            LDR R0, =10
            LDR R1, =10    
            LDR R2, =10    
            LDR R3, =10    
            LDR R10, =10    
            LDR R11, =10
			LDR R12, =0
			LDR R8, =0xFF200040    
			LDR R6, =0xFF200000

MAIN:
			LDR R5, COUNT
			AND R5, #0b1
			STR R5, [R6]   // write to the LEDR lights
			
			CMP R5, #0b1
			BNE SKIP

			CMP R9, #0
            LDREQ R0, =10
            BEQ HEX  

            CMP R9, #1
            LDREQ R1, =10
			BEQ HEX

            CMP R9, #2
            LDREQ R2, =10
            BEQ HEX

            CMP R9, #3
            LDREQ R3, =10
            BEQ HEX  

            CMP R9, #4
            LDREQ R10, =10
            BEQ HEX  

            CMP R9, #5
            LDREQ R11, =10
            BEQ HEX  





SKIP:       LDR R9, [R8]		
			//Note: R12 keeps track of which ones already on, so they stay on
			
            CMP R9, #0
            LDREQ R0, =0
			ORREQ R12, #0b000001
            BEQ HEX  

            CMP R9, #1
            LDREQ R1, =1
			ORREQ R12, #0b000010
			BEQ HEX

            CMP R9, #2
            LDREQ R2, =2
			ORREQ R12, #0b000100
            BEQ HEX  

            CMP R9, #3
            LDREQ R3, =3
			ORREQ R12, #0b001000
            BEQ HEX  

            CMP R9, #4
            LDREQ R10, =4
			ORREQ R12, #0b010000
            BEQ HEX  

            CMP R9, #5
            LDREQ R11, =5
			ORREQ R12, #0b100000
            BEQ HEX  

			//Check which to leave on, using data stored in R12
CHECKHEX:	CMP R9, #0
			BEQ SKIPZERO
			MOV R7, R12
			AND R7, #0b000001
			CMP R7, #1
			LDRGE R0, =0
SKIPZERO:
			CMP R9, #1
			BEQ SKIPONE
			MOV R7, R12
			AND R7, #0b000010
			CMP R7, #1
			LDRGE R1, =1
SKIPONE:
			CMP R9, #2
			BEQ SKIPTWO
			MOV R7, R12
			AND R7, #0b000100
			CMP R7, #1
			LDRGE R2, =2
SKIPTWO:
			CMP R9, #3
			BEQ SKIPTHREE
			MOV R7, R12
			AND R7, #0b001000
			CMP R7, #1
			LDRGE R3, =3
SKIPTHREE:
			CMP R9, #4
			BEQ SKIPFOUR
			MOV R7, R12
			AND R7, #0b010000
			CMP R7, #1
			LDRGE R10, =4
SKIPFOUR:
			CMP R9, #5
			BEQ SKIPFIVE
			MOV R7, R12
			AND R7, #0b100000
			CMP R7, #1
			LDRGE R11, =5
SKIPFIVE:


			B FIXHEX


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
            B CHECKHEX              //Branch back to main



FIXHEX:        //R0, R1, R2, R3, R10, R11 have the data
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
            B MAIN             //Branch back to main





IRQ_HANDLER:
                PUSH	{R0-R5, LR}

    			/* Read the ICCIAR from the CPU interface */
    			LDR		R4, =0xFFFEC100
    			LDR		R5, [R4, #0xC]		// read from ICCIAR

PRIVATE_TIMER_HANDLER:
                CMP     R5, #29
				BL      PRIVATE_TIMER_ISR

UNEXPECTED:		B		EXIT_IRQ    		// if not recognized, stop here

EXIT_IRQ:
    			/* Write to the End of Interrupt Register (ICCEOIR) */
    			STR		R5, [R4, #0x10]     // write to ICCEOIR

    			POP		{R0-R5, LR}
    			SUBS	PC, LR, #4			//return

				.global	KEY_ISR

RETURN:		MOV	R12, #0xF
			STR	R12, [R6, #0xC]			// clear the interrupt

			POP	{R0-R12,PC}				// return

SETRUN:     //Set the RUN global
            LDR R1, =RUN    //Get global variable
            LDR R2, [R1]    //Store value of global
            CMP R2, #0      //Check if RUN = 0
            MOVNE R5, #0
            STRNE R5, [R1]
            MOVEQ R5, #1
            STR R5, [R1]
            B RETURN


PRIVATE_TIMER_ISR:
 			PUSH {R0-R10, LR}
			
			LDR R2, =COUNT 
			
			LDR R3, [R2]        //get value of count

            ADD R3, #1
            STR R3, [R2]        //saves the value back to count

			LDR     R4, =0xFFFEC600
            MOV     R1, #1
            STR     R1, [R4, #0xC]        //restarts count of timer

			POP {R0-R10, LR}
			MOV PC, LR

/* Global variables */
                  .global  COUNT                           
COUNT:            .word    0x0              // used by timer
                  .global  RUN              // used by pushbutton KEYs
RUN:              .word    0x1              // initial value to increment
                                            // COUNT


CONFIG_GIC:
				PUSH		{LR}
    			/* Configure the A9 Private Timer interrupt, FPGA KEYs, and FPGA Timer
				/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
    			MOV		R0, #MPCORE_PRIV_TIMER_IRQ
    			MOV		R1, #CPU0
    			BL			CONFIG_INTERRUPT
    			MOV		R0, #INTERVAL_TIMER_IRQ
    			MOV		R1, #CPU0
    			BL			CONFIG_INTERRUPT
    			MOV		R0, #KEYS_IRQ
    			MOV		R1, #CPU0
    			BL			CONFIG_INTERRUPT

				/* configure the GIC CPU interface */
    			LDR		R0, =0xFFFEC100		// base address of CPU interface
    			/* Set Interrupt Priority Mask Register (ICCPMR) */
    			LDR		R1, =0xFFFF 			// enable interrupts of all priorities levels
    			STR		R1, [R0, #0x04]
    			/* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
				 * allows interrupts to be forwarded to the CPU(s) */
    			MOV		R1, #1
    			STR		R1, [R0]

    			/* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
				 * allows the distributor to forward interrupts to the CPU interface(s) */
    			LDR		R0, =0xFFFED000
    			STR		R1, [R0]    

    			POP     	{PC}

CONFIG_PRIV_TIMER:  
				PUSH    {R0-R3}
				LDR     R0, =0xFFFEC600
                LDR     R1, =100000000      //assume 0.5s delay
                STR     R1, [R0]

				MOV     R2, #0b111
                STR     R2, [R0, #8] 		//set I/A/E to 1

				POP     {R0-R3}
                BX      LR



/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
    			PUSH		{R4-R5, LR}
    
    			/* Configure Interrupt Set-Enable Registers (ICDISERn). 
				 * reg_offset = (integer_div(N / 32) * 4
				 * value = 1 << (N mod 32) */
    			LSR		R4, R0, #3							// calculate reg_offset
    			BIC		R4, R4, #3							// R4 = reg_offset
				LDR		R2, =0xFFFED100
				ADD		R4, R2, R4							// R4 = address of ICDISER
    
    			AND		R2, R0, #0x1F   					// N mod 32
				MOV		R5, #1								// enable
    			LSL		R2, R5, R2							// R2 = value

				/* now that we have the register address (R4) and value (R2), we need to set the
				 * correct bit in the GIC register */
    			LDR		R3, [R4]								// read current register value
    			ORR		R3, R3, R2							// set the enable bit
    			STR		R3, [R4]								// store the new register value

    			/* Configure Interrupt Processor Targets Register (ICDIPTRn)
     			 * reg_offset = integer_div(N / 4) * 4
     			 * index = N mod 4 */
    			BIC		R4, R0, #3							// R4 = reg_offset
				LDR		R2, =0xFFFED800
				ADD		R4, R2, R4							// R4 = word address of ICDIPTR
    			AND		R2, R0, #0x3						// N mod 4
				ADD		R4, R2, R4							// R4 = byte address in ICDIPTR

				/* now that we have the register address (R4) and value (R2), write to (only)
				 * the appropriate byte */
				STRB	R1, [R4]
    
    			POP		{R4-R5, PC}
				

/* FPGA interrupts (there are 64 in total; only a few are defined below) */
			.equ	INTERVAL_TIMER_IRQ, 			72
			.equ	KEYS_IRQ, 						73
			.equ	FPGA_IRQ2, 						74
			.equ	FPGA_IRQ3, 						75
			.equ	FPGA_IRQ4, 						76
			.equ	FPGA_IRQ5, 						77
			.equ	AUDIO_IRQ, 						78
			.equ	PS2_IRQ, 						79
			.equ	JTAG_IRQ, 						80
			.equ	IrDA_IRQ, 						81
			.equ	FPGA_IRQ10,						82
			.equ	JP1_IRQ,						83
			.equ	JP2_IRQ,						84
			.equ	FPGA_IRQ13,						85
			.equ	FPGA_IRQ14,						86
			.equ	FPGA_IRQ15,						87
			.equ	FPGA_IRQ16,						88
			.equ	PS2_DUAL_IRQ,					89
			.equ	FPGA_IRQ18,						90
			.equ	FPGA_IRQ19,						91

/* ARM A9 MPCORE devices (there are many; only a few are defined below) */
			.equ	MPCORE_GLOBAL_TIMER_IRQ,	27
			.equ	MPCORE_PRIV_TIMER_IRQ,		29
			.equ	MPCORE_WATCHDOG_IRQ,		30

/* HPS devices (there are many; only a few are defined below) */
			.equ	HPS_UART0_IRQ,   			194
			.equ	HPS_UART1_IRQ,   			195
			.equ	HPS_GPIO0_IRQ,          	196
			.equ	HPS_GPIO1_IRQ,          	197
			.equ	HPS_GPIO2_IRQ,          	198
			.equ	HPS_TIMER0_IRQ,         	199
			.equ	HPS_TIMER1_IRQ,         	200
			.equ	HPS_TIMER2_IRQ,         	201
			.equ	HPS_TIMER3_IRQ,         	202
			.equ	HPS_WATCHDOG0_IRQ,     		203
			.equ	HPS_WATCHDOG1_IRQ,     		204

//define.s
			.equ		EDGE_TRIGGERED,         0x1
			.equ		LEVEL_SENSITIVE,        0x0
			.equ		CPU0,         			0x01	// bit-mask; bit 0 represents cpu0
			.equ		ENABLE, 				0x1

			.equ		KEY0, 					0b0001
			.equ		KEY1, 					0b0010
			.equ		KEY2,					0b0100
			.equ		KEY3,					0b1000

			.equ		RIGHT,					1
			.equ		LEFT,					2

			.equ		USER_MODE,				0b10000
			.equ		FIQ_MODE,				0b10001
			.equ		IRQ_MODE,				0b10010
			.equ		SVC_MODE,				0b10011
			.equ		ABORT_MODE,				0b10111
			.equ		UNDEF_MODE,				0b11011
			.equ		SYS_MODE,				0b11111

			.equ		INT_ENABLE,				0b01000000
			.equ		INT_DISABLE,			0b11000000

/* Memory */
        .equ  DDR_BASE,	            0x00000000
        .equ  DDR_END,              0x3FFFFFFF
        .equ  A9_ONCHIP_BASE,	    0xFFFF0000
        .equ  A9_ONCHIP_END,        0xFFFFFFFF
        .equ  SDRAM_BASE,    	    0xC0000000
        .equ  SDRAM_END,            0xC3FFFFFF
        .equ  FPGA_ONCHIP_BASE,	    0xC8000000
        .equ  FPGA_ONCHIP_END,      0xC803FFFF
        .equ  FPGA_CHAR_BASE,   	0xC9000000
        .equ  FPGA_CHAR_END,        0xC9001FFF

/* Cyclone V FPGA devices */
        .equ  LEDR_BASE,             0xFF200000
        .equ  HEX3_HEX0_BASE,        0xFF200020
        .equ  HEX5_HEX4_BASE,        0xFF200030
        .equ  SW_BASE,               0xFF200040
        .equ  KEY_BASE,              0xFF200050
        .equ  JP1_BASE,              0xFF200060
        .equ  JP2_BASE,              0xFF200070
        .equ  PS2_BASE,              0xFF200100
        .equ  PS2_DUAL_BASE,         0xFF200108
        .equ  JTAG_UART_BASE,        0xFF201000
        .equ  JTAG_UART_2_BASE,      0xFF201008
        .equ  IrDA_BASE,             0xFF201020
        .equ  TIMER_BASE,            0xFF202000
        .equ  AV_CONFIG_BASE,        0xFF203000
        .equ  PIXEL_BUF_CTRL_BASE,   0xFF203020
        .equ  CHAR_BUF_CTRL_BASE,    0xFF203030
        .equ  AUDIO_BASE,            0xFF203040
        .equ  VIDEO_IN_BASE,         0xFF203060
        .equ  ADC_BASE,              0xFF204000

/* Cyclone V HPS devices */
        .equ   HPS_GPIO1_BASE,       0xFF709000
        .equ   HPS_TIMER0_BASE,      0xFFC08000
        .equ   HPS_TIMER1_BASE,      0xFFC09000
        .equ   HPS_TIMER2_BASE,      0xFFD00000
        .equ   HPS_TIMER3_BASE,      0xFFD01000
        .equ   FPGA_BRIDGE,          0xFFD0501C

/* ARM A9 MPCORE devices */
        .equ   PERIPH_BASE,          0xFFFEC000   /* base address of peripheral devices */
        .equ   MPCORE_PRIV_TIMER,    0xFFFEC600   /* PERIPH_BASE + 0x0600 */

        /* Interrupt controller (GIC) CPU interface(s) */
        .equ   MPCORE_GIC_CPUIF,     0xFFFEC100   /* PERIPH_BASE + 0x100 */
        .equ   ICCICR,               0x00         /* CPU interface control register */
        .equ   ICCPMR,               0x04         /* interrupt priority mask register */
        .equ   ICCIAR,               0x0C         /* interrupt acknowledge register */
        .equ   ICCEOIR,              0x10         /* end of interrupt register */
        /* Interrupt controller (GIC) distributor interface(s) */
        .equ   MPCORE_GIC_DIST,      0xFFFED000   /* PERIPH_BASE + 0x1000 */
        .equ   ICDDCR,               0x00         /* distributor control register */
        .equ   ICDISER,              0x100        /* interrupt set-enable registers */
        .equ   ICDICER,              0x180        /* interrupt clear-enable registers */
        .equ   ICDIPTR,              0x800        /* interrupt processor targets registers */
        .equ   ICDICFR,              0xC00        /* interrupt configuration registers */
        
/* Undefined instructions */
SERVICE_UND:                                
        B   SERVICE_UND         
/* Software interrupts */
SERVICE_SVC:                                
        B   SERVICE_SVC         
/* Aborted data reads */
SERVICE_ABT_DATA:                           
        B   SERVICE_ABT_DATA    
/* Aborted instruction fetch */
SERVICE_ABT_INST:                           
        B   SERVICE_ABT_INST    
SERVICE_FIQ:                                
        B   SERVICE_FIQ   
		                                    

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .byte   0b00000000
			.end  