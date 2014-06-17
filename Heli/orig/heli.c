// helico.c 
// this code is inspired from: http://people.ece.cornell.edu/land/courses/ece4760/FinalProjects/s2006/rg242/webpage/ece%20476.htm

#include "io.h"
 
// define sensor channels
#define GYRO_CHANNEL 0 
#define AROMX_CHANNEL 1
#define AROMY_CHANNEL 2
#define AROMZ_CHANNEL 3 
char currentChannel = GYRO_CHANNEL;    

// define Helicopter states
#define GROUND 0
#define LANDING 1
#define TAKEOFF 2 
#define HOVER 3
char heliState = GROUND;

// define flight phases
#define TAKEOFF_START 5
#define HOVER_START 23
#define LANDING_START 299
#define LANDING_END 400
#define GROUNDED_START 410

// define motor speeds
#define MINIMUM_PWM_VALUE 0      
#define MAXIMUM_ROTOR_PWM_VALUE (100<<8)    
#define MARKS_PER_SEC 1600 
int pwm_ticks = 0;          
int marks = 0;
int sec = 0;

#define MAX_TAKEOFF_MOTOR_SPEED (95<<8)
#define TAKEOFF_ROTOR_SPEED_INCR 16
#define ROTOR_SPEED_INCR 8
#define HOVER_ROTOR_SPEED_INCR_HIGH 2
#define HOVER_ROTOR_SPEED_INCR_LOW 5
#define MAX_STAB_MOTOR_SPEED (60<<8)
#define MIN_STAB_MOTOR_SPEED 0
#define STAB_SPEED_INCR 256
#define MIN_LANDING_ROTOR_SPEED (50<<8)
#define LANDING_ROTOR_SPEED_INCR 1

int topRotorSpeed = 0;
int bottomRotorSpeed = 0;
int stabMotorSpeed1 = 0;
int stabMotorSpeed2 = 0;
int stabMotorSpeed3 = 0;

// ADC 
char data_in;
#define ADMUX_GYRO 0b01100000
#define ADMUX_AROMX 0b01100001
#define ADMUX_AROMY 0b01100010
#define ADMUX_AROMZ 0b01100011

// Sensors
uint8_t gyroCalibrateThresholdLow;  
uint8_t gyroCalibrateThresholdHigh;  
uint8_t aromXCalibrateThresholdLow;  
uint8_t aromXCalibrateThresholdHigh;  
uint8_t aromYCalibrateThresholdLow;  
uint8_t aromYCalibrateThresholdHigh;  
uint8_t aromZCalibrateThresholdLow;  
uint8_t aromZCalibrateThresholdHigh; 
uint8_t gyro[32]; 
uint8_t aromX[128];
uint8_t aromY[128];
uint8_t aromZ[128];
 

void updatePWM(void);  
void processSensorData(void);
void runFlightPlan(void);
void calibrateGyro(void); 
void calibrateArom(void);
uint8_t fixFilter(uint8_t *f, int size);
void addSample(uint8_t *f, int size, uint8_t value);


void timer_interrupt(void){
  pwm_ticks++;
  marks++;
  if (marks == MARKS_PER_SEC){
    sec++;
    marks = 0;
  } 
  updatePWM();
}

void updatePWM(void){
  char command = 0;
  int ticks = pwm_ticks << 8;
  // generate PWM command for the 5 motors
  if (ticks <= topRotorSpeed) 
    command |=  PIN0;
  if (ticks <= bottomRotorSpeed) 
    command |= PIN1;
  if (ticks <= stabMotorSpeed1)
    command |= PIN2;
  if (ticks <= stabMotorSpeed2) 
    command |= PIN3;
  if (ticks <= stabMotorSpeed3) 
    command |= PIN4;
  PORTC = command;    
  if (ticks == MAXIMUM_ROTOR_PWM_VALUE)
    pwm_ticks = 0;                
}


int main(void){ 

  // wait for button press on 1
  while ( (PIND & PIN1) != 0) ;
    
  calibrateGyro();
  calibrateArom();
    
  // start 
  topRotorSpeed = 0;
  bottomRotorSpeed = 0;
  stabMotorSpeed1 = 0;
  stabMotorSpeed2 = 0;
  stabMotorSpeed3 = 0;
    
  sec = 0;
  while (1) {          
    if ( (ADCSR & PIN6) == 0) // end of ADC conversion
      processSensorData();  
    runFlightPlan();
  }
}  

