include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/sw/include)
include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/avr/include/)
include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/sw/var/include)

add_definitions(-D__AVR_ATmega8__ -DSTACK=\"0x80000000\")

add_executable(fly_by_wire main.c ppm.c servo.c spi.c uart.c adc_fbw.c)
