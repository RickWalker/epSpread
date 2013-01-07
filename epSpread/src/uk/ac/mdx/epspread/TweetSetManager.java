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
	TwitterFiltering papplet;

	int optionButtonsOffset = 0;

	TweetSetManager(TwitterFiltering papplet, TwitterFilteringComponent parent) {
		this.parent = parent;
		this.papplet = papplet;

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

		papplet.textSize(18 * parent.fontScale);
		papplet.text("Results", origin.x - 1 * parent.scaleFactorX, origin.y - 12
				* parent.scaleFactorY);
		float alphaCol = 255;
		mouseOverRemoveBox = -1;
		mouseOverBaseButton = -1;
		mouseOverPointsOptionButton = false;
		mouseOverHeatmapOptionButton = false;
		mouseOverWeatherOptionButton = false;

		// -------- Draw the background pane --------

		papplet.strokeWeight(1 * parent.fontScale);
		papplet.stroke(200);
		papplet.fill(225 - 5, 228 - 5, 233 - 5);

		for (int i = 0; i < maxTweetSets; i++)
			papplet.rect(origin.x, origin.y + (buttonDim.y * i) + (buttonDist * i),
					buttonDim.x, buttonDim.y, 10.0f * parent.scaleFactorX,
					2.4f * parent.scaleFactorY);

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

		int pointsOptionButtonColour = papplet.color(247, 247, 247,
				pointsOptionButtonAlpha);
		int heatmapOptionButtonColour = papplet.color(247, 247, 247,
				heatmapOptionButtonAlpha);
		int weatherOptionButtonColour = papplet.color(247, 247, 247,
				weatherOptionButtonAlpha);

		if ((papplet.mouseX > pointsOptionPos.x)
				&& (papplet.mouseX < pointsOptionPos.x + optionButtonDim.x)
				&& (papplet.mouseY > pointsOptionPos.y)
				&& (papplet.mouseY < pointsOptionPos.y + optionButtonDim.y)) {
			pointsOptionButtonColour = papplet.color(
					papplet.red(pointsOptionButtonColour) * 2.3f,
					papplet.green(pointsOptionButtonColour) * 2.3f,
					papplet.blue(pointsOptionButtonColour) * 2.3f,
					pointsOptionButtonAlpha);
			mouseOverPointsOptionButton = true;
		}

		if ((papplet.mouseX > heatmapOptionPos.x)
				&& (papplet.mouseX < heatmapOptionPos.x + optionButtonDim.x)
				&& (papplet.mouseY > heatmapOptionPos.y)
				&& (papplet.mouseY < heatmapOptionPos.y + optionButtonDim.y)) {
			heatmapOptionButtonColour = papplet.color(
					papplet.red(heatmapOptionButtonColour) * 2.3f,
					papplet.green(heatmapOptionButtonColour) * 2.3f,
					papplet.blue(heatmapOptionButtonColour) * 2.3f,
					heatmapOptionButtonAlpha);
			mouseOverHeatmapOptionButton = true;
		}

		if ((papplet.mouseX > weatherOptionPos.x)
				&& (papplet.mouseX < weatherOptionPos.x + optionButtonDim.x)
				&& (papplet.mouseY > weatherOptionPos.y)
				&& (papplet.mouseY < weatherOptionPos.y + optionButtonDim.y)) {
			weatherOptionButtonColour = papplet.color(
					papplet.red(weatherOptionButtonColour) * 2.3f,
					papplet.green(weatherOptionButtonColour) * 2.3f,
					papplet.blue(weatherOptionButtonColour) * 2.3f,
					weatherOptionButtonAlpha);
			mouseOverWeatherOptionButton = true;
		}

		papplet.strokeWeight(1.5f * parent.fontScale);
		papplet.stroke(181, 184, 188, alphaCol);

		papplet.fill(pointsOptionButtonColour);
		papplet.rect(pointsOptionPos.x, pointsOptionPos.y, optionButtonDim.x,
				optionButtonDim.y, 10.0f * parent.scaleFactorX,
				2.4f * parent.scaleFactorY);

		papplet.fill(heatmapOptionButtonColour);
		papplet.rect(heatmapOptionPos.x, heatmapOptionPos.y, optionButtonDim.x,
				optionButtonDim.y, 10.0f * parent.scaleFactorX,
				2.4f * parent.scaleFactorY);

		papplet.fill(weatherOptionButtonColour);
		papplet.rect(weatherOptionPos.x, weatherOptionPos.y, optionButtonDim.x,
				optionButtonDim.y, 10.0f * parent.scaleFactorX,
				2.4f * parent.scaleFactorY);

		papplet.textAlign(PConstants.CENTER, PConstants.CENTER);
		papplet.fill(50, 50, 50, pointsOptionButtonAlpha);
		papplet.text("Points", pointsOptionPos.x + (optionButtonDim.x / 2.0f),
				pointsOptionPos.y + (optionButtonDim.y / 2.0f));
		papplet.fill(50, 50, 50, heatmapOptionButtonAlpha);
		papplet.text("Heatmap", heatmapOptionPos.x + (optionButtonDim.x / 2.0f),
				heatmapOptionPos.y + (optionButtonDim.y / 2.0f));
		papplet.fill(50, 50, 50, weatherOptionButtonAlpha);
		papplet.text("Weather", weatherOptionPos.x + (optionButtonDim.x / 2.0f),
				weatherOptionPos.y + (optionButtonDim.y / 2.0f));
		papplet.textAlign(PConstants.LEFT, PConstants.LEFT);

		papplet.fill(76, 86, 108);
		papplet.text("Options", pointsOptionPos.x, pointsOptionPos.y - 12
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
			int buttonColour = papplet.color(247, 247, 247, alphaCol);
			int removeCircleColour = papplet.color(247, 247, 247, alphaCol);

			a.getButtonPosY().update(); // update the tweetSet's interpolator (y
										// pos of button)

			if (a.getRegularExpressionSymbol() == "*") {
				buttonColour = papplet.color(210, 242, 210, alphaCol);
				removeCircleColour = papplet.color(210, 242, 210, alphaCol);
			}

			if (a.getRegularExpressionSymbol() == "$") {
				buttonColour = papplet.color(210, 210, 242, alphaCol);
				removeCircleColour = papplet.color(210, 210, 242, alphaCol);
			}

			if (a.getRegularExpressionSymbol() == "!") {
				buttonColour = papplet.color(240, 240, 200, alphaCol);
				removeCircleColour = papplet.color(240, 240, 200, alphaCol);
			}

			// -------- If mouse is over remove box, process! --------

			if ((PApplet.abs(papplet.mouseX - removeCirclePos.x) < 10 * parent.scaleFactorX)
					&& (PApplet.abs(papplet.mouseY - removeCirclePos.y) < 10 * parent.scaleFactorY)) {
				removeCircleColour = papplet.color(
						papplet.red(removeCircleColour) * 2.3f,
						papplet.green(removeCircleColour) * 2.3f,
						papplet.blue(removeCircleColour) * 2.3f, 255 * 0.6f);
				mouseOverRemoveBox = a.getId();
			}

			// -------- If mouse is over button in general, process! --------

			else if ((papplet.mouseX > buttonPos.x)
					&& (papplet.mouseX < buttonPos.x + buttonDim.x)
					&& (papplet.mouseY > buttonPos.y)
					&& (papplet.mouseY < buttonPos.y + buttonDim.y)) {
				buttonColour = papplet.color(papplet.red(buttonColour) * 1.05f,
						papplet.green(buttonColour) * 1.05f,
						papplet.blue(buttonColour) * 1.05f, alphaCol);
				removeCircleColour = papplet.color(
						papplet.red(removeCircleColour) * 1.05f,
						papplet.green(removeCircleColour) * 1.05f,
						papplet.blue(removeCircleColour) * 1.05f, alphaCol);
				mouseOverBaseButton = a.getId();
			}

			// -------- Draw the button outline --------
			papplet.stroke(181, 184, 188, alphaCol);
			papplet.strokeWeight(1.5f * parent.fontScale);
			papplet.fill(buttonColour);
			// rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y);
			papplet.rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y,
					10.0f * parent.scaleFactorX, 2.4f * parent.scaleFactorY);

			// -------- Draw the tweet box colour --------

			papplet.stroke(150, 150, 150, alphaCol);
			papplet.strokeWeight(1 * parent.fontScale);
			int tweetSetColour = a.getColour();
			papplet.fill(papplet.red(tweetSetColour), papplet.green(tweetSetColour),
					papplet.blue(tweetSetColour), alphaCol);
			papplet.rect(buttonPos.x + 8 * parent.scaleFactorX, buttonPos.y + 8
					* parent.scaleFactorY, 11 * parent.scaleFactorX,
					11 * parent.scaleFactorY);

			// -------- Draw the button text --------
			papplet.textAlign(PConstants.LEFT, PConstants.CENTER);
			papplet.fill(40, 40, 40, (int) alphaCol);
			papplet.text(a.getSearchTerms(), buttonPos.x + 30 * parent.scaleFactorX,
					buttonPos.y + (buttonDim.y / 2.0f));

			// ------- Draw the crossover percentage ----------

			if (a.getNumberOfCrossoverMatches() > 0) {
				float percentageMatch = (a.getNumberOfCrossoverMatches() / (float) (parent.numberSelected)) * 100.0f;

				papplet.fill(100, 100, 100, (int) alphaCol);
				papplet.text(PApplet.nf(percentageMatch, 1, 1) + "%", buttonPos.x
						+ buttonDim.x + 5 * parent.scaleFactorX, buttonPos.y
						+ (buttonDim.y / 2.0f));
			}

			// -------- Draw remove box --------

			papplet.stroke(220, 220, 200, alphaCol);

			papplet.strokeWeight(0);
			if (mouseOverRemoveBox == a.getId()) // if mouse over, add outline
				papplet.strokeWeight(1 * parent.fontScale);

			papplet.fill(removeCircleColour);
			// rect(removeBoxPos.x, removeBoxPos.y, removeBoxDim.x,
			// removeBoxDim.y);
			papplet.ellipse(removeCirclePos.x, removeCirclePos.y, removeCircleDim.x,
					removeCircleDim.y);

			papplet.fill(0, 0, 0, alphaCol);
			papplet.text("x", removeCirclePos.x - 4.0f * parent.scaleFactorX,
					removeCirclePos.y - 1.0f * parent.scaleFactorY);

			papplet.textAlign(PConstants.LEFT, PConstants.LEFT);
		}

		// reset for other draw functions
		papplet.strokeWeight(1 * parent.fontScale);
		papplet.stroke(181, 184, 188);
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
					papplet.colours.add(a.getColour());
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
