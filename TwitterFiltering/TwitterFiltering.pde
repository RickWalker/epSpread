import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;


/*
*
 * Main Code
 *
 */

import processing.opengl.*;

//import de.bezier.data.sql.SQLite;
import controlP5.*;
import java.util.ArrayList;

float testVal = 0.028f;

// ---- Globals ----

//String[] keywordList;
///de.bezier.data.sql.SQLite db;
PFont font = createFont("FFScala", 18);
PApplet mainApplet;


int imgX = 1304; //original image size for scaling
int imgY = 663;  //image size

ArrayList<Integer> colours = new ArrayList<Integer>(); 
int colourTracker = 0; //tracks number of colours

boolean b_generateNetwork = false;  //Generate network for selected tweets?

// ---- Interval Range -----

//Note : are intervals inclusive or exclusive?
DateTime minDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(1));
DateTime maxDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period.hours(1));
DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");
DateTimeFormatter fmt2 = DateTimeFormat.forPattern("MMM dd              HH:mma"); 
Interval fullTimeInterval = new Interval(minDate, maxDate);


ControlP5 controlP5;
// ---- Weather ----
WeatherFrame weatherFrame;
WeatherApplet weatherApplet;
PImage rain;
PImage showers;
PImage cloudy;
PImage clear;
int componentCount = 0;//unique ID for each component!
TimeLineComponent storyboard;

/* -----------------------------
 *
 * Setup the application
 *
 * -----------------------------*/
//List<TwitterFilteringComponent> timePoints;// llyrComponent;

void setup()
{
  size( screenWidth, screenHeight, OPENGL);
  //textMode(SHAPE);
  smooth();
  createRegions();
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
  mainApplet = this;
  //setup database
  //db = new de.bezier.data.sql.SQLite( this, "VAST2011_MC1.sqlite" );  // open database file
  storyboard = new TimeLineComponent(this, 0, 0, width, height);
  //timePoints.add(new TwitterFilteringComponent(this, 0, height/2, width/2, height/2));
  //timePoints.add(new TwitterFilteringComponent(this, width/2, height/2, width/2, height/2));
  //timePoints.add(new TwitterFilteringComponent(this, width/2, 0, width/2, height/2));
}

void keyPressed() {
  
    storyboard.keyPressed();
    
    if(key == 'i')
    {
      testVal += 1.0;
      println(testVal);
    }
      
    if(key == 'k')
    {
      testVal -= 1.0;  
      println(testVal);
    }
    
  /*
  else if (key == 'q') {
    timePoints.get(0).halveSize();
  }
  else if (key == 'e') {
    timePoints.get(0).doubleSize();
  }
  else if (key == 'd') {
    timePoints.get(0).moveRight();
  }
  else if (key == 'a') {
    timePoints.get(0).moveLeft();
  }
  else if (key == 'w') {
    timePoints.get(0).moveUp();
  }
  else if (key == 's') {
    timePoints.get(0).moveDown();
  }*/
}

/* -----------------------------
 *
 * Main draw method
 *
 * -----------------------------*/

void draw() {
  background(225, 228, 233);
  storyboard.draw();
}

void controlEvent(ControlEvent theControlEvent) {
  storyboard.controlEvent(theControlEvent); 
}

void mousePressed() {
  storyboard.mousePressed();
}

void mouseReleased() {
  storyboard.mouseReleased();
}

