class TwitterFilteringComponent {
  int x, y, width, height;
  PApplet parent;
  int componentID;
  //SQLite db;

  TweetSetManager tweetSetManager;
  Interval dateSelection;

  ArrayList<TweetNetwork> tweetNetworks = new ArrayList<TweetNetwork>();
  ArrayList<Integer> selectedTweetUserIds = new ArrayList<Integer>();


  // ---- Mouse Drag/Selection ----

  //mouse drag selection
  float mouseDragStart_x = -1;
  float mouseDragStart_y = -1; 
  float mouseDragEnd_x = -1;
  float mouseDragEnd_y = -1;

  boolean b_draggingMouse = false;
  boolean b_selection = false;
  int numberSelected = 0;


  float topleft_lat = 42.3017;
  float topleft_lon = 93.5673;
  float bottomright_lat = 42.1609;
  float bottomright_lon = 93.1923;


  int filterTextField_x;
  int filterTextField_y;


  // ---- Control P5 objects ----

  Range range;
  Textfield filterTextField;
  ListBox filterShortcutList;


  PVector imgPos;  //pos offset of image



  PImage imgMap;


  /* -----------------------------
   *
   * Setup the component
   *
   * -----------------------------*/
  float scaleFactorX, scaleFactorY;
  float fontScale;
  float tweetBoxSize = 10; //size of tweet map icon

  TwitterFilteringComponent(PApplet parent, int x, int y, int width, int height)
  {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;

    componentID = componentCount++;

    scaleFactorX = (float)width/(imgX+310);
    scaleFactorY = (float)height/(imgY+130);
    fontScale = min(scaleFactorX, scaleFactorY);
    tweetBoxSize *= fontScale;
    println("Scale factors are " + scaleFactorX + " and " + scaleFactorY);
    //size( imgX+310, imgY + 130, OPENGL);
    //smooth();
    //println("Scale factors are " + scaleFactorX + " and " + scaleFactorY);
    //setup database
    //db = new SQLite( parent, "VAST2011_MC1.sqlite" );  // open database file

    //Load the map
    imgMap = loadImage("data/Vastopolis_Map_B&W_2.png");
    imgPos = new PVector(10, 40);

    //Load the weather images
    rain= loadImage("data/rain.jpg");
    showers= loadImage("data/showers.jpg");
    cloudy= loadImage("data/cloudy.jpg");
    clear= loadImage("data/clear.jpg");

    //Load font 
    textFont(font); 

    //setup tweetSetManager
    tweetSetManager = new TweetSetManager(this);

    //Setup Weather frame
    WeatherFrame weatherFrame = new WeatherFrame();

    //Setup Time Slider

    dateSelection = new Interval(minDate, maxDate);

    //Add horizontal range slider
    range = controlP5.addRange("Date"+componentID, 0, Hours.hoursIn(dateSelection).getHours(), 0, 24, int(x + 130*scaleFactorX), int(y + (imgY + 50)*scaleFactorY), int((imgX-260) * scaleFactorX), int(30*scaleFactorY));
    //println("Range slider at" + int(imgY*scaleFactorY));
    range.setColorBackground(color(130, 130, 130));
    range.setLabelVisible(false);
    range.setCaptionLabel("");
    dateSelection=new Interval(minDate, minDate.plus(Period.hours(24)));

    //Setup Colours
    setupColours();

    //Setup CP5 search field
    setupSearchField();
  }


  boolean hasMouseOver() {
    return mouseX>x && mouseX<(x+width) && mouseY>y && mouseY<(y+height);
  }









  /* -----------------------------
   *
   * Main draw method
   *
   * -----------------------------*/

