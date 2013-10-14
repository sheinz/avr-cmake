

generate_avr_firmware(example
                      SRCS main.c
                      MCU atmega8
                      FCPU 16000000UL 
                      LIBS test_lib
                      )

generate_avr_library(test_lib
                     SRCS test_lib.c
                     MCU atmega8
                     FCPU 16000000UL
                     )
