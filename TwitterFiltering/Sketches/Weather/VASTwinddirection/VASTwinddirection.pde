PImage a;
float windSpeed = 0.14;
String setWindDirection;
int windDirection;
float windX = 0.0;
float windY = 0.0;

void setup() {
  size(1300, 650);
  a = loadImage("Vastopolis_Map_B&W_2.png");
}

void draw() {
  image(a, 0, 0, width, height);
  
  // SET A WIND DIRECTION N/E/S/W/NE/SE/SW/NW
  setWindDirection = "SW";
  
  if(setWindDirection == "N") {
    windDirection = 1;
  } else if(setWindDirection == "E") {
    windDirection = 2;
  } else if(setWindDirection == "S") {
    windDirection = 3;
  } else if(setWindDirection == "W") {
    windDirection = 4;
  } else if(setWindDirection == "NE") {
    windDirection = 5;
  } else if(setWindDirection == "SE") {
    windDirection = 6;
  } else if(setWindDirection == "SW") {
    windDirection = 7;
  } else if(setWindDirection == "NW") {
    windDirection = 8;
  }
  
  drawWindLines();

}

void drawWindLines() {
  // move across screen at representative speed - "X" mph * 24h = how many miles in a day?
  stroke(255,0,0);
  // work out the angle of rotation
  switch(windDirection) {
    // N
    case 1:
      // draw the wind line
      windY = windY - (windSpeed*24);
      if(windY < 0) {
        windY = height;
      }
      line(0, windY, width, windY);
      //line(0, windY + 100, width, windY + 100);
      break;
      
    // E
    case 2:
      // draw the wind line
      windX = windX + (windSpeed*24);
      if(windX > width) {
        windX = 0;
      }
      line(windX, 0, windX, height);
      break;
      
    // S
    case 3:
      // draw the wind line
      windY = windY + (windSpeed*24);
      if(windY > height) {
        windY = 0;
      }
      line(0, windY, width, windY);
      break;
      
    // W
    case 4:
      // draw the wind line
      windX = windX - (windSpeed*24);
      if(windX < 0) {
        windX = width;
      }
      line(windX, 0, windX, height);
      break;
      
    // NE
    case 5:
      // draw the wind line
      // sets the starting point properly
      if(windX == 0 && windY == 0) {
        windX = 0;
        windY = height;
      }
      windX = windX + (windSpeed*24);
      windY = windY - (windSpeed*24);
      if(windX > width + height && windY < 0 - width) {
        windX = 0;
        windY = height;
      }
      line(0, windY, windX, height);
      break;
      
    // SE
    case 6:
      // draw the wind line
      windX = windX + (windSpeed*24);
      windY = windY + (windSpeed*24);
      if(windX > width + height && windY > height + width) {
        windX = 0;
        windY = 0;
      }
      line(0, windY, windX, 0);
      break;
      
    // SW
    case 7:
      // draw the wind line
      // sets the starting point properly
      if(windX == 0 && windY == 0) {
        windX = width;
        windY = 0;
      }
      windX = windX - (windSpeed*24);
      windY = windY + (windSpeed*24);
      if(windX < 0 - height && windY > height + width) {
        windX = width;
        windY = 0;
      }
      line(width, windY, windX, 0);
      break;
    
    // NW
    case 8:
      // draw the wind line
      windX = windX - (windSpeed*24);
      windY = windY - (windSpeed*24);
      if(windX < 0 && windY < 0) {
        windX = width + height;
        windY = height + width;
      }
      line(0, windY, windX, 0);
      break;
    
  }  
}
