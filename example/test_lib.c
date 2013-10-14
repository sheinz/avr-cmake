#include <avr/io.h>

void test_func(void)
{
    PORTB &= ~_BV(PB0);
}
