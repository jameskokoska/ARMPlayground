				.section .vectors, "ax"

				B 	_start						// reset vector
				B 	SERVICE_UND								// undefined instruction vector
				B 	SERVICE_SVC								// software interrrupt vector
				B	SERVICE_ABT_INST								// aborted prefetch vector
				B 	SERVICE_ABT_DATA								// aborted data vector
				B 	0								// unused vector
				B	IRQ_HANDLER					// IRQ interrupt vector
				B	SERVICE_FIQ 								// FIQ interrupt vector

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly language code. 
 * The program responds to interrupts from the pushbutton KEY port in the FPGA.
 ********************************************************************************/
            	.text
				.global	_start
_start:		
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #0b11010010		// interrupts masked, MODE = IRQ
				MSR		CPSR_c, R1			// change to IRQ mode
				LDR		SP, =0x20000        // set IRQ stack pointer
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b11010011		// interrupts masked, MODE = SVC
				MSR		CPSR, R1			// change to supervisor mode
				LDR		SP, =0x40000		// set SVC stack 

				BL		CONFIG_GIC			// configure the ARM generic interrupt controller

				// write to the pushbutton KEY interrupt mask register
				LDR		R0, =0xFF200050		// pushbutton KEY base address
				MOV		R1, #0xF			// set interrupt mask bits
				STR		R1, [R0, #0x8]		// interrupt mask register is (base + 8)

				// enable IRQ interrupts in the processor
				MOV		R0, #0b01010011		// IRQ unmasked, MODE = SVC
				MSR		CPSR, R0
MAIN_LOOP:
				B 		MAIN_LOOP			// main program simply repeats the loop

				.text
IRQ_HANDLER:
    			PUSH	{R0-R5, LR}
    
    			/* Read the ICCIAR from the CPU interface */
    			LDR		R4, =0xFFFEC100
    			LDR		R5, [R4, #0xC]		// read from ICCIAR

CHECK_KEYS: 	CMP		R5, #73
UNEXPECTED:		BNE		UNEXPECTED    		// if not recognized, stop here
    
    			BL		KEY_ISR				// pass R0 as a parameter to KEY_ISR
EXIT_IRQ:
    			/* Write to the End of Interrupt Register (ICCEOIR) */
    			STR		R5, [R4, #0x10]     // write to ICCEOIR
    
    			POP		{R0-R5, LR}
    			SUBS	PC, LR, #4			//return

				.global	KEY_ISR





KEY_ISR:		PUSH {R0-R12, LR}
				MOV R0, #0          //R0 use as counter storage
				//  R1	bit corresponce 
				//	R2	currently displayed on hex value
				//  R3	hex offset (factor of 8 bits)
				//  R4
				//  R5
				LDR R6, =0xFF200050 //store KEY address in R6
				//  R7              //used to hold the key value
				LDR R8, =0xFF200020 //store HEX 3-0 address in R8
				LDR R9, =BIT_CODES
				//	R10 bits of current hex
				//	R12 used to clear interrupt reg
	
				LDR R7, [R6, #0xC]  //Load the key value into R7 [Key0:0x01, Key1:0x02, Key2:0x04, Key3:0x08] from edge capture
				
				CMP R7, #0x01       //If R7 (key value) is key0
				MOVEQ R0, #0
				MOVEQ R3, #0		//Hex offset
				BEQ HEX             //Branch to what key does

				CMP R7, #0x02       //If R7 (key value) is key1
				MOVEQ R0, #1
				MOVEQ R3, #8		//Hex offset
				BEQ HEX             //Branch to what key does

				CMP R7, #0x04       //If R7 (key value) is key2
				MOVEQ R0, #2
				MOVEQ R3, #16		//Hex offset
				BEQ HEX             //Branch to what key does

				CMP R7, #0x08       //If R7 (key value) is key3
				MOVEQ R0, #3
				MOVEQ R3, #24
				BEQ HEX             //Branch to what key does

				//Fix bug when all keys pressed r7 goes to ffffffff
				LDR R4, =0xfffffff0
				SUB R7, R4

				CMP R7, #0x01       //If R7 (key value) is key0
				MOVEQ R0, #0
				MOVEQ R3, #0		//Hex offset
				BEQ HEX             //Branch to what key does

				CMP R7, #0x02       //If R7 (key value) is key1
				MOVEQ R0, #1
				MOVEQ R3, #8		//Hex offset
				BEQ HEX             //Branch to what key does

				CMP R7, #0x04       //If R7 (key value) is key2
				MOVEQ R0, #2
				MOVEQ R3, #16		//Hex offset
				BEQ HEX             //Branch to what key does

				CMP R7, #0x08       //If R7 (key value) is key3
				MOVEQ R0, #3
				MOVEQ R3, #24
				BEQ HEX             //Branch to what key does

//Write to the hex using bit code conversion, using R5 as storage, R0 (counter) offset address for R9 bit codes
HEX:
			LDRB R2, [R8, R0]   //Load what is currently displayed
            LDRB R1, [R9, R0]	//Load bit code correspondence

			LSL R1, R3			//Shift bits corresponding to which HEX displayed, hex offset

			//Determine if HEX is on or off
			LDR R10, [R8]
			CMP R2, #0
			ORREQ R10, R1		//hex off, write new number by or ing the bit code and current displayed
			SUBNE R10, R1		//hex on, remove it from display
			
			STR R10, [R8]        //Store R5 into R8 (HEX address)
			


			
RETURN:		MOV	R12, #0xF
			STR	R12, [R6, #0xC]		// clear the interrupt

			POP	{R0-R12,PC}				// return


//Values for corresponding HEX lights
BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment








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
				STRB		R1, [R4]
    
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
			.equ	JP1_IRQ,							83
			.equ	JP2_IRQ,							84
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
			.equ	MPCORE_WATCHDOG_IRQ,			30

/* HPS devices (there are many; only a few are defined below) */
			.equ	HPS_UART0_IRQ,   				194
			.equ	HPS_UART1_IRQ,   				195
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
			.equ		CPU0,         				0x01	// bit-mask; bit 0 represents cpu0
			.equ		ENABLE, 						0x1

			.equ		KEY0, 						0b0001
			.equ		KEY1, 						0b0010
			.equ		KEY2,							0b0100
			.equ		KEY3,							0b1000

			.equ		RIGHT,						1
			.equ		LEFT,							2

			.equ		USER_MODE,					0b10000
			.equ		FIQ_MODE,					0b10001
			.equ		IRQ_MODE,					0b10010
			.equ		SVC_MODE,					0b10011
			.equ		ABORT_MODE,					0b10111
			.equ		UNDEF_MODE,					0b11011
			.equ		SYS_MODE,					0b11111

			.equ		INT_ENABLE,					0b01000000
			.equ		INT_DISABLE,				0b11000000

/* Memory */
        .equ  DDR_BASE,	            0x00000000
        .equ  DDR_END,              0x3FFFFFFF
        .equ  A9_ONCHIP_BASE,	      0xFFFF0000
        .equ  A9_ONCHIP_END,        0xFFFFFFFF
        .equ  SDRAM_BASE,    	      0xC0000000
        .equ  SDRAM_END,            0xC3FFFFFF
        .equ  FPGA_ONCHIP_BASE,	   0xC8000000
        .equ  FPGA_ONCHIP_END,      0xC803FFFF
        .equ  FPGA_CHAR_BASE,   	   0xC9000000
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
		.end