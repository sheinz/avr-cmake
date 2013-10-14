#==============================================================================
# generate_avr_firmware(
#       name
#       [MCU avr_mcu_name]
#       [FCPU cpu_frequency]
#       [SRCS src1 src2 .. srcN]
#       [LIBS lib1 lib2 .. libN]
#   )
#==============================================================================
cmake_minimum_required(VERSION 2.8.5)
include(CMakeParseArguments)

macro(GENERATE_PARSE_ARGUMENTS ARGUMENTS)

    message(STATUS "Parsing arguments: ${ARGUMENTS}")

    cmake_parse_arguments(INPUT             # prefix
                          ""                # Options 
                          "MCU;FCPU"        # One value keywords 
                          "SRCS;LIBS"       # Multi Value Keywords
                          ${ARGUMENTS}           # Arguments to parse
                          )

    message(STATUS "MCU: ${INPUT_MCU}")
    message(STATUS "FCPU: ${INPUT_FCPU}")
    message(STATUS "SRCS: ${INPUT_SRCS}")
    message(STATUS "LIBS: ${INPUT_LIBS}")
    message(STATUS "Unexpected options: ${INPUT_UNPARSED_ARGUMENTS}")

    if(NOT INPUT_MCU)
        message(FATAL_ERROR "MCU not set")
    endif()

    if(NOT INPUT_FCPU)
        message(FATAL_ERROR "FCPU not set")
    endif()

    if(NOT INPUT_SRCS)
        message(FATAL_ERROR "SRCS not set")
    endif()

endmacro()

function(GENERATE_AVR_FIRMWARE INPUT_NAME)
    message(STATUS "Generating AVR firmware ${INPUT_NAME}")

    generate_parse_arguments("${ARGN}") 
    
    add_executable(${INPUT_NAME} ${INPUT_SRCS})

    if(INPUT_LIBS)
        message(STATUS "Linking libraries: ${INPUT_LIBS}")
        target_link_libraries(${INPUT_NAME} ${INPUT_LIBS})
    endif()

    set_target_properties(${INPUT_NAME} PROPERTIES
        COMPILE_FLAGS "-mmcu=${INPUT_MCU} -DF_CPU=${INPUT_FCPU}")

    setup_programmer(${INPUT_MCU})
endfunction()

function(GENERATE_AVR_LIBRARY INPUT_NAME)
    message(STATUS "Generating AVR library ${INPUT_NAME}")
      
    generate_parse_arguments("${ARGN}") 

    add_library(${INPUT_NAME} STATIC ${INPUT_SRCS})

    if(INPUT_LIBS)
        message(STATUS "Linking libraries: ${INPUT_LIBS}")
        target_link_libraries(${INPUT_NAME} ${INPUT_LIBS})
    endif()

    set_target_properties(${INPUT_NAME} PROPERTIES
        COMPILE_FLAGS "-mmcu=${INPUT_MCU} -DF_CPU=${INPUT_FCPU}")

endfunction()

function(SETUP_PROGRAMMER MCU_NAME)
    find_program(AVRDUDE avrdude)
    IF(${AVRDUDE-NOTFOUND})
            message(WARNING "'avrdude' program not found. 'upload' and 'info' targets will not be available!")
    ELSE(${AVRDUDE-NOTFOUND})

    SET(PROG_ID "usbtiny")
    SET(PROG_PART ${MCU_NAME})
    SET(HEXFORMAT "ihex")

    add_custom_target(upload
            ${AVRDUDE}
                    -c ${PROG_ID}
                    -p ${PROG_PART}
                    #-P ${PROGR_PORT} -e
                    -U flash:w:${PROJECT_NAME}.hex
            DEPENDS ${PROJECT_NAME}.hex ${PROJECT_NAME}.ee.hex
            VERBATIM)

    add_custom_target(info
            ${AVRDUDE} -v
                    -c ${PROG_ID}
                    -p ${PROG_PART}
                    #-P ${PROGR_PORT} -e
                    -U hfuse:r:high.txt:r -U lfuse:r:low.txt:r
            VERBATIM)

    add_custom_command(
            OUTPUT ${PROJECT_NAME}.hex
            COMMAND /usr/bin/${CMAKE_SYSTEM_NAME}-objcopy --strip-all -j .text -j .data -O ${HEXFORMAT} ${PROJECT_NAME} ${PROJECT_NAME}.hex
            DEPENDS ${PROJECT_NAME}
            VERBATIM
    )

    add_custom_command(
            OUTPUT ${PROJECT_NAME}.ee.hex
            COMMAND /usr/bin/${CMAKE_SYSTEM_NAME}-objcopy --strip-all -j .eeprom --change-section-lma .eeprom=0
                               -O ${HEXFORMAT} ${PROJECT_NAME} ${PROJECT_NAME}.ee.hex
            DEPENDS ${PROJECT_NAME}
            VERBATIM
    )

    ENDIF(${AVRDUDE-NOTFOUND})
endfunction()
