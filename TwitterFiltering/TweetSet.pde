class TweetSet{
  
ArrayList<Tweet> tweets = new ArrayList<Tweet>();  
String[] filterTerms;
color setColour;
HeatmapOverlay heatmap;
int id = 0;
String mSearchTerms = "";
Integrator integrator_buttonPosY;  //Y position of this tweet set's button
   
TweetSet(String keywords, color colour)
    {
    setColour = colour;
    heatmap = new HeatmapOverlay();
    mSearchTerms = keywords;
    integrator_buttonPosY = new Integrator(80);
    }
    
    
Integrator getButtonPosY()
{
 return integrator_buttonPosY; 
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
