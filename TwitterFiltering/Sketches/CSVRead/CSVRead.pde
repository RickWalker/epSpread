

// --------- Stores a labelled set of tweet frequencies ---------

class TweetFrequencies {

  int hours = 505;
  int days = 21;

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
  }
}






// --------- Loads in a csv file, creates as many tweetFrequency objects as there are columns ---------


TweetFrequencies[] loadCSV(String filename, int numRegions) {

  String[] theData = loadStrings(filename);
  String[] regions = new String[] {
  };

  //this will store all the data, passed back at the end
  TweetFrequencies[] tweetFrequencies = new TweetFrequencies[numRegions];

  for (int i=0; i<numRegions; i++) {
    tweetFrequencies[i] = new TweetFrequencies();
    tweetFrequencies[i].setName(split(theData[0], ",")[i]);
  }


  //This nested loop will work magic and put the csv columns in the correct tweetfrequency objects
  for (int l=numRegions-2; l < theData.length; l++) {
    regions = split(theData[l], ",");

    for (int j=0; j<numRegions; j++) {
      tweetFrequencies[j].addToData(Integer.parseInt(regions[j]));
    }
  }

  return tweetFrequencies;
}





// --------- Test the code ---------

void setup() {
  TweetFrequencies[] results;

  results = loadCSV("output.csv", 3);

  println("Tweet Frequency name : " + results[1].getName());
  for (int i=0; i<results[2].getData().size(); i++) {
    println(results[2].getData().get(i));
  }
}


