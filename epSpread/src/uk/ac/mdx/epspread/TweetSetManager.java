package uk.ac.mdx.epspread;

import java.util.ArrayList;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;

class TweetSetManager {
	int height;
	ArrayList<TweetSet> tweetSets;
	PVector origin;
	PVector buttonDim;
	PVector removeCircleDim;
	PVector optionButtonDim;
	PVector pointsOptionPos;
	PVector heatmapOptionPos;
	PVector weatherOptionPos;

	float buttonDist;
	int maxTweetSets;
	int mouseOverRemoveBox = -1;
	int mouseOverBaseButton = -1;
	boolean mouseOverPointsOptionButton = false;
	boolean mouseOverHeatmapOptionButton = false;
	boolean mouseOverWeatherOptionButton = false;

	boolean b_heatmapViewActive = false;
	boolean b_pointsViewActive = true;
	boolean b_weatherViewActive = false;

	TwitterFilteringComponent parent;
	TwitterFiltering gp;

	int optionButtonsOffset = 0;

	TweetSetManager(TwitterFiltering gp, TwitterFilteringComponent parent) {
		this.parent = parent;
		this.gp = gp;

		tweetSets = new ArrayList<TweetSet>();
		setConstants();
		maxTweetSets = 8;
		height = (int) ((buttonDim.y + buttonDist) * maxTweetSets);
	}

	void setConstants() {
		optionButtonsOffset = (int) (110 * parent.scaleFactorY);
		origin = new PVector(parent.x
				+ (parent.imgPos.x + TwitterFiltering.imgX + 40)
				* parent.scaleFactorX, parent.y + 130 * parent.scaleFactorY);
		buttonDim = new PVector(180 * parent.scaleFactorX,
				40 * parent.scaleFactorY);

		removeCircleDim = new PVector(20 * parent.scaleFactorX,
				20 * parent.scaleFactorY);
		optionButtonDim = new PVector(88 * parent.scaleFactorX,
				30 * parent.scaleFactorY);
		buttonDist = 8.0f * parent.scaleFactorY;
		// also move buttons? shuffle tweet sets down!
		for (TweetSet a : tweetSets) {
			// target them at the right place!
			a.getButtonPosY().set(
					origin.y + (buttonDim.y * a.id) + (buttonDist * a.id));
			a.getButtonPosY().target(
					origin.y + (buttonDim.y * a.id) + (buttonDist * a.id));
		}
		// height = int((buttonDim.y+buttonDist)*(maxTweetSets-1));
	}

	int getHeight() {
		// println("position is " + int(origin.y) + height);
		return height;
	}

