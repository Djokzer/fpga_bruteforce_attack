#include "xil_printf.h"
#include "stdint.h"

#define PWD_COUNT 4
#define PWD_WORD_SIZE 18
#define PWD_RAM_SIZE PWD_COUNT * PWD_WORD_SIZE
#define HASH_WORD_SIZE 6 // 6 => 24 Bytes, but a hash is 23 Bytes !!
#define SALT_WORD_SIZE 4

#define GPIO_ADDRESS 0x40000000
#define ULTRARAM_ADDRESS 0xC0000000

volatile uint32_t *pwd_ram 		= (uint32_t*)ULTRARAM_ADDRESS;
volatile uint32_t *hash_ram 	= (uint32_t*)ULTRARAM_ADDRESS + PWD_RAM_SIZE;
volatile uint32_t *salt_ram 	= (uint32_t*)ULTRARAM_ADDRESS + PWD_RAM_SIZE + HASH_WORD_SIZE;
volatile uint32_t *start_attack = (uint32_t*)ULTRARAM_ADDRESS + PWD_RAM_SIZE + HASH_WORD_SIZE + SALT_WORD_SIZE;

int main()
{
	// DATA TO STORE
	uint32_t pwd[PWD_COUNT] = {0x61006100, 0x62006200, 0x63006300, 0x64006400};
	uint32_t hash[HASH_WORD_SIZE] = {0x1982ade7, 0x12f9ec3d, 0x3a57ce85, 0xadf7fc3e, 0x2b43d7d8, 0x9f90d3};
	uint32_t salt[SALT_WORD_SIZE] = {0x7e949a07, 0xe88186c6, 0x49bbeb0a, 0x9740c5e0};


    // Write Passwords (each increment corresponds to 4 bytes)
    for(int i = 0; i < PWD_COUNT; i++)
    {
    	for(int j = 0; j < PWD_WORD_SIZE; j++)
    	{
            pwd_ram[i * PWD_WORD_SIZE + j] = pwd[i]; // Write to the 32-bit word
            //xil_printf("VAL at word %d : %08x\r\n", i, pwd_ram[i]);
    	}
    }

    // Write Hash to break
    for(int i = 0; i < HASH_WORD_SIZE; i++)
    {
    	hash_ram[i] = hash[i];
    }

    // Write Salt
    for(int i = 0; i < SALT_WORD_SIZE; i++)
    {
    	salt_ram[i] = salt[i];
    }

    xil_printf("MEMORY WRITTEN\r\n");

    // Write to the start register, to yield memory to the cracker
    *start_attack = 0;
    xil_printf("Start Register Write VAL : %08x\r\n", *start_attack);

    while(*start_attack != 0);
    xil_printf("CRACKER FETCHED THE PASSWORDS\r\n");


    while(1)
    {
    }

    return 0;
}
