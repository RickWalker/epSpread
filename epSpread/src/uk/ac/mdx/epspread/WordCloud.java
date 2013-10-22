package uk.ac.mdx.epspread;

import wordcram.*;
import org.gicentre.utils.colour.*;
//import wordcram.text.*;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.core.PImage;

class WordCount implements Comparable<WordCount> {

	String name;
	int freq;
	float codeLength;
	float newnum; // final HDiff for this word on this day
	float cdash; // raw HMicro for this word

	WordCount() {
		name = "empty";
		freq = 0;
		codeLength = 0;
	}

	WordCount(String _name, int _freq, float _codeLength) {
		name = _name;
		freq = _freq;
		codeLength = _codeLength;
	}

	public String toString() {
		return name + " " + newnum;
	}

	/**
	 * Compares Words based on weight only. Words with equal weight are
	 * arbitrarily sorted.
	 */
	public int compareTo(WordCount w) {
		if (w.newnum < newnum) {
			return -1;
		} else if (w.newnum > newnum) {
			return 1;
		} else
			return 0;
	}
}

public class WordCloud {
	int x, y, width, height;
	TwitterFilteringComponent parent;
	TwitterFiltering gp;
	PImage img;
	static final int WORDMINFONTSIZE = 8;
	static final int WORDMAXFONTSIZE = 36;
	static final int BUFFERSIZE = 450;
	static final int NUMBEROFWORDSINCLOUD = 45;
	static final boolean ENABLEIMAGECACHING = true;
	PGraphics buffer;
	//PGraphics variableBuffer;
	//PImage varImg;
	HashMap<Integer, PImage> imageCache = null;
	HashMap<Integer, ArrayList<WordCount>> wordCounts;
	ArrayList<WordCount> oneDayCount;
	int pStart, pStop;
	ColourTable cTable;

	Integer[] totalDayCounts;

	WordCloud(TwitterFiltering gp, TwitterFilteringComponent parent, int x,
			int y, int width, int height) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.parent = parent;
		this.gp = gp;
		
		this.wordCounts = new HashMap<Integer, ArrayList<WordCount>>();

		cTable = ColourTable.getPresetColourTable(ColourTable.YL_OR_RD);

		// load total day counts
		String[] tempC = gp.loadStrings(gp.dataPath("counts.txt"));
		PApplet.println("Days count is " + tempC.length);
		totalDayCounts = new Integer[tempC.length];
		for (int i = 0; i < tempC.length; i++) {
			totalDayCounts[i] = PApplet.parseInt(tempC[i]);
			// println("Count for "+i +" is " + totalDayCounts[i]);
		}

		buffer = gp.createGraphics(BUFFERSIZE, BUFFERSIZE, PConstants.JAVA2D);
		// buffer.background(gp.color(225, 228, 233));

		// load them all in!