  void draw() {

    // ---- Border + Map ----
    stroke(0);
    noFill();
    rect(x, y, width, height);
    //
    strokeWeight(0);
    fill(40);
    rect(x + (imgPos.x - 3)*scaleFactorX, y+ (imgPos.y - 3)*scaleFactorY, (imgX+6)*scaleFactorX, (imgY+6)*scaleFactorY);
    image(imgMap, x + imgPos.x*scaleFactorX, y + imgPos.y*scaleFactorY, imgX*scaleFactorX, imgY*scaleFactorY);  
    //popMatrix();
    // ---- Filter terms text ----
    textSize(18*fontScale);
    fill(76, 86, 108);
    text("Filter Terms", filterTextField_x - 2*scaleFactorX, filterTextField_y - 10*scaleFactorY);

    //pushMatrix();
    //scale(scaleFactorX, scaleFactorY);
    // ---- Border for Range slider ----

    float rangeBorderSize = 2;
    fill(80);
    rect(x + (130 - rangeBorderSize)*scaleFactorX, y+(imgY + 50 - rangeBorderSize)*scaleFactorY, (imgX-260 + rangeBorderSize*2)*scaleFactorX, (30 + rangeBorderSize*2)*scaleFactorY);

    // ---- Draw all the TweetSet Buttons ----
    tweetSetManager.draw();
    //popMatrix();
    // ---- Draw ControlP5 ----  
    controlP5.draw();
    //popMatrix();
    // ---- Draw tweet network if selected / on ----  
    if (b_selection)
      drawTweetNetwork();


    // ---- Draw the tweets on the map ----  
    drawTweetsOnce();


    // --- draw semi-transparent rectangle if click-dragging ---

    if (b_draggingMouse) {
      stroke(200, 200, 255, 100);
      strokeWeight(2*fontScale);
      fill(100, 100, 255, 50);
      rect(mouseDragStart_x, mouseDragStart_y, constrain(mouseX, x + imgPos.x*scaleFactorX, x+(imgX + imgPos.x)*scaleFactorX) - mouseDragStart_x, constrain(mouseY, y+imgPos.y, y+(imgY + imgPos.y)*scaleFactorY) - mouseDragStart_y); //limit rectangle to image boundary
    }


    // ---- Refresh weather applet ----    
    weatherApplet.redraw();
  }



  /* -----------------------------
   *
   * Setup colours (from colorbrewer)
   *
   * -----------------------------*/









  /* -----------------------------
   *
   * Setup the CP5 search field
   *
   * -----------------------------*/

  void setupSearchField()
  {
    filterTextField_x = int(x + scaleFactorX*(imgX+ imgPos.x+ 50));
    filterTextField_y = int(y + 60*scaleFactorY);
    int filterTextField_width = int(180*scaleFactorX);
    int filterTextField_height = int(30*scaleFactorY);

    filterTextField = controlP5.addTextfield("Filters"+componentID, filterTextField_x, filterTextField_y, filterTextField_width, filterTextField_height);
    filterTextField.setColorBackground(250);
    filterTextField.setColorForeground(0);
    filterTextField.setColorValue(50);
    filterTextField.setColorActive(0);
    filterTextField.setColorLabel(0);
    controlP5.setControlFont(new ControlFont(createFont("FFScala", int(18.0*fontScale)), int(18.0*fontScale)));
    filterTextField.setLabel("");
    filterTextField.setFocus(true);
  }




  /* -----------------------------
   *
   * Translate map lon/lat to image map
   *
   * -----------------------------*/

  PVector mapCoordinates(PVector coords)
  {
    //corrects loc for scale *and* offset
    PVector result = new PVector(0.0f, 0.0f);
    result.x = map(coords.x, topleft_lon, bottomright_lon, 0, imgX);
    result.y = map(coords.y, topleft_lat, bottomright_lat, 0, imgY);

    return result;
  }






  /* -----------------------------
   *
   * Draw mouse over info box
   *
   * -----------------------------*/


  void drawMouseOver(Tweet t)
  {

    PVector loc = t.getLocation();

    String s =  t.getText();
    DateTime date = t.getDate();
    String d = fmt2.print(date);
    // date.month().getText();
    int sLength = s.length();
    float gap = 20;
    float info_header_size = 30;
    textSize(18*fontScale);
    int textBoxSize = sLength * 2;
    float headerWidth = 220;

    float shadowOffset = 4;


    if (!b_draggingMouse)
    {
      //shadow
      strokeWeight(0);
      fill(0, 0, 0, 100);
      rect(x + (shadowOffset + loc.x + imgPos.x)*scaleFactorX, y+(shadowOffset + loc.y + imgPos.y)*scaleFactorY, (shadowOffset + headerWidth)*scaleFactorX, (shadowOffset + textBoxSize + info_header_size)*scaleFactorY);

      stroke(0, 0, 0, 200);
      strokeWeight(4*fontScale);

      fill(230, 230, 250, 200);
      rect(x+ (loc.x  + imgPos.x)*scaleFactorX, y+(loc.y  + imgPos.y + info_header_size)*scaleFactorY, (headerWidth*scaleFactorX), textBoxSize*scaleFactorY);

      fill(130, 180, 130, 200);
      rect(x+(loc.x  + imgPos.x)*scaleFactorX, y+(loc.y  + imgPos.y)*scaleFactorY, (headerWidth*scaleFactorX), info_header_size*scaleFactorY);

      fill(255, 255, 255, 255);
      text(d, x+(loc.x  + imgPos.x + 10)*scaleFactorX, y+(loc.y  + imgPos.y + info_header_size - 8)*scaleFactorY);

      fill(0, 50, 100);
      text(s, x+(loc.x + gap  + imgPos.x)*scaleFactorX, y+(loc.y + gap  + imgPos.y + info_header_size)*scaleFactorY, (headerWidth - gap*2)*scaleFactorX, (300 - gap*2)*scaleFactorY);

      fill(t.getTweetSetColour());
    }
  }










