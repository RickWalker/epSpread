import java.lang.Math.*;

class StreamGraphRange {

  int x = 0;
  int y = 0;
  int mWidth = 0;
  int mHeight = 0;
  int sliderSize = 100;
  int gapY = 50;
  int offsetX = 5;
  //  float DPI = 400;
  PGraphics buffer;
  PImage streamGraphImg;

  int numLayers = 0;
  int layerSize = 21;

  LayerLayout layout;
  LayerSort   ordering;
  ColorPicker coloring;
  Layer[] layers;

  boolean isGraphCurved = true; // catmull-rom interpolation

  ArrayList<String> weatherInfo = new ArrayList<String>() ;
  ArrayList<String> windDirection = new ArrayList<String>() ;
  ArrayList<String> windSpeed = new ArrayList<String>() ;

  TwitterFilteringComponent parent;

  StreamGraphRange(TwitterFilteringComponent _parent) {

    this.parent = _parent; 
    updateScaling();
    buffer = createGraphics(imgX, sliderSize, JAVA2D);
    createStreamGraph();
    //currDay = 0;
    loadWeatherData();
  }  

  void loadWeatherData() {
    //weatherFont = createFont("Arial", 26, true); // name, size, antialiased?
    println("Grabbing weather data from db"); 
    // load the sqlite-JDBC driver using the current class loader
    try {
      Class.forName("org.sqlite.JDBC");
    }
    catch(ClassNotFoundException e) {
      println("Weather couldn't find database!");
    }
    Connection connection = null;
    try
    {
      // create a database connection
      connection = DriverManager.getConnection("jdbc:sqlite:"+sketchPath("VAST2011_MC1.sqlite"));
      Statement statement = connection.createStatement();
      statement.setQueryTimeout(30);  // set timeout to 30 sec.

      ResultSet rs = statement.executeQuery("SELECT * FROM weather");
      while (rs.next ())
      {
        // read the result set
        weatherInfo.add(rs.getString("Weather"));
        windDirection.add(rs.getString("Wind_Direction"));
        windSpeed.add(rs.getString("Average_Wind_Speed"));
      }
    }
    catch(SQLException e)
    {
      // if the error message is "out of memory", 
      // it probably means no database file is found
      System.err.println(e.getMessage());
    }
    finally
    {
      try
      {
        if (connection != null)
          connection.close();
      }
      catch(SQLException e)
      {
        // connection close failed.
        System.err.println(e);
      }
    }
  }  


  void setup() {
  }


