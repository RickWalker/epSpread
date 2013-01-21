package uk.ac.mdx.epspread;

import java.util.ArrayList;

//import org.joda.time.DateTime;
import org.joda.time.Days;
import org.joda.time.Interval;

//import org.joda.time.Period;

public class TweetSet {

	ArrayList<Tweet> tweets = new ArrayList<Tweet>();
	String[] filterTerms;
	String regularExpression = "";
	int setColour;
	HeatmapOverlay heatmap;
	int id = 0;
	String mSearchTerms = "";
	Integrator integrator_buttonPosY; // Y position of this tweet set's button
	boolean b_active;
	TwitterFilteringComponent parent;
	TwitterFiltering gp;

	int[] tweetDayFrequencies;// = new int[21];

	int crossoverMatches = 0; // How many of these tweets are made by people
								// currently selected

	// DateTime startDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period
	// .hours(0));
	// DateTime endDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period
	// .hours(0));

	TweetSet(String keywords, int colour, String re,
			TwitterFilteringComponent parent, TwitterFiltering gp) // argh
	{
		this.parent = parent;
		this.gp = gp;
		tweetDayFrequencies = new int[Days
				.daysIn(new Interval(TwitterFiltering.minDate,
						TwitterFiltering.maxDate)).getDays()];
		setColour = colour;
		heatmap = new HeatmapOverlay(gp, parent);
		mSearchTerms = keywords;
		integrator_buttonPosY = new Integrator(80);
		b_active = true;
		regularExpression = re;

		for (int i = 0; i < 21; i++)
			tweetDayFrequencies[i] = 0;
	}

	Integrator getButtonPosY() {
		return integrator_buttonPosY;
	}

	boolean isActive() {
		return b_active;
	}

	void setActive(boolean val) {
		b_active = val;
	}

	void setId(int _id) {
		id = _id;
	}

	int getId() {
		return id;
	}

	void addTweet(Tweet theTweet) {
		tweets.add(theTweet);
		if(theTweet.getDate().isBefore(TwitterFiltering.minDate)){
			System.err.println("Date for tweet " + theTweet.getText() + " is" + theTweet.getDate());
			System.err.println("minDate is " + TwitterFiltering.minDate);
		}

		// find and increment day of tweet
		int dayOfTweet = Days.daysIn(
				new Interval(TwitterFiltering.minDate, theTweet.getDate()))
				.getDays();
		if (dayOfTweet < tweetDayFrequencies.length)
			tweetDayFrequencies[dayOfTweet] = tweetDayFrequencies[dayOfTweet] + 1;
	}

	int getFrequencyOnDay(int theDay) {
		return tweetDayFrequencies[theDay];
	}

	ArrayList<Tweet> getTweets() {
		return tweets;
	}

	int getNumberOfTweets() {
		return tweets.size();
	}

	String getSearchTerms() {
		return mSearchTerms;
	}

	void updateHeatMap() {
		// heatmap.createSimpleSurface(imgX, imgY, tweets);
		heatmap.createWeightedSurface(TwitterFiltering.imgX,
				TwitterFiltering.imgY, tweets);

	}

	int getColour() {
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

	int[] getTweetDayFrequencies() {
		return tweetDayFrequencies;
	}

	String getRegularExpressionSymbol() {
		return regularExpression;
	}
}