	void draw() {

		gp.textSize(18 * parent.fontScale);
		gp.text("Results", origin.x - 1 * parent.scaleFactorX, origin.y - 12
				* parent.scaleFactorY);
		float alphaCol = 255;
		mouseOverRemoveBox = -1;
		mouseOverBaseButton = -1;
		mouseOverPointsOptionButton = false;
		mouseOverHeatmapOptionButton = false;
		mouseOverWeatherOptionButton = false;

		// -------- Draw the background pane --------

		gp.strokeWeight(1 * parent.fontScale);
		gp.stroke(200);
		gp.fill(225 - 5, 228 - 5, 233 - 5);

		for (int i = 0; i < maxTweetSets; i++)
			gp.rrect(origin.x, origin.y + (buttonDim.y * i) + (buttonDist * i),
					buttonDim.x, buttonDim.y, 10.0f * parent.scaleFactorX,
					2.4f * parent.scaleFactorY, "");

		pointsOptionPos = new PVector(origin.x, optionButtonsOffset + origin.y
				+ (optionButtonDim.y * maxTweetSets + 1)
				+ (buttonDist * maxTweetSets + 1));
		heatmapOptionPos = new PVector(origin.x + optionButtonDim.x + 5
				* parent.scaleFactorX, optionButtonsOffset + origin.y
				+ (optionButtonDim.y * maxTweetSets + 1)
				+ (buttonDist * maxTweetSets + 1));
		weatherOptionPos = new PVector(origin.x, optionButtonsOffset + origin.y
				+ (optionButtonDim.y * maxTweetSets + 1)
				+ (buttonDist * maxTweetSets + 1) + (35 * parent.scaleFactorY));

		// -------- Draw view options buttons --------

		float pointsOptionButtonAlpha = 255 * 1.0f;
		float heatmapOptionButtonAlpha = 255 * 1.0f;
		float weatherOptionButtonAlpha = 255 * 1.0f;

		if (b_pointsViewActive == false)
			pointsOptionButtonAlpha = 255 * 0.3f;

		if (b_heatmapViewActive == false)
			heatmapOptionButtonAlpha = 255 * 0.3f;

		if (b_weatherViewActive == false)
			weatherOptionButtonAlpha = 255 * 0.3f;

		int pointsOptionButtonColour = gp.color(247, 247, 247,
				pointsOptionButtonAlpha);
		int heatmapOptionButtonColour = gp.color(247, 247, 247,
				heatmapOptionButtonAlpha);
		int weatherOptionButtonColour = gp.color(247, 247, 247,
				weatherOptionButtonAlpha);

		if ((gp.mouseX > pointsOptionPos.x)
				&& (gp.mouseX < pointsOptionPos.x + optionButtonDim.x)
				&& (gp.mouseY > pointsOptionPos.y)
				&& (gp.mouseY < pointsOptionPos.y + optionButtonDim.y)) {
			pointsOptionButtonColour = gp.color(
					gp.red(pointsOptionButtonColour) * 2.3f,
					gp.green(pointsOptionButtonColour) * 2.3f,
					gp.blue(pointsOptionButtonColour) * 2.3f,
					pointsOptionButtonAlpha);
			mouseOverPointsOptionButton = true;
		}

		if ((gp.mouseX > heatmapOptionPos.x)
				&& (gp.mouseX < heatmapOptionPos.x + optionButtonDim.x)
				&& (gp.mouseY > heatmapOptionPos.y)
				&& (gp.mouseY < heatmapOptionPos.y + optionButtonDim.y)) {
			heatmapOptionButtonColour = gp.color(
					gp.red(heatmapOptionButtonColour) * 2.3f,
					gp.green(heatmapOptionButtonColour) * 2.3f,
					gp.blue(heatmapOptionButtonColour) * 2.3f,
					heatmapOptionButtonAlpha);
			mouseOverHeatmapOptionButton = true;
		}

		if ((gp.mouseX > weatherOptionPos.x)
				&& (gp.mouseX < weatherOptionPos.x + optionButtonDim.x)
				&& (gp.mouseY > weatherOptionPos.y)
				&& (gp.mouseY < weatherOptionPos.y + optionButtonDim.y)) {
			weatherOptionButtonColour = gp.color(
					gp.red(weatherOptionButtonColour) * 2.3f,
					gp.green(weatherOptionButtonColour) * 2.3f,
					gp.blue(weatherOptionButtonColour) * 2.3f,
					weatherOptionButtonAlpha);
			mouseOverWeatherOptionButton = true;
		}

		gp.strokeWeight(1.5f * parent.fontScale);
		gp.stroke(181, 184, 188, alphaCol);

		gp.fill(pointsOptionButtonColour);
		gp.rrect(pointsOptionPos.x, pointsOptionPos.y, optionButtonDim.x,
				optionButtonDim.y, 10.0f * parent.scaleFactorX,
				2.4f * parent.scaleFactorY, "");

		gp.fill(heatmapOptionButtonColour);
		gp.rrect(heatmapOptionPos.x, heatmapOptionPos.y, optionButtonDim.x,
				optionButtonDim.y, 10.0f * parent.scaleFactorX,
				2.4f * parent.scaleFactorY, "");

		gp.fill(weatherOptionButtonColour);
		gp.rrect(weatherOptionPos.x, weatherOptionPos.y, optionButtonDim.x,
				optionButtonDim.y, 10.0f * parent.scaleFactorX,
				2.4f * parent.scaleFactorY, "");

		gp.textAlign(PConstants.CENTER, PConstants.CENTER);
		gp.fill(50, 50, 50, pointsOptionButtonAlpha);
		gp.text("Points", pointsOptionPos.x + (optionButtonDim.x / 2.0f),
				pointsOptionPos.y + (optionButtonDim.y / 2.0f));
		gp.fill(50, 50, 50, heatmapOptionButtonAlpha);
		gp.text("Heatmap", heatmapOptionPos.x + (optionButtonDim.x / 2.0f),
				heatmapOptionPos.y + (optionButtonDim.y / 2.0f));
		gp.fill(50, 50, 50, weatherOptionButtonAlpha);
		gp.text("Weather", weatherOptionPos.x + (optionButtonDim.x / 2.0f),
				weatherOptionPos.y + (optionButtonDim.y / 2.0f));
		gp.textAlign(PConstants.LEFT, PConstants.LEFT);

		gp.fill(76, 86, 108);
		gp.text("Options", pointsOptionPos.x, pointsOptionPos.y - 12
				* parent.scaleFactorY);
		height = (int) (pointsOptionPos.y + optionButtonDim.y);
		// println(height);

		// -------- Loop through tweetSets --------

		for (TweetSet a : tweetSets) {
			if (!a.isActive())
				alphaCol = 255 * 0.3f;
			else
				alphaCol = 255;

			PVector buttonPos = new PVector(origin.x, a.getButtonPosY().value);
			PVector removeCirclePos = new PVector(buttonPos.x + buttonDim.x
					- 12 * parent.scaleFactorX, buttonPos.y + 13
					* parent.scaleFactorY);
			int buttonColour = gp.color(247, 247, 247, alphaCol);
			int removeCircleColour = gp.color(247, 247, 247, alphaCol);

			a.getButtonPosY().update(); // update the tweetSet's interpolator (y
										// pos of button)

			if (a.getRegularExpressionSymbol() == "*") {
				buttonColour = gp.color(210, 242, 210, alphaCol);
				removeCircleColour = gp.color(210, 242, 210, alphaCol);
			}

			if (a.getRegularExpressionSymbol() == "$") {
				buttonColour = gp.color(210, 210, 242, alphaCol);
				removeCircleColour = gp.color(210, 210, 242, alphaCol);
			}

			if (a.getRegularExpressionSymbol() == "!") {
				buttonColour = gp.color(240, 240, 200, alphaCol);
				removeCircleColour = gp.color(240, 240, 200, alphaCol);
			}

			// -------- If mouse is over remove box, process! --------

			if ((PApplet.abs(gp.mouseX - removeCirclePos.x) < 10 * parent.scaleFactorX)
					&& (PApplet.abs(gp.mouseY - removeCirclePos.y) < 10 * parent.scaleFactorY)) {
				removeCircleColour = gp.color(
						gp.red(removeCircleColour) * 2.3f,
						gp.green(removeCircleColour) * 2.3f,
						gp.blue(removeCircleColour) * 2.3f, 255 * 0.6f);
				mouseOverRemoveBox = a.getId();
			}

			// -------- If mouse is over button in general, process! --------

			else if ((gp.mouseX > buttonPos.x)
					&& (gp.mouseX < buttonPos.x + buttonDim.x)
					&& (gp.mouseY > buttonPos.y)
					&& (gp.mouseY < buttonPos.y + buttonDim.y)) {
				buttonColour = gp.color(gp.red(buttonColour) * 1.05f,
						gp.green(buttonColour) * 1.05f,
						gp.blue(buttonColour) * 1.05f, alphaCol);
				removeCircleColour = gp.color(
						gp.red(removeCircleColour) * 1.05f,
						gp.green(removeCircleColour) * 1.05f,
						gp.blue(removeCircleColour) * 1.05f, alphaCol);
				mouseOverBaseButton = a.getId();
			}

			// -------- Draw the button outline --------
			gp.stroke(181, 184, 188, alphaCol);
			gp.strokeWeight(1.5f * parent.fontScale);
			gp.fill(buttonColour);
			// rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y);
			gp.rrect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y,
					10.0f * parent.scaleFactorX, 2.4f * parent.scaleFactorY, "");

			// -------- Draw the tweet box colour --------

			gp.stroke(150, 150, 150, alphaCol);
			gp.strokeWeight(1 * parent.fontScale);
			int tweetSetColour = a.getColour();
			gp.fill(gp.red(tweetSetColour), gp.green(tweetSetColour),
					gp.blue(tweetSetColour), alphaCol);
			gp.rect(buttonPos.x + 8 * parent.scaleFactorX, buttonPos.y + 8
					* parent.scaleFactorY, 11 * parent.scaleFactorX,
					11 * parent.scaleFactorY);

			// -------- Draw the button text --------
			gp.textAlign(PConstants.LEFT, PConstants.CENTER);
			gp.fill(40, 40, 40, (int) alphaCol);
			gp.text(a.getSearchTerms(), buttonPos.x + 30 * parent.scaleFactorX,
					buttonPos.y + (buttonDim.y / 2.0f));

			// ------- Draw the crossover percentage ----------

			if (a.getNumberOfCrossoverMatches() > 0) {
				float percentageMatch = (a.getNumberOfCrossoverMatches() / (float) (parent.numberSelected)) * 100.0f;

				gp.fill(100, 100, 100, (int) alphaCol);
				gp.text(PApplet.nf(percentageMatch, 1, 1) + "%", buttonPos.x
						+ buttonDim.x + 5 * parent.scaleFactorX, buttonPos.y
						+ (buttonDim.y / 2.0f));
			}

			// -------- Draw remove box --------

			gp.stroke(220, 220, 200, alphaCol);

			gp.strokeWeight(0);
			if (mouseOverRemoveBox == a.getId()) // if mouse over, add outline
				gp.strokeWeight(1 * parent.fontScale);

			gp.fill(removeCircleColour);
			// rect(removeBoxPos.x, removeBoxPos.y, removeBoxDim.x,
			// removeBoxDim.y);
			gp.ellipse(removeCirclePos.x, removeCirclePos.y, removeCircleDim.x,
					removeCircleDim.y);

			gp.fill(0, 0, 0, alphaCol);
			gp.text("x", removeCirclePos.x - 4.0f * parent.scaleFactorX,
					removeCirclePos.y - 1.0f * parent.scaleFactorY);

			gp.textAlign(PConstants.LEFT, PConstants.LEFT);
		}

