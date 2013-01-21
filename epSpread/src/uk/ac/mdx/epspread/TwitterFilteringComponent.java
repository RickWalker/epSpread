package uk.ac.mdx.epspread;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.joda.time.DateTime;
import org.joda.time.Days;
import org.joda.time.Hours;
import org.joda.time.Interval;
import org.joda.time.Period;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.sqlite.SQLiteJDBCLoader;

import controlP5.ControlEvent;
import controlP5.ControlFont;
import controlP5.ListBox;
import controlP5.Range;
import controlP5.Textfield;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.core.PMatrix3D;
import processing.core.PVector;

import geomerative.*;
import org.gicentre.utils.text.*;

//import codeanticode.glgraphics.GLConstants;

import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.geo.Location;

//import de.fhpotsdam.unfolding.providers.OpenStreetMap;
//import de.fhpotsdam.unfolding.providers.StamenMapProvider;
import de.fhpotsdam.unfolding.utils.MapUtils;
import de.fhpotsdam.unfolding.utils.ScreenPosition;

//storyboard panel

class TwitterFilteringComponent {
	int x, y, width, height;
	TimeLineComponent parent;
	TwitterFiltering papplet; // PApplet class for methods! eventually just
								// PApplet
	String panelFocus = null;
	int componentID;
	boolean enableThumbnails = false;
	// SQLite db;
	PanelCaption caption;
	TweetSetManager tweetSetManager;
	WordCloud wordCloud;

	String drawLarge = null;

	Interval dateSelection;
	Interval previousDateSelection;
	String previousKeyword = "";
	// int oldWidth, oldHeight;
	MovementState currentTransitionState;
	MovementState previousTransitionState;
	PImage thumbnail;
	PGraphics thumbnailBuffer;
	// boolean doneResize = true;

	ArrayList<TweetNetwork> tweetNetworks = new ArrayList<TweetNetwork>();
	ArrayList<Integer> selectedTweetUserIds = new ArrayList<Integer>();
	ArrayList<Annotation> annotations = new ArrayList<Annotation>();

	// ---- Mouse Drag/Selection ----

	// mouse drag selection
	float mouseDragStart_x = -1;
	float mouseDragStart_y = -1;
	float mouseDragEnd_x = -1;
	float mouseDragEnd_y = -1;

	boolean b_draggingMouse = false;
	boolean b_selection = false;
	int numberSelected = 0;

	float topleft_lat = 42.3017f;
	float topleft_lon = 93.5673f;
	float bottomright_lat = 42.1609f;
	float bottomright_lon = 93.1923f;

	int filterTextField_x;
	int filterTextField_y;

	Integrator windAngle_integrator = new Integrator(-90);
	Integrator windSpeed_integrator = new Integrator(0);

	// ---- Control P5 objects ----

	Range range;
	Textfield filterTextField;
	ListBox filterShortcutList;

	StreamGraphRange streamGraphRange;

	UnfoldingMap map;

	PVector imgPos; // pos offset of image

	PImage rain;
	PImage showers;
	PImage cloudy;
	PImage clear;

	PImage imgMap;
	RShape shp = new RShape();
	// RFont rfont = new RFont("Verdana.ttf", 18);

	/*
	 * -----------------------------
	 * 
	 * Setup the component
	 * 
	 * -----------------------------
	 */
	float scaleFactorX, scaleFactorY;
	float fontScale;
	float tweetBoxSize;// = 10; //size of tweet map icon
	Integrator xIntegrator, yIntegrator, widthIntegrator, heightIntegrator;

	TwitterFilteringComponent(TwitterFiltering papplet,
			TimeLineComponent parent, int x, int y, int width, int height) {
		this.parent = parent;
		this.papplet = papplet;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		// oldWidth = width;
		// oldHeight = height;
		xIntegrator = new Integrator(x);
		yIntegrator = new Integrator(y);
		widthIntegrator = new Integrator(width);
		heightIntegrator = new Integrator(height);
		// PVector newPos = getLocalCoordinate(new PVector(x,y));
		caption = null;// new PanelCaption(papplet, this);
		// componentID = papplet.componentCount++;

		calculateScale();

		// tweetBoxSize = 10*fontScale;
		PApplet.println("Scale factors are " + scaleFactorX + " and "
				+ scaleFactorY);
		// size( imgX+310, imgY + 130, OPENGL);
		// smooth();
		// println("Scale factors are " + scaleFactorX + " and " +
		// scaleFactorY);
		// setup database
		// db = new SQLite( parent, "VAST2011_MC1.sqlite" ); // open database
		// file

		// Load the map
		imgMap = papplet.loadImage("data/Vastopolis_Map_B&W_2.png");
		imgPos = new PVector(20, 60);
		map = new UnfoldingMap(papplet, imgPos.x, imgPos.y,
				TwitterFiltering.imgX, TwitterFiltering.imgY);// , new
																// StamenMapProvider.TonerLite());
		// TwitterFiltering.imgX * scaleFactorX, TwitterFiltering.imgY
		// * scaleFactorY);
		resizeUnfoldingMap(); // set initial transform
		PApplet.println("Graphics for applet is " + papplet.g
				+ " and for map is " + map.mapDisplay.getInnerPG());
		PApplet.println("Graphics size is " + papplet.g.width + " and "
				+ papplet.g.height);
		PApplet.println("Graphics size for map is  "
				+ map.mapDisplay.getInnerPG().width + " and "
				+ map.mapDisplay.getInnerPG().height);

		map.zoomAndPanTo(new Location(51.6f, -0.6f), 10);
		MapUtils.createDefaultEventDispatcher(papplet, map);

		// Load font
		papplet.textFont(papplet.font);

		// setup tweetSetManager
		tweetSetManager = new TweetSetManager(papplet, this);
		setConstants();
		// Setup Weather frame
		// WeatherFrame weatherFrame = new WeatherFrame();

		// Setup Time Slider

		dateSelection = new Interval(TwitterFiltering.minDate,
				TwitterFiltering.minDate.plus(Period.hours(24)));

		createP5Components();
		// Add horizontal range slider

		previousDateSelection = new Interval(TwitterFiltering.minDate,
				TwitterFiltering.minDate.plus(Period.hours(24)));
		// Setup Colours
		papplet.setupColours();

		// Create Streamgraph range
		streamGraphRange = new StreamGraphRange(this, papplet);

		wordCloud = new WordCloud(papplet, this, 275, 275, 250, 250);
		wordCloud.setRange(0, 1);

		currentTransitionState = previousTransitionState = MovementState.SMALL;
		if (enableThumbnails) {
			thumbnailBuffer = papplet.createGraphics(
					(int) (parent.smallVizSize.x),
					(int) (parent.smallVizSize.y),
					// GLConstants.GLGRAPHICS);
					PConstants.JAVA2D);//
			// P2D);//screenWidth, screenHeight,
			// P2D);

			PApplet.println("Buffer size is " + thumbnailBuffer.width + " and "
					+ thumbnailBuffer.height);
			generateThumbnail();
		}

		RG.init(parent.parent);
	}

	void createP5Components() {
		PApplet.println("Creating components!");
		range = papplet.controlP5.addRange(
				"Date" + componentID,
				0,
				Hours.hoursIn(
						new Interval(TwitterFiltering.minDate,
								TwitterFiltering.maxDate)).getHours(),
				Hours.hoursIn(
						new Interval(TwitterFiltering.minDate, dateSelection
								.getStart())).getHours(),
				Hours.hoursIn(
						new Interval(TwitterFiltering.minDate, dateSelection
								.getEnd())).getHours(),
				(int) (x + (imgPos.x * scaleFactorX)),
				(int) (y + (TwitterFiltering.imgY + imgPos.y + 10)
						* scaleFactorY),
				(int) ((TwitterFiltering.imgX) * scaleFactorX),
				(int) (30 * scaleFactorY)).setBroadcast(false);
		// println("Range slider at" + int(imgY*scaleFactorY));
		range.setColorBackground(papplet.color(130, 130, 130));
		range.setLabelVisible(false);
		range.setCaptionLabel("");
		range.setBroadcast(true);
		// Setup CP5 search field
		setupSearchField();
	}

