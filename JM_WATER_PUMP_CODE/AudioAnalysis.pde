/*************************************************************************************
 **                                                                                  **
 **                               The Audio Analysis Section                         **
 **                                                                                  **
 *************************************************************************************/

void audioAnalysis() { // perform a forward FFT on the samples in JM_Tune's mix buffer
  // note that if JM_Tune were a MONO file, this would be the same as using JM_Tune.left or JM_Tune.right
  fftLin.forward( JM_Tune[currentSong].mix );

  // draw the full spectrum
  noFill();
  for (int i = 0; i < 200; i++)
  {  
    stroke(255); //colour of the lines
    line(i, audioSpectrumHeight, i, audioSpectrumHeight - fftLin.getBand(i)*spectrumScale); //draw the white lines
  }

  // no more outline, we'll be doing filled rectangles from now

  // draw the linear averages
  // since linear averages group equal numbers of adjacent frequency bands
  // we can simply precalculate how many pixel wide each average's 
  // rectangle should be.
  // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better       fill(255, 0, 0);

  float musicAverage = (fftLin.getAvg(0));
  musicAverageValueMapped = (int(map(musicAverage, 0, offset, 0, 100 ))); // the mapped average music level
  pushStyle();
  noStroke();
  //println(musicAverageValueMapped)
  fill(255, 0, 0);
  rect(0, audioAverageHeight, 200, audioAverageHeight - (musicAverageValueMapped*2));
  popStyle();
  pushStyle();
  textSize(50);
  fill(255);
  //change to it stayed at increments of ten
  for (int i = 0; i <= 10; i++) {
    if (musicAverageValueMapped > (i*10)) {
      pushStyle();
      fill(0);
      rect (50, 250, 150, 350);
      popStyle();
      textAlign(CENTER);

      text(i*10, 100, 315);
    }
  }
  popStyle();
}

