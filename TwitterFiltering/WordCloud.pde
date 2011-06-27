import wordcram.*;
import wordcram.text.*;


class WordCount {

  String name;
  int freq;
  float codeLength;
  float newnum;

  WordCount() {
    name = "empty";
    freq = 0;
    codeLength = 0;
  }  

  WordCount(String _name, int _freq, float _codeLength) {
    name = _name;
    freq = _freq;
    codeLength = _codeLength;
  }

  String toString() {
    return name + " " + newnum;
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
  int pStart, pStop;

  Integer[] totalDayCounts;
  WordCloud(TwitterFilteringComponent parent, int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.parent = parent;

    //load total day counts
    String [] tempC = loadStrings("counts.txt");
    totalDayCounts = new Integer[tempC.length];
    for (int i = 0; i<tempC.length; i++) {
      totalDayCounts[i]=int(tempC[i]);
      //println("Count for "+i +" is " + totalDayCounts[i]);
    }

    buffer = createGraphics(450, 450, JAVA2D);
    buffer.background(color(225, 228, 233));

    //load them all in!

    for (int k=0; k<= 20; k++) {

      int numLines = 0;
      int maxLines = 25;

      oneDayCount = new ArrayList<WordCount>();

      //String lines[] = loadStrings(k+".txt");

      String lines[];
      lines = loadStrings("5-" + nf(k, 2) + ".txt");

      if (lines != null) {

        numLines = lines.length;
        if (numLines > maxLines) numLines = maxLines; 


        println("there are " + lines.length + " lines");
        for (int i=0; i < numLines; i++) {
          String name = split(lines[i], " ")[0];
          String freq = split(lines[i], " ")[1];
          String codeLength = split(lines[i], " ")[2];


         //println(name + ", " + freq + ", " + codeLength);

          oneDayCount.add(  new WordCount(name, int(freq), float(codeLength)));
        }
        wordCounts.put(k-1, oneDayCount);
      }
    }
  }


  float log2(float a) {
    return log(a)/log(2);
  }



  void createWordCloud(int start, int end) {

    ArrayList<WordCount> tempList = new ArrayList<WordCount>();  
    HashMap<String, Integer> keywordMap = new HashMap<String, Integer>();

    int daysInRange = end-start;
    //println("days in range : " + daysInRange);

    //check if we've done this before:
    File f = new File(dataPath(start+"-"+end+".png"));
    println("looking for " + dataPath(start+"-"+end+".png"));
    if (!f.exists()) {
      //create the cloud!
      //First pass - load all word counts in this range into tempList  
      for (int i=start; i<end; i++) {
        for (WordCount wc : wordCounts.get(i-1)) {

          //if keyword already processed
          if (keywordMap.containsKey(wc.name)) {
            //increment 
            int index = keywordMap.get(wc.name);

            tempList.get(index).freq += wc.freq;

            //println("****** Found keyword on multiple days : " + wc.name + " Freq : " + tempList.get(index).freq + " Code Length : " + tempList.get(index).codeLength );
          }
          else
          {
            tempList.add(wc); //add to temp list
            keywordMap.put(wc.name, tempList.indexOf(wc)); //store index to this keyname
          }
        }
      }

      //now calculate denominator (n1 + n2 + n3)
      float denom =0;
      for (int i = start;i<end;i++) {
        denom += totalDayCounts[i];
      }

      //work out new nos
      ArrayList<Word> forCloud = new ArrayList<Word>();
      for (WordCount a: tempList) {
        //do the calculation!
        float cdash = -log2(a.freq/denom);
        a.newnum = abs(cdash - a.codeLength);
        forCloud.add(new Word(a.name, int(pow(2, a.newnum))));
        //println("Final weight for " +a.name + " is " + a.newnum);
      }
      Collections.sort(forCloud);
      if (forCloud.size() > 10)
        forCloud.subList(10, forCloud.size()).clear();

      println("Sorted version is " + forCloud);

      buffer.background(color(225, 228, 233));
      if (forCloud.size()>0) {
        WordCram wordcram = new WordCram(mainApplet)

          // Pass in the words to draw.
          .fromWords( forCloud.toArray(new Word[forCloud.size()]))

            //set canvas
            .withCustomCanvas(buffer)

              .withSizer(Sizers.byWeight(30, 80))
                .withAngler(Anglers.horiz())

                  .withPlacer(Placers.horizLine());

        // Now we've created our WordCram, we can draw it to the buffer
        wordcram.drawAll();
        //take the buffer as an image
        img = buffer.get(0, 0, buffer.width, buffer.height);
        //write image to cache
        img.save(dataPath(start+"-"+end+".png"));
      }
    }
    else {
      img = loadImage(dataPath(start+"-"+end+".png"));
    }
  }

  boolean contains(ArrayList<WordCount> theArray, String _name) {

    for (WordCount wc : theArray) {
      if (wc.name.equals(_name))
        return true;
    }

    return false;
  }






  void setRange(int start) {
    //just do just day for now!
    println("Asking for day " + start + " from cache!");
    start = constrain(start, 0, 19);
    //img = imageCache.get(start);
  }



  void setRange(int start, int stop) {
   
    start = constrain(start, 0, 20);
    stop = constrain(stop, 1, 21);
    if (pStart != start || pStop != stop) {   
       println("Asking for day range" + start + ", " + stop);
      createWordCloud(start, stop);
      pStart = start;
      pStop = stop;
    }
  }


  void draw() {
    imageMode(CORNER);
    //pushMatrix();
    //translate(x,y);
    //image(img, 0, 0, width, height);
    //popMatrix();
    image(img, parent.x + parent.width-275*parent.scaleFactorX, parent.y + (parent.height)-y*parent.scaleFactorY, width*parent.scaleFactorX, height*parent.scaleFactorY);
  }
}