	void removeP5Components() { // /aaaargh
		papplet.controlP5.remove("Date" + componentID);
		papplet.controlP5.remove("Filters" + componentID);
	}

	boolean hasMouseOver() {
		return papplet.mouseX > x && papplet.mouseX < (x + width)
				&& papplet.mouseY > y && papplet.mouseY < (y + height);
	}

	void calculateScale() {
		scaleFactorX = (float) width / (TwitterFiltering.imgX + 310);
		scaleFactorY = (float) height / (TwitterFiltering.imgY + 230);
		fontScale = Math.min(scaleFactorX, scaleFactorY);
	}

	void updateIntegrators() {
		xIntegrator.update();
		yIntegrator.update();
		widthIntegrator.update();
		heightIntegrator.update();
	}

	void updateSizes() {
		x = (int) (xIntegrator.value);
		y = (int) (yIntegrator.value);
		width = (int) (widthIntegrator.value);
		height = (int) (heightIntegrator.value);
	}

	void setConstants() {
		tweetBoxSize = 30 * fontScale;
		filterTextField_x = (int) (x + scaleFactorX
				* (TwitterFiltering.imgX + imgPos.x + 50));
		filterTextField_y = (int) (y + 60 * scaleFactorY);
		tweetSetManager.setConstants();
	}

	void resizeP5Components() {
		range.setBroadcast(false);
		papplet.controlP5.setFont(papplet.font, (int) (18.0 * fontScale));
		// expensive - only do if not moving!
		range.setPosition((int) (x + ((imgPos.x) * scaleFactorX)),
				(int) (y + (imgPos.y + TwitterFiltering.imgY + 10)
						* scaleFactorY));
		range.setSize((int) ((TwitterFiltering.imgX) * scaleFactorX),
				(int) (30 * scaleFactorY)); // doesn't update the handles!
		range.setRangeValues(
				Hours.hoursIn(
						new Interval(TwitterFiltering.minDate, dateSelection
								.getStart())).getHours(),
				Hours.hoursIn(
						new Interval(TwitterFiltering.minDate, dateSelection
								.getEnd())).getHours());
		// range.update();
		range.setBroadcast(true);

		filterTextField.setSize((int) (180 * scaleFactorX),
				(int) (30 * scaleFactorY));
		filterTextField.setPosition(filterTextField_x, filterTextField_y);
		for (Annotation a : annotations)
			a.resize();
		resizeUnfoldingMap();

	}

	void hideP5Components() {
		filterTextField.hide();
		range.hide();
		for (Annotation a : annotations)
			a.hide();
		resizeUnfoldingMap();
	}

	void showP5Components() {
		filterTextField.show();
		range.show();
		for (Annotation a : annotations)
			a.show();
		resizeUnfoldingMap();
	}

	public void checkComponents() {
		// work out which component they double-clicked on!
		// easiest to do here because we know coords of everything
		PVector transformedMouse = map.getViewingTransform().mult(
				new PVector(papplet.mouseX, papplet.mouseY), null);
		if (map.isHit(transformedMouse.x, transformedMouse.y)) {
			PApplet.println("Map selected!");
			drawLarge = "map";
		} else if (streamGraphRange.hasMouseOver()) {
			PApplet.println("Stream graph selected!");
			drawLarge = "streamgraph";
		} else if (wordCloud.hasMouseOver()) {
			PApplet.println("Word cloud selected!");
			drawLarge = "wordcloud";
		} else {
			drawLarge = null;
		}
	}

	void resizeUnfoldingMap() {
		// just do the mouse transform!
		// screen to world space!
		PMatrix3D view = new PMatrix3D();
		view.scale(1.0f / scaleFactorX, 1.0f / scaleFactorY);
		view.translate(-x, -y);
		map.setViewingTransform(view);
	}

	boolean doneMoving() {
		return PApplet.abs(width - (int) (widthIntegrator.target)) <= 1
				&& PApplet.abs(height - (int) (heightIntegrator.target)) <= 1
				&& PApplet.abs(x - (int) (xIntegrator.target)) <= 1
				&& PApplet.abs(y - (int) (yIntegrator.target)) <= 1;
	}

	/*
	 * -----------------------------
	 * 
	 * Main draw method
	 * 
	 * -----------------------------
	 */

	void draw() {
		papplet.colorMode(PConstants.RGB, 255);
		updateIntegrators();
		// if (!doneMoving()) {
		if (doneMoving()) {
			if (currentTransitionState == MovementState.GROWING) {
				PApplet.println("Done growing!");
				currentTransitionState = MovementState.LARGE;
				showP5Components();
			} else if (currentTransitionState == MovementState.SHRINKING) {
				currentTransitionState = MovementState.SMALL;
				PApplet.println("Done shrinking!");
				generateThumbnail();
				hideP5Components();
			}
		}

		if (currentTransitionState == MovementState.SHRINKING
				&& previousTransitionState == MovementState.LARGE) {
			generateThumbnail();
		}

		/*
		 * if (currentTransitionState == MovementState.SHRINKING) {
		 * println("Moving is " + doneMoving());
		 * 
		 * System.out.printf("%d %d %d %d %d %d %d %d", width,
		 * int(widthIntegrator.target), height, int(heightIntegrator.target), x,
		 * int(xIntegrator.target), y, int(yIntegrator.target)); }
		 */
		// if we're resizing:
		if (currentTransitionState == MovementState.GROWING
				|| currentTransitionState == MovementState.SHRINKING) {
			updateSizes();
			calculateScale();
			setConstants();
			resizeP5Components();
		} else if (currentTransitionState == MovementState.MOVING) {
			// PApplet.println("Moving it via transition state!");
			updateSizes();
			calculateScale();
			setConstants();
			resizeP5Components();
			// resizeUnfoldingMap();
		} else if (previousTransitionState != currentTransitionState) {
			// check for just finished transition for controlp5
			// re-add p5 components?
			PApplet.println("New transition state!");
			removeP5Components();
			/*for (Annotation a : annotations) {
				a.removeNote();
				a.createNote();
			}*/
			createP5Components();
			if (currentTransitionState == MovementState.SMALL) {
				hideP5Components();
			} else {
				PApplet.println("Finished transition, showing again!");
				showP5Components();
			}
			previousTransitionState = currentTransitionState;
		}
		if (currentTransitionState == MovementState.SMALL && drawLarge != null) {
			drawLargeComponent(drawLarge);

		} else if (currentTransitionState != MovementState.SMALL
				|| thumbnail == null) {
			// draw live unless small!
			drawComponents();// x, y, width, height);
		} else {
			// drawThumbnail();

			papplet.image(thumbnail, x, y);// , width, height);
			// stroke(100);
			// strokeWeight(2);
			// noFill();
			// rrect(x, y, width, height, 3.0f*scaleFactorX, 2.4f*scaleFactorY,
			// "");
		}

		// draw selection shape
		papplet.fill(100, 100, 255, 100);
		papplet.strokeWeight(3);
		shp.draw();
	}