void runFlightPlan(void){
  // take off
  if (sec <= TAKEOFF_START){
    heliState = TAKEOFF;
    topRotorSpeed += TAKEOFF_ROTOR_SPEED_INCR;
    if (topRotorSpeed > MAX_TAKEOFF_MOTOR_SPEED) 
      topRotorSpeed = MAX_TAKEOFF_MOTOR_SPEED;
    bottomRotorSpeed += TAKEOFF_ROTOR_SPEED_INCR; 
    if (bottomRotorSpeed > MAX_TAKEOFF_MOTOR_SPEED) 
      bottomRotorSpeed = MAX_TAKEOFF_MOTOR_SPEED;    
  }     
         
  // hover
  if (sec == HOVER_START) 
    heliState = HOVER;       
         
  // landing         
  if (sec == LANDING_START){
    heliState = LANDING;
    stabMotorSpeed1 = 0;
    stabMotorSpeed2 = 0;
    stabMotorSpeed3 = 0;
  } 
              
  if ( (sec > LANDING_START) && (sec <= LANDING_END) ){
    topRotorSpeed -= LANDING_ROTOR_SPEED_INCR;
    if (topRotorSpeed < MIN_LANDING_ROTOR_SPEED)
      topRotorSpeed = MIN_LANDING_ROTOR_SPEED;
    bottomRotorSpeed -= LANDING_ROTOR_SPEED_INCR;
    if (bottomRotorSpeed < MIN_LANDING_ROTOR_SPEED)
      bottomRotorSpeed = MIN_LANDING_ROTOR_SPEED;
  }   
         
  // grounded
  if(sec >= GROUNDED_START){
    heliState = GROUND;
    WDTCR = 0x08;   //enable watchdog
    while (1) ;     //just wait for watchdog to reset machine 
  }            
}

