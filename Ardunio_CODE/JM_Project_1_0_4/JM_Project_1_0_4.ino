#include <Servo.h> 

// MESSAGE PROTOCOL OBJECT
#include <OscSerial.h>

// tile support libraries
#include <EthernetUdp.h>
#include <SPI.h> 


#define REDPIN 5
#define GREENPIN 6
#define BLUEPIN 7







OscSerial oscSerial;

int pump1IncomingMSG;
int pump2IncomingMSG;
int pump3IncomingMSG;
int LEDIncomingMSG;

int reverse = 10;
int openvalve = 10;
int forward = 170;

int pump1Motion, pump2Motion, pump3Motion;

Servo pump1_myservo, pump2_myservo, pump3_myservo;
Servo pump1_valve1_myservo, pump1_valve2_myservo, pump2_valve1_myservo, pump2_valve2_myservo, pump3_valve1_myservo, pump3_valve2_myservo;


int pump1_button1State = 0;     // the number of the pushbutton pin
int pump1_button2State = 0;     // the number of the pushbutton pin
int pump2_button1State = 0;     // the number of the pushbutton pin
int pump2_button2State = 0;     // the number of the pushbutton pin
int pump3_button1State = 0;     // the number of the pushbutton pin
int pump3_button2State = 0;     // the number of the pushbutton pin

int pump1_button1, pump1_button2, pump2_button1, pump2_button2, pump3_button1, pump3_button2;

const int pressed = 0;
const int notPressed = 1;
const int hit = 0;

const int on = 10;
const int off = 90;

const int pump1_button1Pin = 44;     // the number of the pushbutton pin
const int pump1_button2Pin = 46;     // the number of the pushbutton pin
const int pump2_button1Pin = 40;     // the number of the pushbutton pin
const int pump2_button2Pin = 42;     // the number of the pushbutton pin
const int pump3_button1Pin = 50;     // the number of the pushbutton pin
const int pump3_button2Pin = 48;     // the number of the pushbutton pin

const int pump1_Pin = 35;//35     // the number of the pushbutton pin
const int pump2_Pin = 33;//33     // the number of the pushbutton pin
const int pump3_Pin = 31;//31     // the number of the pushbutton pin

const int pump1_valve1Pin_Servo = 37;     // the number of the pushbutton pin
const int pump1_valve2Pin_Servo = 39;     // the number of the pushbutton pin
const int pump2_valve1Pin_Servo = 41;     // the number of the pushbutton pin
const int pump2_valve2Pin_Servo = 43;     // the number of the pushbutton pin
const int pump3_valve1Pin_Servo = 45;     // the number of the pushbutton pin
const int pump3_valve2Pin_Servo = 47;     // the number of the pushbutton pin


const int pump1_valve1Pin = 34;     // the number of the pushbutton pin
const int pump1_valve2Pin = 32;     // the number of the pushbutton pin
const int pump2_valve1Pin = 30;     // the number of the pushbutton pin
const int pump2_valve2Pin = 28;     // the number of the pushbutton pin
const int pump3_valve1Pin = 26;     // the number of the pushbutton pin
const int pump3_valve2Pin = 24;     // the number of the pushbutton pin

int noPin = 190;

int pump1_valve1, pump1_valve2, pump2_valve1, pump2_valve2, pump3_valve1, pump3_valve2;


// Variables will change:
int pump1_button1_ButtonState;
int pump1_button2_ButtonState;   
int pump1_lastButton1State = LOW;   // the previous reading from the input pin
int pump1_lastButton2State = LOW;   // the previous reading from the input pin
long pump1_button1LastDebounceTime = 0;  // the last time the output pin was toggled
long pump1_button2LastDebounceTime = 0;  // the last time the output pin was toggled

int pump2_button1_ButtonState;
int pump2_button2_ButtonState;   
int pump2_lastButton1State = LOW;   // the previous reading from the input pin
int pump2_lastButton2State = LOW;   // the previous reading from the input pin
long pump2_button1LastDebounceTime = 0;  // the last time the output pin was toggled
long pump2_button2LastDebounceTime = 0;  // the last time the output pin was toggled

