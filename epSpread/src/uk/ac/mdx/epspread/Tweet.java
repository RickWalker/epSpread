package uk.ac.mdx.epspread;

import org.joda.time.DateTime;

import de.fhpotsdam.unfolding.geo.Location;

//import processing.core.PVector;

public class Tweet {

	String mText;

	Location mLocation;
	DateTime mDate;
	int userId;
	boolean b_selected;
	int tweetSetColour;
	Integrator alphaVal;
	//Region tweetRegion;

	Tweet() {

		mText = "blah";
		mLocation = new Location(0, 0);
		//tweetRegion = null;
		// mDate = 0.0f;
		userId = -1;
		b_selected = false;
		tweetSetColour = 0;
		alphaVal = new Integrator(255);
	}

	DateTime getDate() {
		return mDate;
	}

	void setAlphaTarget(float value) {
		alphaVal.target(value);
	}

	Integrator getAlphaIntegrator() {
		return alphaVal;
	}

	float getAlpha() {
		return alphaVal.value;
	}

	void setTweetSetColour(int _theColour) {
		tweetSetColour = _theColour;
	}

	int getTweetSetColour() {
		return tweetSetColour;
	}

	void setText(String someText) {
		mText = someText;
	}

	void setDate(DateTime d) {
		mDate = new DateTime(d);
		// println("mDate is " + mDate);
	}

	void setLocation(Location coords) {
		mLocation.setLat(coords.getLat());
		mLocation.setLon(coords.getLon());
		// find out what region it's in!
		// tweetRegion = findRegion(mLocation);
	}

	/*
	 * Region findRegion(PVector t) { //map to the same space! PVector newT =
	 * new PVector(0,0); newT.x = map(t.x, 0, imgX, 1, 1799); newT.y = map(t.y,
	 * 0, imgY, 1,915); for (Region a: regions) { if (a.contains(newT)) { return
	 * a; } } return null; }
	 */

	void setUserId(int id) {
		userId = id;
	}

	int getUserId() {
		return userId;
	}

	Location getLocation() {
		return mLocation;
	}

	String getText() {
		return mText;
	}

	void setSelected(boolean val) {
		b_selected = val;
	}

	boolean isSelected() {
		return b_selected;
	}

	public String toString() {
		// returns nicely formatted tweet representation
		//return mDate + " " + mText + " " + tweetRegion.getName() + " at "
			//	+ mLocation;
		return mDate + " " + mText + " at "
		+ mLocation;
	}
}
