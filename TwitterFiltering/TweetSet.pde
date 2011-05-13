class TweetSet{
  
ArrayList<Tweet> tweets = new ArrayList<Tweet>();  
String[] filterTerms;
color setColour;
   
TweetSet(String keywords, color colour)
    {
    setColour = colour;
    }
  
  

void addTweet(Tweet theTweet)
{
 tweets.add(theTweet); 
}
  
  
ArrayList<Tweet> getTweets()
{
 return tweets; 
}
  
  
color getColour()
{
 return setColour; 
}
  
  
  
  
  
  
}
