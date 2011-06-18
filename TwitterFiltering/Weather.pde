


public class WeatherFrame extends Frame {
    public WeatherFrame() {
        setBounds(100,100,180,250);
        weatherApplet = new WeatherApplet();
        add(weatherApplet);
        weatherApplet.init();
        show();
    }
}



public class WeatherApplet extends PApplet {
  
  String theText;
  int currDay;
  DateTime currDate;
  ArrayList<String> weatherInfo = new ArrayList<String>() ;
  ArrayList<String> windDirection = new ArrayList<String>() ;
  ArrayList<String> windSpeed = new ArrayList<String>() ;

  DateTimeFormatter fmt3 = DateTimeFormat.forPattern("MMM dd");
  
  PFont weatherFont;
    
    public void setup() {
        size(500, 500);
        noLoop();
        smooth();
        
        weatherFont = createFont("Arial",26, true); // name, size, antialiased?
        
       println("Grabbing weather data from db"); 
       if ( db.connect() )
        {
        // list table names
        db.query("SELECT * FROM weather");
        
         while (db.next ())
          {
          weatherInfo.add(db.getString("Weather"));
          windDirection.add(db.getString("Wind_Direction"));
          windSpeed.add(db.getString("Average_Wind_Speed"));
          }
        }
    }

    public void draw() {
      
     PVector imgDim = new PVector(60,60); 
     PVector outlineDim = new PVector(66,66);
      
     if(currDay > 20)
      currDay = 20; 
      
     background(225, 228, 233);
     fill(0);    
     
     textAlign(CENTER, CENTER);
     textFont(weatherFont,26); // font, SIZE to use
     
     text(fmt3.print(currDate), width/2, height/5);
   
     String weatherType = weatherInfo.get(currDay);
     String windSpd = windSpeed.get(currDay);
     String windDir = windDirection.get(currDay);
    
     fill(120);
     strokeWeight(0);
     rect(width/2 - outlineDim.x/2, height/2 - outlineDim.y/2, outlineDim.x, outlineDim.y);
   
     // set correct image
  if(weatherType.equals("rain")) 
      image(rain, width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
  if(weatherType.equals("showers")) 
    image(showers,  width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
  if(weatherType.equals("cloudy")) 
    image(cloudy,  width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
  if(weatherType.equals("clear")) 
    image(clear,  width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
       
     fill(0);
     text(windSpd + " " + windDir, width/2, height/1.25);
    }
    
    void setDate(DateTime _minDate, int _sliderVal){
      currDate = _minDate.plus(Period.hours(_sliderVal));
      currDay = Days.daysIn(new Interval(_minDate, minDate.plus(Period.hours(_sliderVal)))).getDays();
    }
}
