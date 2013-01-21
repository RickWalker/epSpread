package uk.ac.mdx.epspread;

import byron.streamgraph.*;

//import java.lang.Math.*;
import java.util.ArrayList;
import java.util.Arrays;

import org.joda.time.DateTime;
import org.joda.time.Days;
import org.joda.time.Interval;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.core.PImage;

//Makes use of some code from the github download of Byron and Wattenberg's Streamgraph,  
//https://github.com/leebyron/streamgraph_generator
//to produce a streamgraph.
//most of it's wrapped in a library now
class StreamGraphRange {

	int x = 0;
	int y = 0;
	int mWidth = 0;
	int mHeight = 0;
	int sliderSize = 100;
	int gapY = 50;
	// float DPI = 400;
	PGraphics smallBuffer;
	PGraphics variableBuffer;
	boolean usingVariable;
	PImage streamGraphImg;

	int numLayers = 0;
	int layerSize;
	int startDay, endDay;

	LayerLayout layout;
	LayerSort ordering;
	ColorPicker coloring;
	Layer[] layers;

	boolean isGraphCurved = true; // catmull-rom interpolation

	ArrayList<String> weatherInfo = new ArrayList<String>();
	ArrayList<String> windDirection = new ArrayList<String>();
	ArrayList<String> windSpeed = new ArrayList<String>();

	TwitterFilteringComponent parent;
	TwitterFiltering gp;

	StreamGraphRange(TwitterFilteringComponent _parent, TwitterFiltering gp) {

		this.parent = _parent;
		this.gp = gp;
		this.startDay = 0;
		this.endDay = Days
				.daysIn(new Interval(TwitterFiltering.minDate,
						TwitterFiltering.maxDate)).getDays();
		this.layerSize = endDay;

		smallBuffer = gp.createGraphics(TwitterFiltering.imgX, sliderSize,
				PConstants.JAVA2D);

		updateScaling();
		createStreamGraph(smallBuffer, startDay, endDay);
		usingVariable = false;
		// currDay = 0;
	}

	void createStreamGraph() {
		createStreamGraph(smallBuffer, startDay, endDay);
	}

	void createStreamGraph(PGraphics bufferToUse, int start, int end) {

		ArrayList<TweetSet> tweetSets = parent.tweetSetManager
				.getTweetSetList();
		numLayers = tweetSets.size();
		PApplet.println("number of streamgraph layers to generate : "
				+ numLayers);

		// create requisite number of layers
		layers = new Layer[numLayers];

		for (int l = 0; l < numLayers; l++) {
			String name = tweetSets.get(l).getSearchTerms();
			float[] size = new float[end - start];
			size = new float[end - start];

			for (int j = 0; j < (end - start); j++) {
				float normalized;
				int freqOnDay = tweetSets.get(l).getFrequencyOnDay(j + start);
				PApplet.print(freqOnDay);
				// Find max and min
				int[] frequencies = new int[21];
				frequencies = tweetSets.get(l).getTweetDayFrequencies().clone();

				Arrays.sort(frequencies);
				// int minDayFreq = frequencies[0];
				// int maxDayFreq = frequencies[frequencies.length - 1];

				// normalize and store data
				// normalized = float(freqOnDay - minDayFreq ) /
				// float(maxDayFreq - minDayFreq);
				PApplet.println(freqOnDay);
				normalized = freqOnDay + 1;

				size[j] = normalized;
				PApplet.println(" (" + normalized + ")");
			}

			// set this layer
			layers[l] = new Layer(name, size);
		}

		// ORDER DATA
		// ordering = new LateOnsetSort();
		// ordering = new VolatilitySort();
		// ordering = new InverseVolatilitySort();
		// ordering = new BasicLateOnsetSort();
		ordering = new NoLayerSort();

		// LAYOUT DATA
		layout = new StreamLayout();
		// layout = new MinimizedWiggleLayout();
		// layout = new ThemeRiverLayout();
		// layout = new StackLayout();

		// Give each layer a unique colour
		for (int i = 0; i < numLayers; i++) {
			int layerColour = tweetSets.get(i).getColour();
			layers[i].rgb = layerColour;// getRGB((int) gp.red(layerColour),
					//(int) gp.green(layerColour), (int) gp.blue(layerColour),
					//255);
		}

		// calculate time to generate graph
		long time = System.currentTimeMillis();

		// generate graphs
		if (layers.length > 0) {
			layers = ordering.sort(layers);
			layout.layout(layers);
			// fit graph to viewport

			scaleLayers(layers, 0, (int) (bufferToUse.height));

			// give report
			PApplet.println();
			long layoutTime = System.currentTimeMillis() - time;
			int numLayers = layers.length;
			int layerSize = layers[0].size.length;
			PApplet.println("Data has " + numLayers + " layers, each with "
					+ (layerSize) + " datapoints.");
			PApplet.println("Layout Method: " + layout.getName());
			PApplet.println("Ordering Method: " + ordering.getName());
			PApplet.println("Coloring Method: " + layout.getName());
			PApplet.println("Elapsed Time: " + layoutTime + "ms");
		}

		drawGraphToBuffer(bufferToUse, start, end);
	}

