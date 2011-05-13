import processing.opengl.*;

// fjenett 20081129

import de.bezier.data.sql.*;
import controlP5.*;
import java.util.ArrayList;

String[] keywordList;




//ControlP5 objects
//-----------------

ControlP5 controlP5;
Range range;
ListBox twitterSetList;
Textfield filterTextField;

//-----------------



SQLite db;
PImage imgMap;

int imgX = 1304;
int imgY = 663;

float topleft_lat = 42.3017;
float topleft_lon = 93.5673;
float bottomright_lat = 42.1609;
float bottomright_lon = 93.1923;

int tweetSelectionMin = 0;
int tweetSelectionMax = 100;

PVector tweet_loc = new PVector(42.2838, 93.47745);

ArrayList<Tweet> tweets = new ArrayList<Tweet>();
ArrayList<TweetSet> tweetSets = new ArrayList<TweetSet>();

ArrayList<Integer> colours = new ArrayList<Integer>();

//Note : are intervals inclusive or exclusive?
DateTime minDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(1));
DateTime maxDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period.hours(1));

Interval dateSelection;

void setup()
{
  size( imgX+250, imgY + 100, OPENGL);
  smooth();

  //setup database
  db = new SQLite( this, "VAST2011_MC1.sqlite" );  // open database file

  //Load font 
  PFont font;
  font = createFont("FFScala", 18);
  textFont(font); 


  //Load an image
  imgMap = loadImage("Vastopolis_Map_B&W_2.png");

  //Setup Time Slider
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);

  //Load keyword list, scrape tweets
  keywordList = loadStrings("keywords.txt");

  println("Keywords are : ");  
  for (int i=0; i<keywordList.length; i++)
    println(keywordList[i]);

  //scrapeTweets();
  dateSelection = new Interval(minDate, maxDate);
  // add horizontal range slider
  range = controlP5.addRange("Date", 0, Hours.hoursIn(dateSelection).getHours(), 0, 24, 50, imgY + 10, imgX - 100, 30);

  println("Duration is " + Hours.hoursIn(dateSelection).getHours() + " hours");
  dateSelection=new Interval(minDate, minDate.plus(Period.hours(24)));

  setupColours();
  setupGUI();
}




void draw() {
  background(130); //blank to start with
  image(imgMap, 0, 0, imgX, imgY);

  controlP5.draw();
  drawTweetsOnce();//tweetSelectionMin, tweetSelectionMax);


  //this has to happen every frame
  //drawMouseOver();//tweetSelectionMin, tweetSelectionMax);
}



int colourTracker = 0;

void setupColours()
{
  colours.add(color( 77, 175, 74  ));
  colours.add(color( 55, 126, 184   ));
  colours.add(color( 228, 26, 28 ));
  colours.add(color( 152, 78, 163  ));
  colours.add(color( 255, 127, 0  ));
  colours.add(color( 255, 255, 51  ));
  colours.add(color( 166, 86, 40  ));
  colours.add(color( 247, 129, 191  ));
}




void setupGUI()
{
  setupTwitterSetList();
}


void setupTwitterSetList()
{

  int twitterSetList_x = width-210;
  int twitterSetList_y = 90;
  int twitterSetList_width = 180;
  int twitterSetList_height = 180;

  int filterTextField_x = twitterSetList_x;
  int filterTextField_y = twitterSetList_y - 60;
  int filterTextField_width = 180;
  int filterTextField_height = 20;


  twitterSetList = controlP5.addListBox("TwitterSetList", twitterSetList_x, twitterSetList_y, twitterSetList_width, twitterSetList_height);
  twitterSetList.setItemHeight(30);
  twitterSetList.setBarHeight(20);
  twitterSetList.setId(1);

  twitterSetList.captionLabel().toUpperCase(false);
  twitterSetList.captionLabel().set("TwitterSet List");
  twitterSetList.captionLabel().style().marginTop = 10;

  filterTextField = controlP5.addTextfield("Filters", filterTextField_x, filterTextField_y, filterTextField_width, filterTextField_height);
  filterTextField.setFocus(true);
}














PVector mapCoordinates(PVector coords)
{
  PVector result = new PVector(0.0f, 0.0f);
  result.x = map(coords.x, topleft_lon, bottomright_lon, 0, imgX);
  result.y = map(coords.y, topleft_lat, bottomright_lat, 0, imgY);

  return result;
}




void drawMouseOver(Tweet t)
{
  PVector loc = t.getLocation();

  if (dist(mouseX, mouseY, loc.x, loc.y) < 7)
  {
    String s =  t.getText();
    int sLength = s.length();
    float gap = 20;

    int textBoxSize = sLength * 2;

    float shadowOffset = 4;

    //shadow
    strokeWeight(0);
    fill(0, 0, 0, 100);
    rect(shadowOffset + loc.x, shadowOffset + loc.y, shadowOffset + 200, shadowOffset + textBoxSize);

    stroke(0, 0, 0, 100);
    strokeWeight(4);

    fill(230, 230, 250, 200);
    rect(loc.x, loc.y, 200, textBoxSize);

    fill(0, 50, 100);
    text(s, loc.x + gap, loc.y + gap, 200 - gap*2, 300 - gap*2);
  }
}



