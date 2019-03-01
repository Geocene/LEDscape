// //////////////////////////////////////////////////////////////////////////////////////////////////////
// WS281x Mapping for PRU1
// Overall Channels: 48
// PRU Channels: 24
// //////////////////////////////////////////////////////////////////////////////////////////////////////
#define PRU1
#include "common.p.h"
// Intialize the PRU
START:
// Enable OCP master port
// clear the STANDBY_INIT bit in the SYSCFG register,
// otherwise the PRU will not be able to write outside the
// PRU memory space and to the BeagleBone's pins.
LBCO r0, C4, 4, 4;
CLR r0, r0, 4;
SBCO r0, C4, 4, 4;
// Configure the programmable pointer register for PRU0 by setting
// c28_pointer[15:0] field to 0x0120.  This will make C28 point to
// 0x00012000 (PRU shared RAM).
MOV r0, 0x0120;
MOV r1, 0x022028;
ST32 r0, r1;
// Configure the programmable pointer register for PRU0 by setting
// c31_pointer[15:0] field to 0x0010.  This will make C31 point to
// 0x80001000 (DDR memory).
MOV r0, 0x100000;
MOV r1, 0x02202C;
ST32 r0, r1;
// Write a 0x1 into the response field so that they know we have started
MOV r2, 1;
SBCO r2, C24, 12, 4;
MOV r20, 0xFFFFFFFF;
RESET_COUNTER;
// Wait for the start condition from the main program to indicate
// that we have a rendered frame ready to clock out.  This also
// handles the exit case if an invalid value is written to the start
// start position.

