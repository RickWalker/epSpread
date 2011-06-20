class TweetSet {

  ArrayList<Tweet> tweets = new ArrayList<Tweet>();  
  String[] filterTerms;
  String regularExpression = "";
  color setColour;
  HeatmapOverlay heatmap;
  int id = 0;
  String mSearchTerms = "";
  Integrator integrator_buttonPosY;  //Y position of this tweet set's button
  boolean b_active;
  TwitterFilteringComponent parent;

  int[] tweetDayFrequencies = new int[21];

  int crossoverMatches = 0;  //How many of these tweets are made by people currently selected
  
  DateTime startDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(0));
  DateTime endDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period.hours(0));


  TweetSet(String keywords, color colour, String re, TwitterFilteringComponent parent) //argh
  {
    this.parent = parent;
    setColour = colour;
    heatmap = new HeatmapOverlay(parent);
    mSearchTerms = keywords;
    integrator_buttonPosY = new Integrator(80);
    b_active = true;
    regularExpression = re;
    
    for (int i=0; i<21; i++)
      tweetDayFrequencies[i] = 0;
  }


  Integrator getButtonPosY()
  {
    return integrator_buttonPosY;
  }


  boolean isActive() {
    return b_active;
  }

  void setActive(boolean val)
  {
    b_active = val;
  }

  void setId(int _id) {
    id = _id;
  }

  int getId() {
    return id;
  }


  void addTweet(Tweet theTweet)
  {
    tweets.add(theTweet);

    //find and increment day of tweet
    int dayOfTweet = Days.daysIn(new Interval(startDate, theTweet.getDate())).getDays();
    tweetDayFrequencies[dayOfTweet] = tweetDayFrequencies[dayOfTweet]+1;
  }


int getFrequencyOnDay(int theDay){
return tweetDayFrequencies[theDay];  
}


  ArrayList<Tweet> getTweets()
  {
    return tweets;
  }


  int getNumberOfTweets()
  {
    return tweets.size();
  }


  String getSearchTerms()
  {
    return mSearchTerms;
  }


  void updateHeatMap() {
    //heatmap.createSimpleSurface(imgX, imgY, tweets);
    heatmap.createWeightedSurface(imgX, imgY, tweets);
  }


  color getColour()
  {
    return setColour;
  }



  void incrementCrossoverMatches() {
    crossoverMatches++;
  }

  int getNumberOfCrossoverMatches() {
    return crossoverMatches;
  }


  void resetCrossoverMatches() {
    crossoverMatches = 0;
  }


  int[] getTweetDayFrequencies(){
  return tweetDayFrequencies;  
  }

  String getRegularExpressionSymbol()
  {
    return regularExpression;
  }
}