	void drawLargeComponent(String dl) {
		// PApplet.println("Drawing large " + dl);
		papplet.stroke(0);
		papplet.rect(x, y, width, height);
		if (dl.equals("map")) {
			papplet.pushMatrix();
			papplet.translate(x, y);
			papplet.scale(scaleFactorX, scaleFactorY);

			// now work out how much to scale it!
			float xScale = (float) width
					/ ((float) map.mapDisplay.getWidth() * scaleFactorX);
			float yScale = (float) height
					/ ((float) map.mapDisplay.getHeight() * scaleFactorY);
			papplet.scale(xScale, yScale);
			papplet.translate(-map.mapDisplay.offsetX, -map.mapDisplay.offsetY);
			map.draw();
			drawTweetsOnce();
			papplet.popMatrix();
		} else if (dl.equals("streamgraph")) {
			streamGraphRange.draw(x, y, width, height);
			// streamGraphRange.drawLarge();
		} else if (dl.equals("wordcloud")) {
			wordCloud.draw(x, y, width, height);
		}
		if (caption != null)
			caption.draw();
	}

	void drawDateRange() {
		papplet.textAlign(PConstants.CENTER, PConstants.TOP);
		papplet.fill(0);
		papplet.textFont(papplet.font);
		papplet.textSize(24 * fontScale);
		int yval = (int) (y + 3 * scaleFactorY);// + (imgPos.y)/15.0);
		int startX = (int) (x + imgPos.x + 0.35 * TwitterFiltering.imgX
				* scaleFactorX);
		int endX = (int) (x + imgPos.x + TwitterFiltering.imgX * scaleFactorX - 0.35
				* TwitterFiltering.imgX * scaleFactorX);
		// rfont.draw(formatDate(dateSelection.getStart()));
		papplet.text(formatDate(dateSelection.getStart()), startX, yval);
		papplet.text(formatTime(dateSelection.getStart()), startX, yval
				+ papplet.textAscent() + papplet.textDescent());
		papplet.text(
				"to",
				(int) (x + imgPos.x + (TwitterFiltering.imgX * scaleFactorX) / 2),
				yval);
		papplet.text(formatDate(dateSelection.getEnd()), endX, yval);
		papplet.text(formatTime(dateSelection.getEnd()), endX,
				yval + (papplet.textAscent() + papplet.textDescent()));
	}

	void drawComponents() {// int x, int y, int width, int height) {
		if (caption != null)
			caption.draw(); // panel caption! in world coords!
		// ---- Border + Map ----
		papplet.stroke(0);
		papplet.fill(225, 228, 233);
		papplet.rect(x, y, width, height);
		// draw date at the top!
		drawDateRange();
		// ---- Draw ControlP5 ----
		papplet.controlP5.draw();
		//
		// ----- Draw streamgraph range -------
		streamGraphRange.draw();

		papplet.strokeWeight(0);
		papplet.fill(40);

		papplet.pushMatrix();
		papplet.translate(x, y);
		papplet.scale(scaleFactorX, scaleFactorY);

		map.draw();

		/*
		 * papplet.stroke(0); grandparent.fill(0, 100);
		 * grandparent.rect(ref.offsetX, ref.offsetY, ref.getWidth(),
		 * ref.getHeight()); ref.getInnerPG().fill(255,0,0,255);
		 * ref.getInnerPG().rect(ref.offsetX, ref.offsetY, ref.getWidth(),
		 * ref.getHeight());
		 */
		papplet.popMatrix();

		// ---- Filter terms text ----
		papplet.textSize(18 * fontScale);
		papplet.textAlign(PConstants.LEFT, PConstants.BOTTOM);
		papplet.fill(76, 86, 108);
		papplet.text("Filter Terms", filterTextField_x - 2 * scaleFactorX,
				filterTextField_y - 10 * scaleFactorY);

		// ---- Draw all the TweetSet Buttons ----
		tweetSetManager.draw();

		// ---- Draw tweet network if selected / on ----
		if (b_selection)
			drawTweetNetwork();

		// --- draw semi-transparent rectangle if click-dragging ---
		/*
		 * if (b_draggingMouse) { stroke(200, 200, 255, 100);
		 * strokeWeight(2*fontScale); fill(100, 100, 255, 50);
		 * rect(mouseDragStart_x, mouseDragStart_y, constrain(mouseX, x +
		 * imgPos.x*scaleFactorX, x+(imgX + imgPos.x)*scaleFactorX) -
		 * mouseDragStart_x, constrain(mouseY, y+imgPos.y, y+(imgY +
		 * imgPos.y)*scaleFactorY) - mouseDragStart_y); //limit rectangle to
		 * image boundary }
		 */

		if (b_draggingMouse) {
			shp.addLineTo(papplet.mouseX, papplet.mouseY);
		}

		wordCloud.draw();

		// ---- Draw the tweets on the map ----
		papplet.pushMatrix();
		papplet.translate(x, y);
		papplet.scale(scaleFactorX, scaleFactorY);
		drawTweetsOnce();
		// papplet.popMatrix();

		// draw annotations!
		// papplet.pushMatrix();
		// papplet.translate(x, y);
		// papplet.scale(scaleFactorX, scaleFactorY);

		for (Annotation a : annotations) {
			a.draw();
		}

		papplet.popMatrix();

	}

	void generateThumbnail() {
		if (thumbnailBuffer != null) { // if we've disabled thumbnails, don't
										// use!
			// take buffer into image!
			PApplet.println("Start");
			PGraphics temp = papplet.g;
			// g.endDraw();
			papplet.g = thumbnailBuffer;
			papplet.g.beginDraw();
			papplet.background(225, 228, 233);
			papplet.pushMatrix();
			papplet.translate(-x, -y);
			drawComponents();// 0, 0, width,
								// height);//int(parent.smallVizSize.x),
								// int(parent.smallVizSize.y));
			papplet.popMatrix();
			papplet.g.endDraw();
			// generateThumbnail();
			papplet.g = temp;
			// g.beginDraw();
			PApplet.println("Drew to offscreen, back now!");
			thumbnail = thumbnailBuffer.get(0, 0, thumbnailBuffer.width,
					thumbnailBuffer.height);
			// thumbnail.save("temp.png");
			PApplet.println("Done generating thumbnail!");
		}
		// hide controlp5 components
	}

	// popMatrix();
	String formatDate(DateTime t) {
		StringBuilder dateString = new StringBuilder();
		dateString.append(t.dayOfWeek().getAsText());
		dateString.append(" ");
		dateString.append(t.dayOfMonth().getAsText());
		dateString.append(" ");
		dateString.append(t.monthOfYear().getAsText());
		dateString.append(" ");
		dateString.append(t.year().getAsText());
		// dateString.append("\n");
		// dateString.append(nf(t.hourOfDay().get(), 2));
		// dateString.append(":00");

		return dateString.toString();
	}

	String formatTime(DateTime t) {
		// need this for pdf output, line breaks are handled poorly
		StringBuilder dateString = new StringBuilder();
		dateString.append(PApplet.nf(t.hourOfDay().get(), 2));
		dateString.append(":00");
		return dateString.toString();
	}

	/*
	 * -----------------------------
	 * 
	 * Setup the CP5 search field
	 * 
	 * -----------------------------
	 */

	void setupSearchField() {

		int filterTextField_width = (int) (180 * scaleFactorX);
		int filterTextField_height = (int) (30 * scaleFactorY);

		filterTextField = papplet.controlP5.addTextfield("Filters"
				+ componentID, filterTextField_x, filterTextField_y,
				filterTextField_width, filterTextField_height);
		filterTextField.setColorBackground(papplet.color(250));
		filterTextField.setColorForeground(papplet.color(250));
		// filterTextField.setColorValue(50);

		// filterTextField.setColorLabel(0);
		papplet.controlP5.setFont(new ControlFont(papplet.font,
				(int) (18.0 * fontScale)));
		filterTextField.setColor(papplet.color(0));
		filterTextField.setCaptionLabel("");
		filterTextField.setFocus(true);
	}

