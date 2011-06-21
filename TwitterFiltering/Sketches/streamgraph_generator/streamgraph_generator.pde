/**
 * streamgraph_generator
 * Processing Sketch
 * Explores different stacked graph layout, ordering and coloring methods
 * Used to generate example graphics for the Streamgraph paper
 *
 * Press Enter to save image
 *
 * @author Lee Byron
 * @author Martin Wattenberg
 */

import processing.opengl.*;
boolean     isGraphCurved = true; // catmull-rom interpolation
int         seed          = 28;   // random seed

float       DPI           = 400;
float       widthInches   = 3.2;
float       heightInches  = 2.4;
int         numLayers     = 1;
int         layerSize     = 20;

int layerTop;
int layerBottom;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int xmin;
int xmax;
int ymin;
int ymax;
int x = 450;
int y = 20;


int selectedDay = 0;

PFont font = createFont("Calibri",20);
boolean normalise = false;
boolean bMouseClicked =false;      
      
      
LayerLayout layout;
LayerSort   ordering;
ColorPicker coloring;
TweetFrequencies[] tweetFrequencies;
TweetFrequencies[] tweetFrequenciesHours;
ArrayList<Integer> colours = new ArrayList<Integer>();

Layer[]     layers;

void setup() {

  plotX1 = x; 
  plotX2 = x + 350;
  labelX = x + 50;
  plotY1 = y ;
  plotY2 = y + 320;
  labelY = y + height - (height * 0.26) + 50;

  
  size(int(widthInches*DPI), int(heightInches*DPI), OPENGL);
  smooth();
  //noLoop();

  //Get data
    tweetFrequencies = loadCSV("days.csv", numLayers); 
    tweetFrequenciesHours = loadCSV("hours.csv", numLayers); 

  setupColours();

  //set colours
  for(int j=0; j<numLayers; j++){
   tweetFrequencies[j].setLayerColour(colours.get(j)); 
   tweetFrequenciesHours[j].setLayerColour(colours.get(j)); 
  }

  //place in layers
  layers = new Layer[numLayers];

  for (int l = 0; l < numLayers; l++) {
    String name   = tweetFrequencies[l].getName();
    float[] size  = new float[layerSize];

    size = new float[layerSize];

    size[0] = 6;
    size[1] = 2;
    size[2] = 4;
    size[3] = 2;
    size[4] = 4;
    size[5] = 1;
    size[6] = 1;
    size[7] = 6;
    size[8] = 3;
    size[9] = 3;
    size[10] = 6;
    size[11] = 3;
    size[12] = 4;
    size[13] = 2;
    size[14] = 2;
    size[15] = 3;
    size[16] = 2;
    size[17] = 3;
    size[18] = 771;
    size[19] = 11;
   




    for (int j=0; j<layerSize; j++)
    {    
      float normalized;

     // normalized = (size[j] - tweetFrequencies[l].getMinTweets() ) / (tweetFrequencies[l].getMaxTweets() - tweetFrequencies[l].getMinTweets()); 
      //normalized = normalized / float(getPopulationDensity(tweetFrequencies[l].getName()));
      normalized = size[j];


      size[j] = normalized;
    }



    //println(tweetFrequencies[l].getName() + " " + float(tweetFrequencies[l].getMaxTweets()));

    layers[l]  = new Layer(name, size);
  }

  // ORDER DATA
  // ordering = new LateOnsetSort();
  //ordering = new VolatilitySort();
  //ordering = new InverseVolatilitySort();
  // ordering = new BasicLateOnsetSort();
  ordering = new NoLayerSort();

  // LAYOUT DATA
  layout   = new StreamLayout();
  //layout   = new MinimizedWiggleLayout();
  //layout   = new ThemeRiverLayout();
  //layout   = new StackLayout();

  // COLOR DATA
  //coloring = new LastFMColorPicker(this, "layers-nyt.jpg");
  //coloring = new LastFMColorPicker(this, "layers.jpg");
  //coloring = new RandomColorPicker(this);

  ArrayList<Integer> colours = new ArrayList<Integer>();

  //Give each layer a unique colour
  for (int i=0; i<numLayers; i++)
  {
    colours.add(tweetFrequencies[i].getLayerColour());
    layers[i].rgb = getRGB(int(red(colours.get(i))), int(green(colours.get(i))), int(blue(colours.get(i))), 255);
  }


  //=========================================================================

  // calculate time to generate graph
  long time = System.currentTimeMillis();

  // generate graph
  // layers = data.make(numLayers, layerSize);
  layers = ordering.sort(layers);
  layout.layout(layers);
  //coloring.colorize(layers);


  layerTop = 700;
  layerBottom = height - 10;

  // fit graph to viewport
  scaleLayers(layers, layerTop, layerBottom);
  
  

  // give report
  long layoutTime = System.currentTimeMillis()-time;
  int numLayers = layers.length;
  int layerSize = layers[0].size.length;
  println("Data has " + numLayers + " layers, each with " +
    layerSize + " datapoints.");
  println("Layout Method: " + layout.getName());
  println("Ordering Method: " + ordering.getName());
  println("Coloring Method: " + layout.getName());
  println("Elapsed Time: " + layoutTime + "ms");
}