  void createStreamGraph() {

    ArrayList<TweetSet> tweetSets = parent.tweetSetManager.getTweetSetList();
    numLayers = tweetSets.size();
    println("number of streamgraph layers to generate : "+ numLayers);

    //create requisite number of layers
    layers = new Layer[numLayers];

    for (int l = 0; l < numLayers; l++) {
      String name   = tweetSets.get(l).getSearchTerms();
      float[] size  = new float[layerSize];
      size = new float[layerSize];

      for (int j=0; j<layerSize; j++) {    
        float normalized;
        int freqOnDay = tweetSets.get(l).getFrequencyOnDay(j);
        print(freqOnDay);
        //Find max and min
        int[] frequencies = new int[21]; 
        frequencies = tweetSets.get(l).getTweetDayFrequencies().clone();


        Arrays.sort(frequencies);  
        int minDayFreq = frequencies[0];
        int maxDayFreq = frequencies[frequencies.length-1]; 

        //normalize and store data
        //normalized = float(freqOnDay - minDayFreq ) / float(maxDayFreq - minDayFreq); 
        println(freqOnDay);
        normalized = freqOnDay+1;

        size[j] = normalized;
        println(" (" + normalized + ")");
      }

      //set this layer    
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


    //Give each layer a unique colour
    for (int i=0; i<numLayers; i++)
    {
      color layerColour = tweetSets.get(i).getColour(); 
      layers[i].rgb = getRGB(int(red(layerColour)), int(green(layerColour)), int(blue(layerColour)), 255);
    }


    // calculate time to generate graph
    long time = System.currentTimeMillis();

    // generate graphs
    if (layers.length > 0) {
      layers = ordering.sort(layers);
      layout.layout(layers);
      // fit graph to viewport

      scaleLayers(layers, 0, int(sliderSize));

      // give report
      println();
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

    drawGraphToBuffer();
  }

  PImage getWeatherImage(String weatherType) {
    PImage toReturn = rain;
    // set correct image
    if (weatherType.equals("rain")) 
      toReturn = rain;

    if (weatherType.equals("showers")) 
      toReturn = showers;
    if (weatherType.equals("cloudy")) 
      toReturn = cloudy;
    if (weatherType.equals("clear")) 
      toReturn = clear;
    //image(clear, width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);

    return toReturn;
  }




  void scaleLayers(Layer[] layers, int screenTop, int screenBottom) {

    screenTop += 10 * parent.scaleFactorY;
    screenBottom -= 10 * parent.scaleFactorY;


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



  int getRGB(int r, int g, int b, int a) {

    int value = ((a & 0xFF) << 24) |
      ((r & 0xFF) << 16) |
      ((g & 0xFF) << 8) |
      ((b & 0xFF) << 0);

    return value;
  }



  void updateScaling() {

    if (parent.tweetSetManager.isWeatherViewActive()) //cheeky!
    {
      sliderSize = 50;
    }
    else
      sliderSize = 100;

    int imageOffsetX = parent.x + int(parent.imgPos.x * parent.scaleFactorX);
    int imageOffsetY = parent.y + int((parent.imgPos.y+imgY+gapY) * parent.scaleFactorY);  

    x=imageOffsetX;
    y=imageOffsetY;

    mWidth = int((imgX) * parent.scaleFactorX);
    mHeight = int((sliderSize) * parent.scaleFactorY);

    if (numLayers > 0)
      scaleLayers(layers, 0, int(sliderSize));
  }



  void graphVertex(int point, float[] source, boolean curve, boolean pxl) {
    float x = map(point, 0, layerSize - 1, 0, buffer.width);
    float y = source[point] - (pxl ? 1 : 0);

    buffer.beginDraw();
    if (curve) {
      //buffer.curveTightness(testVal);
      // stroke(0);
      // strokeWeight(3);
      buffer.curveVertex(x, y);
    } 
    else {
      buffer.vertex(x, y);
    }

    buffer.endDraw();
  }





  void drawDayRects() {
    //Draw day rectangles

      for (int k=0; k<20; k++) {

      buffer.stroke(0, 0, 0, 20);
      float rectSize = float(buffer.width)/20.0f;

      if (k % 2 == 0)  
        buffer.fill(0, 0, 0, 10); //even
      else
        buffer.fill(0, 0, 0, 5); //even

      buffer.rect((rectSize * k), 0, rectSize, sliderSize);
    }
  }

  void drawWeatherIcons() {
    fill(color(115, 162, 192));
    noStroke();
    PImage weatherImage = getWeatherImage(weatherInfo.get(0));

    rect(x, y+sliderSize*parent.scaleFactorY, mWidth, weatherImage.height*parent.scaleFactorY * 0.5f);   
    for (int k=0; k<20; k++) {
      //println("Drawing");
      float rectSize = float(buffer.width)/20.0f;
      weatherImage = getWeatherImage(weatherInfo.get(k));
      imageMode(CORNER);
      float imageOffset = (rectSize - (weatherImage.width/2))/2; 
      image(weatherImage, x + ((rectSize * k + imageOffset) * parent.scaleFactorX) + (offsetX * parent.scaleFactorX), y + (sliderSize * parent.scaleFactorY), weatherImage.width*parent.scaleFactorX * 0.5f, weatherImage.height*parent.scaleFactorY * 0.5f);
    } 

    /*fill(color(255, 0, 0));
     rect(x, y, mWidth, mHeight);
     fill(color(0,255,0));
     rect(x, y, sliderSize* parent.scaleFactorY, sliderSize* parent.scaleFactorY);*/
  }



  void draw() {
    updateScaling();

    //check if a tweet set has recently been removed
    if (layers.length > parent.tweetSetManager.getTweetSetListSize()) {
      createStreamGraph();
    }

    image(streamGraphImg, x + (offsetX * parent.scaleFactorX), y, mWidth, mHeight);

    if (parent.tweetSetManager.isWeatherViewActive()) //cheeky!
      drawWeatherIcons();
  }




  void drawGraphToBuffer() {

    updateScaling();
    int n = layers.length;


    buffer.beginDraw();
    buffer.background(235, 238, 243);
    buffer.noStroke();
    buffer.smooth();

    if (n > 0) {
      int m = layers[0].size.length;
      int start;
      int end;
      int lastIndex = m - 1;
      int lastLayer = n - 1;
      int pxl;

      // calculate time to draw graph
      long time = System.currentTimeMillis();



      // generate graph
      for (int i = 0; i < n; i++) {
        start = max(0, layers[i].onset - 1);
        end   = min(m - 1, layers[i].end);
        pxl   = i == lastLayer ? 0 : 1;

        // set fill color of layer
        buffer.fill(layers[i].rgb);


        // draw shape
        buffer.beginShape();

        // draw bottom edge, right to left
        graphVertex(end, layers[i].yBottom, isGraphCurved, false);
        for (int j = end; j >= start; j--) {
          graphVertex(j, layers[i].yBottom, isGraphCurved, false);
        }
        graphVertex(start, layers[i].yBottom, isGraphCurved, false);

        // draw top edge, left to right
        graphVertex(start, layers[i].yTop, isGraphCurved, i == lastLayer);
        for (int j = start; j <= end; j++) {
          graphVertex(j, layers[i].yTop, isGraphCurved, i == lastLayer);
        }
        graphVertex(end, layers[i].yTop, isGraphCurved, i == lastLayer);


        buffer.endShape(CLOSE);
      }
    }



    //rect(x, y, (imgX+6) * parent.scaleFactorX, (sliderSize * parent.scaleFactorY)); 
    drawDayRects();
    buffer.endDraw();

    // println("Buffer Width : " + buffer.width);
    // println("Buffer Height : " + buffer.height);
    streamGraphImg = buffer.get(0, 0, buffer.width, buffer.height);
    //image(streamGraphImg, x, y, mWidth, mHeight);
  }
}

