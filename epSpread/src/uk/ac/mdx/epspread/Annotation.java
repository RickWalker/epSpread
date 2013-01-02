package uk.ac.mdx.epspread;

import java.awt.event.KeyEvent;
import java.util.List;

import org.gicentre.utils.text.WordWrapper;

import guicomponents.GTextField;
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PVector;

public class Annotation {
	// contains a textfield!
	int x, y, width, height;
	TwitterFilteringComponent parent;
	private GTextField txtAnnotation;
	int index;
	String noteText;
	TwitterFiltering gp;
	static final int DEFAULT_WIDTH = 200;
	static final float PADDING = 10;
	static final int TEXTSIZE = 18;

	Annotation(TwitterFiltering gp, TwitterFilteringComponent parent, int x,
			int y, int width, int height, int index) {
		this.parent = parent;
		this.gp = gp;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.index = index;
		noteText = new String("Note contents");
		createNote();
		PApplet.print("coords are " + x + ", " + y + ", " + width + ", "
				+ height);
		PApplet.println("parent coords are " + parent.x + ", " + parent.y
				+ ", " + parent.scaleFactorX + ", " + parent.scaleFactorY);
		gp.registerKeyEvent(this);
	}

	void draw() {
		// we're assuming that the transform is set correctly here!
		// draw shadow first!
		float shadowOffset = 2;
		// float gap = 10;// margin for text
		gp.noStroke();
		gp.fill(0, 0, 0, 100);
		gp.rect(x + shadowOffset, y + shadowOffset, width + 2 * shadowOffset,
				height + 2 * shadowOffset);
		// now rest of note
		gp.rectMode(PConstants.CORNER);
		gp.stroke(255, 255, 0, 50);
		gp.fill(255, 255, 0, 100);
		gp.rect(x, y, width, height);
		// draw the text!
		gp.textFont(gp.font);
		gp.textSize(Annotation.TEXTSIZE * parent.fontScale);
		gp.fill(0);
		gp.text(noteText, x + Annotation.PADDING, y + Annotation.PADDING, width - 2*Annotation.PADDING, height
				- 2*Annotation.PADDING);
	}

	boolean mouseOver() {
		PVector local = parent.getLocalCoordinate(new PVector(gp.mouseX,
				gp.mouseY));
		PApplet.println("MouseOver test: coords are " + x + ", " + y + ","
				+ width + "," + height);
		PApplet.println("Local mouse is " + local);
		PApplet.println("Screen Mouse is " + gp.mouseX + "," + gp.mouseY);
		if (x < local.x && (x + width) >= local.x) {
			if (y <= local.y && (y + height) >= local.y) {
				return true;
			}
		}
		return false;
	}

	void resize() {
		if (txtAnnotation != null)
			txtAnnotation.setVisible(false);
	}

	void updateNote() {
		if (txtAnnotation != null && !txtAnnotation.getText().equals(noteText)) {
			noteText = txtAnnotation.getText();
			txtAnnotation.setVisible(false);
			txtAnnotation = null;
			// now update height for the note!
			gp.textFont(gp.font);
			gp.textSize(Annotation.TEXTSIZE * parent.fontScale);
			List<String> lines = WordWrapper.wordWrap(noteText,
					(int) (width - Annotation.PADDING * 2), gp);
			height = (int) ((lines.size() + 1) * (gp.textAscent() + gp
					.textDescent()) + 2*Annotation.PADDING);
			PApplet.println("Note spreads over "+lines.size() +" lines, new height is now " + height);
		}
		// note.setText(editNote.getText());
		// noteText = note.getText();
	}

	void removeNote() {
		// noteText = note.getText();
		// gp.controlP5.remove("note" + index);
		txtAnnotation.setVisible(false);
		txtAnnotation = null;
	}

	public void keyEvent(KeyEvent e) {
		if (txtAnnotation != null && e.getKeyCode() == PConstants.ENTER) {
			updateNote();
		}
	}

	private void saveAnnotation() {
		noteText = txtAnnotation.getText();
		txtAnnotation.setVisible(false);
		txtAnnotation = null;
	}

	void createNote() {
		// g4p works in screen space, not local space
		// so do the conversion!
		PVector screenCoord = parent.getScreenCoordinate(new PVector(x, y));
		txtAnnotation = new GTextField(gp, "", (int) screenCoord.x,
				(int) (screenCoord.y), (int) (width * parent.scaleFactorX),
				(int) (height * parent.scaleFactorY), true);
		PApplet.println("Created at " + x + ", " + y);
		// txtAnnotation = new GTextArea(gp, x, y, width,
		// height);

		txtAnnotation.setText(noteText);
	}

	void hide() {
		PApplet.println("Hiding note!");
		if (txtAnnotation != null && !txtAnnotation.getText().equals(noteText)) {
			saveAnnotation();
		}
		// wholeNote.hide();
	}

	void show() {
		// wholeNote.show();
	}

}
