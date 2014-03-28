/*************************************************************************************
 **                                                                                  **
 **                               Light Values                                       **
 **                                                                                  **
 *************************************************************************************/
void light() {  
  pushStyle();
   colorMessage = int(map(musicAverageValueMapped, 0, 100, 0, 255));
  if (colorMessage > 255) {
    colorMessage = 255;
  }
  fill(colorMessage);
  rect (600, 489, 800, 800);
  popStyle();
}

