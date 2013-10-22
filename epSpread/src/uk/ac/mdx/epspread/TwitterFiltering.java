package uk.ac.mdx.epspread;

//import processing.pdf.*;
import processing.core.PApplet;
//import processing.core.PConstants;
//import processing.core.PConstants;
//import processing.opengl.*;
import processing.core.PFont;
import processing.core.PImage;
import processing.core.PVector;

import controlP5.*;

import geomerative.RG;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
//import java.awt.event.KeyEvent;
import java.util.ArrayList;

import org.gicentre.utils.FrameTimer;
import org.joda.time.DateTime;
import org.joda.time.Days;
import org.joda.time.Interval;
//import org.joda.time.Period;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.sqlite.SQLiteJDBCLoader;

import codeanticode.glgraphics.GLConstants;

//import codeanticode.glgraphics.GLConstants;

//import codeanticode.glgraphics.GLConstants;

@SuppressWarnings("serial")
public class TwitterFiltering extends PApplet {

	float testVal = 0.028f;

	// ---- Globals ----

	// String[] keywordList;
	// /de.bezier.data.sql.SQLite db;
	PFont font = createFont("Verdana", 18, true);
	ControlFont cFont = new ControlFont(font, 18);
	PApplet mainApplet;

	enum DataSet {
		VAST2011MC1, OLYMPICTWITTER
	};

	static DataSet dataToUse;

	public static final int imgX = 1304; // original image size for scaling
	public static final int imgY = 663; // image size
	public static String databaseTableName = "tweets"; // or "micro2"
	public static String databaseMessageColumnName = "text"; // or "message"
	public static String path = "";
	public static String databaseName = "tweetsdb.sqlite";

	ArrayList<Integer> colours = new ArrayList<Integer>();
	int colourTracker = 0; // tracks number of colours
	public FrameTimer frametimer;

	boolean b_generateNetwork = false; // Generate network for selected tweets?

	// ---- Interval Range -----

	// Note : are intervals inclusive or exclusive?
	public static DateTime minDate = new DateTime(2012, 07, 16, 0, 0, 0, 0);// (new
																			// DateTime(2011,
																			// 4,
																			// 30,
																			// 0,
																			// 0,
																			// 0,
																			// 0)).minus(Period
	// .hours(1));
	public static DateTime maxDate = new DateTime(2012, 8, 18, 0, 0, 0, 0);// (new
																			// DateTime(2011,
																			// 5,
																			// 20,
																			// 23,
																			// 59,
																			// 0,
																			// 0)).plus(Period
	// .hours(1));
	public static final int TOTALDAYS = Days.daysIn(
			new Interval(minDate, maxDate)).getDays();
	static DateTimeFormatter fmt = DateTimeFormat
			.forPattern("yyyy-MM-dd HH:mm:ss");
	static DateTimeFormatter vastfmt = DateTimeFormat
			.forPattern("yyyy-MM-dd HH:mm");
	DateTimeFormatter fmt2 = DateTimeFormat
			.forPattern("MMM dd              HH:mm");
	Interval fullTimeInterval = new Interval(minDate, maxDate);

	ControlP5 controlP5;

	int componentCount = 0;// unique ID for each component!
	TimeLineComponent storyboard;

	/*
	 * -----------------------------
	 * 
	 * Setup the application
	 * 
	 * -----------------------------
	 */
	// List<TwitterFilteringComponent> timePoints;// llyrComponent;

	/**
	 * Starts epSpread as an application.
	 * 
	 * @param args
	 *            Command line arguments (ignored)
	 */
	public static void main(String[] args) {
		// Replace the contents of the string below with the fully specified
		// name of this class.

		println(args);
		if (args.length == 0 || args[0].toUpperCase().equals("OLYMPICTWITTER")) {
			dataToUse = DataSet.OLYMPICTWITTER;
			databaseTableName = "tweets";
			databaseMessageColumnName = "text";
			databaseName = "tweetsdb.sqlite";
			path = "data/";
		} else if (args[0].equals("VAST2011MC1")) {
			databaseTableName = "micro2"; // or "micro2"
			databaseMessageColumnName = "message";
			dataToUse = DataSet.VAST2011MC1;
			databaseName = "VAST2011_MC1.sqlite";
			path = "data/VAST/";
			if (args.length > 1) {
				// dataFilename = args[1];
			} else {
				// dataFilename = "vast2011mc1_29851.xml";
			}
		}
		setMinMaxDates();
		PApplet.main(new String[] { "--present",
				"uk.ac.mdx.epspread.TwitterFiltering" });
		// PApplet.main(new String[] {"uk.ac.mdx.epspread.TwitterFiltering" });
	}