int getRGB(int r, int g, int b, int a) {

  int value = ((a & 0xFF) << 24) |
    ((r & 0xFF) << 16) |
    ((g & 0xFF) << 8) |
    ((b & 0xFF) << 0);

  return value;
}








void setupColours()
{ 
  colours.add(color(77, 175, 74));
  colours.add(color(55, 126, 184));
  colours.add(color(179, 222, 105));
  colours.add(color(252, 205, 229));
  colours.add(color(217, 217, 217));
  colours.add(color(188, 128, 189));
  colours.add(color(204, 235, 197) );
  colours.add(color(255, 237, 111));
  colours.add(color(141, 211, 199));
  colours.add(color(255, 255, 179));
  colours.add(color(190, 186, 218) );
  colours.add(color(251, 128, 114) );
  colours.add(color(128, 177, 211) );
  colours.add(color(253, 180, 98));
  
}






















// adding a pixel to the top compensate for antialiasing letting
// background through. This is overlapped by following layers, so no
// distortion is made to data.
// detail: a pixel is not added to the top-most layer
// detail: a shape is only drawn between it's non 0 values
void draw() {


  int n = layers.length;
  int m = layers[0].size.length;
  int start;
  int end;
  int lastIndex = m - 1;
  int lastLayer = n - 1;
  int pxl;


  background(235, 238, 243);
  //background(255);
  noStroke();
  
  
  // calculate time to draw graph
  long time = System.currentTimeMillis();



  // generate graph
  for (int i = 0; i < n; i++) {
    start = max(0, layers[i].onset - 1);
    end   = min(m-1, layers[i].end);
    pxl   = i == lastLayer ? 0 : 1;

    // set fill color of layer
    fill(layers[i].rgb);


    // draw shape
    beginShape(POLYGON);

 
    // draw top edge, left to right
    graphVertex(start, layers[i].yTop, isGraphCurved, i == lastLayer);

    for (int j = start; j <= end; j++) {
      graphVertex(j, layers[i].yTop, isGraphCurved, i == lastLayer);       
    }
    graphVertex(end, layers[i].yTop, isGraphCurved, i == lastLayer);

  
   // draw bottom edge, right to left
    graphVertex(end, layers[i].yBottom, isGraphCurved, false);

    for (int j = end; j >= start; j--) {
      graphVertex(j, layers[i].yBottom, isGraphCurved, false);
    }
    graphVertex(start, layers[i].yBottom, isGraphCurved, false);

    endShape(CLOSE);
  }
 


//Draw day rectangles
    for(int k=0; k<21; k++){
  
  stroke(0,0,0,20);
  float rectSize = float(width)/21.0f;
    
  if (k % 2 == 0)  
    fill(0,0,0,10); //even
  else
    fill(0,0,0,5); //even
    
  if(  (((rectSize * (k+1)) - mouseX) <= rectSize) &&  (mouseX - ((rectSize * (k))) < rectSize) && (mouseY > layerTop) )
  {
    selectedDay = k;
    fill(0,0,255,20);
  }
    
  rect(rectSize * k, layerTop, rectSize, layerBottom);
  }



  drawYLabels();
  drawXLabels();
  drawHoursGraph();

  drawLegend();

  // give report
  long layoutTime = System.currentTimeMillis() - time;
  //println("Draw Time: " + layoutTime + "ms");
  
  bMouseClicked = false;
}

