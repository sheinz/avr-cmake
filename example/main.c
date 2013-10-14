#include <inttypes.h>

#include <avr/io.h>


int main(void)
{
    DDRB |= _BV(PB0);

    PORTB |= _BV(PB0);

    while (1)
    {
    }

	return 0;
}

