

// --------- Stores a labelled set of tweet frequencies ---------

public class TweetFrequencies {

  int hours = 505;
  int days = 21;
  float maxTweets = -10000000;
  float minTweets = 10000000;
  

  String mName;
  ArrayList<Integer> mData = new ArrayList<Integer>();

  void TweetFrequencies() {

    mName = "blank";
  }

  ArrayList<Integer> getData() {
    return mData;
  }


  void setName(String name) {
    mName = name;
  }

  String getName() {
    return mName;
  }

  void addToData(Integer value) {
    mData.add(value);
    
    if(value > maxTweets)
      maxTweets = value;
    
    if(value < minTweets)
      minTweets = value;
  }
  
    float getMaxTweets(){
   return maxTweets; 
  }
  
   float getMinTweets(){
   return minTweets; 
  }
  
  
}
