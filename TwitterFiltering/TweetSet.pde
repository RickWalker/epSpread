class TweetSet{
  
ArrayList<Tweet> tweets = new ArrayList<Tweet>();  
String[] filterTerms;
color setColour;
HeatmapOverlay heatmap;
int id = 0;
String mSearchTerms = "";
   
TweetSet(String keywords, color colour)
    {
    setColour = colour;
    heatmap = new HeatmapOverlay();
    mSearchTerms = keywords;
    }
  
  
void setId(int _id){
 id = _id;
}
  
int getId(){
  return id;
}
  

void addTweet(Tweet theTweet)
{
 tweets.add(theTweet); 
}
  
    
ArrayList<Tweet> getTweets()
{
 return tweets; 
}


String getSearchTerms()
{
  return mSearchTerms;
}


void updateHeatMap(){
heatmap.createSurface(imgX, imgY, tweets);
}
  
  
color getColour()
{
 return setColour; 
}
  
  
  
  
  
  
}
