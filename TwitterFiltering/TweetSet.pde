class TweetSet{
  
ArrayList<Tweet> tweets = new ArrayList<Tweet>();  
String[] filterTerms;
color setColour;
HeatmapOverlay heatmap;
   
TweetSet(String keywords, color colour)
    {
    setColour = colour;
	heatmap = new HeatmapOverlay();
    }
  
  

void addTweet(Tweet theTweet)
{
 tweets.add(theTweet); 
}
  
  
ArrayList<Tweet> getTweets()
{
 return tweets; 
}

void updateHeatMap(){
heatmap.createSurface(imgX, imgY, tweets);
}
  
  
color getColour()
{
 return setColour; 
}
  
  
  
  
  
  
}