	/*
	 * -----------------------------
	 * 
	 * Translate map lon/lat to image map
	 * 
	 * -----------------------------
	 */

	PVector mapCoordinates(PVector coords) {
		// corrects loc for scale *and* offset
		PVector result = new PVector(0.0f, 0.0f);
		result.x = PApplet.map(coords.x, topleft_lon, bottomright_lon, 0,
				TwitterFiltering.imgX);
		result.y = PApplet.map(coords.y, topleft_lat, bottomright_lat, 0,
				TwitterFiltering.imgY);

		return result;
	}

	/*
	 * -----------------------------
	 * 
	 * Draw mouse over info box
	 * 
	 * -----------------------------
	 */

	void drawMouseOver(Tweet t) {

		ScreenPosition loc = map.getScreenPosition(t.getLocation());

		String s = t.getText();
		DateTime date = t.getDate();
		String d = papplet.fmt2.print(date);
		// date.month().getText();
		int sLength = s.length();
		float gap = 20;
		float info_header_size = 30;
		papplet.textSize(18 * fontScale);
		int textBoxSize = sLength * 2;
		float headerWidth = 220;
		List<String> lines = WordWrapper.wordWrap(s,
				(int) (headerWidth - gap * 2), papplet);
		float lineHeight = papplet.textAscent() + papplet.textDescent();

		textBoxSize = (int) ((lines.size() + 1) * (lineHeight) + gap * 2);
		float shadowOffset = 4;

		// TwitterFiltering.imgX * scaleFactorX,
		// TwitterFiltering.imgY * scaleFactorY

		// if (!b_draggingMouse) {
		// make sure we stay on the map!
		if ((loc.x + shadowOffset + shadowOffset + headerWidth) > (imgPos.x + TwitterFiltering.imgX)) {
			// bump it across a bit more!
			// PApplet.println("Would overhang x - translating back by "+(shadowOffset
			// + shadowOffset+headerWidth));
			papplet.translate(-(shadowOffset + shadowOffset + headerWidth), 0);
		}
		if ((loc.y + info_header_size + textBoxSize) > (imgPos.y + TwitterFiltering.imgY)) {
			// PApplet.println("Would overhang y - translating back by "
			// + (info_header_size + textBoxSize));
			papplet.translate(0, -(info_header_size + textBoxSize));
		}

		// shadow
		papplet.strokeWeight(0);
		papplet.fill(0, 0, 0, 100);
		papplet.rect(shadowOffset + loc.x, shadowOffset + loc.y, shadowOffset
				+ headerWidth, shadowOffset + textBoxSize + info_header_size);

		papplet.stroke(0, 0, 0, 200);
		papplet.strokeWeight(4 * fontScale);

		papplet.fill(230, 230, 250, 200);
		papplet.rect(loc.x, loc.y + info_header_size, (headerWidth),
				textBoxSize);

		papplet.fill(130, 180, 130, 200);
		papplet.rect(loc.x, loc.y, headerWidth, info_header_size);

		papplet.fill(255, 255, 255, 255);
		papplet.text(d, loc.x + 10, loc.y + info_header_size - 8);

		papplet.fill(0, 50, 100);
		papplet.text(s, loc.x + gap, loc.y + gap + info_header_size,
				headerWidth - gap * 2, 300 - gap * 2);

		papplet.fill(t.getTweetSetColour());
		// }
	}

	/*
	 * -----------------------------------------------
	 * 
	 * Draws all the tweets from the tweetsets active
	 * 
	 * -----------------------------------------------
	 */

	void drawTweetsOnce()// int mini, int maxi)
	{
		// new plan - assume we're in 0,0 coordinate space here!
		papplet.textFont(papplet.font);
		papplet.strokeWeight(2 * fontScale);
		Tweet forMouseOver = null;

		// Draw all the tweets
		if (tweetSetManager.getTweetSetListSize() > 0)
			for (TweetSet b : tweetSetManager.getTweetSetList()) {
				if (b.isActive()) // if this tweetset is active
				{
					if (tweetSetManager.isHeatmapViewActive()) {
						b.heatmap.draw();
					}

					for (Tweet a : b.getTweets()) {

						if (dateSelection.contains(a.mDate)) {

							int c = b.getColour();
							a.setAlphaTarget(255);

							papplet.fill(papplet.red(c), papplet.green(c),
									papplet.blue(c), a.getAlpha());

							papplet.stroke(0, 0, 0, a.getAlpha());
							papplet.strokeWeight(2 * fontScale);
							if ((2 * fontScale) < 1.0)
								papplet.noStroke();

							ScreenPosition loc = map.getScreenPosition(a
									.getLocation());
							// offset and scale this position?

							// if there is a drag-select happening
							if (b_draggingMouse) {
								// if this tweet point is inside the selection
								// box
								if (shp.contains(x + (loc.x + imgPos.x)
										* scaleFactorX, y + (loc.y + imgPos.y)
										* scaleFactorY)) {
									papplet.fill(255);
								}
							} else { // mouseover disabled when dragging
								if (PApplet.dist(papplet.mouseX,
										papplet.mouseY, x + (loc.x)
												* scaleFactorX, y + (loc.y)
												* scaleFactorY) < tweetBoxSize) {
									// only mouseover if we're over the map!
									if (loc.x > imgPos.x
											&& loc.x < (imgPos.x + TwitterFiltering.imgX)) {
										if (loc.y > imgPos.y
												&& loc.y < (imgPos.y + TwitterFiltering.imgY)) {
											forMouseOver = a;
										}
									}
								}
							}

							if (a.isSelected()) {
								papplet.stroke(255);
							}

							if (tweetSetManager.isPointsViewActive()) {
								// PApplet.println("Drawing tweet with lat lon "
								// + a.getLocation());
								// PApplet.println("Screen position is " + loc);
								//
								/*
								 * papplet.rect(x + (imgPos.x - tweetBoxSize +
								 * loc.x) , y + (imgPos.y + loc.y -
								 * tweetBoxSize) , tweetBoxSize, tweetBoxSize);
								 */
								float scaledBoxSize = tweetBoxSize
										* Math.max(1.0f / scaleFactorX,
												1.0f / scaleFactorY);
								// only draw if we're within the map box!
								// also, tweak
								loc.x = loc.x - scaledBoxSize / 2;
								loc.y = loc.y - scaledBoxSize / 2;
								if (loc.x > imgPos.x
										&& (loc.x + scaledBoxSize) < (imgPos.x + TwitterFiltering.imgX)) {
									if (loc.y > imgPos.y
											&& (loc.y + scaledBoxSize) < (imgPos.y + TwitterFiltering.imgY)) {
										// could replace with four calls to
										// isOverMap, but seems silly to do so
										papplet.rect(loc.x, loc.y,
												scaledBoxSize, scaledBoxSize);
									}
								}
							}
						} else {
							// tweet not in date range
							a.setAlphaTarget(0);
						}
					}
				}
			}
		// Location location = map.getLocation(papplet.mouseX, papplet.mouseY);
		// papplet.text("geo:" + location.toString(), papplet.mouseX,
		// papplet.mouseY);
		if (forMouseOver != null)
			drawMouseOver(forMouseOver);
	}

	void moveTo(int mx, int my) {
		xIntegrator.target(mx);
		yIntegrator.target(my);
	}

	void moveImmediatelyTo(int mx, int my) {
		x = mx;
		y = my;
		xIntegrator = new Integrator(x);
		yIntegrator = new Integrator(y);
	}

	void setSize(int sw, int sh) {
		widthIntegrator.target(sw);
		heightIntegrator.target(sh);
	}

