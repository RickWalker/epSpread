package uk.ac.mdx.epspread;

import java.awt.event.KeyEvent;
import java.util.List;

import org.gicentre.utils.text.WordWrapper;

import guicomponents.GTextField;
import processing.core.PApplet;
import processing.core.PConstants;

public class PanelCaption {

	// contains a textfield!
	// int x, y, width, height;
	int height;
	TwitterFilteringComponent parent;
	private GTextField txtCaption;
	String noteText;
	TwitterFiltering papplet;
	// static final int DEFAULT_WIDTH = 200;
	static final float PADDING = 5;
	static final int TEXTSIZE = 72;

	PanelCaption(TwitterFiltering gp, TwitterFilteringComponent parent) {
		this.parent = parent;
		this.papplet = gp;
		// doesn't need these because it's tied always to the parent
		// this.x = x;
		// this.y = y;
		// this.width = width;
		this.height = parent.height / 3;
		noteText = new String(
				"Caption contents - this might be a bit more text than usual");
		// createNote();
		// PApplet.print("coords are " + x + ", " + y + ", " + width + ", "
		// + height);
		PApplet.println("parent coords are " + parent.x + ", " + parent.y
				+ ", " + parent.scaleFactorX + ", " + parent.scaleFactorY);
		gp.registerKeyEvent(this);
	}
	
	private int getY(){
		return (parent.y < (papplet.height/2) ? (parent.y-height):(parent.y+parent.height));
	}

	void draw() {
		// we're assuming that the transform is set correctly here!
		// draw shadow first!
		int x = parent.x;
		int y = getY();
		int width = parent.width;

		// float shadowOffset = 2;
		// float gap = 10;// margin for text
		papplet.noStroke();
		papplet.fill(0, 0, 0, 100);
		// papplet.rect(x + shadowOffset, y + shadowOffset, width + 2
		// * shadowOffset, height + 2 * shadowOffset);
		// now rest of note
		papplet.rectMode(PConstants.CORNER);
		papplet.stroke(0);
		papplet.fill(255, 255, 255);
		papplet.rect(x, y, width, height);
		// draw the text!
		papplet.textFont(papplet.font);
		papplet.textSize(PanelCaption.TEXTSIZE * parent.fontScale);
		papplet.fill(0);
		papplet.textAlign(PConstants.CENTER);
		papplet.text(noteText, x + PanelCaption.PADDING, y
				+ PanelCaption.PADDING, width - 2 * PanelCaption.PADDING,
				height - 2 * PanelCaption.PADDING);
	}

	boolean mouseOver() {
		PApplet.println("Screen Mouse is " + papplet.mouseX + ","
				+ papplet.mouseY);
		if (parent.x < papplet.mouseX
				&& (parent.x + parent.width) >= papplet.mouseX) {
			if (getY() <= papplet.mouseY
					&& (getY() + height) >= papplet.mouseY) {
				return true;
			}
		}
		return false;
	}

	void resize() {
		if (txtCaption != null)
			txtCaption.setVisible(false);
	}

	void updateNote() {
		if (txtCaption != null && !txtCaption.getText().equals(noteText)) {
			noteText = txtCaption.getText();
			txtCaption.setVisible(false);
			txtCaption = null;
			// now update height for the note!
			papplet.textFont(papplet.font);
			papplet.textSize(PanelCaption.TEXTSIZE * parent.fontScale);
			List<String> lines = WordWrapper.wordWrap(noteText,
					(int) (parent.width - PanelCaption.PADDING * 2), papplet);
			height = (int) ((lines.size() + 1)
					* (papplet.textAscent() + papplet.textDescent()) + 2 * PanelCaption.PADDING);
			PApplet.println("Note spreads over " + lines.size()
					+ " lines, new height is now " + height);
		}
		// note.setText(editNote.getText());
		// noteText = note.getText();
	}

	void removeNote() {
		// noteText = note.getText();
		// gp.controlP5.remove("note" + index);
		txtCaption.setVisible(false);
		txtCaption = null;
	}

	public void keyEvent(KeyEvent e) {
		if (txtCaption != null && e.getKeyCode() == PConstants.ENTER) {
			updateNote();
		}
	}

	private void saveCaption() {
		noteText = txtCaption.getText();
		txtCaption.setVisible(false);
		txtCaption = null;
	}

	void createNote() {
		// g4p works in screen space, not local space
		// so do the conversion!
		// PVector screenCoord = parent.getScreenCoordinate(new PVector(x, y));
		txtCaption = new GTextField(papplet, "", parent.x, getY(),
				parent.width, height, true);
		PApplet.println("Created at " + parent.x + ", " +getY());
		// txtAnnotation = new GTextArea(gp, x, y, width,
		// height);

		txtCaption.setText(noteText);
	}

	void hide() {
		PApplet.println("Hiding caption!");
		if (txtCaption != null && !txtCaption.getText().equals(noteText)) {
			saveCaption();
		}
		// wholeNote.hide();
	}

	void show() {
		// wholeNote.show();
	}

}