  /* -----------------------------------------------
   *
   * Draws all the tweets from the tweetsets active
   *
   * -----------------------------------------------*/


  void drawTweetsOnce()//int mini, int maxi) 
  {
    textFont(font); 
    strokeWeight(2*fontScale);
    Tweet forMouseOver = null;

    //Draw all the tweets
    if (tweetSetManager.getTweetSetListSize() > 0)
      for (TweetSet b: tweetSetManager.getTweetSetList()) {
        if (b.isActive()) //if this tweetset is active
        {      
          if (tweetSetManager.isHeatmapViewActive()) {
            pushMatrix();
            translate(x, y);
            scale(scaleFactorX, scaleFactorY);
            b.heatmap.draw();
            popMatrix();
          }

          for (Tweet a: b.getTweets()) {

            if (dateSelection.contains(a.mDate)) {

              color c = b.getColour();
              a.setAlphaTarget(255);

              fill(red(c), green(c), blue(c), a.getAlpha());

              stroke(0, 0, 0, a.getAlpha());
              strokeWeight(2*fontScale);

              PVector loc = a.getLocation();

              //if there is a drag-select happening
              if (b_draggingMouse) {
                //if this tweet point is inside the selection box
                if (isInsideSelectionBox(loc.x + imgPos.x, loc.y + imgPos.y)) {
                  fill(255);
                }
              }

              if (a.isSelected()) {
                stroke(255);
              }

              if (tweetSetManager.isPointsViewActive())
                rect(x+(imgPos.x - tweetBoxSize/2   + loc.x)*scaleFactorX, y+(imgPos.y  + loc.y- tweetBoxSize/2)*scaleFactorY, tweetBoxSize, tweetBoxSize);

              if (dist(mouseX, mouseY, x+( loc.x + imgPos.x)*scaleFactorX, y+(loc.y + imgPos.y)*scaleFactorY) < 10) {
                forMouseOver =a ;
              }
            }
            else {
              //tweet not in date range 
              a.setAlphaTarget(0);
            }
          }
        }
      }
    if (forMouseOver != null)
      drawMouseOver(forMouseOver);
  }





  /* -----------------------------------------------
   *
   * Returns true if tweet is inside the drag-select box
   *
   * -----------------------------------------------*/

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





  /* -----------------------------------------------
   *
   * Generates a tweet set based on filter term (* for RE)
   *
   * -----------------------------------------------*/


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
    if (keywords.indexOf("*") >= 0)
    {
      RESymbol = "*";
      keywords = keywords.substring(1);
    }

    //Create new tweet set
    TweetSet newTweetSetToAdd = new TweetSet(keywords, setColour, RESymbol, this);

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
      DateTime thisDate;

      // -------- Go through data, storing them as tweets in a tweetset (if they pass optional RE match) --------   

