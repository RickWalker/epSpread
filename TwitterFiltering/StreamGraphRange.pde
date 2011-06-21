class StreamGraphRange {

  int x = 0;
  int y = 0;
  int mWidth = 0;
  int mHeight = 0;
  int sliderSize = 110;
  int gapY = 40;
  float DPI = 400;

  int numLayers = 0;
  int layerSize = 21;

  LayerLayout layout;
  LayerSort   ordering;
  ColorPicker coloring;
  Layer[] layers;


  boolean isGraphCurved = false; // catmull-rom interpolation

  ArrayList<String> weatherInfo = new ArrayList<String>() ;
  ArrayList<String> windDirection = new ArrayList<String>() ;
  ArrayList<String> windSpeed = new ArrayList<String>() ;

  TwitterFilteringComponent parent;

  StreamGraphRange(TwitterFilteringComponent _parent) {

    this.parent = _parent; 
    //x = _x;
    //y = _y;
    //mWidth = _width;
    //mHeight = _height;
    updateScaling();
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
        normalized = float(freqOnDay - minDayFreq ) / float(maxDayFreq - minDayFreq); 
        normalized = freqOnDay;

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

      scaleLayers(layers, y, int(y + (sliderSize * parent.scaleFactorY)));

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

    int imageOffsetX = parent.x + int(parent.imgPos.x-3 * parent.scaleFactorX);
    int imageOffsetY = parent.y + int(parent.imgPos.y * parent.scaleFactorY) + int(imgY*parent.scaleFactorY) + int(gapY * parent.scaleFactorY);  

    x=imageOffsetX;
    y=imageOffsetY;

    mWidth = int((imgX) * parent.scaleFactorX);
    mHeight = int((sliderSize) * parent.scaleFactorY);

    if (numLayers > 0)
      scaleLayers(layers, y, int(y + (sliderSize * parent.scaleFactorY)));
  }



  void graphVertex(int point, float[] source, boolean curve, boolean pxl) {
    float x = map(point, 0, layerSize - 1, this.x, this.mWidth+this.x);
    float y = source[point] - (pxl ? 1 : 0);
    if (curve) {
      curveVertex(x, y);
    } 
    else {
      vertex(x, y);
    }
  }





  void drawDayRects() {
    //Draw day rectangles
    for (int k=0; k<20; k++) {

      stroke(0, 0, 0, 20);
      float rectSize = float(this.mWidth)/20.0f;

      if (k % 2 == 0)  
        fill(0, 0, 0, 10); //even
      else
        fill(0, 0, 0, 5); //even

      /*    
       //This only works when there's only one (full size) component
       if(  (((rectSize * (k+1)) - mouseX) <= rectSize) &&  (mouseX - ((rectSize * (k))) < rectSize) && (mouseY > this.y) && (mouseY < (this.y + this.mHeight)))
       {
       //selectedDay = k;
       fill(0,0,255,20);
       }
       */

      rect(x + (rectSize * k), y, rectSize, sliderSize * parent.scaleFactorY);
      //draw weather!
      PImage weatherImage = getWeatherImage(weatherInfo.get(k));
      image(weatherImage, x + (rectSize * k) + (rectSize-weatherImage.width*parent.scaleFactorX)/2, y+sliderSize * parent.scaleFactorY, weatherImage.width*parent.scaleFactorX, weatherImage.height*parent.scaleFactorY);
    }
  }





  void draw() {

    updateScaling();
    int n = layers.length;

    if (n > 0) {
      int m = layers[0].size.length;
      int start;
      int end;
      int lastIndex = m - 1;
      int lastLayer = n - 1;
      int pxl;


      // background(235, 238, 243);
      //background(255);
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
    }







    fill(0, 0, 0, 0); //blank
    stroke(170);
    strokeWeight(1.0);

    //rect(x, y, (imgX+6) * parent.scaleFactorX, (sliderSize * parent.scaleFactorY)); 
    drawDayRects();
  }
}

