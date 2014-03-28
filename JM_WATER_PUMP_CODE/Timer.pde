// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 10-5: Object-oriented timer

class Timer {

  int savedTime = 0; // When Timer started
  int totalTime; // How long Timer should last
  int returnTime;
  
    Timer() {
  }

  // Starting the timer

    void start(int tempTotalTime) {
    totalTime = tempTotalTime;
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
    //  print(millis() + " , ");
  }
  boolean hasStarted() { 
    // Check how much time has passed
    if (millis() > savedTime) {
      return true;
    } 
    else {
      return false;
    }
  }
  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis() - savedTime;
    //println(abs(passedTime));
    if (passedTime > totalTime) {
      return true;
    } 
    else {
      return false;
    }
  }

  int timeLeft() {
    int adjustTime = (totalTime/1000)-((millis()/1000) - (savedTime/1000))  ;
    returnTime = adjustTime;
    return returnTime;
  }
}