main_loop:
SLEEPNS 0x1B58, 0, frame_break;
// Let ledscape know that we're starting the loop again. It waits for this
// interrupt before sending another frame
RAISE_ARM_INTERRUPT;
// Load the pointer to the buffer from PRU DRAM into r0 and the
// length (in bytes-bit words) into r1.
// start command into r2
LBCO r0, C24, 0, 12;
// Wait for a non-zero command
QBEQ main_loop, r2, 0;
// Zero out the start command so that they know we have received it
// This allows maximum speed frame drawing since they know that they
// can now swap the frame buffer pointer and write a new start command.
MOV r3, 0;
SBCO r3, C24, 8, 4;
// Command of 0xFF is the signal to exit
QBEQ EXIT, r2, 255;
// Reset the sleep timer
RESET_COUNTER;

  l_word_loop:
  // Load the data address from the constant table
  LBCO r3, C24, 0, 4;
  // Load 24 channels of data into data registers
  LBBO r5, r3, 96, 96; // store 96 bytes into r3 + 96 from registers starting at r5
  // Loop over the 24 bits in a word
  MOV r2.b0, 24;

    l_bit_loop:
    DECREMENT r2.b0; // r2.b0 --
    WAITNS 0x044C, interbit_wait;
    RESET_COUNTER;
    MOV r4, 0;
    MOV r0, 0;
    MOV r29, 0;
    MOV r30, 0;
    //  Pins HIGH: 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
      // Bank 0
        // Prep GPIO address register for SET on GPIO bank 0
        MOV r3, 0x44E07194;
        // Set the GPIO (bank 0) mask register for setting or clearing channels 24, 26, 27, 29, 32, 33, 40, 45, 47
        MOV r4, 0xC8D08480;
        // Apply GPIO bank 0 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
      // Bank 1
        // Prep GPIO address register for SET on GPIO bank 1
        MOV r3, 0x4804C194;
        // Set the GPIO (bank 1) mask register for setting or clearing channels 28, 41, 42, 43, 44, 46
        MOV r4, 0x100F8000;
        // Apply GPIO bank 1 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
      // Bank 2
        // Prep GPIO address register for SET on GPIO bank 2
        MOV r3, 0x481AC194;
        // Set the GPIO (bank 2) mask register for setting or clearing channels 25, 30, 31
        MOV r4, 0x800024;
        // Apply GPIO bank 2 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
      // Bank 3
        // Prep GPIO address register for SET on GPIO bank 3
        MOV r3, 0x481AE194;
        // Set the GPIO (bank 3) mask register for setting or clearing channels 34, 35, 36, 37, 38, 39
        MOV r4, 0x2BC000;
        // Apply GPIO bank 3 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
    // Bank 0
      // Test if pin (pruDataChannel=0, global=24) is ZERO and SET bit 10 in GPIO0 register
      QBBS channel_0_zero_skip, r5, r2.b0; // if (r5 & (1 << r2.b0) != 0) goto channel_0_zero_skip
      SET r4, r4, 10;
      channel_0_zero_skip:
      // Test if pin (pruDataChannel=2, global=26) is ZERO and SET bit 22 in GPIO0 register
      QBBS channel_2_zero_skip, r7, r2.b0; // if (r7 & (1 << r2.b0) != 0) goto channel_2_zero_skip
      SET r4, r4, 22;
      channel_2_zero_skip:
      // Test if pin (pruDataChannel=3, global=27) is ZERO and SET bit 27 in GPIO0 register
      QBBS channel_3_zero_skip, r8, r2.b0; // if (r8 & (1 << r2.b0) != 0) goto channel_3_zero_skip
      SET r4, r4, 27;
      channel_3_zero_skip:
      // Test if pin (pruDataChannel=5, global=29) is ZERO and SET bit 23 in GPIO0 register
      QBBS channel_5_zero_skip, r10, r2.b0; // if (r10 & (1 << r2.b0) != 0) goto channel_5_zero_skip
      SET r4, r4, 23;
      channel_5_zero_skip:
      // Test if pin (pruDataChannel=8, global=32) is ZERO and SET bit 7 in GPIO0 register
      QBBS channel_8_zero_skip, r13, r2.b0; // if (r13 & (1 << r2.b0) != 0) goto channel_8_zero_skip
      SET r4, r4, 7;
      channel_8_zero_skip:
      // Test if pin (pruDataChannel=9, global=33) is ZERO and SET bit 20 in GPIO0 register
      QBBS channel_9_zero_skip, r14, r2.b0; // if (r14 & (1 << r2.b0) != 0) goto channel_9_zero_skip
      SET r4, r4, 20;
      channel_9_zero_skip:
      // Test if pin (pruDataChannel=16, global=40) is ZERO and SET bit 15 in GPIO0 register
      QBBS channel_16_zero_skip, r21, r2.b0; // if (r21 & (1 << r2.b0) != 0) goto channel_16_zero_skip
      SET r4, r4, 15;
      channel_16_zero_skip:
      // Test if pin (pruDataChannel=21, global=45) is ZERO and SET bit 31 in GPIO0 register
      QBBS channel_21_zero_skip, r26, r2.b0; // if (r26 & (1 << r2.b0) != 0) goto channel_21_zero_skip
      SET r4, r4, 31;
      channel_21_zero_skip:
      // Test if pin (pruDataChannel=23, global=47) is ZERO and SET bit 30 in GPIO0 register
      QBBS channel_23_zero_skip, r28, r2.b0; // if (r28 & (1 << r2.b0) != 0) goto channel_23_zero_skip
      SET r4, r4, 30;
      channel_23_zero_skip:
    // Bank 1
      // Test if pin (pruDataChannel=4, global=28) is ZERO and SET bit 15 in GPIO1 register
      QBBS channel_4_zero_skip, r9, r2.b0; // if (r9 & (1 << r2.b0) != 0) goto channel_4_zero_skip
      SET r0, r0, 15;
      channel_4_zero_skip:
      // Test if pin (pruDataChannel=17, global=41) is ZERO and SET bit 17 in GPIO1 register
      QBBS channel_17_zero_skip, r22, r2.b0; // if (r22 & (1 << r2.b0) != 0) goto channel_17_zero_skip
      SET r0, r0, 17;
      channel_17_zero_skip:
      // Test if pin (pruDataChannel=18, global=42) is ZERO and SET bit 19 in GPIO1 register
      QBBS channel_18_zero_skip, r23, r2.b0; // if (r23 & (1 << r2.b0) != 0) goto channel_18_zero_skip
      SET r0, r0, 19;
      channel_18_zero_skip:
      // Test if pin (pruDataChannel=19, global=43) is ZERO and SET bit 16 in GPIO1 register
      QBBS channel_19_zero_skip, r24, r2.b0; // if (r24 & (1 << r2.b0) != 0) goto channel_19_zero_skip
      SET r0, r0, 16;
      channel_19_zero_skip:
      // Test if pin (pruDataChannel=20, global=44) is ZERO and SET bit 18 in GPIO1 register
      QBBS channel_20_zero_skip, r25, r2.b0; // if (r25 & (1 << r2.b0) != 0) goto channel_20_zero_skip
      SET r0, r0, 18;
      channel_20_zero_skip:
      // Test if pin (pruDataChannel=22, global=46) is ZERO and SET bit 28 in GPIO1 register
      QBBS channel_22_zero_skip, r27, r2.b0; // if (r27 & (1 << r2.b0) != 0) goto channel_22_zero_skip
      SET r0, r0, 28;
      channel_22_zero_skip:
    // Bank 2
      // Test if pin (pruDataChannel=1, global=25) is ZERO and SET bit 23 in GPIO2 register
      QBBS channel_1_zero_skip, r6, r2.b0; // if (r6 & (1 << r2.b0) != 0) goto channel_1_zero_skip
      SET r29, r29, 23;
      channel_1_zero_skip:
      // Test if pin (pruDataChannel=6, global=30) is ZERO and SET bit 5 in GPIO2 register
      QBBS channel_6_zero_skip, r11, r2.b0; // if (r11 & (1 << r2.b0) != 0) goto channel_6_zero_skip
      SET r29, r29, 5;
      channel_6_zero_skip:
      // Test if pin (pruDataChannel=7, global=31) is ZERO and SET bit 2 in GPIO2 register
      QBBS channel_7_zero_skip, r12, r2.b0; // if (r12 & (1 << r2.b0) != 0) goto channel_7_zero_skip
      SET r29, r29, 2;
      channel_7_zero_skip:
    // Bank 3
      // Test if pin (pruDataChannel=10, global=34) is ZERO and SET bit 14 in GPIO3 register
      QBBS channel_10_zero_skip, r15, r2.b0; // if (r15 & (1 << r2.b0) != 0) goto channel_10_zero_skip
      SET r30, r30, 14;
      channel_10_zero_skip:
      // Test if pin (pruDataChannel=11, global=35) is ZERO and SET bit 16 in GPIO3 register
      QBBS channel_11_zero_skip, r16, r2.b0; // if (r16 & (1 << r2.b0) != 0) goto channel_11_zero_skip
      SET r30, r30, 16;
      channel_11_zero_skip:
      // Test if pin (pruDataChannel=12, global=36) is ZERO and SET bit 15 in GPIO3 register
      QBBS channel_12_zero_skip, r17, r2.b0; // if (r17 & (1 << r2.b0) != 0) goto channel_12_zero_skip
      SET r30, r30, 15;
      channel_12_zero_skip:
      // Test if pin (pruDataChannel=13, global=37) is ZERO and SET bit 17 in GPIO3 register
      QBBS channel_13_zero_skip, r18, r2.b0; // if (r18 & (1 << r2.b0) != 0) goto channel_13_zero_skip
      SET r30, r30, 17;
      channel_13_zero_skip:
      // Test if pin (pruDataChannel=14, global=38) is ZERO and SET bit 19 in GPIO3 register
      QBBS channel_14_zero_skip, r19, r2.b0; // if (r19 & (1 << r2.b0) != 0) goto channel_14_zero_skip
      SET r30, r30, 19;
      channel_14_zero_skip:
      // Test if pin (pruDataChannel=15, global=39) is ZERO and SET bit 21 in GPIO3 register
      QBBS channel_15_zero_skip, r20, r2.b0; // if (r20 & (1 << r2.b0) != 0) goto channel_15_zero_skip
      SET r30, r30, 21;
      channel_15_zero_skip:
    WAITNS 200, zero_bits_wait;
    // Bank 0
      // Prep GPIO address register for CLEAR on GPIO bank 0
      MOV r3, 0x44E07190;
      // Apply GPIO bank 0 changes
      SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
    // Bank 1
      // Prep GPIO address register for CLEAR on GPIO bank 1
      MOV r3, 0x4804C190;
      // Apply GPIO bank 1 changes
      SBBO r0, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r0
    // Bank 2
      // Prep GPIO address register for CLEAR on GPIO bank 2
      MOV r3, 0x481AC190;
      // Apply GPIO bank 2 changes
      SBBO r29, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r29
    // Bank 3
      // Prep GPIO address register for CLEAR on GPIO bank 3
      MOV r3, 0x481AE190;
      // Apply GPIO bank 3 changes
      SBBO r30, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r30
    WAITNS 0x02BC, one_bits_wait;
    //  Pins LOW: 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47
      // Bank 0
        // Prep GPIO address register for CLEAR on GPIO bank 0
        MOV r3, 0x44E07190;
        // Set the GPIO (bank 0) mask register for setting or clearing channels 24, 26, 27, 29, 32, 33, 40, 45, 47
        MOV r4, 0xC8D08480;
        // Apply GPIO bank 0 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
      // Bank 1
        // Prep GPIO address register for CLEAR on GPIO bank 1
        MOV r3, 0x4804C190;
        // Set the GPIO (bank 1) mask register for setting or clearing channels 28, 41, 42, 43, 44, 46
        MOV r4, 0x100F8000;
        // Apply GPIO bank 1 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
      // Bank 2
        // Prep GPIO address register for CLEAR on GPIO bank 2
        MOV r3, 0x481AC190;
        // Set the GPIO (bank 2) mask register for setting or clearing channels 25, 30, 31
        MOV r4, 0x800024;
        // Apply GPIO bank 2 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
      // Bank 3
        // Prep GPIO address register for CLEAR on GPIO bank 3
        MOV r3, 0x481AE190;
        // Set the GPIO (bank 3) mask register for setting or clearing channels 34, 35, 36, 37, 38, 39
        MOV r4, 0x2BC000;
        // Apply GPIO bank 3 changes
        SBBO r4, r3, 0, 4; // copy 4 bytes from r3 + 0 into registers starting at r4
    QBNE l_bit_loop, r2.b0, 0;
  ADD r0, r0, 192; // r0 = r0 + 192
  DECREMENT r1; // r1 --
  QBNE l_word_loop, r1, 0;
MOV r8, 0x024000;
LBBO r2, r8, 12, 4; // store 4 bytes into r8 + 12 from registers starting at r2
SBCO r2, C24, 12, 4;
RESET_COUNTER;
QBA main_loop;

EXIT:
MOV r2, 255;
SBCO r2, C24, 12, 4;
RAISE_ARM_INTERRUPT;
HALT;