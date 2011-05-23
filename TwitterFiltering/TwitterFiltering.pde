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
Textfield filterTextField;
ListBox filterShortcutList;

//-----------------

//mouse drag selection
float mouseDragStart_x = -1;
float mouseDragStart_y = -1; 
float mouseDragEnd_x = -1;
float mouseDragEnd_y = -1;

boolean b_draggingMouse = false;
boolean b_selection = false;
int numberSelected = 0;

SQLite db;
PImage imgMap;
PVector imgPos;


int imgX = 1304;
int imgY = 663;

float topleft_lat = 42.3017;
float topleft_lon = 93.5673;
float bottomright_lat = 42.1609;
float bottomright_lon = 93.1923;

int filterTextField_x;
int filterTextField_y;

int tweetSelectionMin = 0;
int tweetSelectionMax = 100;

PVector tweet_loc = new PVector(42.2838, 93.47745);


TweetSetManager tweetSetManager;
ArrayList<Integer> colours = new ArrayList<Integer>();

//Note : are intervals inclusive or exclusive?
DateTime minDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(1));
DateTime maxDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period.hours(1));

Interval dateSelection;

PFont font = createFont("FFScala", 18);

void setup()
{
  size( imgX+300, imgY + 100, OPENGL);
  smooth();

  //setup database
  db = new SQLite( this, "VAST2011_MC1.sqlite" );  // open database file

  //setup tweetSetManager
  tweetSetManager = new TweetSetManager();

  //Load font 
  textFont(font); 


  //Load an image
  imgMap = loadImage("Vastopolis_Map_B&W_2.png");
  imgPos = new PVector(10, 10);

  //Setup Time Slider
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);


  dateSelection = new Interval(minDate, maxDate);
  
  
  // add horizontal range slider
  range = controlP5.addRange("Date", 0, Hours.hoursIn(dateSelection).getHours(), 0, 24, 50, imgY + 24, imgX - 100, 30);
  range.setColorBackground(color(130,130,130));
  range.setLabelVisible(false);
  range.setCaptionLabel("");
  

  println("Duration is " + Hours.hoursIn(dateSelection).getHours() + " hours");
  dateSelection=new Interval(minDate, minDate.plus(Period.hours(24)));

  setupColours();
  setupGUI();
}




void draw() {
  background(225, 228, 233); //blank to start with

  strokeWeight(0);
  fill(40);
  rect(7, 7, imgX+6, imgY+6);
  image(imgMap, imgPos.x, imgPos.y, imgX, imgY);  

  fill(76, 86, 108);
  text("Filter Terms", filterTextField_x - 2, filterTextField_y - 10);

  //add border to date range slider!
  float rangeBorderSize = 2;
  fill(80);
  rect(50 - rangeBorderSize, imgY + 24 - rangeBorderSize, imgX-100 + rangeBorderSize*2, 30 + rangeBorderSize*2);

  tweetSetManager.draw();
  controlP5.draw();
  drawTweetsOnce();

  //draw semi-transparent rectangle if click-dragging
    //if (  (mouseX > imgPos.x) && (mouseY > imgPos.y) && (mouseX < imgX) && (mouseY < imgY) ) 
      if (b_draggingMouse) {
        stroke(200, 200, 255, 100);
        strokeWeight(2);
        fill(100, 100, 255, 50);
        rect(mouseDragStart_x, mouseDragStart_y, constrain(mouseX, imgPos.x, imgX + imgPos.x) - mouseDragStart_x, constrain(mouseY, imgPos.y, imgY + imgPos.y) - mouseDragStart_y); //limit rectangle to image boundary
      }
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



  //overspill
  colours.add(color( 179, 222, 105  ));
  colours.add(color( 128, 177, 211    ));
  colours.add(color( 251, 128, 114 ));
  colours.add(color(  141, 211, 199 ));
  colours.add(color( 255, 255, 179   ));
  colours.add(color( 190, 186, 218   ));
  colours.add(color(253, 180, 98 ));
  colours.add(color( 252, 205, 229  ));
  colours.add(color(217, 217, 217  ));
  colours.add(color( 188, 128, 189  )); 


  /*
  colours.add(color( 166, 206, 227  ));
   colours.add(color( 31, 120, 180  ));
   colours.add(color( 178, 223, 138  ));
   colours.add(color(  51, 160, 44  ));
   colours.add(color( 251, 154, 153   ));
   colours.add(color(  227, 26, 28  ));
   colours.add(color(253, 191, 111 ));
   colours.add(color( 255, 127, 0  ));
   colours.add(color(202, 178, 214  ));
   colours.add(color( 106, 61, 154  )); 
   */
}







