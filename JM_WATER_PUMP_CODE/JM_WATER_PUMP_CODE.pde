import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
import controlP5.*;

//Controls
ControlP5[] cp5;
CheckBox checkbox;


//Audio classes
Minim minim;  
AudioPlayer JM_Tune;
FFT fftLin;
float audioSpectrumHeight = 200;
float audioAverageHeight = 400;
float spectrumScale = 4;

//Font
PFont font;

//Serial Connection
Serial myPort;  // Create object from Serial class
int val;        // Data received from the serial port


//Servo Variables
int ON = 1;
int OFF = 0;
int servo1Direction;



//Timers

Timer[] timer;


//Pump Variables

int musicAverageValueMapped;
boolean[] timerlock = { 
  false, false, false, false, false
};
int[] TempPumpDurationValue = { 
  0, 0, 0, 0, 0
};

int[] pump1TriggerValue = new int[5];
int[] pump1DurationValue = new int [5];
int[] curentPumpDurationValue = new int [5];

int whichTimer;

//Message Variables
int pump1TriggerValueMessenger = ON;

void setup() 
{
  size(1200, 500);  //Screen Size


  //Serial Connection Setup
  println(Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);

  //Audio Setup
  minim = new Minim(this);
  JM_Tune = minim.loadFile("2-10 You & Me (feat. Eliza Doolittle) [Flume Remix].mp3", 1024);
  // loop the file
  JM_Tune.loop();
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin = new FFT( JM_Tune.bufferSize(), JM_Tune.sampleRate() );
  fftLin.linAverages( 1 );


  rectMode(CORNERS); //How to draw rectangles
  font = loadFont("Helvetica-48.vlw"); // font used
  PFont fontSmaller = createFont("arial", 20); // font used

  /*************************************************************************************
   **                                                                                  **
   **                              ControlP5 Setup                                     **
   **                                                                                  **
   *************************************************************************************/

  cp5 = new ControlP5[15];

  for (int i = 0; i < 15; i++) {
    cp5[i] = new ControlP5(this);
  }  

  //for (int i = 1; i < 4; i++) {

  checkbox = cp5[0].addCheckBox("checkBox")
    .setPosition(372, 212)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(15, 15)
              .setItemsPerRow(1)
                .setSpacingRow(25)
                  .addItem("0", 0)
                    .addItem("50", 50)
                      .addItem("100", 100)
                        .addItem("150", 150)
                          .addItem("200", 200)
                            .hideLabels()
                              ;
  // }

  for (int i = 0; i < 5; i++) {

    cp5[i].addTextfield("Trigger"+i)
      .setPosition(210, 210+(i*40))
        .setSize(40, 20)
          .setFont(fontSmaller)
            .setLabelVisible(false)


              ;

    cp5[4+i].addTextfield("Duration"+i)
      .setPosition(290, 210+(i*40))
        .setSize(40, 20)
          .setFont(fontSmaller)
            .setLabelVisible(false)


              ;
  }

  timer = new Timer[10];
  for (int i = 0; i < 10; i++) {
    timer[i] = new Timer();
  }
}

void draw() {

  /*************************************************************************************
   **                                                                                  **
   **                               User Interface                                     **
   **                                                                                  **
   *************************************************************************************/


  background(0);  //background colour
  //Font use
  textFont(font);
  textSize( 18 );



  stroke(255);
  rect(0, 401, 200, 439); //audio label
  fill(255);
  //Labels
  text("Audio", 20, 430);
  text("Pump 1", 220, 430);
  text("Pump 2", 420, 430);
  text("Pump 3", 620, 430);
  text("Video", 820, 430);


  //Pump 1
  text("Active: ", 220, 30);
  text("Status: ", 220, 80);
  text("Trigger ", 210, 185);
  for (int i = 1; i < 6; i++) {

    text("%", 255, 187+(i*40));
    text("s", 340, 187+(i*40));
  }
  text("Duration ", 285, 185);
  text("I/O ", 370, 185);




  noFill();

  rect(200, -1, 400, 401); //pump 1 frame
  rect(200, 401, 400, 439); //pump 1 label frame
  rect(200, 360, 400, 401); //trigger box 1 pump 1
  rect(200, 320, 400, 401); //trigger box 2 pump 1
  rect(200, 280, 400, 401); // trigger box 3 pump 1
  rect(200, 240, 400, 401); // trigger box 4 pump 1
  rect(200, 200, 400, 401); //trigger box 5 pump 1
  rect(200, 160, 400, 401); //trigger/ duration label box for pump 1
  line(275, 160, 275, 400);
  line(360, 160, 360, 400);



  rect(400, -1, 600, 401); // pump 2 frame
  rect(400, 401, 600, 439); // pump 2 label frame

  rect(600, -1, 800, 401); // pump 3 frame
  rect(600, 401, 800, 439); // pump 3 label frame

  rect(800, 401, 1199, 439); // video stream frame



  /*************************************************************************************
   **                                                                                  **
   **                               The Audio Analysis Section                         **
   **                                                                                  **
   *************************************************************************************/

  // perform a forward FFT on the samples in JM_Tune's mix buffer
  // note that if JM_Tune were a MONO file, this would be the same as using JM_Tune.left or JM_Tune.right
  fftLin.forward( JM_Tune.mix );

  // draw the full spectrum
  noFill();
  for (int i = 0; i < 200; i++)
  {  
    stroke(255); //colour of the lines
    line(i, audioSpectrumHeight, i, audioSpectrumHeight - fftLin.getBand(i)*spectrumScale); //draw the white lines
  }

  // no more outline, we'll be doing filled rectangles from now
  noStroke();

  // draw the linear averages
  // since linear averages group equal numbers of adjacent frequency bands
  // we can simply precalculate how many pixel wide each average's 
  // rectangle should be.
  // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better       fill(255, 0, 0);
  fill(255, 0, 0);
  rect(0, audioAverageHeight, 200, audioAverageHeight - fftLin.getAvg(0)*20);

  float musicAverage = ( fftLin.getAvg(0));
  musicAverageValueMapped = int(map(musicAverage, 0, 10, 0, 255 )); // the mapped average music level

  /*************************************************************************************
   **                                                                                  **
   **                               Light Values                                       **
   **                                                                                  **
   *************************************************************************************/
  pushStyle();
  fill(musicAverageValueMapped);
  rect (0, 441, 200, 500);
  popStyle();
  pump1logic();
}