	/*
	 * -----------------------------------------------
	 * 
	 * Returns true if tweet is inside the drag-select box
	 * 
	 * -----------------------------------------------
	 */

	boolean isInsideSelectionBox(float x, float y) {
		if ((x > mouseDragStart_x) && (y > mouseDragStart_y)
				&& (x < papplet.mouseX) && (y < papplet.mouseY))
			return true;
		else if ((x < mouseDragStart_x) && (y > mouseDragStart_y)
				&& (x > papplet.mouseX) && (y < papplet.mouseY))
			return true;
		else if ((x < mouseDragStart_x) && (y < mouseDragStart_y)
				&& (x > papplet.mouseX) && (y > papplet.mouseY))
			return true;
		else if ((x > mouseDragStart_x) && (y < mouseDragStart_y)
				&& (x < papplet.mouseX) && (y > papplet.mouseY))
			return true;
		else
			return false;
	}

	void generateRealTweetSet(String keywords) {
		// Get a fresh and exciting colour for this set
		int setColour = papplet.colours.get(papplet.colourTracker);

		if (papplet.colourTracker < papplet.colours.size())
			papplet.colourTracker++;
		else
			papplet.colourTracker = 0;

		String RESymbol = "";

		// Find out if we are processing this tweetSet using RE's, store symbol
		// in RESymbol
		if (keywords.indexOf("*") >= 0) {
			RESymbol = "*";
			keywords = keywords.substring(1);
		}

		// Find out if we are processing this tweetSet using RE's, store symbol
		// in RESymbol
		if (keywords.indexOf("$") >= 0) {
			RESymbol = "$";
			keywords = keywords.substring(1);
		}

		// Find out if we are processing this tweetSet using RE's, store symbol
		// in RESymbol
		if (keywords.indexOf("!") >= 0) {
			RESymbol = "!";
			keywords = keywords.substring(1);
		}

		// Create new tweet set
		TweetSet newTweetSetToAdd = new TweetSet(keywords, setColour, RESymbol,
				this, papplet);

		PApplet.println("Creating new tweet set...");
		String[] filterTerms = PApplet.splitTokens(keywords, ",");

		PApplet.println("Terms are : ");

		for (int i = 0; i < filterTerms.length; i++)
			PApplet.println(filterTerms[i]);

		// Build the query
		String query_part1 = "SELECT * FROM tweets WHERE createdAt > \""
				+ papplet.fmt.print(TwitterFiltering.minDate) + "\" AND ";
		String query_part2 = "";

		// append all the keywords to search for
		for (int i = 0; i < filterTerms.length; i++) {
			if (i != 0)
				query_part2 += " OR ";
			query_part2 += "text like '%" + filterTerms[i] + "%'";
		}

		String sqlQuery = query_part1 + query_part2;

		PApplet.println("Query being performed is : " + sqlQuery);
		// boolean firstRecord = true;
		System.out.println(String.format("running in %s mode",
				SQLiteJDBCLoader.isNativeMode() ? "native" : "pure-java"));

		// use new sqlite driver for query!
		try {
			Class.forName("org.sqlite.JDBC");
		} catch (ClassNotFoundException e) {
			PApplet.println("Argh can't find db class");
		}
		Connection connection = null;
		try {
			// create a database connection
			connection = DriverManager.getConnection("jdbc:sqlite:"
					+ papplet.dataPath("tweetsdb.sqlite"));// ("tweetsdb.sqlite"));//
															// "+sketchPath("sample.db");
			Statement statement = connection.createStatement();
			ResultSet rs = statement.executeQuery(sqlQuery);
			Tweet newTweetToAdd;
			DateTime thisDate;
			while (rs.next()) {
				// read the result set
				// System.out.println("name = " + rs.getString("message"));
				boolean passesRE = true; // passes RE check?

				if (RESymbol != "") // if a symbol has been specified for this
									// tweetSet
				{
					// check if it matches a RE
					if (!matchesRegularExpression(rs.getString("text"),
							filterTerms[0], RESymbol))
						passesRE = false;
				}

				if (passesRE) {
					// we have a new record, create tweet object
					newTweetToAdd = new Tweet();

					// set the text of this tweet
					newTweetToAdd.setText(rs.getString("text"));

					// set the user id
					newTweetToAdd.setUserId(rs.getInt("ID"));

					// get and set the location of this tweet
					Location tweetLocation = null;
					String locationString = rs.getString("location");
					if (rs.getFloat("latitude") != 9999) {
						// easiest case - we have location directly
						tweetLocation = new Location(rs.getFloat("latitude"),
								rs.getFloat("longitude"));
					} else if (locationString != null) {
						if (locationString.startsWith("\u00DCT: ")) {

							// parse blackberry result!
							// System.err.println("Found umlaut!");
							// System.err.println("To tokenise" +toTokenise);
							String[] tokens = PApplet.split(
									locationString.substring(4), ",");
							if (tokens.length == 2) {
								tweetLocation = new Location(
										PApplet.parseFloat(tokens[0]),
										PApplet.parseFloat(tokens[1]));
							} else {
								System.err
										.println("Unexpected length for tokens: "
												+ tokens.length);
								System.err.println("Location was "
										+ locationString);
								tweetLocation = new Location(9999.0, 9999.0);
							}
						} else if (locationString.startsWith("iPhone:")) {
							String[] tokens = PApplet.split(
									locationString.substring(7), ",");
							if (tokens.length == 2) {
								tweetLocation = new Location(
										PApplet.parseFloat(tokens[0]),
										PApplet.parseFloat(tokens[1]));
							} else {
								System.err
										.println("Unexpected length for tokens: "
												+ tokens.length);
								System.err.println("Location was "
										+ locationString);
								tweetLocation = new Location(9999.0, 9999.0);
							}
						} else {
							// location we don't parse yet
							tweetLocation = new Location(9999.0, 9999.0);
						}
					} else {
						tweetLocation = new Location(9999.0, 9999.0);
						// System.err.println("No location!");
					}
					thisDate = papplet.fmt.parseDateTime(rs
							.getString("createdAt"));

					newTweetToAdd.setTweetSetColour(setColour);
					newTweetToAdd.setDate(thisDate);

					// convert to pixels and set
					// change from old code: we store location as lat and lon!
					newTweetToAdd.setLocation(tweetLocation);
					// newTweetToAdd.findAndSetRegion(tweetLocation); //find and
					// set region by uncorrected coords?

					// add tweet to tweet set
					newTweetSetToAdd.addTweet(newTweetToAdd);
				}
				// System.out.println("id = " + rs.getInt("id"));
			}
		} catch (SQLException e) {
			// if the error message is "out of memory",
			// it probably means no database file is found
			System.err.println(e.getMessage());
		} finally {
			try {
				if (connection != null)
					connection.close();
			} catch (SQLException e) {
				// connection close failed.
				System.err.println(e);
			}
		}

		// add this finished tweet set to the array
		tweetSetManager.addTweetSet(newTweetSetToAdd);
		PApplet.println("Added tweetset to list");

		// update heat maps for first time
		for (TweetSet a : tweetSetManager.getTweetSetList()) {
			PApplet.println("Updating heatmap!");
			a.updateHeatMap();
		}
		PApplet.println("Updated heatmaps");

		// update the streamgraph
		streamGraphRange.createStreamGraph();
		// db.close();
	}

