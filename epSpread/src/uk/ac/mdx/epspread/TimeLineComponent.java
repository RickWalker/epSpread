package uk.ac.mdx.epspread;

import java.util.ArrayList;
import java.util.List;

import processing.core.PApplet;
import processing.core.PConstants;

import org.joda.time.DateTime;
import org.joda.time.Hours;
import org.joda.time.Period;

import controlP5.ControlEvent;

import processing.core.PVector;
//import processing.pdf.*;

public class TimeLineComponent {
	// idea is that we can 'stick' other visualisations to this timeline
	// together with annotations to tell a story
	TwitterFiltering parent;
	int x, y, width, height;
	DateTime timelineStartDate, timelineEndDate; // ARGH HACK TO TWEAK TIMELINE
													// ZOOM
	PVector originalSize; // for scaling!
	PVector smallVizSize;
	TwitterFilteringComponent currentLarge = null;
	TwitterFilteringComponent currentDragging = null;
	PVector previousPos;
	int lineStart, lineStop, lineY;
	float scaleFactorX, scaleFactorY;
	float fontScale;

	int draggingOffsetX, draggingOffsetY;

	boolean record = false; // to try writing to pdf!

	List<TwitterFilteringComponent> timePoints;// llyrComponent;

	TimeLineComponent(TwitterFiltering parent, int x, int y, int width,
			int height) {
		this.parent = parent;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		originalSize = new PVector(1280, 720);
		timelineStartDate = TwitterFiltering.minDate.withHourOfDay(0)
				.withMinuteOfHour(0).withSecondOfMinute(0)
				.withMillisOfSecond(0);// (new DateTime(2011, 4, 29, 0, 0, 0,
										// 0)); // hack for
		// screenshots
		// for
		// now
		timelineEndDate = TwitterFiltering.maxDate;
		scaleFactorX = width / originalSize.x;
		scaleFactorY = height / originalSize.y; // change eventually!
		smallVizSize = new PVector(320 * scaleFactorX, 180 * scaleFactorY);

		lineStart = (int) (x + 50 * scaleFactorX);
		lineStop = (int) (x + width - 50 * scaleFactorX);
		lineY = height / 2;
		fontScale = Math.min(scaleFactorX, scaleFactorY);
		timePoints = new ArrayList<TwitterFilteringComponent>();
		timePoints.add(new TwitterFilteringComponent(parent, this, 50,
				(int) (lineY - smallVizSize.y * 1.5f), (int) (smallVizSize.x),
				(int) (smallVizSize.y)));
	}

	private void drawFrameRate(int xp, int yp){
		//draw frame rate!
		parent.textAlign(PConstants.LEFT, PConstants.TOP);
		parent.textFont(parent.font);
		parent.textSize(18);
		parent.fill(0);
		parent.text(parent.frametimer.getFrameRateAsText(),xp, yp);
		//System.out.println(frametimer.getFrameRateAsText());
	}

	void draw() {
		if (record) {
			// Note that #### will be replaced with the frame number. Fancy!
			parent.beginRecord(PConstants.PDF, "frame-####.pdf");
			parent.textMode(PConstants.SHAPE);
			parent.font = parent.createFont("Verdana", 18); // recreate as a
															// shape
			parent.textFont(parent.font);
		}
		parent.background(130, 130, 130);

		if (currentLarge == null) {
			// draw the actual timeline
			for (TwitterFilteringComponent a : timePoints) {
				a.draw();
				drawLinksTo(a);
				// moveToPosition(a);
			}

			drawTimeLine();
			fixOverlaps();
			// draw visualisations!
		} else {
			currentLarge.draw();
		}
		if (record) {
			parent.endRecord();
			parent.textMode(PConstants.MODEL);
			record = false;
		}
		drawFrameRate(0,25);
		// controlP5.draw();
	}

