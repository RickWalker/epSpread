package uk.ac.mdx.epspread;
import geomerative.RShape;
import processing.core.PVector;

public class Region {

	RShape regionShape; // stores shape of region
	String regionName; // stores name of region
	int regionColour; // stores colour of region
	int residents;
	int daytimePopulation;

	// constructor
	Region(RShape _theShape, String _theName, int _theColour, int residents,
			int daytimePopulation) {
		regionShape = _theShape;
		regionName = _theName;
		regionColour = _theColour;
		this.residents = residents;
		this.daytimePopulation = daytimePopulation;
	}

	void draw() {
		regionShape.draw();
	}

	String getName() {
		return regionName;
	}

	int getColour() {
		return regionColour;
	}

	boolean contains(PVector coord) {
		// remap range! coord is screen coords

		if (regionShape.contains(coord.x, coord.y))
			return true;
		else
			return false;
	}

	public String toString() {
		return "Region " + regionName;
	}
}
