#include <stdint.h>

#define UART_TX (volatile uint32_t *)0x10000000
#define UART_LSR (volatile uint8_t *)(0x10000000 + 0x0005)

void putchar(char c) {
  while ((*((volatile uint8_t *)UART_LSR) & 0x60) == 0)
    ;
  *((volatile uint32_t *)UART_TX) = c == 13 ? 10 : c;
}

void print_str(char *p) {
  while (*p != 0) {
    while ((*((volatile uint8_t *)UART_LSR) & 0x60) == 0)
      ;
    putchar(*(p++));
  }
}

void start(void) {
    print_str("Hello World\n");
    print_str("Hello World\n");
    print_str("Hello World\n");
}