		for (int k = 0; k <= tempC.length; k++) {

			int numLines = 0;
			int maxLines = 100;

			oneDayCount = new ArrayList<WordCount>();

			// String lines[] = loadStrings(k+".txt");

			String lines[];
			lines = gp
					.loadStrings(gp.dataPath("5-" + PApplet.nf(k, 2) + ".txt"));
			Set<String> wordsToIgnore = new HashSet<String>();
			wordsToIgnore.add("olymp");
			wordsToIgnore.add("2012");
			wordsToIgnore.add("london");
			wordsToIgnore.add("london2012");
			if (lines != null) {

				numLines = lines.length;
				if (numLines > maxLines)
					numLines = maxLines;

				PApplet.println("there are " + lines.length + " lines");
				for (int i = 0; i < numLines; i++) {
					String[] tokens = PApplet.split(lines[i], " ");
					String name = stripQuotes(tokens[0]);
					if (!wordsToIgnore.contains(name)) { // only add if we're
															// not ignoring this
															// word!
						int freq = PApplet.parseInt(tokens[1]);
						float codeLength = 0.0f;
						if (!tokens[2].equals("NA")) { // handle NA from R
							codeLength = PApplet.parseFloat(tokens[2]);
						}

						PApplet.println(name + ", " + freq + ", " + codeLength);

						oneDayCount.add(new WordCount(name, freq, codeLength));
					}
				}

			}
			wordCounts.put(k - 1, oneDayCount); // do this even if empty!
		}
	}

	float log2(float a) {
		return PApplet.log(a) / PApplet.log(2);
	}

	void createNewCloud(PGraphics buffer, int start, int end) {
		ArrayList<WordCount> tempList = new ArrayList<WordCount>();
		HashMap<String, Integer> keywordMap = new HashMap<String, Integer>();
		// create the cloud!
		// First pass - load all word counts in this range into tempList
		for (int i = start; i < end; i++) {
			for (WordCount wc : wordCounts.get(i - 1)) {

				// if keyword already processed
				if (keywordMap.containsKey(wc.name)) {
					// increment
					int index = keywordMap.get(wc.name);

					tempList.get(index).freq += wc.freq;

					// println("****** Found keyword on multiple days : " +
					// wc.name + " Freq : " + tempList.get(index).freq +
					// " Code Length : " + tempList.get(index).codeLength );
				} else {
					tempList.add(wc); // add to temp list
					keywordMap.put(wc.name, tempList.indexOf(wc)); // store
																	// index
																	// to
																	// this
																	// keyname
				}
			}
		}

		// now calculate denominator (n1 + n2 + n3)
		float denom = 0;
		for (int i = start; i < end; i++) {
			denom += totalDayCounts[i];
		}

		// work out new nos

		for (WordCount a : tempList) {
			// do the calculation!
			if (denom != 0) {
				a.cdash = -log2(a.freq / denom);
			} else {
				a.cdash = 0.0f;
			}
			a.newnum = PApplet.abs(a.cdash - a.codeLength);
			if (a.newnum <= 0) {
				a.newnum = 1.0f;
			}
			PApplet.println("Final weight for " + a.name + " is " + a.newnum);
		}

		Collections.sort(tempList);
		if (tempList.size() > NUMBEROFWORDSINCLOUD)
			tempList.subList(NUMBEROFWORDSINCLOUD, tempList.size()).clear();
		float minVal = Float.MAX_VALUE, maxVal = Float.MIN_VALUE;
		// we actually need yet another pass now...
		// can't use Collections.max because we want this to work on frequency!
		for (WordCount a : tempList) {
			minVal = Math.min(minVal, a.freq);
			maxVal = Math.max(maxVal, a.freq);
		}

		ArrayList<Word> forCloud = new ArrayList<Word>();
		// pass 3, to create words and colour them!
		for (WordCount a : tempList) {
			if (maxVal != minVal) {
				float magicNum = (float) Math.pow(2,
						PApplet.map(a.freq, minVal, maxVal, 0, 1.0f));
				forCloud.add(new Word(a.name, a.newnum).setColor(cTable
						.findColour(PApplet.map(magicNum, 1.0f, 2.0f, 0.0f,
								1.0f))));// (int)
											// (PApplet.pow(2,
											// a.newnum))));
			} else {// color all as max!
				forCloud.add(new Word(a.name, a.newnum).setColor(cTable
						.findColour(1.0f)));// (int)

			}
			// PApplet.println("vals are " + a.cdash + " " + minVal + " "
			// + maxVal);
		}
		// PApplet.println("Max and min are " + maxVal + "   " + minVal);

		// PApplet.println("Sorted version is " + tempList);

		buffer.background(gp.color(128));// gp.color(225, 228, 233));
		float fontScaleFactor = (float) BUFFERSIZE / (float) buffer.width;
		if (forCloud.size() > 0) {
			WordCram wordcram = new WordCram(gp)
					// mainApplet)

					// Pass in the words to draw.
					.fromWords(forCloud.toArray(new Word[forCloud.size()]))
					.withFont("Georgia")
					// set canvas
					.withCustomCanvas(buffer)
					.sizedByWeight((int) (8 * fontScaleFactor),
							(int) (36 * fontScaleFactor)).angledAt(0)
					// .withSizer(Sizers.byWeight(10, 74)).angledAt(0)
					.withWordPadding(1);// .withPlacer(Placers.horizLine());

			// Now we've created our WordCram, we can draw it to the buffer
			wordcram.drawAll();
			// draw scale for colours
			float inc = 0.001f;
			for (float i = 0; i < 1; i += inc) {
				buffer.fill(cTable.findColour(i));
				buffer.stroke(cTable.findColour(i));
				buffer.rect(buffer.width * i, buffer.height - 25, width * inc,
						50);
			}
		}
	}

	void createWordCloud(int start, int end) {

		// int daysInRange = end - start;
		// println("days in range : " + daysInRange);

		// check if we've done this before:
		File f = new File(gp.dataPath(start + "-" + end + ".png"));
		PApplet.println("looking for "
				+ gp.dataPath(start + "-" + end + ".png"));
		if (!f.exists() || !ENABLEIMAGECACHING) {
			createNewCloud(buffer, start, end);
			// take the buffer as an image
			img = buffer.get(0, 0, buffer.width, buffer.height);
			// write image to cache
			if (ENABLEIMAGECACHING)
				img.save(gp.dataPath(start + "-" + end + ".png"));

		} else {
			img = gp.loadImage(gp.dataPath(start + "-" + end + ".png"));
		}
	}

	boolean contains(ArrayList<WordCount> theArray, String _name) {

		for (WordCount wc : theArray) {
			if (wc.name.equals(_name))
				return true;
		}

		return false;
	}

	void setRange(int start, int stop) {

		start = PApplet.constrain(start, 0, TwitterFiltering.TOTALDAYS);
		stop = PApplet.constrain(stop, 1, TwitterFiltering.TOTALDAYS + 1);
		if (pStart != start || pStop != stop) {
			PApplet.println("Asking for day range" + start + ", " + stop);
			createWordCloud(start, stop);
			pStart = start;
			pStop = stop;
		}
	}

	void draw() {
		gp.imageMode(PConstants.CORNER);
		gp.pushMatrix();
		// gp.resetMatrix();
		gp.translate(parent.x + parent.width, parent.y + parent.height);
		gp.scale(parent.scaleFactorX, parent.scaleFactorY);
		gp.translate(-275, -y);
		gp.image(img, 0, 0, width, height);
		gp.popMatrix();
	}

	void draw(int x, int y, int w, int h) {
			gp.image(img, x, y,w,h);
	}

	boolean hasMouseOver() {
		float myX1 = parent.x + parent.width - 275 * parent.scaleFactorX;
		float myX2 = myX1 + width * parent.scaleFactorX;
		float myY1 = parent.y + (parent.height) - y * parent.scaleFactorY;
		float myY2 = myY1 + height * parent.scaleFactorY;

		return (gp.mouseX > myX1 && gp.mouseX < myX2 && gp.mouseY > myY1 && gp.mouseY < myY2);
	}

	String stripQuotes(String a) {
		return a.replace("\"", "");
	}
}