      while (db.next ())
      {
        boolean passesRE = true;  //passes RE check?

        if (RESymbol != "") //if a symbol has been specified for this tweetSet
        {
          //check if it matches a RE      
          if (!matchesRegularExpression( db.getString("message"), filterTerms[0], RESymbol))
            passesRE = false;
        }

        if (passesRE)
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

          newTweetToAdd.setTweetSetColour(setColour);
          newTweetToAdd.setDate(thisDate);

          //convert to pixels and set
          newTweetToAdd.setLocation(mapCoordinates(tweetLocation));
          //newTweetToAdd.findAndSetRegion(tweetLocation); //find and set region by uncorrected coords?

          //add tweet to tweet set
          newTweetSetToAdd.addTweet(newTweetToAdd);
        }
      }

      println("Created " + newTweetSetToAdd.tweets.size() + " tweet records");
    }

    //add this finished tweet set to the array
    tweetSetManager.addTweetSet(newTweetSetToAdd);
    println("Added tweetset to list");

    //update heat maps for first time
    for (TweetSet a: tweetSetManager.getTweetSetList()){
      println("Updating heatmap!");
      a.updateHeatMap();
    }
    println("Updated heatmaps");

    db.close();
  }







  /* -----------------------------------------------
   *
   * Process ControlP5 events
   *
   * -----------------------------------------------*/

  void controlEvent(ControlEvent theControlEvent) {

    /*if (theControlEvent.isGroup()) {
     
     if (theControlEvent.group().id() == 1) // id #1 is for the tweetSetListBox
     {
     int index = int(theControlEvent.group().value());
     println("Removing : " + theControlEvent.group().name());
     }
     }
     else
     {*/
    if (theControlEvent.controller().name().equals("Date"+componentID)) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.
      dateSelection = new Interval(minDate.plus(Period.hours(int(theControlEvent.controller().arrayValue()[0]))), 
      minDate.plus(Period.hours(int(theControlEvent.controller().arrayValue()[1]))));
      println("Selection is " + dateSelection);
      for (TweetSet a: tweetSetManager.getTweetSetList())
        a.updateHeatMap();

      //weatherApplet.setDate(minDate, int(theControlEvent.controller().arrayValue()[1]));
    }


    // -------- Typing something in and hitting return will trigger this code, creating a new tweet set --------
    if (theControlEvent.controller().name().equals("Filters"+componentID)) {
      String keywords = theControlEvent.controller().stringValue();

      if (tweetSetManager.getTweetSetListSize() < tweetSetManager.getMaxTweetSets())
        generateTweetSet(keywords);
      else
        println("**** Too many tweetSets! Please remove before requesting another ***");
    }
    //}
  }










  /* -----------------------------------------------
   *
   * For each uniquely selected user, create a tweet 
   * history that stores all of their tweets
   *
   * Note : Nothing in the data by the look of things
   *
   * -----------------------------------------------*/


  void generateTweetNetwork() {

    println("Generating tweet network");  
    DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");

    //build the query  
    if ( db.connect() ) {  

      String ids = "";
      int counter = 0;
      //loop through the users selected
      for (Integer id: selectedTweetUserIds) {

        println(counter);
        if (counter < selectedTweetUserIds.size()-1)
          ids += "ID= " + id + " OR ";
        else
          ids += "ID = " + id;

        counter++;
      }

      //this way of querying (all in one go) is significantly faster than doing the queries userId by userId
      //requires more work later though, as the tweets aren't organised by id!

      String sqlQuery = "SELECT * FROM micro2 WHERE " + ids + " ORDER BY date";
      println("sqlQuery : " + sqlQuery);

      // list table names
      db.query(sqlQuery);


      while (db.next ())
      {        
        Integer userId =  db.getInt("ID");
        String message = db.getString("message");
        Integer lat = db.getInt("lat");
        Integer lon = db.getInt("lon");

        DateTime thisDate;

        boolean found = false;
        TweetNetwork thisNetwork = new TweetNetwork(0, this);  //blank

        //look to see if we have a tweetNetwork for this user
        for (TweetNetwork n: tweetNetworks) {
          if (n.getUserId().equals(userId))
            found = true;
          thisNetwork = n;
        } 

        if (found == false)
        {
          thisNetwork = new TweetNetwork(userId, this);
          tweetNetworks.add(thisNetwork);
        }


        for (TweetNetwork n: tweetNetworks) {
          if (n.getUserId().equals(userId)) {

            //by this point we have the correct tweetNetwork (either newly created or grabbed)  

            Tweet newTweet = new Tweet();

            //set userid and message
            newTweet.setUserId(userId);
            newTweet.setText(message);

            //set location
            PVector tweetLocation = new PVector(0, 0);
            tweetLocation.x = db.getFloat("lon");
            tweetLocation.y = db.getFloat("lat");
            newTweet.setLocation(mapCoordinates(tweetLocation));

            //set date
            thisDate =fmt.parseDateTime(db.getString("date"));
            newTweet.setDate(thisDate);

            //add to tweet network
            n.getTweetSet().addTweet(newTweet);
          }
        }
      }

      //uncomment to print out 

        for (TweetNetwork v: tweetNetworks) {
        println();
        println();

        ArrayList<Tweet> tweeties = v.getTweetSet().getTweets();  

        for (Tweet t: tweeties)
          //println(t.getText());
          println(t.getDate());
      }
    }

    db.close();

    println("Tweet Networks size : " + tweetNetworks.size());
  }











  /* -----------------------
   *
   * Draw tweet network 
   *
   * ----------------------- */


  void drawTweetNetwork() {

    float nodeSize = 10;

    for (TweetNetwork v: tweetNetworks) {

      ArrayList<Tweet> tweets = v.getTweetSet().getTweets();  

      int counter = 0;
      PVector lastLocation = new PVector(0, 0);
      for (Tweet t: tweets) {

        PVector loc = t.getLocation();

        //if tweet is in past  
        if (t.getDate().isBefore(dateSelection.getStart())) {
          fill(100, 100, 200);
          stroke(100, 100, 200, 200);
          strokeWeight(4*fontScale);
        } 
        //if tweet is in future  
        else if (t.getDate().isAfter(dateSelection.getEnd())) {
          fill(100, 200, 100);
          stroke(100, 200, 100, 200);
          strokeWeight(4*fontScale);
        }
        //tweet is inside range
        else {
          fill(200, 100, 100);
          stroke(200, 100, 100, 200);
          strokeWeight(4*fontScale);
        }

        //if we are at the second point+, draw line
        if (counter > 0)
        {
          // line(lastLocation.x + imgPos.x, lastLocation.y + imgPos.y, loc.x+ imgPos.x, loc.y + imgPos.y);
        }

        lastLocation = loc;

        //draw ellipse at this tweet position
        stroke(0);
        strokeWeight(0);

        ellipse(loc.x + imgPos.x, loc.y + imgPos.y, nodeSize, nodeSize);

        counter++;
      }
    }
  }







  /* -----------------------------------------------
   *
   * Calculates based on selection if the users talk 
   * about other filter terms at some point
   *
   * -----------------------------------------------*/


  void calculateTweetSetCrossover()
  {
    println("calculating tweet set crossover");

    //reset crossover matches at the start
    for (TweetSet o: tweetSetManager.getTweetSetList()) {
      o.resetCrossoverMatches();
    }

    //loop through tweetsets
    if (tweetSetManager.getTweetSetListSize() > 0)
      for (TweetSet b: tweetSetManager.getTweetSetList()) { 
        for (Tweet a: b.getTweets()) {

          if (a.isSelected()) //if this tweet is selected, find out if the user id exists in other tweetSets
          {
            int userId = a.getUserId();

            //now loop through the tweetSets and see if there are matches to this id 
            for (TweetSet d: tweetSetManager.getTweetSetList()) { 
              boolean b_found = false;

              for (Tweet c: d.getTweets()) {
                if (c.getUserId() == userId)
                  b_found = true; //found an id match in this tweetSet
              }

              if (b_found)
                d.incrementCrossoverMatches();
            }
          }
        }
      }

    for (TweetSet b: tweetSetManager.getTweetSetList()) { 
      println("For tweetSet " + b.getSearchTerms() + " : " + b.getNumberOfCrossoverMatches());
    }
  }









  /* -----------------------
   *
   * Mouse code!
   *
   * ----------------------- */


  void mousePressed() {


    //If mouse click / drag on image  
    if (  (mouseX > x+(imgPos.x*scaleFactorX)) && (mouseY > y+(imgPos.y*scaleFactorY)) && (mouseX < x+ (imgX + imgPos.x)*scaleFactorX) && (mouseY < y+(imgY + imgPos.y)*scaleFactorY) ) 
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
    if (b_draggingMouse == true)
      if (mouseButton == LEFT) {  
        numberSelected = 0;
        selectedTweetUserIds.clear();
        tweetNetworks.clear();

        println("calculating new crossover matches");
        // clear all selections!
        for (TweetSet b: tweetSetManager.getTweetSetList()) {

          b.resetCrossoverMatches();


          for (Tweet a: b.getTweets()) {
            a.setSelected(false);
          }
        }

        b_draggingMouse = false;

        mouseDragEnd_x = max(mouseX, imgX*scaleFactorX);
        mouseDragEnd_y = min(mouseY, imgY*scaleFactorY);


        // finished dragging, so set any tweets within drag box to 'selected'
        if (tweetSetManager.getTweetSetListSize() > 0)
          for (TweetSet b: tweetSetManager.getTweetSetList()) {
            if (b.isActive())
            {      
              for (Tweet a: b.getTweets()) {
                if (dateSelection.contains(a.mDate)) 
                  if (isInsideSelectionBox(x+(a.getLocation().x + imgPos.x)*scaleFactorX, y+(a.getLocation().y + imgPos.y)*scaleFactorY))
                  {
                    a.setSelected(true);

                    //If user id doesn't exist in selected tweet username list 
                    if (!selectedTweetUserIds.contains(a.getUserId()))
                      selectedTweetUserIds.add(a.getUserId());

                    numberSelected++;
                  }
              }
            }
          }

        if (numberSelected > 0)
        {
          b_selection = true;
          if (b_generateNetwork)
            generateTweetNetwork();
        }

        //now that we have a selection, calculate the crossover percentage between tweetSets (i.e. how many of these people also mention the other keywords)
        calculateTweetSetCrossover();
      }
      else
        b_draggingMouse = false;


    if (mouseButton == RIGHT) {  
      numberSelected = 0;
      selectedTweetUserIds.clear();
      tweetNetworks.clear();
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
}
