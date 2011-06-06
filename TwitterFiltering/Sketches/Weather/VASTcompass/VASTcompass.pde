// set up font storage
PFont f;

void setup() {
  size(600,600);
  f = createFont("Arial",30, true); // name, size, antialiased?
}

void draw() {
  background(255); // background colour
  
  drawCompass();
  
  // set arrow direction
  pushMatrix();
  translate(300,300);
  float rAngle = atan2(mouseY - 300, mouseX - 300);
  rotate(rAngle + HALF_PI);
  compassArrow();
  popMatrix();
}

void drawCompass() {
  // letters
  textFont(f); // font to use
  fill(0); // font colour
  text("N",290,40); // string, x, y
  text("E",560,310);
  text("S",290,580);
  text("W",15,310);
  
  // main circle
  // centre, centre, width, height
  fill(200,200,200);
  ellipse(300,300,450,450);
  
  // halfway arrows (clockwise from top left arrow)
  fill(100,100,255);
  beginShape();
  vertex(150,150); // top-left point
  vertex(300,225); // mid
  vertex(450,150); // top-right point
  vertex(375,300); // mid
  vertex(450,450); // lower-right point
  vertex(300,375); // mid
  vertex(150,450); // lower-left point
  vertex(225,300); // mid
  endShape(CLOSE);
  
  // NESW arrows - (clockwise from top left line)
  fill(0);
  // TOP RIGHT
  beginShape();
  vertex(300,50); // top point
  vertex(350,250); // top-right midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  // RIGHT LOWER
  beginShape();
  vertex(550,300); // right point
  vertex(350,350); // bottom-right midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  // BOTTOM LEFT
  beginShape();
  vertex(300,550); // bottom point
  vertex(250,350); // bottom-left midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  // LEFT UPPER
  beginShape();
  vertex(50,300); // left point
  vertex(250,250); // top-left midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  
  fill(255);
  // TOP LEFT
  beginShape();
  vertex(300,50); // top point
  vertex(250,250); // top-left midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  // RIGHT UPPER
  beginShape();
  vertex(550,300); // right point
  vertex(350,250); // top-right midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  // BOTTOM RIGHT
  beginShape();
  vertex(300,550); // bottom point
  vertex(350,350); // bottom-right midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
  // LEFT LOWER
  beginShape();
  vertex(50,300); // left point
  vertex(250,350); // bottom-left midpoint
  vertex(300,300); // middle point
  endShape(CLOSE);
}

// draw the compass arrow
void compassArrow() {
  // UPPER
  fill(255,100,100);
  beginShape();
  vertex(0,-200); // top point
  vertex(-20,0); // top-left
  vertex(0,0); // middle point
  vertex(20,0); // top-right
  endShape(CLOSE);
  // LOWER
  fill(255);
  beginShape();
  vertex(0,200); // bottom point
  vertex(-20,0); // bottom-left
  vertex(0,0); // middle point
  vertex(20,0); // bottom-right
  endShape(CLOSE);
  // middle point
  fill(255);
  ellipse(0,0,10,10);
}
