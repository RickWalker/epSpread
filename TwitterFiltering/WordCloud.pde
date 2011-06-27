import wordcram.*;
import wordcram.text.*;


class WordCount{

String name;
int freq;
float codeLength;

WordCount(){
name = "empty";
freq = 0;
codeLength = 0;
}  

WordCount(String _name, int _freq, float _codeLength){
name = _name;
freq = _freq;
codeLength = _codeLength;
}
}


class WordCloud {
  int x, y, width, height;
  TwitterFilteringComponent parent;
  PImage img;
  PGraphics buffer;
  HashMap<Integer, PImage> imageCache = null;
  HashMap<Integer, ArrayList<WordCount>> wordCounts = new HashMap<Integer, ArrayList<WordCount>>();
  ArrayList<WordCount> oneDayCount;
  
  WordCloud(TwitterFilteringComponent parent, int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.parent = parent;
    buffer = createGraphics(450, 450, JAVA2D);
    buffer.background(color(225, 228, 233));


    //load them all in!
    // String start = 
    for (int k=1; k<= 20; k++) {
      int numLines = 0;
      int maxLines = 25;
      
      oneDayCount = new ArrayList<WordCount>();

      //String lines[] = loadStrings(k+".txt");
      String lines[] = loadStrings("abc.txt");
      if (lines != null) {

        numLines = lines.length;
        if (numLines > maxLines) numLines = maxLines; 


        println("there are " + lines.length + " lines");
        for (int i=0; i < numLines; i++) {
          String name = split(lines[i], " ")[0];
          String freq = split(lines[i], " ")[1];
          String codeLength = split(lines[i], " ")[2];


          oneDayCount.add(  new WordCount(name, Integer.parseInt(freq), Float.valueOf(codeLength).floatValue()) );
        }
      }
      wordCounts.put(k-1, oneDayCount);
    }
     /*

    imageCache = new HashMap<Integer, PImage>();
    for (int i = 0; i<20; i++) {
      buffer.background(color(225, 228, 233));
      WordCram wordcram = new WordCram(mainApplet)

      // Pass in the words to draw.
      .fromWords( wordCounts.get(i).toArray(new Word[wordCounts.get(i).size()]))

      //set canvas
      .withCustomCanvas(buffer)

      .withSizer(Sizers.byWeight(30, 80))
        .withAngler(Anglers.horiz())

      .withPlacer(Placers.horizLine());

      // Now we've created our WordCram, we can draw it to the buffer
      wordcram.drawAll();
      //take the buffer as an image
      img = buffer.get(0, 0, buffer.width, buffer.height);
      imageCache.put(i, img);
    }
    */
  }
  
  /*void writeToFiles(){ //writes the images out as jpgs!
  
  saveBytes("filename.jpg", bufferImage(buffer.get(0, 0, width, height)))
  }*/






void createWordCloud(int start, int end){
  
  
  /*
    int i = start;
    
    buffer.background(color(225, 228, 233));
    WordCram wordcram = new WordCram(mainApplet)

      // Pass in the words to draw.
      .fromWords( wordCounts.get(i).toArray(new Word[wordCounts.get(i).size()]))

      //set canvas
      .withCustomCanvas(buffer)

      .withSizer(Sizers.byWeight(30, 80))
        .withAngler(Anglers.horiz())

      .withPlacer(Placers.horizLine());

      // Now we've created our WordCram, we can draw it to the buffer
      wordcram.drawAll();
      //take the buffer as an image
      img = buffer.get(0, 0, buffer.width, buffer.height);
      
      */
}






  void setRange(int start) {
    //just do just day for now!
    println("Asking for day " + start + " from cache!");
    start = constrain(start, 0, 19);
    //img = imageCache.get(start);
  }
  
  
  
  void setRange(int start, int stop){
    println("Asking for day range" + start + ", " + stop);
    start = constrain(start, 0, 19);   
    //createWordCloud(start,stop);
  }
  

  void draw() {
    imageMode(CORNER);
    //pushMatrix();
    //translate(x,y);
    //image(img, 0, 0, width, height);
    //popMatrix();
   // image(img, parent.x + parent.width-275*parent.scaleFactorX, parent.y + (parent.height)-y*parent.scaleFactorY, width*parent.scaleFactorX, height*parent.scaleFactorY);
  }
}