	/*
	 * -----------------------------------------------
	 * 
	 * Generates a tweet set based on filter term (* for RE)
	 * 
	 * -----------------------------------------------
	 */
	@Deprecated
	void generateTweetSet(String keywords) {
		// Get a fresh and exciting colour for this set
		int setColour = papplet.colours.get(papplet.colourTracker);

		if (papplet.colourTracker < papplet.colours.size())
			papplet.colourTracker++;
		else
			papplet.colourTracker = 0;

		String RESymbol = "";

		// Find out if we are processing this tweetSet using RE's, store symbol
		// in RESymbol
		if (keywords.indexOf("*") >= 0) {
			RESymbol = "*";
			keywords = keywords.substring(1);
		}

		// Find out if we are processing this tweetSet using RE's, store symbol
		// in RESymbol
		if (keywords.indexOf("$") >= 0) {
			RESymbol = "$";
			keywords = keywords.substring(1);
		}

		// Find out if we are processing this tweetSet using RE's, store symbol
		// in RESymbol
		if (keywords.indexOf("!") >= 0) {
			RESymbol = "!";
			keywords = keywords.substring(1);
		}

		// Create new tweet set
		TweetSet newTweetSetToAdd = new TweetSet(keywords, setColour, RESymbol,
				this, papplet);

		PApplet.println("Creating new tweet set...");
		String[] filterTerms = PApplet.splitTokens(keywords, ",");

		PApplet.println("Terms are : ");

		for (int i = 0; i < filterTerms.length; i++)
			PApplet.println(filterTerms[i]);

		// Build the query
		String query_part1 = "SELECT * FROM micro2 WHERE ";
		String query_part2 = "";

		// append all the keywords to search for
		for (int i = 0; i < filterTerms.length; i++) {
			if (i != 0)
				query_part2 += " OR ";
			query_part2 += "message like '%" + filterTerms[i] + "%'";
		}

		String sqlQuery = query_part1 + query_part2;

		PApplet.println("Query being performed is : " + sqlQuery);
		// boolean firstRecord = true;
		System.out.println(String.format("running in %s mode",
				SQLiteJDBCLoader.isNativeMode() ? "native" : "pure-java"));

		// use new sqlite driver for query!
		try {
			Class.forName("org.sqlite.JDBC");
		} catch (ClassNotFoundException e) {
			PApplet.println("Argh can't find db class");
		}
		Connection connection = null;
		try {
			// create a database connection
			connection = DriverManager.getConnection("jdbc:sqlite:"
					+ papplet.sketchPath("VAST2011_MC1.sqlite"));// "+sketchPath("sample.db");
			Statement statement = connection.createStatement();
			ResultSet rs = statement.executeQuery(sqlQuery);
			Tweet newTweetToAdd;
			DateTime thisDate;
			while (rs.next()) {
				// read the result set
				// System.out.println("name = " + rs.getString("message"));
				boolean passesRE = true; // passes RE check?

				if (RESymbol != "") // if a symbol has been specified for this
									// tweetSet
				{
					// check if it matches a RE
					if (!matchesRegularExpression(rs.getString("message"),
							filterTerms[0], RESymbol))
						passesRE = false;
				}

				if (passesRE) {
					// we have a new record, create tweet object
					newTweetToAdd = new Tweet();

					// set the text of this tweet
					newTweetToAdd.setText(rs.getString("message"));

					// set the user id
					newTweetToAdd.setUserId(rs.getInt("ID"));

					// get and set the location of this tweet
					PVector tweetLocation = new PVector(0, 0);
					tweetLocation.x = rs.getFloat("lon");
					tweetLocation.y = rs.getFloat("lat");
					thisDate = papplet.fmt.parseDateTime(rs.getString("date"));

					newTweetToAdd.setTweetSetColour(setColour);
					newTweetToAdd.setDate(thisDate);

					// convert to pixels and set
					// newTweetToAdd.setLocation(mapCoordinates(tweetLocation));
					// newTweetToAdd.findAndSetRegion(tweetLocation); //find and
					// set region by uncorrected coords?

					// add tweet to tweet set
					newTweetSetToAdd.addTweet(newTweetToAdd);
				}
				// System.out.println("id = " + rs.getInt("id"));
			}
		} catch (SQLException e) {
			// if the error message is "out of memory",
			// it probably means no database file is found
			System.err.println(e.getMessage());
		} finally {
			try {
				if (connection != null)
					connection.close();
			} catch (SQLException e) {
				// connection close failed.
				System.err.println(e);
			}
		}

		// add this finished tweet set to the array
		tweetSetManager.addTweetSet(newTweetSetToAdd);
		PApplet.println("Added tweetset to list");

		// update heat maps for first time
		for (TweetSet a : tweetSetManager.getTweetSetList()) {
			PApplet.println("Updating heatmap!");
			a.updateHeatMap();
		}
		PApplet.println("Updated heatmaps");

		// update the streamgraph
		streamGraphRange.createStreamGraph();
		// db.close();
	}

	/*
	 * -----------------------------------------------
	 * 
	 * Process ControlP5 events
	 * 
	 * -----------------------------------------------
	 */

	public void controlEvent(ControlEvent theControlEvent) {

		/*
		 * if (theControlEvent.isGroup()) {
		 * 
		 * if (theControlEvent.group().id() == 1) // id #1 is for the
		 * tweetSetListBox { int index = int(theControlEvent.group().value());
		 * println("Removing : " + theControlEvent.group().name()); } } else {
		 */
		if (theControlEvent.getController().getName()
				.equals("Date" + componentID)) {
			// min and max values are stored in an array.
			// access this array with controller().arrayValue().
			// min is at index 0, max is at index 1.
			PApplet.println("Range event!");
			dateSelection = new Interval(TwitterFiltering.minDate.plus(Period
					.hours((int) (theControlEvent.getController()
							.getArrayValue(0)))),
					TwitterFiltering.minDate.plus(Period
							.hours((int) (theControlEvent.getController()
									.getArrayValue(1)))));
			if (!dateSelection.equals(previousDateSelection)) {
				// println("Selection is " + dateSelection);
				for (TweetSet a : tweetSetManager.getTweetSetList())
					a.updateHeatMap();
				previousDateSelection = new Interval(dateSelection);
				// update wordcloud
				wordCloud.setRange(
						Days.daysBetween(TwitterFiltering.minDate,
								dateSelection.getStart()).getDays(),
						Days.daysBetween(TwitterFiltering.minDate,
								dateSelection.getEnd()).getDays());
				// parent.moveToPosition(this);
			}

			// weatherApplet.setDate(minDate,
			// int(theControlEvent.controller().arrayValue()[1]));
		} else

		// -------- Typing something in and hitting return will trigger this
		// code, creating a new tweet set --------
		if (theControlEvent.getController().getName()
				.equals("Filters" + componentID)) {
			PApplet.println("Typing in textfield!");
			String keywords = theControlEvent.getController().getStringValue();
			if (!keywords.equals(previousKeyword)) {
				if (tweetSetManager.getTweetSetListSize() < tweetSetManager
						.getMaxTweetSets())
					generateRealTweetSet(keywords);
				else
					PApplet.println("**** Too many tweetSets! Please remove before requesting another ***");
			}
			previousKeyword = new String(keywords);
		}/*
		 * else { // must be an event from an annotation:
		 * PApplet.println("Annotation event!"); // based on the name, work out
		 * which annotation it is! String n =
		 * theControlEvent.controller().name(); PApplet.println(n); int
		 * controllerIndex = PApplet.parseInt(n.substring(4, n.length())); //
		 * now look up the right annotation and update the note!
		 * annotations.get(controllerIndex).updateNote(); }
		 */
		// }
	}

	/*
	 * -----------------------------------------------
	 * 
	 * For each uniquely selected user, create a tweet history that stores all
	 * of their tweets
	 * 
	 * Note : Nothing in the data by the look of things
	 * 
	 * -----------------------------------------------
	 */