int pump3_button1_ButtonState;
int pump3_button2_ButtonState;   
int pump3_lastButton1State = LOW;   // the previous reading from the input pin
int pump3_lastButton2State = LOW;   // the previous reading from the input pin
long pump3_button1LastDebounceTime = 0;  // the last time the output pin was toggled
long pump3_button2LastDebounceTime = 0;  // the last time the output pin was toggled

long debounceDelay = 50;    // the debounce time; increase if the output flickers

//LIGHTD



void setup() {
  pinMode(pump1_button1Pin, INPUT);
  pinMode(pump1_button2Pin, INPUT);
  pinMode(pump2_button1Pin, INPUT);
  pinMode(pump2_button2Pin, INPUT);
  pinMode(pump3_button1Pin, INPUT);
  pinMode(pump3_button2Pin, INPUT);

  pinMode(pump1_valve1Pin, INPUT);
  pinMode(pump1_valve2Pin, INPUT);
  pinMode(pump2_valve1Pin, INPUT);
  pinMode(pump2_valve2Pin, INPUT);
  pinMode(pump3_valve1Pin, INPUT);
  pinMode(pump3_valve2Pin, INPUT);


  pinMode(REDPIN, OUTPUT);
  pinMode(GREENPIN, OUTPUT);
  pinMode(BLUEPIN, OUTPUT);




  Serial.begin(9600);
  oscSerial.begin(Serial); 

}

void loop() {
  oscSerial.listen();
  buttonCheck();
  valveSwitchCheck();
  actions();
  lights();
  // pushFrame():
  /*   
   //Pump 1
   Serial.print("PUMP 1 ");
   Serial.print("B1: ");
   Serial.print(pump1_button1State);
   Serial.print(" B2: ");
   Serial.print(pump1_button2State);
   Serial.print(" V1: ");
   Serial.print(pump1_valve1);
   Serial.print(" V2: ");
   Serial.println(pump1_valve2);
   
   //Pump 2
   Serial.print("      PUMP 2 : ");
   Serial.print("B1: ");
   Serial.print(pump2_button1State);
   Serial.print(" B2: ");
   Serial.print(pump2_button2State);
   Serial.print(" V1: ");
   Serial.print(pump2_valve1);
   Serial.print(" V2: ");
   Serial.println(pump2_valve2);
  
   //Pump 3
   Serial.print("      PUMP 3 : ");
   Serial.print("B1: ");
   Serial.print(pump3_button1State);
   Serial.print(" B2: ");
   Serial.print(pump3_button2State);
   Serial.print(" V1: ");
   Serial.print(pump3_valve1);
   Serial.print(" V2: ");
   Serial.println(pump3_valve2);
   */


}

