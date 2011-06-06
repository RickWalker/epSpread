PFont f;
PImage rain;
PImage sun;
PImage storm;
PImage cloud;
String setWeatherType;
int weatherType;
String setWindDirection;
int setWindSpeed;
int setDayNo;

void setup() {
  size(200,300);
  f = createFont("Arial",30, true); // name, size, antialiased?
  rain = loadImage("rain.png");
  sun = loadImage("sun.png");
  storm = loadImage("storm.png");
  cloud = loadImage("cloud.png");
}

void draw() {
  background(200,200,200); // background colour
  
  // SET WEATHER
  setDayNo = 9;
  setWeatherType = "cloud";
  setWindDirection = "SW";
  setWindSpeed = 1;
  
  drawDay();
}

void drawDay() {
  fill(255);
  rect(50, 50, 100, 200);
  
  // set correct image
  if(setWeatherType == "rain") {
    image(rain, 57, 96, 90, 70);
  } else if (setWeatherType == "sun") {
    image(sun, 55, 96, 90, 70);
  } else if (setWeatherType == "storm") {
    image(storm, 57, 96, 90, 70);
  } else if (setWeatherType == "cloud") {
    image(cloud, 57, 105, 90, 50);
  }
  
  textFont(f,25); // font, SIZE to use
  fill(0); // font colour
  
  // set day number (adjust x and y for double figures)
  if(setDayNo < 10) {
    text("Day " + setDayNo,70,85); // string, x, y
  } else {
    text("Day " + setDayNo,63,85); // string, x, y
  }
  
  textFont(f,38); // font, SIZE to use
  
  // set wind direction (adjust x and y for certain combinations)
  if(setWindDirection.equals("N") || setWindDirection.equals("E") || setWindDirection.equals("S")) {
    text(setWindDirection,85,200);
  } else if(setWindDirection.equals("W")) {
    text(setWindDirection,80,200);
  } else if(setWindDirection.equals("NW") || setWindDirection.equals("SW")) {
    text(setWindDirection,68,200);
  } else {
    text(setWindDirection,73,200);
  }
  
  textFont(f,40); // font, SIZE to use
  // set wind speed (adjust x and y for double figures)
  if(setWindSpeed < 10) {
    text(setWindSpeed,87,240);
  } else {
    text(setWindSpeed,75,240);
  }
  
}