void drawTweetsOnce()//int mini, int maxi) 
{



  //Draw all the ellipses
  strokeWeight(2);
  Tweet forMouseOver = null;
  //for (int i=mini; i<maxi; i++) {

  // ArrayList<Tweet> theTweets = tweetSets.get(0).getTweets();   


  for (TweetSet b: tweetSets){
   b.heatmap.draw();
    for (Tweet a: b.getTweets()) {
      if (dateSelection.contains(a.mDate)) {
        //float colourPerc = float(i-mini) / float(maxi-mini);
        //fill(0, 255, 0);//, 20);// + (235 * colourPerc));
        fill(b.getColour());

        stroke(0, 0, 0);//, 20);// + (235 * colourPerc));

        PVector loc = a.getLocation();
        strokeWeight(2);
        rect(loc.x, loc.y, 10, 10);
        if (dist(mouseX, mouseY, loc.x, loc.y) < 7) {
          forMouseOver =a ;
        }
        //drawMouseOver(a);
      }
    }
  }
  if (forMouseOver != null)
    drawMouseOver(forMouseOver);
  //}
}





void generateTweetSet(String keywords)
{
  //Get a fresh and exciting colour for this set
  color setColour = colours.get(colourTracker);

  if (colourTracker < colours.size()) 
    colourTracker++;
  else
    colourTracker=0;

  //Create new tweet set
  TweetSet newTweetSetToAdd = new TweetSet(keywords, setColour);

  println("Creating new tweet set...");
  String[] filterTerms = splitTokens(keywords, ", ");

  println("Terms are : ");

  for (int i=0; i<filterTerms.length; i++)
    println(filterTerms[i]);

  //Build the query
  String query_part1 = "SELECT * FROM micro2 WHERE ";
  String query_part2 = "";


  //append all the keywords to search for
  for (int i=0; i<filterTerms.length; i++)
  {
    if (i!=0)
      query_part2 += " OR ";
    query_part2 += "message like '%" + filterTerms[i] + "%'";
  } 

  String sqlQuery =  query_part1 + query_part2;

  println("Query being performed is : " + sqlQuery);
  boolean firstRecord = true;

  if ( db.connect() )
  {
    // list table names
    db.query(sqlQuery);
    Tweet newTweetToAdd;
    DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");
    DateTime thisDate;
    //reset max and min dates!
    while (db.next ())
    {

      //we have a new record, create tweet object
      newTweetToAdd = new Tweet();

      //set the text of this tweet            
      newTweetToAdd.setText(db.getString("message"));

      //get and set the location of this tweet
      PVector tweetLocation = new PVector(0, 0);
      tweetLocation.x = db.getFloat("lon");
      tweetLocation.y = db.getFloat("lat");
      thisDate =fmt.parseDateTime(db.getString("date"));

      newTweetToAdd.setDate(thisDate);
      /*if (firstRecord) {
       minDate = new DateTime(thisDate);
       maxDate = new DateTime(thisDate);
       firstRecord = false;
       }
       else if (thisDate.isAfter(maxDate)) {
       maxDate = new DateTime(thisDate);
       }
       else if (thisDate.isBefore(maxDate)) {
       minDate = new DateTime(thisDate);
       }*/

      //convert to pixels and set
      newTweetToAdd.setLocation(mapCoordinates(tweetLocation));
      //ready for next tweet record
      //tweetCount++;

      //add tweet to tweet set
      newTweetSetToAdd.addTweet(newTweetToAdd);
    }

    println("Created " + newTweetSetToAdd.tweets.size() + " tweet records");
    println("Date min is " + minDate + " and max is " + maxDate);
  }

  //add this finished tweet set to the array
  tweetSets.add(newTweetSetToAdd);

  //Add button for this tweet set
  controlP5.ListBoxItem b = twitterSetList.addItem(keywords, tweetSets.size());
  b.setId(tweetSets.size());
}








void controlEvent(ControlEvent theControlEvent) {



  if (theControlEvent.isGroup()) {

    if (theControlEvent.group().id() == 1) // id #1 is for the tweetSetListBox
    {
      int index = int(theControlEvent.group().value());

      println("Removing : " + theControlEvent.group().name());
     // twitterSetList.removeItem("fever");

      tweetSets.remove(index-1);
    }
  }
  else
  {

    if (theControlEvent.controller().name().equals("Date")) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.
      dateSelection = new Interval(minDate.plus(Period.hours(int(theControlEvent.controller().arrayValue()[0]))), 
      minDate.plus(Period.hours(int(theControlEvent.controller().arrayValue()[1]))));
      println("Selection is " + dateSelection);
	  for(TweetSet a: tweetSets)
		a.updateHeatMap();
      //tweetSelectionMin = int(theControlEvent.controller().arrayValue()[0]);
      //tweetSelectionMax = int(theControlEvent.controller().arrayValue()[1]);
    }


    if (theControlEvent.controller().name().equals("Filters")) {
      String keywords = theControlEvent.controller().stringValue();
      generateTweetSet(keywords);
    }
  }
}