void graphVertex(int point, float[] source, boolean curve, boolean pxl) {
  float x = map(point, 0, layerSize - 1, 0, width);
  float y = source[point] - (pxl ? 1 : 0);
  if (curve) {
    stroke(0);
    strokeWeight(3);
    curveVertex(x, y);
  } 
  else {
    vertex(x, y);
  }
}

void scaleLayers(Layer[] layers, int screenTop, int screenBottom) {
  // Figure out max and min values of layers.
  float min = Float.MAX_VALUE;
  float max = Float.MIN_VALUE;
  for (int i = 0; i < layers[0].size.length; i++) {
    for (int j = 0; j < layers.length; j++) {
      min = min(min, layers[j].yTop[i]);
      max = max(max, layers[j].yBottom[i]);
    }
  }

  float scale = (screenBottom - screenTop) / (max - min);
  for (int i = 0; i < layers[0].size.length; i++) {
    for (int j = 0; j < layers.length; j++) {
      layers[j].yTop[i] = screenTop + scale * (layers[j].yTop[i] - min);
      layers[j].yBottom[i] = screenTop + scale * (layers[j].yBottom[i] - min);
    }
  }
}

void keyPressed() {
  if (keyCode == ENTER) {
    println();
    println("Rendering image...");
    String fileName = "images/streamgraph-" + dateString() + ".png";
    save(fileName);
    println("Rendered image to: " + fileName);
  }

  // hack for un-responsive non looping p5 sketches
  if (keyCode == ESC) {
    redraw();
  }
}

String dateString() {
  return year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "@" +
    nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
}









void drawLegend(){
 
  int gap = 25;
  int x_offset = 80;
  int y_offset = 60;
  int y_pos = 0;
  textFont(font); 
  
  
 
  textAlign(LEFT, CENTER);
  fill(30);
  text("Filter Terms", 30, 35);

  
  for(int i=0; i<tweetFrequencies.length; i++){
    
    int alphaVal;
    y_pos = i * gap;
    
    if(i >= 7){
      y_pos = (i-7) * gap;
      x_offset = 230;
    }
    
    if(tweetFrequencies[i].isActive())
      alphaVal = 255;
    else
      alphaVal = 50;
        
    color c = tweetFrequencies[i].getLayerColour();
      
    //where is the mouse?
    
     if(    (mouseX > x_offset) && (mouseX < x_offset + 150) && (mouseY > y_pos + y_offset) && (mouseY < (y_pos + y_offset + 20))   )  //100 accounts for text length
     {
     if(!tweetFrequencies[i].isActive())
       alphaVal = 130;
       
     if(bMouseClicked){
       if(tweetFrequencies[i].isActive())
         tweetFrequencies[i].setActive(false);
       else
         tweetFrequencies[i].setActive(true);
         
      int activeCount = 0;   
     for(TweetFrequencies a: tweetFrequencies)
     {
     if(a.isActive())
       activeCount++;
     }    
     if(activeCount > 0)    
       generateNewStreamGraph();    
         
     }
     }
      
    stroke(80,80,80,alphaVal);
    strokeWeight(1.5);
    fill(red(c), green(c), blue(c), alphaVal);
  
    rect(x_offset,y_pos + y_offset,20,20);
    fill(0,0,0,alphaVal);
    text(tweetFrequencies[i].getName(),x_offset + 30,y_pos + y_offset + 10);
    }
    
   int numFilterTerms = tweetFrequencies.length;
   if(numFilterTerms > 7)
     numFilterTerms = 7;
    
   fill(30);
   
   int optionsX = 30;
   int optionsY = numFilterTerms * (gap + 12);
   
   text("Options", optionsX, optionsY);
  
   drawOptionButtons(optionsX, optionsY);
  
}



void mouseClicked()
{
  bMouseClicked = true;
  
}