	void drawTimeLine() {

		// draw the base timeline

		int minorTickHeight = (int) (20 * scaleFactorY);
		int majorTickHeight = (int) (40 * scaleFactorY);
		parent.strokeWeight(10);
		parent.stroke(0);
		parent.line(lineStart, lineY, lineStop, lineY);
		// draw days
		// int maxDays = Days.daysBetween(timelineStartDate,
		// timelineEndDate).getDays();
		int maxHours = Hours.hoursBetween(timelineStartDate, timelineEndDate)
				.getHours();
		// println("Interval  is " + fullTimeInterval);
		// println("Period is " + Days.daysBetween(minDate, maxDate).getDays());
		// println("Max days is " + maxDays);

		DateTime tempdt = new DateTime(timelineStartDate);
		String previousMonth = timelineStartDate.monthOfYear().getAsText();
		int previousDay = -1;// =tempdt.dayOfYear().get();
		int monthStart = lineStart;
		parent.textAlign(PConstants.CENTER, PConstants.TOP);

		for (int a = 0; a < maxHours; a++) {
			// println(a);
			parent.textAlign(PConstants.CENTER, PConstants.TOP);
			// draw label
			parent.textFont(parent.font);
			parent.textSize(10 * fontScale);

			if (tempdt.dayOfYear().get() != previousDay) {
				int tx = (int) (PApplet
						.map(a, 0, maxHours, lineStart, lineStop));
				// draw tick
				parent.strokeWeight(1);
				parent.line(tx, lineY, tx, lineY + minorTickHeight);
				previousDay = tempdt.dayOfYear().get();
				parent.fill(0);
				if (tempdt.dayOfMonth().get() == 1) {
					// special case!
					parent.textSize(14 * fontScale);
					parent.text(tempdt.dayOfMonth().getAsString(), tx, lineY
							+ majorTickHeight + parent.textDescent());
				} else {
					parent.text(tempdt.dayOfMonth().getAsString(), tx, lineY
							+ minorTickHeight + parent.textDescent());
				}

				// check if need to draw monthName
				if (!previousMonth.equals(tempdt.monthOfYear().getAsText())) {
					// draw some visual markers!
					// line(monthStart, lineY, monthStart,
					// lineY+majorTickHeight);
					parent.line(tx, lineY, tx, lineY + majorTickHeight);
					// position halfway between monthStart and tx, draw
					// monthname
					parent.textSize(18 * fontScale);
					// check! do we overlap the next month? if so, change
					// alignment
					if (parent.textWidth(previousMonth) / 2 + monthStart > tx) {
						parent.textAlign(PConstants.RIGHT, PConstants.TOP);
					}
					parent.text(previousMonth, (tx + monthStart) / 2, lineY
							+ minorTickHeight + 2
							* (parent.textAscent() + parent.textDescent()));
					previousMonth = tempdt.monthOfYear().getAsText();
					monthStart = tx;
				}
			}
			tempdt = tempdt.plus(Period.hours(1));
		}
		// draw final day
		parent.line(lineStop, lineY, lineStop, lineY + minorTickHeight);
		if (tempdt.dayOfMonth().get() == 1) {
			// special case!
			parent.text(tempdt.dayOfMonth().getAsString(), lineStop, lineY
					+ majorTickHeight + parent.textDescent());
		} else {
			parent.text(tempdt.dayOfMonth().getAsString(), lineStop, lineY
					+ minorTickHeight + parent.textDescent());
		}
		// draw final month!
		parent.textSize(18 * fontScale);
		parent.text(tempdt.monthOfYear().getAsText(),
				(lineStop + monthStart) / 2, lineY + minorTickHeight + 2
						* (parent.textAscent() + parent.textDescent()));
	}

	public void keyPressed() {
		if (currentLarge == null) {
			if (parent.key == '(') {
				parent.saveFrame("VASTMC2-####.png");
				record = true; // disable 'cos text should come first
			} else if (parent.key == ')') {
				addNew();
			}
		} else {
			/*
			 * if(e.getKeyCode()==PConstants.ENTER){ //finish annotation! }
			 */
		}
		/*
		 * else if (parent.key == 'S') {
		 * parent.saveFrame("VASTMC2-large-####.png"); record = true; } }
		 */
	}

	void moveToPosition(TwitterFilteringComponent t) {
		// moves component to a position above the middle of its range
		float maxX = PApplet.map(getHourOfYear(t.dateSelection.getEnd()),
				getHourOfYear(timelineStartDate),
				getHourOfYear(timelineEndDate), lineStart, lineStop);
		float minX = PApplet.map(getHourOfYear(t.dateSelection.getStart()),
				getHourOfYear(timelineStartDate),
				getHourOfYear(timelineEndDate), lineStart, lineStop);
		// if (t.x != int((maxX+minX)/2)-t.width/2) {
		t.moveTo((int) ((maxX + minX) / 2 - smallVizSize.x / 2),
				(int) (previousPos.y));
		// }
	}

	void drawLinksTo(TwitterFilteringComponent t) {
		parent.noStroke();
		parent.fill(170, 170, 255, 130);
		int targetY;

		targetY = (t.y<lineY ? (t.y+t.height):t.y);
		
		// println(t.y + " and " + targetY);
		// draw links from timeline to this component
		parent.beginShape(PConstants.POLYGON);
		parent.vertex(PApplet.map(getHourOfYear(t.dateSelection.getStart()),
				getHourOfYear(timelineStartDate),
				getHourOfYear(timelineEndDate), lineStart, lineStop), lineY);
		parent.vertex(t.x, targetY);
		parent.vertex(t.x + t.width, targetY);
		parent.vertex(PApplet.map(getHourOfYear(t.dateSelection.getEnd()),
				getHourOfYear(timelineStartDate),
				getHourOfYear(timelineEndDate), lineStart, lineStop), lineY);
		parent.endShape();
	}

