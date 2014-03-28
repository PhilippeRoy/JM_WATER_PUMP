// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 10-5: Object-oriented timer

class Timer {

  int savedTime = 1000000000; // When Timer started
  int totalTime; // How long Timer should last

  Timer() {
  }

  // Starting the timer

 void start(int tempTotalTime) {
    totalTime = tempTotalTime;
    // When the timer starts it stores the current time in milliseconds.
    savedTime = second();
  }
  boolean hasStarted() { 
    // Check how much time has passed
    if (second() > savedTime) {
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
    int passedTime = second()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } 
    else {
      return false;
    }
  }
}

