







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
  for (int l=1; l < theData.length; l++) {
    regions = split(theData[l], ",");
 
    //region now contains data for each region
    for(int j=0; j<numRegions; j++)
    {
      tweetFrequencies[j].addToData(Integer.parseInt(regions[j]));
    }
  }

  return tweetFrequencies;
}




/*
// --------- Test the code ---------

void setup() {
  TweetFrequencies[] results;

  results = loadCSV("output.csv", 3);

  println("Tweet Frequency name : " + results[1].getName());
  for (int i=0; i<results[2].getData().size(); i++) {
    println(results[2].getData().get(i));
  }
}
*/