void setupGUI()
{
  setupSearchField();
  setupFilterShortcutList();
}


void setupFilterShortcutList()
{
  filterShortcutList = controlP5.addListBox("myList", width-260, 92, 180, 280);
  filterShortcutList.setItemHeight(30);
  filterShortcutList.setBarHeight(11);
  filterShortcutList.setBackgroundColor(250);

  filterShortcutList.captionLabel().toUpperCase(false);
  filterShortcutList.setColorBackground(250);
  filterShortcutList.setColorForeground(255);
  //filterShortcutList.setColorValue(50);
  filterShortcutList.setColorActive(255);
  filterShortcutList.setColorLabel(50);
  filterShortcutList.setLabel("Shortcuts");
  filterShortcutList.captionLabel().style().marginTop = 4;
  filterShortcutList.hideBar();
  filterShortcutList.close();
  filterShortcutList.valueLabel().toUpperCase(false);

  ArrayList<String> keywordShortcuts = new ArrayList<String>();
  keywordShortcuts.add("All Symptoms");
  keywordShortcuts.add("All Events");
  keywordShortcuts.add("All Emergencies");
  keywordShortcuts.add("All Accidents");




  for (String keyword: keywordShortcuts) {
    int id = 0;
    ListBoxItem b = filterShortcutList.addItem(keyword, id);
    //b.captionLabel().toUpperCase(false);
    id++;
  }
}



