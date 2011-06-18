

class WordCloud{


String fontFile = "ArialRoundedMTBold-96.vlw";
int fSize = 192;
PFont font = createFont("FFScala",192);

int maxSize = 192;
int minSize = 48;
float border = 0.03;

String[] words;
int[]  count;
int most;
int least;
float currentSize;
int currentIndex;

int posX;
int posY;
int mWidth;
int mHeight;

ArrayList<TweetFrequencies> wordFrequencies;
 
WordCloud(int _x, int _y, int _width, int _height) 
{
posX = _x;
posY = _y;
mWidth = _width;
mHeight = _height;

wordFrequencies = new ArrayList<TweetFrequencies>();

this.setup();
}
 
 
 
 
 
void setup(){
  colorMode(HSB, TWO_PI, 1, 1, 1);
  rectMode(CORNER);
  smooth();
  //font = loadFont("FFScala");
  initializeWords(); 
  noLoop();
 
}
 
 
 
 
void draw() {
  background(0,0,1);
  
  stroke(0,0,0.5);
  strokeWeight(2);
  rect(posX - (mWidth*border), posY - (mHeight * border), mWidth + (border*mWidth)*2, mHeight + (border*mHeight)*2);
  
  while(currentIndex < words.length) {
    float relsize = map(count[currentIndex],least,most,minSize,maxSize);
    boolean drawn = false; 
    while (!drawn) {
      drawn = drawWord(words[currentIndex], relsize);
      if (!drawn)
       println("redrawing "+words[currentIndex]);
        relsize = relsize * 0.95;
    }
    currentIndex++;
  } 
}
 
boolean drawWord(String word, float wordSize) {
  int intSize = (int)wordSize;
  textFont(font, wordSize);
  int w = int(textWidth(word));
  PGraphics g = createGraphics(w, intSize, P2D);
  g.beginDraw();
  g.background(color(0, 0, 1, 0));
  g.fill(color(0,0,0));
  g.textAlign(CENTER, CENTER);
  g.translate(w/2, wordSize/2);
  g.scale(wordSize / fSize);
  g.textFont(font);
  g.text(word, 0, 0);
  g.endDraw();
 
  PGraphics gMask = createGraphics(w, intSize, P2D);
  gMask.beginDraw();
  //gMask.background(color(0, 0, 1, 1));
  gMask.image(g, 0, 0);
  gMask.filter(ERODE); 
  gMask.filter(ERODE);
  gMask.endDraw();
   
  for (int tries=50; tries>0; tries--) {
    int x = this.posX + (int)random(mWidth-w);
    int y = this.posY + (int)random(mHeight-intSize);
     
    boolean fits = true;
    for (int dx = 0; dx< w && fits; dx++) {
      for (int dy = 0; dy<intSize && fits; dy++) {
        if (brightness(gMask.get(dx, dy))<0.5) {
          if (brightness(get(x+dx, y+dy))<0.5) {
            fits = false;
          }
        }
      }
    }
    if (fits) {
      image(g, x, y);
      return true;
    }
  }
  return false;
}
 
boolean equalColor(color c1, color c2) {
  String h1 = hex(color(c1));
  String h2 = hex(color(c2));
  return h1.equals(h2);
}
 
 
void initializeWords() {
  ArrayList ignore = new ArrayList();
  String[] ignoreStrs  = loadStrings("ignore.txt");
  for (int i = 0; i < ignoreStrs.length; i++) {
    ignore.add(ignoreStrs[i].trim().toUpperCase());
  }
  
  HashMap wordcount = new HashMap();

  String filename = "data/day19.txt";
   	
  String lines[] = loadStrings(filename);
  println("there are " + lines.length + " lines");
    for (int i=0; i < lines.length; i++) {
        String frequency = split(lines[i], " ")[0];
        String name = split(lines[i], " ")[1];
        
        println(name + " " + frequency);
        wordcount.put(name, int(pow(2, int(parseFloat(frequency)))));
}  
    
    /*
    for (int i=0; i<numRegions; i++) {
      tweetFrequencies[i] = new TweetFrequencies();
      tweetFrequencies[i].setName(split(theData[0], ",")[i]);
      }
  */
 

  
  
  words = new String[wordcount.size()];
  count = new int[wordcount.size()];
  int idx = 0;
  Iterator it = wordcount.entrySet().iterator();  // Get an iterator
  while (it.hasNext()) {
      Map.Entry me = (Map.Entry)it.next();
      words[idx] = (String)me.getKey();
      count[idx] = ((Integer)(me.getValue())).intValue();
      idx++;
  }
  sortWords();
  String[] sorted = new String[words.length];
  for (int i = 0; i < words.length; i++) {
    sorted[i] = count[i]+" "+words[i];
  }
  most = count[0];
  least = count[count.length-1];
  //saveStrings("totals.txt", sorted);
 
}
 
String clean(String word) {
  word = word.trim();
  if (word.endsWith(".") || word.endsWith(",") || word.endsWith(";"))
    word = word.substring(0, word.length() - 1);
  return word.trim();   
}
 
 
void sortWords() {
  boolean changed = true;
  while (changed) {
    boolean madeChange = false;
    for (int i = 0; i < count.length-1; i++) {
      if (count[i] < count[i+1]) {
        int temp = count[i];
        String tempW = words[i];
        count[i] = count[i+1];
        words[i] = words[i+1];
        count[i+1] = temp;
        words[i+1] = tempW;
        madeChange = true;
      }
    }
    changed = madeChange;
  }
}
}
