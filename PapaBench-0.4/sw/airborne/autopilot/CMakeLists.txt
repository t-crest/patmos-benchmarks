include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/sw/include)
include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/avr/include)
include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/sw/var/include)
include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/sw/airborne/autopilot)
include_directories(${CMAKE_SOURCE_DIR}/PapaBench-0.4/sw/airborne/fly_by_wire)

add_definitions(-DUBX -D__AVR_ATmega128__ -DSTACK=\"0x80000000\" -DPAPABENCH_TEST -DNO_AVR_PLATFORM -DUNROLL_FP_LOOPS)

add_executable(autopilot main.c modem.c link_fbw.c spi.c adc.c infrared.c pid.c
                         nav.c uart.c estimator.c if_calib.c mainloop.c
                         gps_ubx.c
                         ${CMAKE_SOURCE_DIR}/PapaBench-0.4//sw/lib/c/math.c)