void setupSearchField()
{
  filterTextField_x = width-260;
  filterTextField_y = 60;
  int filterTextField_width = 180;
  int filterTextField_height = 30;

  filterTextField = controlP5.addTextfield("Filters", filterTextField_x, filterTextField_y, filterTextField_width, filterTextField_height);
  filterTextField.setColorBackground(250);
  filterTextField.setColorForeground(0);
  filterTextField.setColorValue(50);
  filterTextField.setColorActive(0);
  filterTextField.setColorLabel(0);
  controlP5.setControlFont(new ControlFont(createFont("FFScala", 18), 18));
  filterTextField.setLabel("");
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

    if (!b_draggingMouse)
    {
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
}



void drawTweetsOnce()//int mini, int maxi) 
{

  //Load font 
  textFont(font); 


  //Draw all the ellipses
  strokeWeight(2);
  Tweet forMouseOver = null;
  //for (int i=mini; i<maxi; i++) {

  // ArrayList<Tweet> theTweets = tweetSets.get(0).getTweets();   

  if (tweetSetManager.getTweetSetListSize() > 0)
    for (TweetSet b: tweetSetManager.getTweetSetList()) {
      if (b.isActive())
      {      
        if (tweetSetManager.isHeatmapViewActive())       
          b.heatmap.draw();

        for (Tweet a: b.getTweets()) {
          if (dateSelection.contains(a.mDate)) {
            //float colourPerc = float(i-mini) / float(maxi-mini);
            //fill(0, 255, 0);//, 20);// + (235 * colourPerc));
            fill(b.getColour());

            stroke(0, 0, 0);//, 20);// + (235 * colourPerc));

            PVector loc = a.getLocation();
            strokeWeight(2);

            //if there is a drag-select happening
            if (b_draggingMouse) {
              //if this tweet point is inside the selection box
              if (isInsideSelectionBox(loc.x, loc.y)) {
                fill(255);
              }
            }
            
            if(a.isSelected())
            {
              stroke(255);
            }

            if (tweetSetManager.isPointsViewActive())
              rect(loc.x, loc.y, 10, 10);

            if (dist(mouseX, mouseY, loc.x, loc.y) < 7) {
              forMouseOver =a ;
            }
            //drawMouseOver(a);
          }
        }
      }
    }
  if (forMouseOver != null)
    drawMouseOver(forMouseOver);
  //}

  
}





boolean isInsideSelectionBox(float x, float y)
{
  if (  (x > mouseDragStart_x) && (y > mouseDragStart_y) && (x < mouseX) && (y < mouseY) )
    return true;
  else if (  (x < mouseDragStart_x) && (y > mouseDragStart_y) && (x > mouseX) && (y < mouseY) )
    return true;
  else if (  (x < mouseDragStart_x) && (y < mouseDragStart_y) && (x > mouseX) && (y > mouseY) )
    return true;
  else if (  (x > mouseDragStart_x) && (y < mouseDragStart_y) && (x < mouseX) && (y > mouseY) )
    return true;   
  else
    return false;
}




void generateTweetSet(String keywords)
{
  //Get a fresh and exciting colour for this set
  color setColour = colours.get(colourTracker);

  if (colourTracker < colours.size()) 
    colourTracker++;
  else
    colourTracker=0;

  String RESymbol = "";
  
  //Find out if we are processing this tweetSet using RE's, store symbol in RESymbol
  if(keywords.indexOf("*") >= 0)
  {
    RESymbol = "*";
    keywords = keywords.substring(1);
  }



  //Create new tweet set
  TweetSet newTweetSetToAdd = new TweetSet(keywords, setColour, RESymbol);

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
    
    
    // -------- Go through data, storing them as tweets in a tweetset (if they pass optional RE match) --------   
    
    while (db.next ())
    {
      boolean passesRE = true;  //passes RE check?
      
      if(RESymbol != "") //if a symbol has been specified for this tweetSet
      {
        //check if it matches a RE      
        if(!matchesRegularExpression( db.getString("message"), RESymbol))
          passesRE = false;
      }
            
      
      if(passesRE)
      {
      
      //we have a new record, create tweet object
      newTweetToAdd = new Tweet();

      //set the text of this tweet            
      newTweetToAdd.setText(db.getString("message"));

      //set the user id         
      newTweetToAdd.setUserId(db.getInt("ID"));

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
    }
    
    println("Created " + newTweetSetToAdd.tweets.size() + " tweet records");
    println("Date min is " + minDate + " and max is " + maxDate);
  }

  //add this finished tweet set to the array
  tweetSetManager.addTweetSet(newTweetSetToAdd);
  
    
  //update heat maps for first time
  for (TweetSet a: tweetSetManager.getTweetSetList())
        a.updateHeatMap();
}










void controlEvent(ControlEvent theControlEvent) {

  if (theControlEvent.isGroup()) {

    if (theControlEvent.group().id() == 1) // id #1 is for the tweetSetListBox
    {
      int index = int(theControlEvent.group().value());

      println("Removing : " + theControlEvent.group().name());

      //  tweetSets.remove(index-1);
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
      for (TweetSet a: tweetSetManager.getTweetSetList())
        a.updateHeatMap();
      //tweetSelectionMin = int(theControlEvent.controller().arrayValue()[0]);
      //tweetSelectionMax = int(theControlEvent.controller().arrayValue()[1]);
    }



    // -------- Typing something in and hitting return will trigger this code, creating a new tweet set --------

    if (theControlEvent.controller().name().equals("Filters")) {
      String keywords = theControlEvent.controller().stringValue();

      if (tweetSetManager.getTweetSetListSize() < tweetSetManager.getMaxTweetSets())
        generateTweetSet(keywords);
      else
        println("**** Too many tweetSets! Please remove before requesting another ***");
    }
  }
}




void calculateTweetSetCrossover()
{
  println("calculating tweet set crossover");
  
  
  //reset crossover matches at the start
  for(TweetSet o: tweetSetManager.getTweetSetList()){
     o.resetCrossoverMatches();
  }
  
  
  println("Number selected : " + numberSelected);
  //loop through tweetsets
  
  
   if (tweetSetManager.getTweetSetListSize() > 0)
        for (TweetSet b: tweetSetManager.getTweetSetList()) { 
           for (Tweet a: b.getTweets()) {
             
              if(a.isSelected()) //if this tweet is selected, find out if the user id exists in other tweetSets
              {
                int userId = a.getUserId();
               
               //now loop through the tweetSets and see if there are matches to this id 
                for (TweetSet d: tweetSetManager.getTweetSetList()) { 
                  boolean b_found = false;
                  
                   for (Tweet c: d.getTweets()) {
                       if(c.getUserId() == userId)
                         b_found = true; //found an id match in this tweetSet
                   }
                   
                   if(b_found)
                     d.incrementCrossoverMatches();   
              }
           }
        }       
    }
  
 
 for (TweetSet b: tweetSetManager.getTweetSetList()) { 
     println("For tweetSet " + b.getSearchTerms() + " : " + b.getNumberOfCrossoverMatches()); 
 } 
 
  
}











void mousePressed() {


  //If mouse click / drag on image  
  if (  (mouseX > imgPos.x) && (mouseY > imgPos.y) && (mouseX < imgX) && (mouseY < imgY) ) 
    if (mouseButton == LEFT) {
      mouseDragStart_x = mouseX;
      mouseDragStart_y = mouseY;
      b_draggingMouse = true;
    }

    if (mouseButton == RIGHT) {
      b_selection = false;
    }
  }





void mouseReleased()
{
  //mouse has clicked and released, let tweet set manager know!  
  tweetSetManager.processMouse();

  
    //click dragging
    if(b_draggingMouse == true)
    if (mouseButton == LEFT) {  
       numberSelected = 0;
  
      println("calculating new crossover matches");
      // clear all selections!
        for (TweetSet b: tweetSetManager.getTweetSetList()) {
          
          b.resetCrossoverMatches();
          
          if (b.isActive())
          {      
            for (Tweet a: b.getTweets()) {
                  a.setSelected(false);
            }
          }
        }


      
      b_draggingMouse = false;

      mouseDragEnd_x = max(mouseX, imgX);
      mouseDragEnd_y = min(mouseY, imgY);
      b_selection = true;

      // finished dragging, so set any tweets within drag box to 'selected'
      if (tweetSetManager.getTweetSetListSize() > 0)
        for (TweetSet b: tweetSetManager.getTweetSetList()) {
          if (b.isActive())
          {      
            for (Tweet a: b.getTweets()) {
              if (dateSelection.contains(a.mDate)) 
                if (isInsideSelectionBox(a.getLocation().x, a.getLocation().y))
                {
                  a.setSelected(true);
                  numberSelected++;
                }
            }
          }
        }
        
        //now that we have a selection, calculate the crossover percentage between tweetSets (i.e. how many of these people also mention the other keywords)
        calculateTweetSetCrossover(); 
    }
     else
    b_draggingMouse = false;
    

    if (mouseButton == RIGHT) {  
      numberSelected = 0;
       // right click means we clear all selections!
      if (tweetSetManager.getTweetSetListSize() > 0)
        for (TweetSet b: tweetSetManager.getTweetSetList()) {
          b.resetCrossoverMatches();
          
            for (Tweet a: b.getTweets()) {
                  a.setSelected(false);
            }
         
        }
    }
  
 
}