	void generateTweetNetwork() {

		PApplet.println("Generating tweet network");
		DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");
		String ids = "";
		int counter = 0;
		// loop through the users selected
		for (Integer id : selectedTweetUserIds) {

			PApplet.println(counter);
			if (counter < selectedTweetUserIds.size() - 1)
				ids += "ID= " + id + " OR ";
			else
				ids += "ID = " + id;

			counter++;
		}

		// this way of querying (all in one go) is significantly faster than
		// doing the queries userId by userId
		// requires more work later though, as the tweets aren't organised by
		// id!

		String sqlQuery = "SELECT * FROM micro2 WHERE " + ids
				+ " ORDER BY date";
		PApplet.println("sqlQuery : " + sqlQuery);
		// build the query
		try {
			Class.forName("org.sqlite.JDBC");
		} catch (ClassNotFoundException e) {
			PApplet.println("Argh can't find db class");
		}
		Connection connection = null;
		try {
			// create a database connection
			connection = DriverManager.getConnection("jdbc:sqlite:"
					+ papplet.sketchPath("VAST2011_MC1.sqlite"));// "+sketchPath("sample.db");
			Statement statement = connection.createStatement();
			ResultSet rs = statement.executeQuery(sqlQuery);
			// Tweet newTweetToAdd;
			DateTime thisDate;
			while (rs.next()) {
				Integer userId = rs.getInt("ID");
				String message = rs.getString("message");
				// Integer lat = rs.getInt("lat");
				// Integer lon = rs.getInt("lon");

				boolean found = false;
				TweetNetwork thisNetwork = new TweetNetwork(0, this, papplet); // blank

				// look to see if we have a tweetNetwork for this user
				for (TweetNetwork n : tweetNetworks) {
					if (n.getUserId().equals(userId))
						found = true;
					thisNetwork = n;
				}

				if (found == false) {
					thisNetwork = new TweetNetwork(userId, this, papplet);
					tweetNetworks.add(thisNetwork);
				}

				for (TweetNetwork n : tweetNetworks) {
					if (n.getUserId().equals(userId)) {

						// by this point we have the correct tweetNetwork
						// (either newly created or grabbed)

						Tweet newTweet = new Tweet();

						// set userid and message
						newTweet.setUserId(userId);
						newTweet.setText(message);

						// set location
						PVector tweetLocation = new PVector(0, 0);
						tweetLocation.x = rs.getFloat("lon");
						tweetLocation.y = rs.getFloat("lat");
						// newTweet.setLocation(mapCoordinates(tweetLocation));

						// set date
						thisDate = fmt.parseDateTime(rs.getString("date"));
						newTweet.setDate(thisDate);

						// add to tweet network
						n.getTweetSet().addTweet(newTweet);
					}
				}
			}
			for (TweetNetwork v : tweetNetworks) {
				PApplet.println();
				PApplet.println();

				ArrayList<Tweet> tweeties = v.getTweetSet().getTweets();

				for (Tweet t : tweeties)
					// println(t.getText());
					PApplet.println(t.getDate());
			}
		} catch (SQLException e) {
			// if the error message is "out of memory",
			// it probably means no database file is found
			System.err.println(e.getMessage());
		} finally {
			try {
				if (connection != null)
					connection.close();
			} catch (SQLException e) {
				// connection close failed.
				System.err.println(e);
			}
		}

		PApplet.println("Tweet Networks size : " + tweetNetworks.size());
	}

	/*
	 * -----------------------
	 * 
	 * Draw tweet network
	 * 
	 * -----------------------
	 */

	void drawTweetNetwork() {

		float nodeSize = 10;

		for (TweetNetwork v : tweetNetworks) {

			ArrayList<Tweet> tweets = v.getTweetSet().getTweets();

			int counter = 0;
			// PVector lastLocation = new PVector(0, 0);
			for (Tweet t : tweets) {

				PVector loc = t.getLocation();

				// if tweet is in past
				if (t.getDate().isBefore(dateSelection.getStart())) {
					papplet.fill(100, 100, 200);
					papplet.stroke(100, 100, 200, 200);
					papplet.strokeWeight(4 * fontScale);
				}
				// if tweet is in future
				else if (t.getDate().isAfter(dateSelection.getEnd())) {
					papplet.fill(100, 200, 100);
					papplet.stroke(100, 200, 100, 200);
					papplet.strokeWeight(4 * fontScale);
				}
				// tweet is inside range
				else {
					papplet.fill(200, 100, 100);
					papplet.stroke(200, 100, 100, 200);
					papplet.strokeWeight(4 * fontScale);
				}

				// if we are at the second point+, draw line
				if (counter > 0) {
					// line(lastLocation.x + imgPos.x, lastLocation.y +
					// imgPos.y, loc.x+ imgPos.x, loc.y + imgPos.y);
				}

				// lastLocation = loc;

				// draw ellipse at this tweet position
				papplet.stroke(0);
				papplet.strokeWeight(0);

				papplet.ellipse(x + (loc.x + imgPos.x) * scaleFactorX, y
						+ (loc.y + imgPos.y) * scaleFactorY, nodeSize, nodeSize);

				counter++;
			}
		}
	}

	/*
	 * -----------------------------------------------
	 * 
	 * Calculates based on selection if the users talk about other filter terms
	 * at some point
	 * 
	 * -----------------------------------------------
	 */

	void calculateTweetSetCrossover() {
		PApplet.println("calculating tweet set crossover");

		// reset crossover matches at the start
		for (TweetSet o : tweetSetManager.getTweetSetList()) {
			o.resetCrossoverMatches();
		}

		// loop through tweetsets
		if (tweetSetManager.getTweetSetListSize() > 0)
			for (TweetSet b : tweetSetManager.getTweetSetList()) {
				for (Tweet a : b.getTweets()) {

					if (a.isSelected()) // if this tweet is selected, find out
										// if the user id exists in other
										// tweetSets
					{
						int userId = a.getUserId();

						// now loop through the tweetSets and see if there are
						// matches to this id
						for (TweetSet d : tweetSetManager.getTweetSetList()) {
							boolean b_found = false;

							for (Tweet c : d.getTweets()) {
								if (c.getUserId() == userId) {
									b_found = true; // found an id match in this
													// tweetSet
									break; // stop looking!
								}
							}

							if (b_found)
								d.incrementCrossoverMatches();
						}
					}
				}
			}

		for (TweetSet b : tweetSetManager.getTweetSetList()) {
			PApplet.println("For tweetSet " + b.getSearchTerms() + " : "
					+ b.getNumberOfCrossoverMatches());
		}
	}

	/*
	 * -----------------------
	 * 
	 * Mouse code!
	 * 
	 * -----------------------
	 */

	void mousePressed() {
		// first check if we're over an annotation!
		/*
		 * for (Annotation a : annotations) { if (a.mouseOver()) {
		 * PApplet.println("Annotation has mouseover!"); return; } }
		 */
		// if we're over the map...
		if ((papplet.mouseX > x + (imgPos.x * scaleFactorX))
				&& (papplet.mouseY > y + (imgPos.y * scaleFactorY))
				&& (papplet.mouseX < x + (TwitterFiltering.imgX + imgPos.x)
						* scaleFactorX)
				&& (papplet.mouseY < y + (TwitterFiltering.imgY + imgPos.y)
						* scaleFactorY)) {
			// if we're shift-dragging, start selecting stuff
			if (papplet.mouseButton == PConstants.LEFT && papplet.keyPressed
					&& papplet.keyCode == PConstants.SHIFT) {
				b_draggingMouse = true;
				shp = new RShape();
				shp.addMoveTo(papplet.mouseX, papplet.mouseY);
			}
		}
		// if we're right-clicking, that's annotation
		if (papplet.mouseButton == PConstants.RIGHT) {
			PApplet.println("RIGHT BUTTON!");
			// three cases: over an existing annotation, and over nothing!
			boolean editing = false;
			for (Annotation a : annotations) {
				if (a.mouseOver()) {
					editing = true;
					PApplet.println("Editing note!");
					a.createNote();
				}
			}
			if (!editing) {
				PApplet.println("Added annotation!");
				PVector newPos = getLocalCoordinate(new PVector(papplet.mouseX,
						papplet.mouseY));
				Annotation a;//
				if (isOverMap(newPos)) {
					// it's a map annotation!
					a = new MapAnnotation(papplet, this, map.getLocation(
							newPos.x, newPos.y), Annotation.DEFAULT_WIDTH, 100,
							map);
					PApplet.println("Added map annotation at " + a);
				} else {
					a = new Annotation(papplet, this, (int) newPos.x,
							(int) newPos.y, Annotation.DEFAULT_WIDTH, 100);
				}
				a.createNote();
				// grandparent.registerKeyEvent(a); //so that we can listen for
				// Enter
				annotations.add(a);
			}
		}

	}

