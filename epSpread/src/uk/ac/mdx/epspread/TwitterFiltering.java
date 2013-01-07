package uk.ac.mdx.epspread;

//import processing.pdf.*;
import processing.core.PApplet;
//import processing.core.PConstants;
//import processing.opengl.*;
import processing.core.PFont;
import processing.core.PImage;
import geomerative.*;

import controlP5.*;

//import java.awt.event.KeyEvent;
import java.util.ArrayList;

import org.joda.time.DateTime;
import org.joda.time.Interval;
import org.joda.time.Period;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

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

	public static final int imgX = 1304; // original image size for scaling
	public static final int imgY = 663; // image size

	ArrayList<Integer> colours = new ArrayList<Integer>();
	int colourTracker = 0; // tracks number of colours

	boolean b_generateNetwork = false; // Generate network for selected tweets?

	// ---- Interval Range -----

	// Note : are intervals inclusive or exclusive?
	public static final DateTime minDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period
			.hours(1));
	public static final DateTime maxDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period
			.hours(1));
	DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");
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
		//PApplet.main(new String[] { "--present",  "uk.ac.mdx.epspread.TwitterFiltering" });
		PApplet.main(new String[] {"uk.ac.mdx.epspread.TwitterFiltering" });
	}
	
	@Override
	public void setup() {
		size(screenWidth, 3*screenHeight/4);//, GLConstants.GLGRAPHICS);
		//size(screenWidth, 3*screenHeight/4, GLConstants.GLGRAPHICS);
		// size( 1280, 720, OPENGL);
		// textMode(SHAPE);
		smooth();
		createRegions();
		controlP5 = new ControlP5(this);
		controlP5.setAutoDraw(false);
		mainApplet = this;
		// setup database
		// db = new de.bezier.data.sql.SQLite( this, "VAST2011_MC1.sqlite" ); //
		// open database file
		storyboard = new TimeLineComponent(this, 0, 0, width, height);
		// timePoints.add(new TwitterFilteringComponent(this, 0, height/2,
		// width/2, height/2));
		// timePoints.add(new TwitterFilteringComponent(this, width/2, height/2,
		// width/2, height/2));
		// timePoints.add(new TwitterFilteringComponent(this, width/2, 0,
		// width/2, height/2));
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

	ArrayList<Region> regions = new ArrayList<Region>();

	void createRegions() {

		RG.init(this);
		RShape villa, suburbia, eastside, lakeside, southville, plainville, smogtown, westside, cornertown, northville, riverside, uptown, downtown, river;
		villa = new RShape();
		suburbia = new RShape();
		eastside = new RShape();
		lakeside = new RShape();
		southville = new RShape();
		plainville = new RShape();
		smogtown = new RShape();
		westside = new RShape();
		cornertown = new RShape();
		northville = new RShape();
		riverside = new RShape();
		uptown = new RShape();
		downtown = new RShape();
		river = new RShape();

		// VILLA
		villa.addMoveTo(1, 106);
		villa.addLineTo(131, 106);
		villa.addLineTo(170, 133);
		villa.addLineTo(195, 241);
		villa.addLineTo(183, 333);
		villa.addLineTo(164, 382);
		villa.addLineTo(171, 428);
		villa.addLineTo(165, 447);
		villa.addLineTo(164, 472);
		villa.addLineTo(149, 553);
		villa.addLineTo(154, 587);
		villa.addLineTo(152, 608);
		villa.addLineTo(144, 650);
		villa.addLineTo(150, 702);
		villa.addLineTo(72, 739);
		villa.addLineTo(1, 768);
		villa.addClose();

		// SUBURBIA
		suburbia.addMoveTo(1121, 1);
		suburbia.addLineTo(1113, 62);
		suburbia.addLineTo(1122, 150);
		suburbia.addLineTo(1127, 281);
		suburbia.addLineTo(1146, 324);
		suburbia.addLineTo(1170, 338);
		suburbia.addLineTo(1179, 360);
		suburbia.addLineTo(1193, 369);
		suburbia.addLineTo(1187, 419);
		suburbia.addLineTo(1352, 412);
		suburbia.addLineTo(1520, 413);
		suburbia.addLineTo(1543, 421);
		suburbia.addLineTo(1799, 414);
		suburbia.addLineTo(1799, 1);
		suburbia.addClose();

		// EASTSIDE
		eastside.addMoveTo(1186, 419);
		eastside.addLineTo(1177, 450);
		eastside.addLineTo(1174, 487);
		eastside.addLineTo(1176, 528);
		eastside.addLineTo(1257, 547);
		eastside.addLineTo(1286, 572);
		eastside.addLineTo(1369, 597);
		eastside.addLineTo(1460, 587);
		eastside.addLineTo(1555, 586);
		eastside.addLineTo(1662, 587);
		eastside.addLineTo(1799, 575);
		eastside.addLineTo(1799, 417);
		eastside.addLineTo(1541, 420);
		eastside.addLineTo(1487, 412);
		eastside.addLineTo(1353, 415);
		eastside.addClose();

		// LAKESIDE
		lakeside.addMoveTo(1214, 533);
		lakeside.addLineTo(1180, 567);
		lakeside.addLineTo(1186, 610);
		lakeside.addLineTo(1209, 655);
		lakeside.addLineTo(1149, 659);
		lakeside.addLineTo(1079, 637);
		lakeside.addLineTo(1021, 632);
		lakeside.addLineTo(964, 639);
		lakeside.addLineTo(964, 741);
		lakeside.addLineTo(986, 789);
		lakeside.addLineTo(1021, 822);
		lakeside.addLineTo(1029, 849);
		lakeside.addLineTo(1020, 915);
		lakeside.addLineTo(1799, 915);
		lakeside.addLineTo(1799, 589);
		lakeside.addLineTo(1456, 589);
		lakeside.addLineTo(1371, 596);
		lakeside.addLineTo(1292, 571);
		lakeside.addLineTo(1257, 547);
		lakeside.addClose();

		// SOUTHVILLE
		southville.addMoveTo(753, 635);
		southville.addLineTo(668, 733);
		southville.addLineTo(606, 820);
		southville.addLineTo(550, 915);
		southville.addLineTo(1021, 915);
		southville.addLineTo(1031, 852);
		southville.addLineTo(1017, 813);
		southville.addLineTo(961, 737);
		southville.addLineTo(959, 640);
		southville.addLineTo(870, 643);
		southville.addClose();

		// PLAINVILLE
		plainville.addMoveTo(775, 488);
		plainville.addLineTo(671, 496);
		plainville.addLineTo(633, 504);
		plainville.addLineTo(613, 525);
		plainville.addLineTo(614, 546);
		plainville.addLineTo(599, 588);
		plainville.addLineTo(567, 606);
		plainville.addLineTo(463, 635);
		plainville.addLineTo(378, 703);
		plainville.addLineTo(294, 762);
		plainville.addLineTo(247, 796);
		plainville.addLineTo(190, 827);
		plainville.addLineTo(151, 895);
		plainville.addLineTo(152, 915);
		plainville.addLineTo(548, 915);
		plainville.addLineTo(773, 612);
		plainville.addLineTo(756, 582);
		plainville.addLineTo(801, 518);
		plainville.addClose();

		// SMOGTOWN
		smogtown.addMoveTo(1, 769);
		smogtown.addLineTo(71, 740);
		smogtown.addLineTo(136, 704);
		smogtown.addLineTo(180, 710);
		smogtown.addLineTo(232, 707);
		smogtown.addLineTo(289, 672);
		smogtown.addLineTo(366, 627);
		smogtown.addLineTo(424, 632);
		smogtown.addLineTo(381, 668);
		smogtown.addLineTo(363, 687);
		smogtown.addLineTo(335, 709);
		smogtown.addLineTo(293, 732);
		smogtown.addLineTo(202, 791);
		smogtown.addLineTo(147, 821);
		smogtown.addLineTo(131, 848);
		smogtown.addLineTo(117, 915);
		smogtown.addLineTo(1, 915);
		smogtown.addClose();

		// WESTSIDE
		westside.addMoveTo(178, 134);
		westside.addLineTo(176, 180);
		westside.addLineTo(199, 242);
		westside.addLineTo(188, 319);
		westside.addLineTo(164, 371);
		westside.addLineTo(171, 428);
		westside.addLineTo(164, 469);
		westside.addLineTo(153, 534);
		westside.addLineTo(150, 604);
		westside.addLineTo(146, 648);
		westside.addLineTo(148, 703);
		westside.addLineTo(188, 714);
		westside.addLineTo(245, 704);
		westside.addLineTo(293, 669);
		westside.addLineTo(340, 638);
		westside.addLineTo(386, 624);
		westside.addLineTo(428, 630);
		westside.addLineTo(464, 611);
		westside.addLineTo(523, 595);
		westside.addLineTo(559, 592);
		westside.addLineTo(583, 572);
		westside.addLineTo(587, 530);
		westside.addLineTo(602, 503);
		westside.addLineTo(626, 487);
		westside.addLineTo(662, 477);
		westside.addLineTo(652, 447);
		westside.addLineTo(573, 369);
		westside.addLineTo(562, 338);
		westside.addLineTo(574, 308);
		westside.addLineTo(588, 278);
		westside.addLineTo(574, 234);
		westside.addLineTo(545, 211);
		westside.addLineTo(488, 203);
		westside.addLineTo(440, 216);
		westside.addLineTo(394, 225);
		westside.addLineTo(320, 200);
		westside.addClose();

		// CORNERTOWN
		cornertown.addMoveTo(1, 1);
		cornertown.addLineTo(301, 1);
		cornertown.addLineTo(331, 27);
		cornertown.addLineTo(374, 91);
		cornertown.addLineTo(490, 206);
		cornertown.addLineTo(400, 225);
		cornertown.addLineTo(178, 133);
		cornertown.addLineTo(132, 104);
		cornertown.addLineTo(1, 103);
		cornertown.addClose();

		// NORTHVILLE
		northville.addMoveTo(300, 1);
		northville.addLineTo(334, 33);
		northville.addLineTo(367, 82);
		northville.addLineTo(494, 206);
		northville.addLineTo(547, 207);
		northville.addLineTo(580, 242);
		northville.addLineTo(585, 287);
		northville.addLineTo(562, 342);
		northville.addLineTo(574, 371);
		northville.addLineTo(653, 446);
		northville.addLineTo(667, 490);
		northville.addLineTo(776, 487);
		northville.addLineTo(871, 438);
		northville.addLineTo(810, 417);
		northville.addLineTo(701, 278);
		northville.addLineTo(695, 250);
		northville.addLineTo(772, 163);
		northville.addLineTo(777, 143);
		northville.addLineTo(805, 111);
		northville.addLineTo(825, 77);
		northville.addLineTo(888, 1);
		northville.addClose();

		// RIVERSIDE
		riverside.addMoveTo(887, 1);
		riverside.addLineTo(877, 19);
		riverside.addLineTo(845, 45);
		riverside.addLineTo(824, 82);
		riverside.addLineTo(800, 117);
		riverside.addLineTo(785, 128);
		riverside.addLineTo(776, 144);
		riverside.addLineTo(773, 162);
		riverside.addLineTo(699, 246);
		riverside.addLineTo(695, 270);
		riverside.addLineTo(707, 284);
		riverside.addLineTo(808, 413);
		riverside.addLineTo(871, 438);
		riverside.addLineTo(907, 409);
		riverside.addLineTo(935, 381);
		riverside.addLineTo(940, 362);
		riverside.addLineTo(1016, 323);
		riverside.addLineTo(1071, 328);
		riverside.addLineTo(1107, 328);
		riverside.addLineTo(1140, 323);
		riverside.addLineTo(1121, 294);
		riverside.addLineTo(1114, 144);
		riverside.addLineTo(1106, 39);
		riverside.addLineTo(1117, 1);
		riverside.addClose();

		// UPTOWN
		uptown.addMoveTo(1020, 321);
		uptown.addLineTo(997, 339);
		uptown.addLineTo(947, 360);
		uptown.addLineTo(935, 383);
		uptown.addLineTo(906, 409);
		uptown.addLineTo(980, 455);
		uptown.addLineTo(1029, 480);
		uptown.addLineTo(1056, 503);
		uptown.addLineTo(1110, 521);
		uptown.addLineTo(1179, 526);
		uptown.addLineTo(1176, 470);
		uptown.addLineTo(1186, 417);
		uptown.addLineTo(1192, 368);
		uptown.addLineTo(1146, 323);
		uptown.addLineTo(1074, 330);
		uptown.addClose();

		// DOWNTOWN
		downtown.addMoveTo(905, 411);
		downtown.addLineTo(869, 441);
		downtown.addLineTo(830, 468);
		downtown.addLineTo(779, 484);
		downtown.addLineTo(800, 514);
		downtown.addLineTo(756, 584);
		downtown.addLineTo(770, 610);
		downtown.addLineTo(756, 638);
		downtown.addLineTo(790, 638);
		downtown.addLineTo(812, 632);
		downtown.addLineTo(873, 642);
		downtown.addLineTo(958, 640);
		downtown.addLineTo(1019, 631);
		downtown.addLineTo(1081, 640);
		downtown.addLineTo(1149, 657);
		downtown.addLineTo(1209, 653);
		downtown.addLineTo(1184, 614);
		downtown.addLineTo(1179, 567);
		downtown.addLineTo(1210, 535);
		downtown.addLineTo(1174, 528);
		downtown.addLineTo(1112, 521);
		downtown.addLineTo(1068, 513);
		downtown.addLineTo(1034, 478);
		downtown.addLineTo(988, 463);
		downtown.addLineTo(943, 433);
		downtown.addClose();

		// RIVER
		river.addMoveTo(662, 476);
		river.addLineTo(640, 480);
		river.addLineTo(614, 492);
		river.addLineTo(596, 508);
		river.addLineTo(588, 520);
		river.addLineTo(588, 546);
		river.addLineTo(582, 572);
		river.addLineTo(567, 587);
		river.addLineTo(542, 595);
		river.addLineTo(522, 598);
		river.addLineTo(484, 603);
		river.addLineTo(462, 612);
		river.addLineTo(449, 618);
		river.addLineTo(434, 626);
		river.addLineTo(389, 660);
		river.addLineTo(378, 668);
		river.addLineTo(369, 680);
		river.addLineTo(353, 694);
		river.addLineTo(334, 711);
		river.addLineTo(320, 713);
		river.addLineTo(308, 724);
		river.addLineTo(206, 788);
		river.addLineTo(193, 791);
		river.addLineTo(162, 809);
		river.addLineTo(138, 825);
		river.addLineTo(126, 848);
		river.addLineTo(118, 880);
		river.addLineTo(115, 915);
		river.addLineTo(150, 915);
		river.addLineTo(169, 864);
		river.addLineTo(185, 834);
		river.addLineTo(204, 816);
		river.addLineTo(250, 792);
		river.addLineTo(288, 762);
		river.addLineTo(334, 740);
		river.addLineTo(411, 673);
		river.addLineTo(449, 641);
		river.addLineTo(503, 617);
		river.addLineTo(561, 609);
		river.addLineTo(592, 595);
		river.addLineTo(603, 581);
		river.addLineTo(607, 553);
		river.addLineTo(608, 536);
		river.addLineTo(614, 521);
		river.addLineTo(626, 506);
		river.addLineTo(656, 496);
		river.addLineTo(671, 493);
		river.addClose();

		// adding Regions to the Regions arrayList

		regions.add(new Region(villa, "villa", color(255, 0, 0), 178571, 173214));
		regions.add(new Region(suburbia, "suburbia", color(0, 255, 0), 446529,
				392858));
		regions.add(new Region(eastside, "eastside", color(0, 255, 0), 178571,
				125000));
		regions.add(new Region(lakeside, "lakeside", color(0, 255, 0), 297619,
				181548));
		regions.add(new Region(southville, "southville", color(0, 255, 0),
				178571, 110714));
		regions.add(new Region(plainville, "plainville", color(0, 255, 0),
				208333, 147916));
		regions.add(new Region(smogtown, "smogtown", color(255, 0, 0), 29762,
				27976));
		regions.add(new Region(westside, "westside", color(0, 255, 0), 148810,
				282739));
		regions.add(new Region(cornertown, "cornertown", color(0, 255, 0),
				59524, 258928));
		regions.add(new Region(northville, "northville", color(0, 255, 0),
				119048, 95238));
		regions.add(new Region(riverside, "riverside", color(0, 255, 0),
				238095, 230952));
		regions.add(new Region(uptown, "uptown", color(0, 255, 0), 29762,
				116072));
		regions.add(new Region(downtown, "downtown", color(0, 255, 0), 89286,
				258928));
		regions.add(new Region(river, "river", color(0, 255, 0), 100000, 100000));

		// println("Printing out the first region's name : " +
		// regions.get(0).getName() );

		// scrapeDatabase();
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