void processSensorData(void){
  char filtered_data;
  char data_in_last;

  data_in_last = data_in;  
  data_in =  ADCH;

  switch (currentChannel) {

  case GYRO_CHANNEL:  
    // start conversion for next channel
    currentChannel = AROMX_CHANNEL;
    ADMUX = ADMUX_AROMX;
    ADCSR = ADCSR | PIN6;  

    addSample(gyro, 5, data_in);
    filtered_data = fixFilter(gyro,5);
    	                               
    if (filtered_data < gyroCalibrateThresholdLow) {
      topRotorSpeed += ROTOR_SPEED_INCR;;
      if (topRotorSpeed > MAXIMUM_ROTOR_PWM_VALUE) 
	topRotorSpeed = MAXIMUM_ROTOR_PWM_VALUE; 
      bottomRotorSpeed -= ROTOR_SPEED_INCR;
      if (bottomRotorSpeed < MINIMUM_PWM_VALUE) 
	bottomRotorSpeed = MINIMUM_PWM_VALUE;
    } 
    else 
      if (filtered_data > gyroCalibrateThresholdHigh) {
	topRotorSpeed -= ROTOR_SPEED_INCR;
	if (topRotorSpeed < MINIMUM_PWM_VALUE) 
	  topRotorSpeed = MINIMUM_PWM_VALUE;
	bottomRotorSpeed += ROTOR_SPEED_INCR;
	if (bottomRotorSpeed > MAXIMUM_ROTOR_PWM_VALUE)
	  bottomRotorSpeed = MAXIMUM_ROTOR_PWM_VALUE;
      } 
    break;
          
 
  case AROMX_CHANNEL:  
    // start conversion for next channel
    currentChannel = AROMY_CHANNEL;
    ADMUX = ADMUX_AROMY; 
    ADCSR |= PIN6;

    if (heliState == HOVER) {

      addSample(aromX,7,data_in);
      filtered_data = fixFilter(aromX,7); 
	                               
      if (filtered_data < aromXCalibrateThresholdLow) {
	stabMotorSpeed1 -= STAB_SPEED_INCR*2;
	if (stabMotorSpeed1 < MIN_STAB_MOTOR_SPEED)
	  stabMotorSpeed1 = MIN_STAB_MOTOR_SPEED; 
	stabMotorSpeed2 += STAB_SPEED_INCR*2;
	if (stabMotorSpeed2 > MAX_STAB_MOTOR_SPEED)
	  stabMotorSpeed2 = MAX_STAB_MOTOR_SPEED; 
	stabMotorSpeed3 += STAB_SPEED_INCR*2;
	if (stabMotorSpeed3 > MAX_STAB_MOTOR_SPEED)
	  stabMotorSpeed3 = MAX_STAB_MOTOR_SPEED; 
      } 
      else 
	if (filtered_data > aromXCalibrateThresholdHigh) {
	  stabMotorSpeed1 += STAB_SPEED_INCR*2;
	  if (stabMotorSpeed1 > MAX_STAB_MOTOR_SPEED)
	    stabMotorSpeed1 = MAX_STAB_MOTOR_SPEED;
	  stabMotorSpeed2 -= STAB_SPEED_INCR*2;
	  if (stabMotorSpeed2 < MIN_STAB_MOTOR_SPEED)
	    stabMotorSpeed2 = MIN_STAB_MOTOR_SPEED; 
	  stabMotorSpeed3 -= STAB_SPEED_INCR*2;
	  if (stabMotorSpeed3 < MIN_STAB_MOTOR_SPEED)
	    stabMotorSpeed3 = MIN_STAB_MOTOR_SPEED; 
	} 
	else {
	  stabMotorSpeed1 -= STAB_SPEED_INCR*2;
	  if (stabMotorSpeed1 < MIN_STAB_MOTOR_SPEED)
	    stabMotorSpeed1 = MIN_STAB_MOTOR_SPEED; 
	} 
    }                                 
    break;                               
          
  case AROMY_CHANNEL:  
    // starting new conversion
    currentChannel = AROMZ_CHANNEL;
    ADMUX = ADMUX_AROMZ;    
    ADCSR |= PIN6;      
                                                          
    if (heliState == HOVER){
      
      addSample(aromY, 7, data_in);
      filtered_data = fixFilter(aromY,7);
	                               
      if (filtered_data < aromYCalibrateThresholdLow) {
	stabMotorSpeed2 += STAB_SPEED_INCR*4;
	if (stabMotorSpeed2 > MAX_STAB_MOTOR_SPEED) 
	  stabMotorSpeed2 = MAX_STAB_MOTOR_SPEED;
	stabMotorSpeed3 -= STAB_SPEED_INCR*2;
	if (stabMotorSpeed3 < MIN_STAB_MOTOR_SPEED) 
	  stabMotorSpeed3 = MIN_STAB_MOTOR_SPEED;	                                  
      } 
      else 
	if (filtered_data > aromYCalibrateThresholdHigh) {  
	  stabMotorSpeed2 -= STAB_SPEED_INCR*2;
	  if (stabMotorSpeed2 < MIN_STAB_MOTOR_SPEED) 
	    stabMotorSpeed2 = MIN_STAB_MOTOR_SPEED;
	  stabMotorSpeed3 += STAB_SPEED_INCR*4;
	  if (stabMotorSpeed3 > MAX_STAB_MOTOR_SPEED) 
	    stabMotorSpeed3 = MAX_STAB_MOTOR_SPEED;
	} 
	else {
	  stabMotorSpeed2 -= STAB_SPEED_INCR;
	  if (stabMotorSpeed2 < MIN_STAB_MOTOR_SPEED) 
	    stabMotorSpeed2 = MIN_STAB_MOTOR_SPEED;
	  stabMotorSpeed3 -= STAB_SPEED_INCR;
	  if (stabMotorSpeed3 < MIN_STAB_MOTOR_SPEED) 
	    stabMotorSpeed3 = MIN_STAB_MOTOR_SPEED;
	}
    }                          
    break;
                               
   case AROMZ_CHANNEL: 
     // Starting new conversion
    currentChannel = GYRO_CHANNEL;
    ADMUX = ADMUX_GYRO;    
    ADCSR |= PIN6;
                                                              
    if (heliState == HOVER){

      addSample(aromZ, 7, data_in);
      filtered_data = fixFilter(aromZ,8);
	                               
      if (filtered_data > aromZCalibrateThresholdHigh){
	topRotorSpeed -= HOVER_ROTOR_SPEED_INCR_HIGH;
	if (topRotorSpeed < MINIMUM_PWM_VALUE) 
	  topRotorSpeed = MINIMUM_PWM_VALUE; 
	bottomRotorSpeed -= HOVER_ROTOR_SPEED_INCR_HIGH;
	if (bottomRotorSpeed < MINIMUM_PWM_VALUE) 
	  bottomRotorSpeed = MINIMUM_PWM_VALUE;
      } 
      else 
	if (filtered_data == aromZCalibrateThresholdLow){
	  topRotorSpeed += HOVER_ROTOR_SPEED_INCR_LOW;
	  if (topRotorSpeed > MAXIMUM_ROTOR_PWM_VALUE) 
	    topRotorSpeed = MAXIMUM_ROTOR_PWM_VALUE; 
	  bottomRotorSpeed += HOVER_ROTOR_SPEED_INCR_LOW;
	  if(bottomRotorSpeed > MAXIMUM_ROTOR_PWM_VALUE) 
	    bottomRotorSpeed = MAXIMUM_ROTOR_PWM_VALUE;
	} 
    }                               
    break;  
  }
}

