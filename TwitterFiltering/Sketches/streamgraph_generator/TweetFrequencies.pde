

// --------- Stores a labelled set of tweet frequencies ---------

public class TweetFrequencies {

  int hours = 505;
  int days = 21;
  int totalTweets;

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
    totalTweets += value;
  }
  
    int getTotalTweets(){
   return totalTweets; 
  }
}