	boolean isOverMap(PVector tx) {
		return isOverMap(tx.x, tx.y);
	}

	boolean isOverMap(float tx, float ty) {
		// in local coords, is this coordinate over the map?
		return (tx > imgPos.x && tx < imgPos.x + TwitterFiltering.imgX
				&& ty > imgPos.y && ty < imgPos.y + TwitterFiltering.imgY);
	}

	public boolean hasCaption() {
		return (caption != null);
	}

	public void addCaption() {
		caption = new PanelCaption(papplet, this);
	}

	boolean contains(int tx, int ty) {
		return (tx >= x && tx <= x + width) && (ty >= y && ty <= y + height);
	}

	void mouseReleased() {
		shp.addClose();

		// mouse has clicked and released, let tweet set manager know!
		tweetSetManager.processMouse();

		// click dragging
		if (b_draggingMouse == true)
			if (papplet.mouseButton == PConstants.LEFT) {
				numberSelected = 0;
				selectedTweetUserIds.clear();
				tweetNetworks.clear();

				PApplet.println("calculating new crossover matches");
				// clear all selections!
				for (TweetSet b : tweetSetManager.getTweetSetList()) {

					b.resetCrossoverMatches();

					for (Tweet a : b.getTweets()) {
						a.setSelected(false);
					}
				}

				b_draggingMouse = false;

				mouseDragEnd_x = PApplet.max(papplet.mouseX, x
						+ TwitterFiltering.imgX * scaleFactorX);
				mouseDragEnd_y = PApplet.min(papplet.mouseY, y
						+ TwitterFiltering.imgY * scaleFactorY);

				// finished dragging, so set any tweets within drag box to
				// 'selected'
				if (tweetSetManager.getTweetSetListSize() > 0)
					for (TweetSet b : tweetSetManager.getTweetSetList()) {
						if (b.isActive()) {
							for (Tweet a : b.getTweets()) {
								if (dateSelection.contains(a.mDate)) {
									if (shp.contains(x
											+ (a.getLocation().x + imgPos.x)
											* scaleFactorX,
											y + (a.getLocation().y + imgPos.y)
													* scaleFactorY)) {
										PApplet.println("mouse");
										a.setSelected(true);

										// If user id doesn't exist in selected
										// tweet username list
										if (!selectedTweetUserIds.contains(a
												.getUserId()))
											selectedTweetUserIds.add(a
													.getUserId());

										numberSelected++;
									}
								}
							}
						}
					}

				if (numberSelected > 0) {
					b_selection = true;
					if (papplet.b_generateNetwork)
						generateTweetNetwork();
				}

				// now that we have a selection, calculate the crossover
				// percentage between tweetSets (i.e. how many of these people
				// also mention the other keywords)
				calculateTweetSetCrossover();
			} else
				b_draggingMouse = false;

		if (papplet.mouseButton == PConstants.RIGHT) {
			numberSelected = 0;
			selectedTweetUserIds.clear();
			tweetNetworks.clear();
			// right click means we clear all selections!
			if (tweetSetManager.getTweetSetListSize() > 0)
				for (TweetSet b : tweetSetManager.getTweetSetList()) {
					b.resetCrossoverMatches();

					for (Tweet a : b.getTweets()) {
						a.setSelected(false);
					}
				}
		}
		shp = new RShape();
	}

	boolean matchesRegularExpression(String _theText, String keyword,
			String _RESymbol) {
		String[] symptomsDict = { "fatigue", "vomit", "vomitting", "flu",
				"the flu", "cold", "headache", "a headache", "fever", "chills",
				"breathing", "cough", "coughing", "a dry cough", "nausea",
				"diarrhea", "sweats", "the sweats", "ache", "stomach ache",
				"throwing up", "coughing up", "bleeding", "back pain",
				"abdomen pain", "ab pain", "chest pain", keyword };
		String[] adjectivesDict = { "bad", "horrible", "nasty", "terrible",
				"terible", "annoying", "attrocious", "painful", "severe",
				"extremely painful" }; // how would I get this to be an optional
										// extra?

		// Build regular expressions
		String symptomString = createREMatchString(symptomsDict);
		String adjectiveString = createREMatchString(adjectivesDict); // not
																		// used
		String optionalAdjectives = "(" + adjectiveString + "\\s)?";

		String regularExpression = "(that|just got|trouble|have been|these|case of the|caught|caught a|with the a|getting a|has a|has|have|caught a|I have a|I have|I cought a|I got a|I am|this|come down with a|come down with|come down with a|difficulty|difficult to)\\s"
				+ optionalAdjectives + symptomString + "\\s*";

		if (_RESymbol.equals("$"))
			regularExpression = "(that|just got|trouble|these|with the a|getting a|have|I have a|I have|I cought a|I got a|I am|this|difficulty|difficult to|I have come down with|I have come down with a|I have come down with a case of the|I cought a|I cought|I caught a|I caught|this case of the)\\s"
					+ optionalAdjectives + symptomString + "\\s*";

		if (_RESymbol.equals("!"))
			regularExpression = "(have been|has a case of the|has caught|has cought a|with the a|has a|has|has come down with a|has come down with|has come down with a case of the|has caught a case of the)\\s"
					+ optionalAdjectives + symptomString + "\\s*";

		boolean found = PerformPatternMatch(_theText, regularExpression);

		if (found)
			return true;
		else
			return false;

	}

	// --------- Takes a list of words and returns a string of them seperated by
	// '|' -------------
	String createREMatchString(String[] theList) {
		String resultString = "(";

		for (int j = 0; j < theList.length; j++) {
			if (j < theList.length - 1)
				resultString += theList[j] + "|";
			else
				resultString += theList[j];
		}

		resultString += ")";

		return resultString;
	}

	boolean PerformPatternMatch(String theText, String re) {

		// Do some natural language processing!
		final int flags = Pattern.CASE_INSENSITIVE;
		Pattern pattern = Pattern.compile(re, flags);
		Matcher matcher = pattern.matcher(theText);

		while (matcher.find()) {
			return true;
		}

		return false;
	}

	PVector getLocalCoordinate(PVector screenCoord) {
		// convert a screen coord into the local coordinate space of this panel
		PVector toReturn = new PVector(screenCoord.x, screenCoord.y);
		toReturn.mult(new PVector(1 / scaleFactorX, 1 / scaleFactorY));
		toReturn.add(new PVector(-x, -y));

		return toReturn;
	}

	PVector getScreenCoordinate(PVector localCoord) {
		// convert a local coordinate into the screen space
		PVector toReturn = new PVector(localCoord.x, localCoord.y);
		toReturn.add(new PVector(x, y));
		toReturn.mult(new PVector(scaleFactorX, scaleFactorY));
		return toReturn;
	}

}
