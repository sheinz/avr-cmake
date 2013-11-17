#include <inttypes.h>

#include <avr/io.h>
#include "test_lib.h"

FUSES =
{
   .low = (FUSE_SUT0 & FUSE_CKSEL3 & FUSE_CKSEL1 & FUSE_CKSEL0),
   .high = (FUSE_WDTON & FUSE_SPIEN & FUSE_CKOPT & FUSE_BOOTSZ1 & FUSE_BOOTSZ0),
};

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

