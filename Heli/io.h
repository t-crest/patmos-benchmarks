/**************** io.h **************/
typedef unsigned char uint8_t;

#define _SFR_BASE 0xF0000
#define _SFR_MEM8(mem_addr) (*(volatile uint8_t *)(mem_addr + _SFR_BASE))

#define ADCH _SFR_MEM8(0x05)
#define ADCSR _SFR_MEM8(0x06)
#define ADMUX _SFR_MEM8(0x07)
#define PIND _SFR_MEM8(0x10)
#define PORTD _SFR_MEM8(0x12)
#define PORTC _SFR_MEM8(0x15)
#define WDTCR _SFR_MEM8(0x31)


#define PIN0 0x1
#define PIN1 0x2
#define PIN2 0x4
#define PIN3 0x8
#define PIN4 0x10
#define PIN5 0x20
#define PIN6 0x40
#define PIN7 0x80
