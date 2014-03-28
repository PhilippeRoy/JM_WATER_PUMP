/*
Untitled
 By
 Philippe Roy
 for Joseph Medgalia
 */
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
import controlP5.*;
import oscP5.*;


//Song Folder
String[] children;
int childCount = 0;
File dir;

//Controls
ControlP5[] cp5;
CheckBox[] checkbox;
Slider abc;
ListBox l;


//Audio classes
Minim minim;  
AudioPlayer[] JM_Tune;
FFT fftLin;
float audioSpectrumHeight = 200;
float audioAverageHeight = 400;
float spectrumScale = 4;
int _ = 5;
int cnt = 0;
int previousChildLength = 1;
int currentSong = 0;
int previousSong;

//Font
PFont font;

//Serial Connection
Serial serial;
OscSerial osc;
String serialName = Serial.list()[2]; //"the name of your serial port"
int led = 0;

int sendMessagePump1;
int sendMessagePump2;
int sendMessagePump3;
int colorMessage;

int pump1Control;
int pump2Control;
int pump3Control;



//int val;        // Data received from the serial port

//Servo Variables
int ON = 1;
int OFF = 0;
int servo1Direction;

//Timers
Timer[] timer;

//Pump Variables
int musicAverageValueMapped;
int offset = 2;
boolean[] timerlock = { 
  false, false, false, false, false, false, false, false, false, false
};

int[] pump1DurationValue = new int [5];
int[] curentPump1DurationValue = new int [5];
int[] TempPump1DurationValue = { 
  0, 0, 0, 0, 0
};

int[] pump1TriggerValue = new int[5];
int[] curentPump1TriggerValue = new int [5];
int[] TempPump1TriggerValue = { 
  0, 0, 0, 0, 0
};


int[] pump2DurationValue = new int [5];
int[] curentPump2DurationValue = new int [5];
int[] TempPump2DurationValue = { 
  0, 0, 0, 0, 0
};

int[] pump2TriggerValue = new int[5];
int[] curentPump2TriggerValue = new int [5];
int[] TempPump2TriggerValue = { 
  0, 0, 0, 0, 0
};

int whichTimer;
int whichTimerPump2;

int[] keyMappingListPump1 = new int [5];
int[] keyMappingListPump2 = new int [5];

//pump 3 variabels
int pump3TimeLeft;
int pump3TotalSteps = 20;
int pump3StepsTaken;
int pump3StepsLeft;
int whenToSendMessage;
int pump3Message;
int amountOfSteps;
int stepsNeededToFinish;
int[] pump3Memory = { 
  168, 1, 1
};
int savedTime;
boolean stepLock = false;


//Message Variables

