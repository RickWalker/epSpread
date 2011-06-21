import wordcram.*;
import wordcram.text.*;

class WordCloud {
  int x, y, width, height;
  TwitterFilteringComponent parent;
  PImage img;
  PGraphics buffer;
  HashMap<Integer, ArrayList<Word>> wordCounts;
  HashMap<Integer, PImage> imageCache;

  WordCloud(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    buffer = createGraphics(350, 350, JAVA2D);
    buffer.background(color(225, 228, 233));
    wordCounts = new HashMap<Integer, ArrayList<Word>>();
    //load them all in!
    ArrayList<Word> oneDayCount;
    // String start = 
    for (int k=1; k<= 20; k++) {
      oneDayCount = new ArrayList<Word>();
      int numLines = 0;
      int maxLines = 15;

      String lines[] = loadStrings(k+".txt");
      if (lines != null) {

        numLines = lines.length;
        if (numLines > maxLines) numLines = maxLines; 


        println("there are " + lines.length + " lines");
        for (int i=0; i < numLines; i++) {
          String frequency = split(lines[i], " ")[0];
          String name = split(lines[i], " ")[1];

          println(name + " " + frequency);
          oneDayCount.add(new Word(name, int(pow(2, parseFloat(frequency)))));
          //wordcount.add(new Word(name, int(parseFloat(frequency))));
        }
      }
      wordCounts.put(k-1, oneDayCount);
    }

    imageCache = new HashMap<Integer, PImage>();
    for (int i = 0; i<20; i++) {
      buffer.background(color(225, 228, 233));
      WordCram wordcram = new WordCram(mainApplet)

        // Pass in the words to draw.
        .fromWords( wordCounts.get(i).toArray(new Word[wordCounts.get(i).size()]))

          //set canvas
          .withCustomCanvas(buffer)

            .withSizer(Sizers.byWeight(24, 60))
              .withAngler(Anglers.horiz())

                .withPlacer(Placers.horizLine());

      // Now we've created our WordCram, we can draw it to the buffer
      wordcram.drawAll();
      //take the buffer as an image
      img = buffer.get(0, 0, buffer.width, buffer.height);
      imageCache.put(i, img);
    }
  }

  void setRange(int start, int stop) {
    //just do just day for now!
    /*ArrayList<Word> wordcount = new ArrayList<Word>();
     int numLines = 0;
     int maxLines = 15;
     
     String lines[] = loadStrings(start+".txt");
     if (lines != null) {
     
     numLines = lines.length;
     if (numLines > maxLines) numLines = maxLines; 
     
     
     println("there are " + lines.length + " lines");
     for (int i=0; i < numLines; i++) {
     String frequency = split(lines[i], " ")[0];
     String name = split(lines[i], " ")[1];
     
     println(name + " " + frequency);
     wordcount.add(new Word(name, int(pow(2, parseFloat(frequency)))));
     //wordcount.add(new Word(name, int(parseFloat(frequency))));
     }*/
    /*buffer.background(color(225, 228, 233));
    // Pass in the sketch (the variable "this"), so WordCram can draw to it.
    WordCram wordcram = new WordCram(mainApplet)

      // Pass in the words to draw.
      .fromWords( wordCounts.get(start).toArray(new Word[wordCounts.get(start).size()]))

        //set canvas
        .withCustomCanvas(buffer)

          .withSizer(Sizers.byWeight(24, 60))
            .withAngler(Anglers.horiz())

              .withPlacer(Placers.horizLine());

    // Now we've created our WordCram, we can draw it to the buffer
    wordcram.drawAll();
    //take the buffer as an image
    img = buffer.get(0, 0, buffer.width, buffer.height);*/
    println("Asking for day " + start + " from cache!");
    start = constrain(start, 0, 19);
    img = imageCache.get(start);
  }

  void draw() {
    imageMode(CORNER);
    image(img, x, y, width, height);
  }
}