void calibrateGyro(void) {
  char gyroCalibrate;  
  int i;
  
  ADMUX = ADMUX_GYRO;   
  ADCSR = 0b11000110;
  
  for (i=0; i<31; i++){
    while ( (ADCSR & PIN6) != 0); 
    gyro[i] = ADCH;
    ADCSR |= PIN6;;   
  }
  while ( (ADCSR & PIN6) != 0); 
  gyro[31] = ADCH;

  gyroCalibrate = fixFilter(gyro,5); 
  gyroCalibrateThresholdLow = gyroCalibrate - 1;
  gyroCalibrateThresholdHigh = gyroCalibrate + 1;
}

void calibrateArom(void){
  char aromCalibrate;
  int i;
  
  ADMUX = ADMUX_AROMX; 
  ADCSR |= PIN6;

  for (i=0; i<127; i++){
    while ( (ADCSR & PIN6) != 0) ; 
    aromX[i] = ADCH;
    ADCSR |= PIN6;   
  }
  while ( (ADCSR & PIN6) != 0) ; 
  aromX[127] = ADCH;    
  aromCalibrate = fixFilter(aromX,7);
  aromXCalibrateThresholdLow = aromCalibrate;
  aromXCalibrateThresholdHigh = aromCalibrate + 1;

  ADMUX = ADMUX_AROMY; 
  ADCSR |= PIN6;   
    
  for (i=0; i<127; i++){
    while ( (ADCSR & PIN6) != 0) ; 
    aromY[i] = ADCH;
    ADCSR |= PIN6;   
  }
  while ( (ADCSR & PIN6) != 0) ;
  aromY[127] = ADCH;
  aromCalibrate = fixFilter(aromY,7); 
  aromYCalibrateThresholdLow = aromCalibrate;
  aromYCalibrateThresholdHigh = aromCalibrate;
  
  ADMUX = ADMUX_AROMZ;
  ADCSR |= PIN6;
  
  for (i=0; i<127; i++){
    while ( (ADCSR & PIN6) != 0) ; 
    aromZ[i] = ADCH;
    ADCSR |= PIN6;   
  }
  while ( (ADCSR & PIN6) != 0) ; 
  aromZ[127] = ADCH;
  aromCalibrate = fixFilter(aromZ,7);
  aromZCalibrateThresholdLow = aromCalibrate;
  aromZCalibrateThresholdHigh = aromCalibrate + 3;
 
  ADMUX = ADMUX_GYRO;
  ADCSR |= PIN6;    
  
}  

uint8_t fixFilter(uint8_t *f, int size){
  int i;
  int length = 1 << size;
  int sum = 0;
  for(i = 0; i < length; i++){
    sum = sum + f[i];	
  }   
  // divide by length
  sum = sum >> size;
  return sum;
}

void addSample(uint8_t *f, int size, uint8_t value){
  int i;
  int length = 1 << size;
  for (i = 0;i < length; i++){
    f[i] = f[i+1];
  }
  f[length-1] = value;
}