void setup() 
{
  size(1200, 800);  //Screen Size

  //Serial Connection Setup
  //  println(Serial.list());
  //  String portName = Serial.list()[0];
  //  myPort = new Serial(this, portName, 9600);

  serial = new Serial(this, serialName, 9600);
  osc = new OscSerial(this, serial);
  osc.plug(this, "myFunction", "/helloFromArduino");



  rectMode(CORNERS); //How to draw rectangles
  font = loadFont("Helvetica-48.vlw"); // font used
  PFont fontSmaller = createFont("arial", 20); // font used

  //Audio Setup
  minim = new Minim(this);
  JM_Tune = new AudioPlayer[20];

  JM_Tune[currentSong] = minim.loadFile("Roy_Orbison_-_Crying.mp3", 1024);

  // loop the file
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin = new FFT( JM_Tune[currentSong].bufferSize(), JM_Tune[currentSong].sampleRate() );
  fftLin.linAverages( 1 );

  //songlist
  dir = new File((System.getProperty("user.home"))+"/Desktop/JM_SongList"); 



  /*************************************************************************************
   **                                                                                  **
   **                              ControlP5 Setup                                     **
   **                                                                                  **
   *************************************************************************************/

  cp5 = new ControlP5[20];
  checkbox = new CheckBox[6];

  for (int i = 0; i < 20; i++) {
    cp5[i] = new ControlP5(this);
  }  


  for (int i = 0; i < 2; i++) {

    checkbox[i] = cp5[i].addCheckBox("checkBox")
      .setPosition((i*200)+372, 212)
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
  }

  checkbox[2] = cp5[2].addCheckBox("pump3Checkbox")
    .setPosition(675, 252)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(50, 50)
              .setItemsPerRow(1)
                .setSpacingRow(25)
                  .addItem("0", 0)
                    .hideLabels()
                      ;

  checkbox[3] = cp5[3].addCheckBox("Pump1Control")
    .setPosition(875, 152)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(50, 50)
              .setItemsPerRow(1)
                .setSpacingRow(25)
                  .addItem("0", 0)
                    .hideLabels()
                      ;
  checkbox[4] = cp5[4].addCheckBox("Pump2Control")
    .setPosition(975, 152)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(50, 50)
              .setItemsPerRow(1)
                .setSpacingRow(25)
                  .addItem("0", 0)
                    .hideLabels()
                      ;
  checkbox[5] = cp5[5].addCheckBox("Pump3Control")
    .setPosition(1075, 152)
      .setColorForeground(color(120))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setSize(50, 50)
              .setItemsPerRow(1)
                .setSpacingRow(25)
                  .addItem("0", 0)
                    .hideLabels()
                      ;


  for (int i = 0; i < 5; i++) {
    //pump 1
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
    //pump 2
    cp5[10+i].addTextfield("Trigger"+(10+i))
      .setPosition(410, 210+(i*40))
        .setSize(40, 20)
          .setFont(fontSmaller)
            .setLabelVisible(false)


              ;

    cp5[14+i].addTextfield("Duration"+(14+i))
      .setPosition(490, 210+(i*40))
        .setSize(40, 20)
          .setFont(fontSmaller)
            .setLabelVisible(false)


              ;
  }


  cp5[0].addSlider("_")
    .setPosition(80, 415)
      .setWidth(100)
        .setRange(1, 10) // values can range from big to small as well
          .setValue(5)
            .setNumberOfTickMarks(5)
              //.setLabelVisible(false)
              ;


  timer = new Timer[10];
  for (int i = 0; i < 10; i++) {
    timer[i] = new Timer();  //timer 0-4 is for pump1 . timer 5-10 is for pump 2
  }

  ControlP5.printPublicMethodsFor(ListBox.class);

  l = cp5[0].addListBox("songList")
    .setPosition(0, 515)
      .setSize(600, 300)
        .setItemHeight(25)
          .setBarHeight(25)
            .setColorBackground(color(255, 128))
              .setColorActive(color(0))
                .setColorForeground(color(0, 111, 255))
                  ;

  l.captionLabel().toUpperCase(true);
  l.captionLabel().set("Select a song");
  l.captionLabel().setColor(0xfffffff);
  l.captionLabel().style().marginTop = 3;
  l.valueLabel().style().marginTop = 3;


  PImage[] imgsPlay = {
    loadImage("button_a.png"), loadImage("button_b.png"), loadImage("button_c.png")
    };
    cp5[0].addButton("play")
      .setValue(10)
        .setPosition(495, 440)
          .setImages(imgsPlay)
            .updateSize()
              ;
  PImage[] imgsPause = {
    loadImage("button_pause_blue.png"), loadImage("button_pause_green.png"), loadImage("button_pause_red.png")
    };

    cp5[0].addButton("pause")
      .setValue(20)
        .setPosition(550, 440)
          .setImages(imgsPause)
            .updateSize()
              ;
}

void draw() {
  offset = _;
  /*************************************************************************************
   **                                                                                  **
   **                               User Interface                                     **
   **                                                                                  **
   *************************************************************************************/


  background(0);  //background colour
  //Font use
  textFont(font);
  textSize( 18 );

  rect(400, -1, 600, 401); // pump 2 frame
  rect(400, 401, 600, 439); // pump 2 label frame

  rect(600, -1, 800, 401); // pump 3 frame
  rect(600, 401, 800, 439); // pump 3 label frame

  rect(800, 401, 1199, 439); // video stream frame

  rect(0, 439, 600, 489); //Songlist
  rect(600, 439, 800, 489); //Light


  // *********************************          PUMP 1      ****************************************************/

  stroke(255);
  rect(0, 401, 200, 439); //audio label
  fill(255);
  //Labels
  text("Audio", 20, 430);
  text("Pump 1", 220, 430);
  text("Pump 2", 420, 430);
  text("Pump 3", 620, 430);
  text("Controls", 820, 430);
  text("Song List", 20, 470);
  text("Lights", 620, 470);





  //Pump 1
  text("Active: ", 220, 30);
  // text("Status: ", 220, 80);
  text("Time Left: ", 220, 130);

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


  // *********************************          PUMP 2      ****************************************************/

  stroke(255);
  fill(255);

  //Pump 2
  text("Active: ", 420, 30);
  // text("Status: ", 420, 80);
  text("Time Left: ", 420, 130);
  text("Trigger ", 410, 185);
  text("Duration ", 485, 185);
  text("I/O ", 570, 185);

  for (int i = 1; i < 6; i++) {
    text("%", 455, 187+(i*40));
    text("s", 540, 187+(i*40));
  }

  noFill();

  rect(400, -1, 600, 401); //pump 1 frame
  rect(400, 401, 600, 439); //pump 1 label frame
  rect(400, 360, 600, 401); //trigger box 1 pump 1
  rect(400, 320, 600, 401); //trigger box 2 pump 1
  rect(400, 280, 600, 401); // trigger box 3 pump 1
  rect(400, 240, 600, 401); // trigger box 4 pump 1
  rect(400, 200, 600, 401); //trigger box 5 pump 1
  rect(400, 160, 600, 401); //trigger/ duration label box for pump 1

    line(475, 160, 475, 400);
  line(560, 160, 560, 400);


  // *********************************          PUMP 3      ****************************************************/

  stroke(255);
  fill(255);

  //Pump 3
  text("Active: ", 620, 30);
  // text("Status: ", 620, 80);
  text("Time Left: ", 620, 130);
  text("Song Length: ", 620, 180);

  // *********************************          Controls      ****************************************************/

text("Pump 1", 875, 130);
  text("Pump 2", 975, 130);
  text("Pump 3", 1075, 130);
  //Program functions
  audioAnalysis();
  light();
  songlist();
  // println((JM_Tune[currentSong].length()/1000) - (JM_Tune[currentSong].position()/1000));
  pump1logic();

  sendMessage();
}


