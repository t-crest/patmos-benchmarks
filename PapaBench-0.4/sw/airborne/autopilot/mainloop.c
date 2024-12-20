/*
 * $Id: mainloop.c,v 1.3 2008/10/22 19:41:18 casse Exp $
 *  
 * Copyright (C) 2003  Pascal Brisset, Antoine Drouin
 *
 * This file is part of paparazzi.
 *
 * paparazzi is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * paparazzi is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with paparazzi; see the file COPYING.  If not, write to
 * the Free Software Foundation, 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA. 
 *
 */
#include <avr/interrupt.h>
#include "std.h"

#include "timer.h"
#include "modem.h"
#include "adc.h"
#include "airframe.h"
#include "autopilot.h"
#include "spi.h"
#include "link_fbw.h"
#include "gps.h"
#include "nav.h"
#include "infrared.h"
#include "estimator.h"
#include "downlink.h"

#ifndef PAPABENCH_SINGLE
	void fbw_init(void);
	void fbw_schedule(void);
#endif

#ifdef EXTERNAL_AVR_MEM
EXTERNAL_AVR_MEM; /* Memory for AVR I/O for non-AVR platforms */
#endif

#ifdef PAPABENCH_TEST

extern bool_t low_battery;
int main( void )
{
  uint8_t init_cpt;

  /* init peripherals */
  timer_init();
  modem_init();
  adc_init();
#ifdef CTL_BRD_V1_1
  adc_buf_channel(ADC_CHANNEL_BAT, &buf_bat);
#endif
  spi_init();
  link_fbw_init();
  gps_init();
  nav_init();
  ir_init();
  estimator_init();
  int m1,m2;
  int b1,b2,b3;
  for(m1 = 0; m1 < 5; m1++)
    for(m2 = 0; m2 < 5; m2++) {
      pprz_mode = m1;
      vertical_mode = m2;
      altitude_control_task();
    }
  for(m1 = 0; m1 < 5; m1++)
    for(m2 = 0; m2 < 5; m2++)
      for(b1 = 0; b1 < 2; b1++)
        for(b2 = 0; b2 < 2; b2++)
          for(b3 = 0; b3 < 2; b3++) {
            pprz_mode = m1;
            vertical_mode = m2;
            low_battery = b1;
            estimator_flight_time = b2;
            launch = b3;
            climb_control_task();
          }
  for(m1 = 0; m1 < 3; m1++) {
    spi_cur_slave = m1;
    link_fbw_send();
  }
  for(m1 = 0; m1 < 5; m1++)
    for(m2 = 0; m2 < 5; m2++) {
      pprz_mode = m1;
      vertical_mode = m2;
      navigation_task();
    }

  /* subtasks:
  navigation_update();
  send_nav_values();
  course_run();
  */

  radio_control_task();
  receive_gps_data_task();
  reporting_task();
  stabilisation_task();

  return 0;
}

#else
int main( void ) 
{
  uint8_t init_cpt;

  /* init peripherals */
  timer_init(); 
  modem_init();
  adc_init();
#ifdef CTL_BRD_V1_1  
  adc_buf_channel(ADC_CHANNEL_BAT, &buf_bat);
#endif
  spi_init();
  link_fbw_init();
  gps_init();
  nav_init();
  ir_init();
  estimator_init();
#	ifdef PAPABENCH_SINGLE
		fbw_init();
#	endif

  /* start interrupt task */
  //sei(); /*Fadia*/

  /* Wait 0.5s (for modem init ?) */
  init_cpt = 30;
  while (init_cpt) {
    if (timer_periodic())
      init_cpt--;
  }

  /*  enter mainloop */
  while( 1 ) {
    if(timer_periodic()) {
      periodic_task();
#		if PAPABENCH_SINGLE
			fbw_schedule();
#		endif
    }
    if (gps_msg_received) 
    {
	/*receive_gps_data_task()*/
	parse_gps_msg();
	send_gps_pos();
        send_radIR();
        send_takeOff();
    }
    if (link_fbw_receive_complete) {
      link_fbw_receive_complete = FALSE;
      radio_control_task();
    }
  }
  return 0;
}
#endif
