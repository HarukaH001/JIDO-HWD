/**
 * Author Teemu Mäntykallio
 * Initializes the library and turns the motor in alternating directions.
*/

#define EN_PIN    16  // Nano v3:	16 Mega:	38	//enable (CFG6)
#define DIR_PIN   19  //			19			55	//direction
#define STEP_PIN  18  //			18			54	//step
#define CS_PIN    17
#define SEL        6                                              //			17			64	//chip select
#define CONTROL    7
#define STATUS     8

int rdy = 1;

#include <TMC2130Stepper.h>
TMC2130Stepper driver = TMC2130Stepper(EN_PIN, DIR_PIN, STEP_PIN, CS_PIN);

void setup() {
	Serial.begin(9600);
	while(!Serial);
	Serial.println("Start...");
	SPI.begin();
	pinMode(MISO, INPUT_PULLUP);
  pinMode(SEL,INPUT);
  pinMode(CONTROL,INPUT);
  pinMode(STATUS,OUTPUT);                                                                                                                
  driver.begin();
  driver.rms_current(600);
  driver.stealthChop(1); 
   
  digitalWrite(STATUS, HIGH); 
	digitalWrite(EN_PIN, LOW);

}

void loop() {
  int ct = digitalRead(CONTROL);
  int se = digitalRead(SEL);
//  Serial.println(ct);
//  Serial.println(se);
//  Serial.println("------");
//  delay(100); 
    if(ct == HIGH && se == LOW){
//      Serial.println("Working");
//      delay(2000);
      digitalWrite(STATUS, LOW);
      for(unsigned int i=0;i < 5;i++){
        for(unsigned int j=0;j < 15000;j++){
          digitalWrite(STEP_PIN, HIGH);
          delayMicroseconds(10);
          digitalWrite(STEP_PIN, LOW);
          delayMicroseconds(10);
        }
      }
//      Serial.println("Done");
      digitalWrite(STATUS, HIGH);
    } 
}
