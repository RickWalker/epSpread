import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;


/*
*
 * Main Code
 *
 */

import processing.opengl.*;

import de.bezier.data.sql.*;
import controlP5.*;
import java.util.ArrayList;

// ---- Mouse Drag/Selection ----

//mouse drag selection
/*float mouseDragStart_x = -1;
 float mouseDragStart_y = -1; 
 float mouseDragEnd_x = -1;
 float mouseDragEnd_y = -1;
 
 boolean b_draggingMouse = false;
 boolean b_selection = false;
 int numberSelected = 0;*/










// ---- Globals ----

//String[] keywordList;
SQLite db;
PFont font = createFont("FFScala", 18);
ArrayList<Integer> colours = new ArrayList<Integer>();


int imgX = 1304; //image size 
int imgY = 663;  //image size

int colourTracker = 0; //tracks number of colours




boolean b_generateNetwork = false;  //Generate network for selected tweets?

// ---- Interval Range -----

//Note : are intervals inclusive or exclusive?
DateTime minDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(1));
DateTime maxDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period.hours(1));
DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");
DateTimeFormatter fmt2 = DateTimeFormat.forPattern("MMM dd              HH:mma"); 


ControlP5 controlP5;
// ---- Weather ----
WeatherFrame weatherFrame;
WeatherApplet weatherApplet;
PImage rain;
PImage showers;
PImage cloudy;
PImage clear;
int componentCount = 0;//unique ID for each component!


/* -----------------------------
 *
 * Setup the application
 *
 * -----------------------------*/
List<TwitterFilteringComponent> timePoints;// llyrComponent;

void setup()
{
  size( 1200, 600, OPENGL);
  //textMode(SHAPE);
  smooth();
  createRegions();
  controlP5 = new ControlP5(this);
  controlP5.setAutoDraw(false);
  //setup database
  db = new SQLite( this, "VAST2011_MC1.sqlite" );  // open database file
  timePoints = new ArrayList<TwitterFilteringComponent>();

  timePoints.add(new TwitterFilteringComponent(this, 0, 0, width/2, height/2));
  //timePoints.add(new TwitterFilteringComponent(this, 0, height/2, width/2, height/2));
  //timePoints.add(new TwitterFilteringComponent(this, width/2, height/2, width/2, height/2));
  //timePoints.add(new TwitterFilteringComponent(this, width/2, 0, width/2, height/2));
}

void keyPressed() {
  if (key == 'r') {
    saveFrame("VASTMC2-####.png");
  }
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
  }
}

/* -----------------------------
 *
 * Main draw method
 *
 * -----------------------------*/

void draw() {
  background(225, 228, 233);
  for (TwitterFilteringComponent a: timePoints) {
    a.draw();
  }
}

void controlEvent(ControlEvent theControlEvent) {
  for (TwitterFilteringComponent a: timePoints) {
    if (a.hasMouseOver()) {
      a.controlEvent(theControlEvent);
    }
  }
}

void mousePressed() {
  for (TwitterFilteringComponent a: timePoints) {
    if (a.hasMouseOver()) {
      a.mousePressed();
    }
  }
}

void mouseReleased() {
  for (TwitterFilteringComponent a: timePoints) {
    if (a.hasMouseOver()) {
      a.mouseReleased();
    }
  }
}