	int getHourOfYear(DateTime t) {
		return t.getDayOfYear() * 24 + t.getHourOfDay();
	}

	void addNew() {
		// 1 is above, -1 is below
		// so 0 goes above, 1 goes below, 2 goes above etc
		int side = (int) (PApplet.pow(-1, timePoints.size()));
		if (side > 0) {
			timePoints.add(new TwitterFilteringComponent(parent, this, 50,
					(int) (lineY - smallVizSize.y * 1.5f),
					(int) (smallVizSize.x), (int) (smallVizSize.y)));
		} else {
			timePoints
					.add(new TwitterFilteringComponent(
							parent,
							this,
							50,
							(int) (lineY + smallVizSize.y * 1.5f - (int) (smallVizSize.y)),
							(int) (smallVizSize.x), (int) (smallVizSize.y)));
		}
	}

	void fixOverlaps() {
		/*
		 * for (TwitterFilteringComponent a: timePoints) { for
		 * (TwitterFilteringComponent b: timePoints) { if (a!=b) { if
		 * (a.contains(b.x, b.y) || a.contains(b.x+width, b.y) ||
		 * a.contains(b.x+width, b.y+height) || a.contains(b.x, b.y+height)) {
		 * if (a.doneResize && b.doneResize) if (b.y <lineY) { b.moveTo(b.x,
		 * int(b.y-smallVizSize.y-10)); } else { b.moveTo(b.x,
		 * int(b.y+smallVizSize.y+10)); } } } } }
		 */
	}

	void controlEvent(ControlEvent theControlEvent) {

		for (TwitterFilteringComponent a : timePoints) {
			if (a.hasMouseOver()) {
				a.controlEvent(theControlEvent);
			}
		}
	}

	void mousePressed() {
		if (currentLarge != null) {
			if (parent.mouseEvent.getClickCount() == 2) {
				// shrink it back down!
				// generate thumbnail
				currentLarge.setSize((int) (smallVizSize.x),
						(int) (smallVizSize.y));
				moveToPosition(currentLarge);
				currentLarge.checkComponents(); //work out if we've double-clicked on the map, the cloud or the streamgraph!
				currentLarge.currentTransitionState = MovementState.SHRINKING;
				currentLarge = null;
			} else {
				currentLarge.mousePressed();
			}
		} else {
			for (TwitterFilteringComponent a : timePoints) {
				if (parent.mouseEvent.getClickCount() == 2 && a.hasMouseOver()) {
					PApplet.println("<double click> on " + a);
					previousPos = new PVector(a.x, a.y);		
					a.moveTo(0, 0);
					a.setSize(width, height);
					currentLarge = a;
					a.currentTransitionState = MovementState.GROWING;
					break;
				} else if (a.hasMouseOver() && parent.keyPressed
						&& parent.keyCode == PConstants.SHIFT) {
					// move middle to where the mouse is?
					PApplet.println("Dragging start" + a);
					currentDragging = a;
					draggingOffsetX = parent.mouseX - a.x;
					draggingOffsetY = parent.mouseY - a.y;
					currentDragging.currentTransitionState = MovementState.MOVING;
					// a.mousePressed();
				}

				if (parent.mouseButton == PConstants.RIGHT) {
					// aha! we're doing captioning!
					if (a.hasMouseOver() && !a.hasCaption()) {
						a.addCaption();
					} else if (a.hasCaption() && a.caption.mouseOver()) {
						PApplet.println("We want to edit the caption!");
						a.caption.createNote();
					}
				}
			}
		}
	}

	void mouseReleased() {
		if (currentDragging != null) {
			currentDragging.currentTransitionState = MovementState.SMALL;
			currentDragging = null;
			PApplet.println("Stopped dragging");
		}
		for (TwitterFilteringComponent a : timePoints) {
			if (a.hasMouseOver()) {
				a.mouseReleased();
			}
		}
	}

	void mouseDragged() {
		if (currentDragging != null) {
			// PApplet.println("Moving!");
			// currentDragging.x = parent.mouseX - draggingOffsetX;
			// currentDragging.y = parent.mouseY - draggingOffsetY;//
			currentDragging.moveImmediatelyTo(parent.mouseX - draggingOffsetX,
					parent.mouseY - draggingOffsetY);
			// PApplet.println("x y are " + currentDragging.x + " and "
			// + currentDragging.y);
		}
	}
}
