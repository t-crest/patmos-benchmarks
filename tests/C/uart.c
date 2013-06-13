
#include <machine/uart.h>


int main(int argc, char** argv) {

    uart_print("Hello ");
    uart_println("World!");

    uart_printd("Test -678: ", -678);
    uart_printdln(", test 12345: ", 12345);

    uart_print("Hex test: 0x");
    uart_hex(0x12345678ABCD1234, 0);

    uart_printh(" hex4: ", 0x1234678, 4);

    uart_printhln(" hex 0x123ABC: ", 0x123ABC, 8);

    return 0;
}
