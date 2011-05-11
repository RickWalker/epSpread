import processing.opengl.*;

// fjenett 20081129

import de.bezier.data.sql.*;
import controlP5.*;

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

Tweet[] tweets = new Tweet[200000];

void setup()
{
  size( imgX, imgY, OPENGL);
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
  for(int i=0; i<keywordList.length; i++)
    println(keywordList[i]);
  
  scrapeTweets();
  
  // add horizontal range slider
  range = controlP5.addRange("rangeController", 0, tweetCount, 0, 100, 50, imgY - 50, imgX - 100, 30);
    
}

void draw() {
  background(0);
  fill(0);

  
  drawTweetsOnce(tweetSelectionMin,tweetSelectionMax);
    controlP5.draw();
  
  //this has to happen every frame
  drawMouseOver(tweetSelectionMin,tweetSelectionMax);
  

}


int tweetCount = 0;
   
void scrapeTweets()
{
   db = new SQLite( this, "VAST2011_MC1.sqlite" );  // open database file

   //Build the query
   String query_part1 = "SELECT * FROM micro2 WHERE ";
   String query_part2 = "";
   String query_part3 = " ORDER BY Date ASC";
   
   //append all the keywords to search for
   for(int i=0; i<keywordList.length; i++)
   {
     if(i!=0)
       query_part2 += " OR ";
       query_part2 += "message like '%" + keywordList[i] + "%'";
   } 
   
  String sqlQuery =  query_part1 + query_part2 + query_part3;
  
  println("Query being performed is : " + sqlQuery);

    if ( db.connect() )
    {
        // list table names
        db.query(sqlQuery);
        
       while (db.next())
        {

            //we have a new record, create tweet object
            tweets[tweetCount] = new Tweet();
            
            //set the text of this tweet            
            tweets[tweetCount].setText(db.getString("message"));
            
            //get and set the location of this tweet
            PVector tweetLocation = new PVector(0,0);
            tweetLocation.x = db.getFloat("lat");
            tweetLocation.y = db.getFloat("lon");
            
            //convert to pixels and set
            tweets[tweetCount].setLocation(mapCoordinates(tweetLocation));
            
            //ready for next tweet record
            tweetCount++;
        }
        
        println("Created " + tweetCount + " tweet records"); 
    }   
}


PVector mapCoordinates(PVector coords)
{
   PVector result = new PVector(0.0f,0.0f);
   result.x = map(coords.y, topleft_lon, bottomright_lon, 0, imgX);
   result.y = map(coords.x, topleft_lat, bottomright_lat, 0, imgY);
 
 return result;
}




void drawMouseOver(int mini, int maxi)
{
  for(int i=mini; i<maxi; i++) {
    PVector loc = tweets[i].getLocation();
 
    if(dist(mouseX, mouseY, loc.x, loc.y) < 7)
        {
          String s =  tweets[i].getText();
          int sLength = s.length();
          float gap = 20;
          
          int textBoxSize = sLength * 2;
          
          float shadowOffset = 4;
          
          //shadow
          strokeWeight(0);
          fill(0,0,0,100);
          rect(shadowOffset + loc.x, shadowOffset + loc.y, shadowOffset + 200, shadowOffset + textBoxSize);
          
          stroke(0,0,0,100);
          strokeWeight(4);

          fill(230,230,250,200);
          rect(loc.x, loc.y, 200, textBoxSize);

          fill(0, 50, 100);
          text(s, loc.x + gap, loc.y + gap, 200 - gap*2, 300 - gap*2);
        } 
  }
}



void drawTweetsOnce(int mini, int maxi) 
{
  
 
  
  background(0); //blank to start with
  image(imgMap, 0, 0, imgX, imgY);
  
  //Draw all the ellipses
  strokeWeight(2);
    
  for(int i=mini; i<maxi; i++) {
        
    float colourPerc = float(i-mini) / float(maxi-mini);
    fill(0,255,0, 20 + (235 * colourPerc));
    stroke(0,0,0,20 + (235 * colourPerc));
    
    PVector loc = tweets[i].getLocation();
        
    ellipse(loc.x, loc.y, 10, 10);
  }
}





void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.controller().name().equals("rangeController")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    tweetSelectionMin = int(theControlEvent.controller().arrayValue()[0]);
    tweetSelectionMax = int(theControlEvent.controller().arrayValue()[1]);
    
  }
}