void buttonCheck(){
  //Seems like there is a lot but it is just checking for debouncing since it is not a switch but a button
  //Pump 1 rear button (button1)
  int pump1_button1reading = digitalRead(pump1_button1Pin);
  if (pump1_button1reading != pump1_lastButton1State) {
    pump1_button1LastDebounceTime = millis();
  } 
  if ((millis() - pump1_button1LastDebounceTime) > debounceDelay) {
    pump1_button1_ButtonState = pump1_button1reading;
  }
  //Serial.print(pump1_button1ButtonState);
  pump1_lastButton1State = pump1_button1reading;
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //Pump 1 front button (button2)
  int pump1_button2reading = digitalRead(pump1_button2Pin);
  if (pump1_button2reading != pump1_lastButton2State) {
    pump1_button2LastDebounceTime = millis();
  } 
  if ((millis() - pump1_button2LastDebounceTime) > debounceDelay) {
    pump1_button2_ButtonState = pump1_button2reading;
  }
  //  Serial.println(pump1_button2ButtonState);
  pump1_lastButton2State = pump1_button2reading;
  //+++++++++++++++++++++++++++++++++++++++++++

  //Pump 2 rear button (button1)
  int pump2_button1reading = digitalRead(pump2_button1Pin);
  if (pump2_button1reading != pump2_lastButton1State) {
    pump2_button1LastDebounceTime = millis();
  } 
  if ((millis() - pump2_button1LastDebounceTime) > debounceDelay) {
    pump2_button1_ButtonState = pump2_button1reading;
  }
  //Serial.print(pump1_button1ButtonState);
  pump2_lastButton1State = pump2_button1reading;
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //Pump 2 front button (button2)
  int pump2_button2reading = digitalRead(pump2_button2Pin);
  if (pump2_button2reading != pump2_lastButton2State) {
    pump2_button2LastDebounceTime = millis();
  } 
  if ((millis() - pump2_button2LastDebounceTime) > debounceDelay) {
    pump2_button2_ButtonState = pump2_button2reading;
  }
  //  Serial.println(pump1_button2ButtonState);
  pump2_lastButton2State = pump2_button2reading;

  //+++++++++++++++++++++++++++++++++++++++++++

  //Pump 3 rear button (button1)
  int pump3_button1reading = digitalRead(pump3_button1Pin);
  if (pump3_button1reading != pump3_lastButton1State) {
    pump3_button1LastDebounceTime = millis();
  } 
  if ((millis() - pump3_button1LastDebounceTime) > debounceDelay) {
    pump3_button1_ButtonState = pump3_button1reading;
  }
  //Serial.print(pump1_button1ButtonState);
  pump3_lastButton1State = pump3_button1reading;
  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //Pump 3 front button (button2)
  int pump3_button2reading = digitalRead(pump3_button2Pin);
  if (pump3_button2reading != pump3_lastButton2State) {
    pump3_button2LastDebounceTime = millis();
  } 
  if ((millis() - pump3_button2LastDebounceTime) > debounceDelay) {
    pump3_button2_ButtonState = pump3_button2reading;
  }
  //  Serial.println(pump1_button2ButtonState);
  pump3_lastButton2State = pump3_button2reading;
  //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  //front
  if (pump1_button1_ButtonState == hit){
    pump1_button1State = off; 
    pump1_button2State = on;
  }
  //back
  if(pump1_button2_ButtonState == hit){
    pump1_button2State = off;
    pump1_button1State = on;
  }

  //Pump 2
  //front
  if (pump2_button1_ButtonState == hit){
    pump2_button1State = off; 
    pump2_button2State = on;
  }
  //back
  if(pump2_button2_ButtonState == hit){
    pump2_button2State = off;
    pump2_button1State = on;
  }

  //Pump 3
  //front
  if (pump3_button1_ButtonState == hit){
    pump3_button1State = off; 
    pump3_button2State = on;
  }
  //back
  if(pump3_button2_ButtonState == hit){
    pump3_button2State = off;
    pump3_button1State = on;
  }

}


void valveSwitchCheck(){
  //this is for testing if switches work


    pump1_valve1 = digitalRead(pump1_valve1Pin);
  pump1_valve2 = digitalRead(pump1_valve2Pin);
  pump2_valve1 = digitalRead(pump2_valve1Pin);
  pump2_valve2 = digitalRead(pump2_valve2Pin);
  pump3_valve1 = digitalRead(pump3_valve1Pin);
  pump3_valve2 = digitalRead(pump3_valve2Pin);
}

