
/*************************************************************************************
 **                                                                                  **
 **                               Program Logic                                      **
 **                                                                                  **
 *************************************************************************************/

void pump1logic() {
  for (int i = 0; i < 5; i++) {

    //pump 1
    pump1TriggerValue[i] = int(cp5[i].get(Textfield.class, "Trigger"+i).getText()); //get Trigger value from text box
    pump1DurationValue[i] = int(cp5[4+i].get(Textfield.class, "Duration"+i).getText()); //get Duration value from trigger box

    curentPump1DurationValue[i] = pump1DurationValue[i]; //set the curentPumpDurationValue to text input
    curentPump1TriggerValue[i] = pump1TriggerValue[i]; //set the curentPumpDurationValue to text input


    //check to see if new input can be enter
    //this can only happen when timer lock in inactive
    //it is onlt inactive whenthe timer is finished
    //if timerlock is active then store variable until inactive and then proceeed
    if (timerlock[i]) {

      TempPump1DurationValue[i] = TempPump1DurationValue[i];
      TempPump1TriggerValue[i] = TempPump1TriggerValue[i];
    }
    else {
      TempPump1DurationValue[i] = curentPump1DurationValue[i];
      TempPump1TriggerValue[i] = curentPump1TriggerValue[i];
    }

    //pump2
    pump2TriggerValue[i] = int(cp5[10+i].get(Textfield.class, "Trigger"+(10+i)).getText()); //get Trigger value from text box
    pump2DurationValue[i] = int(cp5[14+i].get(Textfield.class, "Duration"+(14+i)).getText()); //get Duration value from trigger box


    curentPump2DurationValue[i] = pump2DurationValue[i]; //set the curentPumpDurationValue to text input
    curentPump2TriggerValue[i] = pump2TriggerValue[i]; //set the curentPumpDurationValue to text input

    //check to see if new input can be enter
    //this can only happen when timer lock in inactive
    //it is onlt inactive whenthe timer is finished
    //if timerlock is active then store variable until inactive and then proceeed
    if (timerlock[i+5]) {

      TempPump2DurationValue[i] = TempPump2DurationValue[i];
      TempPump2TriggerValue[i] = TempPump2TriggerValue[i];
    }
    else {
      TempPump2DurationValue[i] = curentPump2DurationValue[i];
      TempPump2TriggerValue[i] = curentPump2TriggerValue[i];
    }
  }

  for (int t = 0; t < 5; t++) {

    //check to see if timer is on
    if (!timerlock[t]) {
      //check to see if row is active
      if ((int)checkbox[0].getArrayValue()[t] == 1) {
        //check to see if tigger has activated
        if (musicAverageValueMapped >= pump1TriggerValue[t]) {
          //if trigger is active start timer
          timer[t].start(TempPump1DurationValue[t]*1000);
          timerlock[t] = true; //turn on timer lock so no new duration can affect timer object until timer is complete
        }
      }
    }

    //check to see if timer is on
    if (!timerlock[t+5]) {
      //check to see if row is active
      if ((int)checkbox[1].getArrayValue()[t] == 1) {
        //check to see if tigger has activated
        if (musicAverageValueMapped >= pump2TriggerValue[t]) {
          //if trigger is active start timer
          timer[t+5].start(TempPump2DurationValue[t]*1000);
          timerlock[t+5] = true; //turn on timer lock so no new duration can affect timer object until timer is complete
        }
      }
    }
  }

  for (int s = 0; s < 5; s++) {

    //when timer is complete unlock timer to allow for new duration value to be entered
    if (timer[s].isFinished()) {
      timerlock[s] = false;
    }
    if ((int)checkbox[0].getArrayValue()[s] == 0) {
      timerlock[s] = false;
    }

    //pump 2
    if (timer[s+5].isFinished()) {
      timerlock[s+5] = false;
    }
    if ((int)checkbox[1].getArrayValue()[s] == 0) {
      timerlock[s+5] = false;
    }
  }
  int[] orderdList = { 
    TempPump1TriggerValue[0], TempPump1TriggerValue[1], TempPump1TriggerValue[2], TempPump1TriggerValue[3], TempPump1TriggerValue[4]
  };

  int[] orderdListPump2 = { 
    TempPump2TriggerValue[0], TempPump2TriggerValue[1], TempPump2TriggerValue[2], TempPump2TriggerValue[3], TempPump2TriggerValue[4]
  };
  orderdList = sort(orderdList);
  orderdListPump2 = sort(orderdListPump2);

  // println(orderdListPump2);
  for (int j = 0; j < 5; j++) {
    for (int k = 0; k < 5; k++) {
      if (orderdList[j] == TempPump1TriggerValue[k]) {
        keyMappingListPump1[j] = k;
      }
      if (orderdListPump2[j] == TempPump2TriggerValue[k]) {
        keyMappingListPump2[j] = k;
      }
    }
  }
  // println(keyMappingListPump1);

  //figure which counter to use, always the highest will be used if triggered
  if ((musicAverageValueMapped >= orderdList[4]) && ((int)checkbox[0].getArrayValue()[keyMappingListPump1[4]] == 1)) {
    whichTimer = keyMappingListPump1[4];
  }

  for (int keyCounter = 4; keyCounter > 0; keyCounter--) {
    if ((musicAverageValueMapped < orderdList[keyCounter])  && (timer[keyMappingListPump1[keyCounter-1]].isFinished()) && ((int)checkbox[0].getArrayValue()[keyMappingListPump1[keyCounter-1]] == 1)) {
      whichTimer = keyMappingListPump1[keyCounter-1];
    }
  }

  //pump 2

  //figure which counter to use, always the highest will be used if triggered
  if ((musicAverageValueMapped >= orderdListPump2[4]) && ((int)checkbox[1].getArrayValue()[keyMappingListPump2[4]] == 1)) {
    whichTimerPump2 = keyMappingListPump2[4];
  }

  for (int keyCounterPump2 = 4; keyCounterPump2 > 0; keyCounterPump2--) {
    if ((musicAverageValueMapped < orderdListPump2[keyCounterPump2])  && (timer[keyMappingListPump2[keyCounterPump2-1]].isFinished()) && ((int)checkbox[1].getArrayValue()[keyMappingListPump2[keyCounterPump2-1]] == 1)) {
      whichTimerPump2 = keyMappingListPump2[keyCounterPump2-1];
    }
  }

  //Pump 1
  if ( timerlock[whichTimer] && timer[whichTimer].hasStarted() ) {
    pushStyle();
    fill(0, 255, 0);
    text("ON  @ " + (TempPump1TriggerValue[whichTimer]) + " %", 285, 30);
    text("for    " + (TempPump1DurationValue[whichTimer] + " s"), 285, 50);
    text((timer[whichTimer].timeLeft()), 320, 130);
    popStyle();
    sendMessagePump1 = 1;
  }
  else {
    pushStyle();
    fill(255, 0, 0);
    text("Waiting ", 300, 30);
    popStyle();
    if (   pump1Control == 1) {

      sendMessagePump1 = 1;
    }
    else {
      sendMessagePump1 = 0;
    }
  }

  //pump 2
  if ( timerlock[whichTimerPump2+5] && timer[whichTimerPump2+5].hasStarted() ) {
    pushStyle();
    fill(0, 255, 0);
    text("ON  @ " + (TempPump2TriggerValue[whichTimerPump2]  + " %"), 485, 30);
    text("for    " + (TempPump2DurationValue[whichTimerPump2]+ " s"), 485, 50);
    text((timer[whichTimerPump2+5].timeLeft()), 520, 130);
    popStyle();
    sendMessagePump2 = 1;
  }
  else {
    pushStyle();
    fill(255, 0, 0);
    text("Waiting ", 500, 30);
    popStyle();
    if (   pump2Control == 1) {

      sendMessagePump2 = 1;
    }
    else {
      sendMessagePump2 = 0;
    }
  }


  //pump 3

  pushStyle();
  fill(0, 255, 0);
  text(pump3TimeLeft, 740, 130);
  text((JM_Tune[currentSong].length()/1000), 740, 180);
  popStyle();


  if ((int)checkbox[2].getArrayValue()[0] == 1) {

    pushStyle();
    fill(255);
    text("ON", 687, 325);
    popStyle();
  }

  else {
    pushStyle();
    fill(255);
    text("OFF", 683, 325);
    popStyle();
  }

  pump3TimeLeft = ((JM_Tune[currentSong].length()/1000) - (JM_Tune[currentSong].position()/1000));//pump3Memory[0]

  pump3StepsLeft = pump3TotalSteps - pump3StepsTaken; //pump3Memory[1]
  //amountOfSteps = (JM_Tune[currentSong].length()/1000))/pump3StepsLeft
  whenToSendMessage = pump3Memory[0]/pump3Memory[1];

  if ((int)checkbox[2].getArrayValue()[0] == 1) {

    whenToSendMessage = pump3Memory[2]/pump3Memory[1];

    if (((millis()/1000) % whenToSendMessage) == 0 && (!stepLock)) {
      // pump3message = (amountOfSteps);
      pump3StepsTaken = pump3StepsTaken + 1 ;
      stepLock = true;
      savedTime = (millis()/1000);
      pump3Message = 1;
      sendMessagePump3 = 1;


      pushStyle();
      fill(0, 255, 0);
      text("ON", 685, 30);
      popStyle();
    }
    else {
      pump3Message = 0;
      sendMessagePump3 = 0;

      pushStyle();
      fill(255, 0, 0);
      text("Waiting", 685, 30);
      popStyle();
    }
    if ((millis()/1000) > savedTime) {
      stepLock = false;
    }
  }
  else {
    if (   pump3Control == 1) {

      sendMessagePump3 = 1;
    }
    else {
      sendMessagePump3 = 0;
    }
  }

 // println(sendMessagePump1 + " , " + sendMessagePump2 + " , " + sendMessagePump3);
  // println((millis()/1000) + " , " + pump3StepsLeft + " , " + whenToSendMessage   + " , " + pump3StepsTaken + " , " + ((millis()/1000) % whenToSendMessage) + " , " + (JM_Tune[currentSong].length()/1000) + " , " + (JM_Tune[currentSong].position()/1000));
  // println(" , " + timerlock[0] + " , " + timer[0].isFinished() + " , " + timerlock[1] + " , " + timer[1].isFinished() + " , " + timerlock[2] + " , " + timer[2].hasStarted() + " , " + timerlock[3] + " , " + timer[3].hasStarted()+ " , " + timerlock[4] + " , " + timer[4].hasStarted());


  //println(timer[whichTimerPump2+5].timeLeft());
  // print(millis()/1000);
  // println(" , " + timerlock[0] + " , " + timer[0].isFinished() + " , " + timerlock[1] + " , " + timer[1].isFinished() + " , " + timerlock[2] + " , " + timer[2].hasStarted() + " , " + timerlock[3] + " , " + timer[3].hasStarted()+ " , " + timerlock[4] + " , " + timer[4].hasStarted());
}

