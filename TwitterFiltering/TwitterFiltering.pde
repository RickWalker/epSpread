import processing.opengl.*;

// fjenett 20081129

import de.bezier.data.sql.*;
import controlP5.*;
import java.util.ArrayList;

String[] keywordList;

ControlP5 controlP5;
Range range;
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
DateTime minDate;
DateTime maxDate;

Interval dateSelection;

void setup()
{
  size( imgX, imgY + 100, OPENGL);
  smooth();

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

  scrapeTweets();
  dateSelection = new Interval(minDate, maxDate);
  // add horizontal range slider
  range = controlP5.addRange("Date", 0, Hours.hoursIn(dateSelection).getHours(), 0, 24, 50, imgY + 10, imgX - 100, 30);

  println("Duration is " + Hours.hoursIn(dateSelection).getHours() + " hours");
  dateSelection=new Interval(minDate, minDate.plus(Period.hours(24)));
}

void draw() {
  background(0);
  fill(0);


  drawTweetsOnce();//tweetSelectionMin, tweetSelectionMax);
  controlP5.draw();

  //this has to happen every frame
  //drawMouseOver();//tweetSelectionMin, tweetSelectionMax);
}


//int tweetCount = 0;

void scrapeTweets()
{
  db = new SQLite( this, "VAST2011_MC1.sqlite" );  // open database file

  //Build the query
  String query_part1 = "SELECT * FROM micro2 WHERE ";
  String query_part2 = "";
  String query_part3 = " ORDER BY Date ASC";

  //append all the keywords to search for
  for (int i=0; i<keywordList.length; i++)
  {
    if (i!=0)
      query_part2 += " OR ";
    query_part2 += "message like '%" + keywordList[i] + "%'";
  } 

  String sqlQuery =  query_part1 + query_part2 + query_part3;

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
      if (firstRecord) {
        minDate = new DateTime(thisDate);
        maxDate = new DateTime(thisDate);
        firstRecord = false;
      }
      else if (thisDate.isAfter(maxDate)) {
        maxDate = new DateTime(thisDate);
      }
      else if (thisDate.isBefore(maxDate)) {
        minDate = new DateTime(thisDate);
      }

      //convert to pixels and set
      newTweetToAdd.setLocation(mapCoordinates(tweetLocation));
      tweets.add(newTweetToAdd);
      //ready for next tweet record
      //tweetCount++;
    }

    println("Created " + tweets.size() + " tweet records");
    println("Date min is " + minDate + " and max is " + maxDate);
  }
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



  background(0); //blank to start with
  image(imgMap, 0, 0, imgX, imgY);

  //Draw all the ellipses
  strokeWeight(2);
  Tweet forMouseOver = null;
  //for (int i=mini; i<maxi; i++) {
  for (Tweet a: tweets) {
    if (dateSelection.contains(a.mDate)) {
      //float colourPerc = float(i-mini) / float(maxi-mini);
      fill(0, 255, 0);//, 20);// + (235 * colourPerc));
      stroke(0, 0, 0);//, 20);// + (235 * colourPerc));

      PVector loc = a.getLocation();
      strokeWeight(2);
      ellipse(loc.x, loc.y, 10, 10);
      if (dist(mouseX, mouseY, loc.x, loc.y) < 7) {
        forMouseOver =a ;
      }
      //drawMouseOver(a);
    }
  }
  if (forMouseOver != null)
    drawMouseOver(forMouseOver);
  //}
}





void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.controller().name().equals("Date")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    dateSelection = new Interval(minDate.plus(Period.hours(int(theControlEvent.controller().arrayValue()[0]))), 
    minDate.plus(Period.hours(int(theControlEvent.controller().arrayValue()[1]))));
    println("Selection is " + dateSelection);
    //tweetSelectionMin = int(theControlEvent.controller().arrayValue()[0]);
    //tweetSelectionMax = int(theControlEvent.controller().arrayValue()[1]);
  }
}