void actions(){

  //PUMP 1 #

  if (pump1_button1State == on && pump1_button2State == off){
    //makesure valves are correct
    if( pump1_valve1 == HIGH && pump1_valve2 == LOW){//make sure valve 2 is closed and valve 1 is open
      pump1_valve1_myservo.attach(noPin);
      pump1_valve2_myservo.attach(noPin);
      if(pump1IncomingMSG == 1){
        pump1_myservo.attach(pump1_Pin);  // set servo to mid-point
        pump1_myservo.write(105);  // set servo to mid-point
      }
      else{
        pump1_myservo.attach(noPin);  // de-attach for no movement
      }
    }

    if(pump1_valve1 == LOW && pump1_valve2 == HIGH && pump1_button1State == on){
      pump1_myservo.attach(noPin);//no movement
      pump1_valve2_myservo.attach(noPin);//stop
      pump1_valve1_myservo.attach(pump1_valve1Pin_Servo);//forward to open
      pump1_valve1_myservo.write(reverse);//forward to open
    }
    if(pump1_valve1 == HIGH && pump1_valve2 == HIGH && pump1_button1State == on){

      pump1_myservo.attach(noPin);//no movement
      pump1_valve1_myservo.attach(noPin);//stop because valve is closed
      pump1_valve2_myservo.attach(pump1_valve2Pin_Servo);//close
      pump1_valve2_myservo.write(forward);//close

    }
  }


  if (pump1_button1State == off && pump1_button2State == on){

    if(pump1_valve2 == LOW && pump1_button2State == on ){
      pump1_myservo.attach(noPin); //stop servo
      pump1_valve1_myservo.attach(noPin);//stop because valve is closed
      pump1_valve2_myservo.attach(pump1_valve2Pin_Servo);//open valve 2
      pump1_valve2_myservo.write(openvalve);//open valve 2


    }
    if(pump1_valve1 == HIGH && pump1_valve2 == HIGH && pump1_button2State == on ){

      pump1_myservo.attach(noPin); //stop servo
      pump1_valve2_myservo.attach(noPin);
      pump1_valve1_myservo.attach(pump1_valve1Pin_Servo);//close valve 1
      pump1_valve1_myservo.write(forward);//close valve 1

    }
    if(pump1_valve1 == LOW && pump1_valve2 == HIGH && pump1_button2State == on ){
      pump1_valve1_myservo.attach(noPin);//stop because valve is closed
      pump1_valve2_myservo.attach(noPin);//stop valve becasue it is open 
      pump1_myservo.attach(pump1_Pin);//reverse pump too fill up again
      pump1_myservo.write(reverse);//reverse pump too fill up again
    }

  }


  //  //#####################################################################################
  //
  //  //PUMP 2 #
  //
  if (pump2_button1State == on && pump2_button2State == off){
    //makesure valves are correct
    if( pump2_valve1 == HIGH && pump2_valve2 == LOW){//make sure valve 2 is closed and valve 1 is open
      pump2_valve1_myservo.attach(noPin);
      pump2_valve2_myservo.attach(noPin);
      if(pump2IncomingMSG == 1){
        pump2_myservo.attach(pump2_Pin);  // set servo to mid-point
        pump2_myservo.write(105);  // set servo to mid-point
      }
      else{
        pump2_myservo.attach(noPin);  // de-attach for no movement
      }
    }

    if(pump2_valve1 == LOW && pump2_valve2 == HIGH && pump2_button1State == on){
      pump2_myservo.attach(noPin);//no movement
      pump2_valve2_myservo.attach(noPin);//stop
      pump2_valve1_myservo.attach(pump2_valve1Pin_Servo);//forward to open
      pump2_valve1_myservo.write(openvalve);//forward to open

    }
    if(pump2_valve1 == HIGH && pump2_valve2 == HIGH && pump2_button1State == on){

      pump2_myservo.attach(noPin);//no movement
      pump2_valve1_myservo.attach(noPin);//stop because valve is closed
      pump2_valve2_myservo.attach(pump2_valve2Pin_Servo);//close
      pump2_valve2_myservo.write(forward);//close
    }
  }


  if (pump2_button1State == off && pump2_button2State == on){

    if(pump2_valve2 == LOW && pump2_button2State == on ){
      pump2_myservo.attach(noPin); //stop servo
      pump2_valve1_myservo.attach(noPin);//stop because valve is closed
      pump2_valve2_myservo.attach(pump2_valve2Pin_Servo);//open valve 2
      pump2_valve2_myservo.write(reverse);//actually closes valse

    }
    if(pump2_valve1 == HIGH && pump2_valve2 == HIGH && pump2_button2State == on ){

      pump2_myservo.attach(noPin); //stop servo
      pump2_valve2_myservo.attach(noPin);
      pump2_valve1_myservo.attach(pump2_valve1Pin_Servo);//close valve 1
      pump2_valve1_myservo.write(forward);//close valve 1


    }
    if(pump2_valve1 == LOW && pump2_valve2 == HIGH && pump2_button2State == on ){
      pump2_valve1_myservo.attach(noPin);//stop because valve is closed
      pump2_valve2_myservo.attach(noPin);//stop valve becasue it is open 
      pump2_myservo.attach(pump2_Pin);//reverse pump too fill up again
      pump2_myservo.write(reverse);//reverse pump too fill up again
    }

  }
  //
  //  //#####################################################################################
  //
  //  //PUMP 3 #
  //
  if (pump3_button1State == on && pump3_button2State == off){
    //makesure valves are correct
    if( pump3_valve1 == HIGH && pump3_valve2 == HIGH){//make sure valve 2 is closed and valve 1 is open
      pump3_valve1_myservo.attach(noPin);
      pump3_valve2_myservo.attach(noPin);
      if(pump3IncomingMSG == 1){
        pump3_myservo.attach(pump3_Pin);  // set servo to mid-point
        pump3_myservo.write(105);  // set servo to mid-point
      }
      else{
        pump3_myservo.attach(noPin);  // de-attach for no movement
      }
    }

    if(pump3_valve1 == LOW && pump3_valve2 == LOW && pump3_button1State == on){
      pump3_myservo.attach(noPin);//no movement
      pump3_valve2_myservo.attach(noPin);//stop
      pump3_valve1_myservo.attach(pump3_valve1Pin_Servo);//forward to open
      pump3_valve1_myservo.write(openvalve);//forward to open

    }
    if(pump3_valve1 == HIGH && pump3_valve2 == LOW && pump3_button1State == on){

      pump3_myservo.attach(noPin);//no movement
      pump3_valve1_myservo.attach(noPin);//stop because valve is closed
      pump3_valve2_myservo.attach(pump3_valve2Pin_Servo);//close
      pump3_valve2_myservo.write(forward);//reverse
    }
  }


  if (pump3_button1State == off && pump3_button2State == on){

    if(pump3_valve2 == HIGH && pump3_button2State == on ){
      pump3_myservo.attach(noPin); //stop servo
      pump3_valve1_myservo.attach(noPin);//stop because valve is closed
      pump3_valve2_myservo.attach(pump3_valve2Pin_Servo);//open valve 2
      pump3_valve2_myservo.write(reverse);//open valve 2






    }
    if(pump3_valve1 == HIGH && pump3_valve2 == LOW && pump3_button2State == on ){
      pump3_valve2_myservo.attach(noPin);
      pump3_valve1_myservo.attach(pump3_valve1Pin_Servo);//close valve 1
      pump3_valve1_myservo.write(forward);//close valve 1
      pump3_myservo.attach(noPin); //stop servo

    }
    if(pump3_valve1 == LOW && pump3_valve2 == LOW && pump3_button2State == on ){
      pump3_valve1_myservo.attach(noPin);//stop because valve is closed
      pump3_valve2_myservo.attach(noPin);//stop valve becasue it is open 
      pump3_myservo.attach(pump3_Pin);//reverse pump too fill up again
      pump3_myservo.write(reverse);//reverse pump too fill up again
    }

  }
  //  //#####################################################################################

}



void oscEvent(OscMessage &m) { // *note the & before msg
  // receive a message 
  m.plug("/JM", myFunction); 
}


// getting to the message data 
void myFunction(OscMessage &m) {  // *note the & before msg
  pump1IncomingMSG = m.getInt(0); 
  pump2IncomingMSG = m.getInt(1); 
  pump3IncomingMSG = m.getInt(2); 
  LEDIncomingMSG = m.getInt(3); 

}


void lights(){

  
int r = LEDIncomingMSG;
int g = LEDIncomingMSG;
int b = LEDIncomingMSG;
  

 analogWrite(REDPIN, r);
 analogWrite(BLUEPIN, g);
 analogWrite(GREENPIN, b);




}


