int getPopulationDensity(String name){
 
      int popDensity = 100000;
      
      if(name.equals("cornertown"))
        popDensity = 59524;
      if(name.equals("downtown"))
        popDensity = 89286;
      if(name.equals("eastside"))
        popDensity = 178571;
      if(name.equals("lakeside"))
        popDensity = 297619;
      if(name.equals("northville"))
        popDensity = 119048;
      if(name.equals("plainville"))
        popDensity = 208333;
      if(name.equals("riverside"))
        popDensity = 238095;
      if(name.equals("smogtown"))
        popDensity = 29762;     
       if(name.equals("southville"))
        popDensity = 178571;
      if(name.equals("suburbia"))
        popDensity = 446429;
      if(name.equals("uptown"))
        popDensity = 29762;
      if(name.equals("villa"))
        popDensity = 178571;
      if(name.equals("westside"))
        popDensity = 148810;
  
  return popDensity;
}



void drawHoursGraph(){
  
  fill(0,0,0,5);
  stroke(0,0,0,80);
  rect(plotX1, plotY1, plotX2, plotY2 - 20); 
  
  ymin = Integer.MAX_VALUE;
  ymax = Integer.MIN_VALUE;
  
  xmin = selectedDay * 24;
  xmax = xmin + 24;
  
  for(int k=0; k<numLayers; k++)
  {
    //get data for this layer
    if(tweetFrequencies[k].isActive())
    {
    ArrayList<Integer> layerData = tweetFrequenciesHours[k].getData();
    
    //find min and max
    for(int l=xmin; l<xmax; l++){
      if( layerData.get(l) < ymin)
        ymin = layerData.get(l);
      
      if( layerData.get(l) > ymax)
        ymax = layerData.get(l);
     }
    }
  }
  

  
  
  for(int i = numLayers-1 ; i >=0  ; i--) {
        if(tweetFrequencies[i].isActive())
    {
    
      color c = tweetFrequenciesHours[i].getLayerColour();
      strokeWeight(2);
      stroke(c);
 
      noFill();
      float tx, ty;
      float value;
      beginShape();

      if(normalise == true){
      ymin = 0;
      ymax = 1;
      }

      for(int j = xmin; j <= xmax; j++) {
        value = tweetFrequenciesHours[i].getData().get(j);
        if(value <= -1) value = 0;
        //plot it!
        tx = map(j, xmin, xmax, plotX1, plotX2 + x);
        if(normalise) {
          ty = map(value, ymin, ymax, plotY2, plotY1);
          if(i == 2)
          {
            //println("PlotY2 = " + plotY2);
            // println("PlotY1 = " + plotY1);
            
            println("Ty is : " + ty);
          }
        }
        else {
          ty = map(value, ymin, ymax, plotY2, plotY1);
        }
        //println("Point " + tx + ", " + ty + " and value " + value);
        if(ty>plotY2) {
          println("Uh oh error!");
        }
        vertex(tx, ty);
        //}
      } 
      
      //vertex(plotX2, plotY2);

      endShape();
      strokeWeight(0);
      stroke(0);
  
  }
}

}




void drawXLabels() {
  
    fill(0);
    textSize(10);
    textAlign(CENTER);

    // Use thin, gray lines to draw the grid
    stroke(210);
    strokeWeight(1);

    //int xLineInterval = int ( (xmax - xmin) /5.0 ); //5 lines over the whole set
    //println(xLineInterval);

    for (int row = 0; row <= 24; row++) {
        float val = map(row, 0, 24, plotX1, plotX2 + x);
        text(row, val, plotY2 + textAscent() + 10);
        line(val, plotY1, val, plotY2);
    }
    
  }











