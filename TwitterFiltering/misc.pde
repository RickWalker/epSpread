
void rrect(float x, float y, float b, float h, float r, float t, String m)
{
// from http://processing.org/discourse/yabb2/YaBB.pl?action=dereferer;url=http://www.openprocessing.org/visuals/?visualID=7177  
  
  if(m == "MITTELPUNKT")
  {
    x = x - b / 2;
    y = y - h / 2;
  }
  //  if(r > b / 2 || r > h / 2) println("Radius zu groß.");
  beginShape();
  vertex(x, y + r);
  bezierVertex(x, y + r / t, x + r / t, y, x + r, y);
  vertex(x + b - r, y);
  bezierVertex(x + b - r / t, y, x + b, y + r / t, x + b, y + r);
  vertex(x + b, y + h - r);
  bezierVertex(x + b, y + h - r / t, x + b - r / t, y + h, x + b - r, y + h);
  vertex(x + r, y + h);
  bezierVertex(x + r / t, y + h, x, y + h - r / t, x, y + h - r);
  //  vertex(x, y + r);
  endShape(CLOSE);
}




// Generate a vertical gradient image
PImage generateGradient(color top, color bottom, int w, int h) {
  int tR = (top >> 16) & 0xFF;
  int tG = (top >> 8) & 0xFF;
  int tB = top & 0xFF;
  int bR = (bottom >> 16) & 0xFF;
  int bG = (bottom >> 8) & 0xFF;
  int bB = bottom & 0xFF;
 
  PImage bg = createImage(w,h,RGB);
  bg.loadPixels();
  for(int i=0; i < bg.pixels.length; i++) {
    int y = i/bg.width;
    float n = y/(float)bg.height;
    // for a horizontal gradient:
    // float n = x/(float)bg.width;
    bg.pixels[i] = color(
    lerp(tR,bR,n), 
    lerp(tG,bG,n), 
    lerp(tB,bB,n), 
    255); 
  }
  bg.updatePixels();
  return bg;
}