		// reset for other draw functions
		gp.strokeWeight(1 * parent.fontScale);
		gp.stroke(181, 184, 188);
	}

	boolean isHeatmapViewActive() {
		return b_heatmapViewActive;
	}

	boolean isPointsViewActive() {
		return b_pointsViewActive;
	}

	boolean isWeatherViewActive() {
		return b_weatherViewActive;
	}

	void processMouse() {

		// -------- If user clicked on options button, select --------

		if (mouseOverPointsOptionButton) {
			b_pointsViewActive = true;
			b_heatmapViewActive = false;
		}

		if (mouseOverHeatmapOptionButton) {
			b_pointsViewActive = false;
			b_heatmapViewActive = true;
		}

		if (mouseOverWeatherOptionButton) {
			b_weatherViewActive = !b_weatherViewActive;

			// if(b_weatherViewActive)
			// parent..createStreamGraph();
		}

		if (mouseOverRemoveBox >= 0) {

			PApplet.println("Over remove box : " + mouseOverRemoveBox);
			b_weatherViewActive = false; // switch weather off (bug fix)

			// loop through tweet sets, find the one that has id =
			// mouseOverRemoveBox and remove it!
			for (TweetSet a : tweetSets)
				if (a.getId() == mouseOverRemoveBox) {
					tweetSets.remove(a);
					gp.colours.add(a.getColour());
					reallocateIds(); // tweetSet has been removed, reallocate
										// id's for correct button drawing
					break;
				}

		} else if (mouseOverBaseButton >= 0) {

			for (TweetSet a : tweetSets)
				if (a.getId() == mouseOverBaseButton) {
					a.setActive(!a.isActive()); // activate or de-activate
												// tweetSet
					break;
				}
		}
	}

	// --------- When a tweetSet is deleted, we need to reallocate Id's to each
	// tweetSet, so that they are drawn correctly as buttons)

	void reallocateIds() {
		int newId = 0;

		for (TweetSet a : tweetSets) {
			a.setId(newId);
			a.getButtonPosY().target(
					origin.y + (buttonDim.y * newId) + (buttonDist * newId));
			newId++;
		}
	}

	void addTweetSet(TweetSet newTweetSet) {
		int theId = tweetSets.size();

		// give this new tweet set a unique id
		newTweetSet.setId(theId);
		newTweetSet.getButtonPosY().set(
				origin.y + (buttonDim.y * theId) + (buttonDist * theId)
						- buttonDim.y);
		newTweetSet.getButtonPosY().target(
				origin.y + (buttonDim.y * theId) + (buttonDist * theId));

		tweetSets.add(newTweetSet);
	}

	int getTweetSetListSize() {
		return tweetSets.size();
	}

	int getMaxTweetSets() {
		return maxTweetSets;
	}

	ArrayList<TweetSet> getTweetSetList() {
		return tweetSets;
	}
}