	public static void setMinMaxDates() {
		// run a quick query to get min and max dates before we create the
		// timeline!
		System.out.println(String.format("running in %s mode",
				SQLiteJDBCLoader.isNativeMode() ? "native" : "pure-java"));

		String sqlQuery = "SELECT min(date), max(date) FROM "
				+ databaseTableName;

		println("Query is " + sqlQuery);

		// use new sqlite driver for query!
		try {
			Class.forName("org.sqlite.JDBC");
		} catch (ClassNotFoundException e) {
			PApplet.println("Argh can't find db class");
		}
		Connection connection = null;
		try {
			// create a database connection
			connection = DriverManager.getConnection("jdbc:sqlite:" + path
					+ databaseName);// "+sketchPath("sample.db");
			Statement statement = connection.createStatement();
			ResultSet rs = statement.executeQuery(sqlQuery);
			while (rs.next()) {
				if (dataToUse == DataSet.OLYMPICTWITTER) {
					minDate = fmt.parseDateTime(rs.getString("min(date)"));
					maxDate = fmt.parseDateTime(rs.getString("max(date)"));
				} else {
					minDate = vastfmt.parseDateTime(rs.getString("min(date)"));
					maxDate = vastfmt.parseDateTime(rs.getString("max(date)"));
				}
				println("Min date = " + rs.getString("min(date)"));
				println("Max date = " + rs.getString("max(date)"));
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

	}

	@Override
	public void setup() {
		// size(screenWidth, screenHeight);//, GLConstants.GLGRAPHICS);
		// size(screenWidth, 3*screenHeight/4, GLConstants.GLGRAPHICS);
		size(screenWidth, screenHeight - 60, GLConstants.GLGRAPHICS);
		frametimer = new FrameTimer();
		// fs = new SoftFullScreen(this); //breaks with opengl!
		// size( 1280, 720, OPENGL);
		// textMode(SHAPE);
		smooth();
		controlP5 = new ControlP5(this);
		controlP5.setAutoDraw(false);
		mainApplet = this;
		frameRate(60);
		// setup database
		// db = new de.bezier.data.sql.SQLite( this, "VAST2011_MC1.sqlite" ); //
		// open database file
		storyboard = new TimeLineComponent(this, 0, 0, width, height);
		// init Geomerative
		RG.init(this);
		// timePoints.add(new TwitterFilteringComponent(this, 0, height/2,
		// width/2, height/2));
		// timePoints.add(new TwitterFilteringComponent(this, width/2, height/2,
		// width/2, height/2));
		// timePoints.add(new TwitterFilteringComponent(this, width/2, 0,
		// width/2, height/2));
		// fs.enter();
	}

	@Override
	public void keyPressed() {

		storyboard.keyPressed();

		// if (key == 'q') {
		// exit();
		// }
	}

	/*
	 * -----------------------------
	 * 
	 * Main draw method
	 * 
	 * -----------------------------
	 */

	@Override
	public void draw() {
		background(225, 228, 233);
		/*
		 * textAlign(PConstants.LEFT, PConstants.TOP); textFont(font);
		 * textSize(18); fill(0); text(frametimer.getFrameRateAsText(),0,100);
		 */
		// System.out.println(frametimer.getFrameRateAsText());
		// frametimer.displayFrameRate();
		storyboard.draw();
	}

	public void controlEvent(ControlEvent theControlEvent) {
		System.err.println("p5 control event!");
		storyboard.controlEvent(theControlEvent);
	}

	@Override
	public void mousePressed() {
		storyboard.mousePressed();
	}

	@Override
	public void mouseReleased() {
		storyboard.mouseReleased();
	}

	@Override
	public void mouseDragged() {
		storyboard.mouseDragged();
	}

	void rrect(float x, float y, float b, float h, float r, float t, String m) {
		// from
		// http://processing.org/discourse/yabb2/YaBB.pl?action=dereferer;url=http://www.openprocessing.org/visuals/?visualID=7177

		if (m == "MITTELPUNKT") {
			x = x - b / 2;
			y = y - h / 2;
		}
		beginShape();
		vertex(x, y + r);
		bezierVertex(x, y + r / t, x + r / t, y, x + r, y);
		vertex(x + b - r, y);
		bezierVertex(x + b - r / t, y, x + b, y + r / t, x + b, y + r);
		vertex(x + b, y + h - r);
		bezierVertex(x + b, y + h - r / t, x + b - r / t, y + h, x + b - r, y
				+ h);
		vertex(x + r, y + h);
		bezierVertex(x + r / t, y + h, x, y + h - r / t, x, y + h - r);
		// vertex(x, y + r);
		endShape(CLOSE);
	}

	// Generate a vertical gradient image
	PImage generateGradient(int top, int bottom, int w, int h) {
		int tR = (top >> 16) & 0xFF;
		int tG = (top >> 8) & 0xFF;
		int tB = top & 0xFF;
		int bR = (bottom >> 16) & 0xFF;
		int bG = (bottom >> 8) & 0xFF;
		int bB = bottom & 0xFF;

		PImage bg = createImage(w, h, RGB);
		bg.loadPixels();
		for (int i = 0; i < bg.pixels.length; i++) {
			int y = i / bg.width;
			float n = y / (float) bg.height;
			// for a horizontal gradient:
			// float n = x/(float)bg.width;
			bg.pixels[i] = color(lerp(tR, bR, n), lerp(tG, bG, n),
					lerp(tB, bB, n), 255);
		}
		bg.updatePixels();
		return bg;
	}

	void setupColours() {
		colours.add(color(77, 175, 74));
		colours.add(color(55, 126, 184));
		colours.add(color(228, 26, 28));
		colours.add(color(152, 78, 163));
		colours.add(color(255, 127, 0));
		colours.add(color(255, 255, 51));
		colours.add(color(166, 86, 40));
		colours.add(color(247, 129, 191));

		// overspill
		colours.add(color(179, 222, 105));
		colours.add(color(128, 177, 211));
		colours.add(color(251, 128, 114));
		colours.add(color(141, 211, 199));
		colours.add(color(255, 255, 179));
		colours.add(color(190, 186, 218));
		colours.add(color(253, 180, 98));
		colours.add(color(252, 205, 229));
		colours.add(color(217, 217, 217));
		colours.add(color(188, 128, 189));
	}

}
