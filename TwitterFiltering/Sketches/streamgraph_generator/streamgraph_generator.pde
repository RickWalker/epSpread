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

boolean     isGraphCurved = true; // catmull-rom interpolation
int         seed          = 28;   // random seed

float       DPI           = 400;
float       widthInches   = 3.5;
float       heightInches  = 1.5;
int         numLayers     = 13;
int         layerSize     = 21;

LayerLayout layout;
LayerSort   ordering;
ColorPicker coloring;

Layer[]     layers;

void setup() {

  size(int(widthInches*DPI), int(heightInches*DPI));
  smooth();
  noLoop();


  //Get data
  TweetFrequencies[] tweetFrequencies = loadCSV("output.csv", numLayers); 

   println("Tweet Frequency name : " + tweetFrequencies[0].getName());
      for (int i=0; i<tweetFrequencies[0].getData().size(); i++) {
        println(tweetFrequencies[0].getData().get(i));
      }

   //place in layers
   layers = new Layer[numLayers];

    for (int l = 0; l < numLayers; l++) {
      String name   = tweetFrequencies[l].getName();
      float[] size  = new float[layerSize];
            
      size = new float[layerSize];
      
      for(int j=0; j<layerSize; j++)
      {
      size[j] =  (float(tweetFrequencies[l].getData().get(j)) / float(tweetFrequencies[l].getTotalTweets()) ); // needs to be normalized (value depends on name)
     // size[j] = float(tweetFrequencies[l].getData().get(j));
      }
     
      
      layers[l]  = new Layer(name, size);
    }

  // ORDER DATA
  //ordering = new LateOnsetSort();
  //ordering = new VolatilitySort();
  ordering = new InverseVolatilitySort();
  //ordering = new BasicLateOnsetSort();
  //ordering = new NoLayerSort();

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
  
  
  colours.add(color(77, 175, 74));
  colours.add(color(55, 126, 184));
  colours.add(color(179, 222, 105));
  colours.add(color(252, 205, 229)); 
  colours.add(color(217, 217, 217)); 
  colours.add(color(188, 128, 189)); 
  colours.add(color(204, 235, 197)); 
  colours.add(color(255, 237, 111));
   colours.add(color(141, 211, 199));
  colours.add(color(255, 255, 179));
  colours.add(color(190, 186, 218)); 
  colours.add(color(251, 128, 114)); 
  colours.add(color(128, 177, 211)); 
  colours.add(color(253, 180, 98));

  
  //Give each layer a unique colour
  for(int i=0; i<numLayers; i++)
    layers[i].rgb = getRGB(int(red(colours.get(i))), int(green(colours.get(i))), int(blue(colours.get(i))), 255);

    
  

  //=========================================================================

  // calculate time to generate graph
  long time = System.currentTimeMillis();

  // generate graph
 // layers = data.make(numLayers, layerSize);
  layers = ordering.sort(layers);
  layout.layout(layers);
  //coloring.colorize(layers);

  // fit graph to viewport
  scaleLayers(layers, 10, height - 10);

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


int getRGB(int r, int g, int b, int a){
  
 int value = ((a & 0xFF) << 24) |
((r & 0xFF) << 16) |
((g & 0xFF) << 8) |
((b & 0xFF) << 0);

return value;
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

  background(255);
  noStroke();

  // calculate time to draw graph
  long time = System.currentTimeMillis();

  // generate graph
  for (int i = 0; i < n; i++) {
    start = max(0, layers[i].onset - 1);
    end   = min(m - 1, layers[i].end);
    pxl   = i == lastLayer ? 0 : 1;

    // set fill color of layer
    fill(layers[i].rgb);

    // draw shape
    beginShape();

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

  // give report
  long layoutTime = System.currentTimeMillis() - time;
  println("Draw Time: " + layoutTime + "ms");
}

void graphVertex(int point, float[] source, boolean curve, boolean pxl) {
  float x = map(point, 0, layerSize - 1, 0, width);
  float y = source[point] - (pxl ? 1 : 0);
  if (curve) {
    curveVertex(x, y);
  } else {
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