	void scaleLayers(Layer[] layers, int screenTop, int screenBottom) {

		screenTop += 10 * parent.scaleFactorY;
		screenBottom -= 10 * parent.scaleFactorY;

		// Figure out max and min values of layers.
		float min = Float.MAX_VALUE;
		float max = Float.MIN_VALUE;
		for (int i = 0; i < layers[0].size.length; i++) {
			for (int j = 0; j < layers.length; j++) {
				min = PApplet.min(min, layers[j].yTop[i]);
				max = PApplet.max(max, layers[j].yBottom[i]);
			}
		}

		float scale = (screenBottom - screenTop) / (max - min);
		for (int i = 0; i < layers[0].size.length; i++) {
			for (int j = 0; j < layers.length; j++) {
				layers[j].yTop[i] = screenTop + scale
						* (layers[j].yTop[i] - min);
				layers[j].yBottom[i] = screenTop + scale
						* (layers[j].yBottom[i] - min);
			}
		}
	}

	int getRGB(int r, int g, int b, int a) {

		int value = ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8)
				| ((b & 0xFF) << 0);

		return value;
	}

	void updateScaling() {

		int imageOffsetX = parent.x
				+ (int) (parent.imgPos.x * parent.scaleFactorX);
		int imageOffsetY = parent.y
				+ (int) ((parent.imgPos.y + TwitterFiltering.imgY + gapY) * parent.scaleFactorY);

		x = imageOffsetX;
		y = imageOffsetY;

		mWidth = (int) ((TwitterFiltering.imgX) * parent.scaleFactorX);
		mHeight = (int) ((100) * parent.scaleFactorY);

		//if (numLayers > 0)
			//scaleLayers(layers, 0, (int) (smallBuffer.height));
	}

	void graphVertex(PGraphics buffer, int days, int point, float[] source,
			boolean curve, boolean pxl) {
		float x = PApplet.map(point, 0, days - 1, 0, buffer.width);
		float y = source[point] - (pxl ? 1 : 0);

		buffer.beginDraw();
		if (curve) {
			buffer.curveVertex(x, y);
		} else {
			buffer.vertex(x, y);
		}

		buffer.endDraw();
	}

	void drawDayRects(PGraphics buffer, int s, int e) {

		DateTime tempdt = new DateTime(TwitterFiltering.minDate);
		buffer.textAlign(PConstants.CENTER, PConstants.BOTTOM);
		buffer.textSize(8);
		for (int k = 0; k < (e - s); k++) {

			buffer.stroke(0, 0, 0, 20);
			float rectSize = (float) (buffer.width) / (float) (e - s);

			if (k % 2 == 0)
				buffer.fill(0, 0, 0, 10); // even
			else
				buffer.fill(0, 0, 0, 5); // even

			buffer.rect((rectSize * k), 0, rectSize, buffer.height);
			//put a day number in here!
			buffer.fill(0);
			//PApplet.println("Adding day " + tempdt.plusDays(k+s).dayOfMonth().getAsString());
			buffer.text(tempdt.plusDays(k+s).dayOfMonth().getAsString(), k*rectSize +rectSize/2, buffer.height);
		}
	}

	void draw() {
		updateScaling();

		// check if a tweet set has recently been removed
		if (layers.length > parent.tweetSetManager.getTweetSetListSize() || usingVariable) {
			createStreamGraph(smallBuffer, startDay, endDay);
		}
		if (usingVariable) {
			//createStreamGraph(buffer, startDay, endDay);
			drawGraphToBuffer(smallBuffer, startDay, endDay);
			usingVariable = false;
		}
		gp.image(streamGraphImg, x, y, mWidth, mHeight);
	}

	void draw(int tx, int ty, int w, int h) {
		// aspect ratio change! redraw the buffer
		if (!usingVariable) {
			variableBuffer = gp.createGraphics(w, h, PConstants.JAVA2D);
			int s = Days.daysIn(
					new Interval(TwitterFiltering.minDate, parent.dateSelection
							.getStart())).getDays();
			int e = Days.daysIn(
					new Interval(TwitterFiltering.minDate, parent.dateSelection
							.getEnd())).getDays();
			PApplet.println("Date range is " + s + " to " + e);
			createStreamGraph(variableBuffer, s, e);
			//
			drawGraphToBuffer(variableBuffer, s, e);
			PApplet.println("Using buffer!");
			usingVariable = true;
		}
		// draw the image wherever we want!
		gp.image(streamGraphImg, tx, ty, w, h);
	}

	boolean hasMouseOver() {
		return (x < gp.mouseX && (x + mWidth) > gp.mouseX && y < gp.mouseY && (y + mHeight) > gp.mouseY);
	}

	void drawGraphToBuffer(PGraphics buffer, int s, int e) {

		updateScaling();
		int n = layers.length;

		buffer.beginDraw();
		buffer.background(235, 238, 243);
		buffer.noStroke();
		buffer.smooth();

		if (n > 0) {
			int m = layers[0].size.length;
			int start;
			int end;
			// int lastIndex = m - 1;
			int lastLayer = n - 1;
			// int pxl;

			// calculate time to draw graph
			// long time = System.currentTimeMillis();
			int days = e - s;
			// generate graph
			for (int i = 0; i < n; i++) {
				start = PApplet.max(0, layers[i].onset - 1);
				end = PApplet.min(m - 1, layers[i].end);
				// pxl = i == lastLayer ? 0 : 1;

				// set fill color of layer
				buffer.fill(layers[i].rgb);

				// draw shape
				buffer.beginShape();

				// draw bottom edge, right to left
				graphVertex(buffer, days, end, layers[i].yBottom,
						isGraphCurved, false);
				for (int j = end; j >= start; j--) {
					graphVertex(buffer, days, j, layers[i].yBottom,
							isGraphCurved, false);
				}
				graphVertex(buffer, days, start, layers[i].yBottom,
						isGraphCurved, false);

				// draw top edge, left to right
				graphVertex(buffer, days, start, layers[i].yTop, isGraphCurved,
						i == lastLayer);
				for (int j = start; j <= end; j++) {
					graphVertex(buffer, days, j, layers[i].yTop, isGraphCurved,
							i == lastLayer);
				}
				graphVertex(buffer, days, end, layers[i].yTop, isGraphCurved,
						i == lastLayer);

				buffer.endShape(PConstants.CLOSE);
			}
		}

		// rect(x, y, (imgX+6) * parent.scaleFactorX, (sliderSize *
		// parent.scaleFactorY));
		drawDayRects(buffer, s, e);
		buffer.endDraw();

		// println("Buffer Width : " + buffer.width);
		// println("Buffer Height : " + buffer.height);
		streamGraphImg = buffer.get(0, 0, buffer.width, buffer.height);
		// image(streamGraphImg, x, y, mWidth, mHeight);
	}
}