void drawYLabels() {
    fill(0);
    textSize(10);
    textAlign(RIGHT);

    stroke(128);
    strokeWeight(1);

    int powerOfTen = ceil(log(ymax-ymin)/log(10));

    float volumeIntervalMinor = int(pow(10, powerOfTen-2)); 
    volumeIntervalMinor = max(volumeIntervalMinor, 1); //always at least 1
    //int volumeIntervalMinor = powerOfTen * int(pow(10, powerOfTen-2));
    float volumeInterval = volumeIntervalMinor * 5;
    //println("Intervals are " + volumeIntervalMinor + " and " + volumeInterval);
   
   
    if(normalise) {
      volumeInterval = 1.0;
      volumeIntervalMinor = 0.25;
      ymin = 0; 
      ymax = 1;
    }

    for (float v = ymin; v <= (ymax); v += volumeIntervalMinor) {
      //if (v % volumeIntervalMinor == 0) {     // If a tick mark
      float val = map( v, ymin, ymax, plotY2, plotY1);  
      if ( v % volumeInterval == 0) {        // If a major tick mark
        float textOffset = textAscent()/2;  // Center vertically
        if (v == ymin) {
          textOffset = 0;                   // Align by the bottom
        } 
        else if (val == ymax) {
          textOffset = textAscent();        // Align by the top
        }
        text(floor(v), plotX1 - 10, val + textOffset);
        line(plotX1 - 4, val, plotX1, val);     // Draw major tick
        //println(v);
      } 
      else {
        line(plotX1 - 2, val, plotX1, val);   // Draw minor tick
      }
      //println(v);
      //}
    }
  }
  
  
  
void generateNewStreamGraph(){

  ArrayList<Integer> activeLayerIndex = new ArrayList<Integer>();

  for(int i=0; i<numLayers; i++)
  {
  if(tweetFrequencies[i].isActive())
     activeLayerIndex.add(i);
  }

  int numActiveLayers = activeLayerIndex.size();

  //place in layers
  layers = new Layer[numActiveLayers];
  
  println("number of active layers : " + numActiveLayers);


  for (int l = 0; l < numActiveLayers; l++) {
    
    int layerIndex = activeLayerIndex.get(l);
    
    String name   = tweetFrequencies[layerIndex].getName();
    float[] size  = new float[21];

    size = new float[21];

    for (int j=0; j<22000; j++)
    {    
      float normalized;

      normalized = (tweetFrequencies[layerIndex].getData().get(j) - tweetFrequencies[layerIndex].getMinTweets() ) / (tweetFrequencies[layerIndex].getMaxTweets() - tweetFrequencies[layerIndex].getMinTweets()); 
     // normalized = (
      
      //normalized = normalized / float(getPopulationDensity(tweetFrequencies[l].getName()));
     // normalized = tweetFrequencies[layerIndex].getData().get(j);

      size[j] = normalized;
    }

    //println(tweetFrequencies[l].getName() + " " + float(tweetFrequencies[l].getMaxTweets()));

    layers[l]  = new Layer(name, size);
  }

   // ordering = new LateOnsetSort();
  //ordering = new VolatilitySort();
  //ordering = new InverseVolatilitySort();
  // ordering = new BasicLateOnsetSort();
  ordering = new NoLayerSort();
  
  // LAYOUT DATA
  layout   = new StreamLayout();
  
  layers = ordering.sort(layers);
  layout.layout(layers);


  layerTop = 400;
  layerBottom = height;

  // fit graph to viewport
  scaleLayers(layers, layerTop, layerBottom);
  
  
   //Give each layer a unique colour
  for (int q=0; q<activeLayerIndex.size(); q++)
  {
    int layerIndex = activeLayerIndex.get(q);
    //println("getting colour : " + layerIndex);
    
    layers[q].rgb = getRGB(int(red(colours.get(layerIndex))), int(green(colours.get(layerIndex))), int(blue(colours.get(layerIndex))), 255);
  }
} 


void drawOptionButtons(int _x, int _y)
{
  int offsetX = _x + 60;
  int offsetY = _y + 30;
  int buttonSize = 20;
  float alphaVal = 80;
  
  
  // ------- Normalise button ---------
    

  if( abs(mouseX - offsetX) < buttonSize) 
    if( abs(mouseY - offsetY) < buttonSize) {
      alphaVal = 150;
      if(bMouseClicked)
        normalise = !normalise;
    }
    
      stroke(100);
  
      if(normalise)
        fill(100,100,255,alphaVal);
      else
        fill(200,200,200,alphaVal);  
  
    
    ellipse(offsetX, offsetY, buttonSize, buttonSize);
  
  fill(0);
  text("Normalise", offsetX + 15, offsetY);
  
  // ------- Next button ---------  
  
  alphaVal = 80;
  offsetY += 30;
  
  fill(200,200,200,alphaVal); 
  ellipse(offsetX, offsetY, buttonSize, buttonSize);
  
  fill(0);
  text("Party", offsetX + 15, offsetY);
  
  
  
  
}
  
