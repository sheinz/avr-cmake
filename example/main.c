#include <inttypes.h>

#include <avr/io.h>
#include "test_lib.h"

int main(void)
{
    DDRB |= _BV(PB0);

    PORTB |= _BV(PB0);

    while (1)
    {
        test_func();
    }

	return 0;
}