void sendMessage() {     

  // send an OSC message
  OscMessage msg = new OscMessage("/JM");

  msg.add(sendMessagePump1);
  msg.add(sendMessagePump2);
  msg.add(sendMessagePump3);
  msg.add(colorMessage);
  osc.send(msg);

  //println(msg);
}

void songlist() {

  children = dir.list();
  if (children == null) {

    // println("-- file not found");
    return;
  } 
  else {
    for (int i=1; i<children.length; i++) {
      //      pushStyle();
      //      textSize(15);
      //      fill(255);
      //      text(children[i], 10, 500+(i*20));
      //      popStyle();
    }
    if ( previousChildLength < children.length) {
      ListBoxItem lbi = l.addItem(children[previousChildLength], previousChildLength);
      lbi.setColorBackground(0xf00000ff);
      JM_Tune[previousChildLength] = minim.loadFile((System.getProperty("user.home"))+"/Desktop/JM_SongList/" + children[previousChildLength], 1024);
    }
    previousChildLength++;
  }

  pushStyle();
  fill(255);
  text(children[currentSong], 150, 470);
  popStyle();
  //println(children.length+" files found...");
}

void controlEvent(ControlEvent theEvent) {
  // ListBox is if type ControlGroup.
  // 1 controlEvent will be executed, where the event
  // originates from a ControlGroup. therefore
  // you need to check the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.

  if (theEvent.isGroup()) {
    // an event from a group e.g. scrollList
    //  println(theEvent.group().value()+" from "+theEvent.group());
  }

  if (theEvent.isGroup() && theEvent.name().equals("songList")) {
    previousSong = currentSong;
    currentSong = (int)theEvent.group().value();
    playSongStopSong();
    //  println(children[currentSong]);
  }

  if (theEvent.isFrom(checkbox[2])) {
    if ((int)checkbox[2].getArrayValue()[0] == 1) {
      pump3Memory[2] = pump3TimeLeft;
    }
  }

  //  if (theEvent.isFrom(checkbox[3])) {
  //    if ((int)checkbox[3].getArrayValue()[0] == 1) {
  //      JM_Tune[currentSong].pause();
  //    }
  //    if ((int)checkbox[3].getArrayValue()[0] == 1) {
  //      JM_Tune[currentSong].play();
  //    }
  //  }

  if (theEvent.isFrom(checkbox[3])) {
    if ((int)checkbox[3].getArrayValue()[0] == 1) {
      pump1Control = 1;
    }
    else {
      pump1Control = 0;
    }
  }
  if (theEvent.isFrom(checkbox[4])) {
    if ((int)checkbox[4].getArrayValue()[0] == 1) {
      pump2Control = 1;
    }
    else {
      pump2Control = 0;
    }
  }
  if (theEvent.isFrom(checkbox[5])) {
    if ((int)checkbox[5].getArrayValue()[0] == 1) {
      pump3Control = 1;
    }
    else {
      pump3Control = 0;
    }
  }

  // println(theEvent.getController().getName());
}


public void play(int theValue) {
  println("a button event from play: "+theValue);
  if (theValue == 10) {
    JM_Tune[currentSong].play();
  };
}
public void pause(int theValue) {
  println("a button event from pause: "+theValue);
  if (theValue == 20) {
    JM_Tune[currentSong].pause();
  };
}



void playSongStopSong() {
  JM_Tune[previousSong].pause();
  JM_Tune[currentSong].loop();
  pump3Memory[0] = (JM_Tune[currentSong].length()/1000);
  pump3Memory[1] = pump3StepsLeft;
  if (pump3Memory[0] < 0) {
    pump3Memory[0] = 1;
  };
}

///OSC MESSAGE STUFF

void plugTest(int value) {
  // println("Plugged from /pattern: " + value);
}

// Any unplugged message will come here
void oscEvent(OscMessage theMessage) {
  //println("Message: " + theMessage + ", " + theMessage.isPlugged());
}