void sendMessage() {     
  //  String myPackage = ( "*"  + Pump1 + "," + Pump2 + "," + Pump3 + "," + LightValue + ",#");
  //  myPort.write(myPackage);
  //println(myPackage);
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );
  }


  if (theEvent.isFrom(checkbox)) {
    //    if ((int)checkbox.getArrayValue()[1] == 1) {
    //      timer.start();
    //    
    //    }

    //    print("got an event from "+checkbox.getName()+"\t\n");
    //    // checkbox uses arrayValue to store the state of 
    //    // individual checkbox-items. usage:
    //    println(checkbox.getArrayValue());
    //    int col = 0;
    //    for (int i=0;i<checkbox.getArrayValue().length;i++) {
    //      int n = (int)checkbox.getArrayValue()[i];
    //      print(n);
    //    }
    //    println();
  }
}

public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}


void checkBox(float[] a) {
  //println(a);
}
/*************************************************************************************
 **                                                                                  **
 **                               Program Logic                                      **
 **                                                                                  **
 *************************************************************************************/

void pump1logic() {
  for (int i = 0; i < 5; i++) {
    pump1TriggerValue[i] = int(cp5[i].get(Textfield.class, "Trigger"+i).getText());
    pump1DurationValue[i] = int(cp5[4+i].get(Textfield.class, "Duration"+i).getText());


    curentPumpDurationValue[i] = pump1DurationValue[i];

    if (timerlock[i]) {

      TempPumpDurationValue[i] = TempPumpDurationValue[i];
    }
    else {
      TempPumpDurationValue[i] = curentPumpDurationValue[i];
    }

    //check to see if timer is on
    if (!timerlock[i]) {
      //check to see if row is active
      if ((int)checkbox.getArrayValue()[i] == 1) {
        //check to see if tigger has activated
        if (musicAverageValueMapped >= pump1TriggerValue[i]) {
          timer[i].start(TempPumpDurationValue[i]);
          timerlock[i] = true;
        }
      }
    }
    if (timer[i].isFinished()) {
      timerlock[i] = false;
    }

    //print pump value
    if ( timerlock[i] && timer[i].hasStarted() ) {

      //pump1TriggerValueMessenger = whichTimer;
      //println(pump1TriggerValueMessenger);
      pushStyle();
      fill(0, 255, 0);
      text("ON ", 300, 30);
      //println("Pump Value");
      popStyle();
      //    }else{
      //    
      //    pushStyle();
      //      fill(255,0,0);
      //      text("OFF ", 300, 30);
      //      //println("Pump Value");
      //      popStyle();
      //    }

      if ((int)checkbox.getArrayValue()[i] == 0) {

        timerlock[i] = false;
      }
    }
    //println("1");
    //println(musicAverageValueMapped + " , " + TempPumpDurationValue[0] + " , " + curentPumpDurationValue[0] + " , " + timerlock[0] + " , " + timer[0].hasStarted());
  }
}
void checkWhichTimerToUse() {
  int highestValue = 0;
  int tempValue = 0;
  //loop
  for (int i = 0; i < 5; i++) {
    (if ((int)checkbox.getArrayValue()[i] == 1) {
      tempValue = pump1TriggerValue[i];
    }

    if ( tempValue > highestValue) {

      highestValue = tempValue;
      if (highestValue == tempValue) {
        //capture i
        whichTimer = i;
      }
    }
  }
}

