#include "xil_printf.h"
#include "stdint.h"

#define GPIO_ADDRESS 0x40000000
volatile uint32_t *pwd_ram = (uint32_t*)0xC0000000;

volatile uint8_t *cracker_cycle = (uint8_t*)GPIO_ADDRESS;
volatile uint8_t *cracker_start = ((uint8_t*)GPIO_ADDRESS)+8;

int main()
{
	*cracker_cycle = 0;

    // Loop over word addresses (each increment corresponds to 4 bytes)
    for(int i = 0; i < 2592; i++)
    {
        pwd_ram[i] = 0x11111111; // Write to the 32-bit word
        //xil_printf("VAL at word %d : %08x\r\n", i, pwd_ram[i]);
    }

    xil_printf("MEMORY WRITTEN\r\n");

    // Write to the start register, which should be at word address 2592
    pwd_ram[2592] = 0x00;
    xil_printf("Start Register Write VAL : %08x\r\n", pwd_ram[0]);

    // Clear start register
    *cracker_cycle = 1;
    xil_printf("Start Register VAL : %08x\r\n", pwd_ram[2592]);

    while(1)
    {
    }

    return 0;
}
