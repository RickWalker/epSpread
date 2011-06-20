


public class WeatherFrame extends Frame {
  public WeatherFrame() {
    setBounds(100, 100, 180, 250);
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

    weatherFont = createFont("Arial", 26, true); // name, size, antialiased?
     println("Grabbing weather data from db"); 
    // load the sqlite-JDBC driver using the current class loader
    try {
      Class.forName("org.sqlite.JDBC");
    }
    catch(ClassNotFoundException e) {
      println("Weather couldn't find database!");
    }
    Connection connection = null;
    try
    {
      // create a database connection
      connection = DriverManager.getConnection("jdbc:sqlite:"+sketchPath("VAST2011_MC1.sqlite"));
      Statement statement = connection.createStatement();
      statement.setQueryTimeout(30);  // set timeout to 30 sec.

      ResultSet rs = statement.executeQuery("SELECT * FROM weather");
      while (rs.next ())
      {
        // read the result set
        weatherInfo.add(rs.getString("Weather"));
        windDirection.add(rs.getString("Wind_Direction"));
        windSpeed.add(rs.getString("Average_Wind_Speed"));
      }
    }
    catch(SQLException e)
    {
      // if the error message is "out of memory", 
      // it probably means no database file is found
      System.err.println(e.getMessage());
    }
    finally
    {
      try
      {
        if (connection != null)
          connection.close();
      }
      catch(SQLException e)
      {
        // connection close failed.
        System.err.println(e);
      }
    }
  }

  public void draw() {

    PVector imgDim = new PVector(60, 60); 
    PVector outlineDim = new PVector(66, 66);

    if (currDay > 20)
      currDay = 20; 

    background(225, 228, 233);
    fill(0);    

    textAlign(CENTER, CENTER);
    textFont(weatherFont, 26); // font, SIZE to use

    text(fmt3.print(currDate), width/2, height/5);

    String weatherType = weatherInfo.get(currDay);
    String windSpd = windSpeed.get(currDay);
    String windDir = windDirection.get(currDay);

    fill(120);
    strokeWeight(0);
    rect(width/2 - outlineDim.x/2, height/2 - outlineDim.y/2, outlineDim.x, outlineDim.y);

    // set correct image
    if (weatherType.equals("rain")) 
      image(rain, width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
    if (weatherType.equals("showers")) 
      image(showers, width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
    if (weatherType.equals("cloudy")) 
      image(cloudy, width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);
    if (weatherType.equals("clear")) 
      image(clear, width/2 - imgDim.x/2, height/2 - imgDim.y/2, imgDim.x, imgDim.y);

    fill(0);
    text(windSpd + " " + windDir, width/2, height/1.25);
  }

  void setDate(DateTime _minDate, int _sliderVal) {
    currDate = _minDate.plus(Period.hours(_sliderVal));
    currDay = Days.daysIn(new Interval(_minDate, minDate.plus(Period.hours(_sliderVal)))).getDays();
  }
}

