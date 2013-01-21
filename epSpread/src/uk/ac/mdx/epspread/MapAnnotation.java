package uk.ac.mdx.epspread;

import processing.core.PApplet;
import processing.core.PVector;
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.utils.ScreenPosition;

public class MapAnnotation extends Annotation {

	UnfoldingMap mapRef;
	Location location;

	public MapAnnotation(TwitterFiltering gp, TwitterFilteringComponent parent,
			Location l, int width, int height, UnfoldingMap map) {
		super(gp, parent, 0, 0, width, height);
		this.location = new Location(l); // lat and lon location!
		mapRef = map; // need to use this to look up places!
	}

	@Override
	void draw() {
		workOutScreenCoords();
		// draw at the right map coords!
		// if we're visible only!
		if (parent.isOverMap(x, y) && parent.isOverMap(x + width, y + height))
			super.draw();
	}

	boolean mouseOver() {
		// work out what x and y really are!
		// (x is transformed lon, y is transformed lat!)
		workOutScreenCoords();
		PVector local = parent.getLocalCoordinate(new PVector(papplet.mouseX,
				papplet.mouseY));
		PApplet.println("MouseOver test: coords are " + x + ", " + y + ","
				+ width + "," + height);
		PApplet.println("Local mouse is " + local);
		PApplet.println("Screen Mouse is " + papplet.mouseX + ","
				+ papplet.mouseY);
		if (x < local.x && (x + width) >= local.x) {
			if (y <= local.y && (y + height) >= local.y) {
				return true;
			}
		}
		return false;
	}

	private void workOutScreenCoords() {
		// set x and y to what they should be!
		// need to look up lat and lon from map first, then convert to screen
		// coords
		// in the same way that tweets do!
		ScreenPosition loc = mapRef.getScreenPosition(location);
		// now to screen coords? actually, the map does that for us now.
		x = (int) loc.x;
		y = (int) loc.y;
	}

	@Override
	void createNote() {
		workOutScreenCoords();
		super.createNote();
	}
}
