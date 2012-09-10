import geomerative.*;
//import org.apache.batik.svggen.font.table.*;
//import org.apache.batik.svggen.font.*;
//import java.util.StringBuilder;
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
DateTime minDate =(new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(1));
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
PImage windArrow;
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
  //size( 1280, 720, OPENGL);
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

  //if (key == 'q') {
  //  exit();
  //}
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
  System.err.println("p5 control event!");
  storyboard.controlEvent(theControlEvent);
}

void mousePressed() {
  storyboard.mousePressed();
}

void mouseReleased() {
  storyboard.mouseReleased();
}

void mouseDragged() {
  storyboard.mouseDragged();
}

