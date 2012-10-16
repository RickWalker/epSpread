public class Annotation {
  //contains a textfield!
  int x, y, width, height;
  TwitterFilteringComponent parent;
  Group wholeNote;
  Textfield editNote;
  Textarea note; //resizing textfields breaks things. FFS.
  int index;
  String noteText;

  Annotation(TwitterFilteringComponent parent, int x, int y, int width, int height, int index) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.index = index;
    noteText= new String("Note contents");
    createNote();
    print("coords are " + x +", " + y +", " +width +", " +height);
    println("parent coords are " + parent.x  +", " +parent.y +", " +parent.scaleFactorX  +", " +parent.scaleFactorY);
  }

  void draw() {
    //stroke(255, 255, 0, 50);
    //fill(255, 255, 0, 50);
    //rect(parent.x + x*parent.scaleFactorX, parent.y+y*parent.scaleFactorY, width*parent.scaleFactorX, height*parent.scaleFactorY);
  }

  boolean mouseOver() {
    if ((x + parent.x*parent.scaleFactorX)<=mouseX && (x + parent.x*parent.scaleFactorX)+width*parent.scaleFactorX>=mouseX) {
      if ((y + parent.y*parent.scaleFactorY)<=mouseY && (y+parent.y*parent.scaleFactorY)+height*parent.scaleFactorY>=mouseY) {
        return true;
      }
    }
    return false;
  }

  void resize() {
    wholeNote.setSize(int(width*parent.scaleFactorX), int(height*parent.scaleFactorY));
    wholeNote.setPosition(int(parent.x + x*parent.scaleFactorX), int(parent.y+y*parent.scaleFactorY));

    note.setSize(int(width*parent.scaleFactorX), int((height-30)*parent.scaleFactorY));
    note.setPosition(0, int(30*parent.scaleFactorY));

    editNote.setSize(int(width*parent.scaleFactorX), int(30*parent.scaleFactorY));
    //note.setFont(new ControlFont(font, int(18*parent.fontScale)));
  }

  void updateNote() {
    note.setText(editNote.getText());
  }

  void removeNote() {
    noteText = note.getText();
    controlP5.remove("note"+index);
  }

  void createNote() {
    //because controlp5 doesn't support multiline text input, we have a textfield for input over a textarea for display
    //and we use a group to keep them moving together!
    wholeNote = controlP5.addGroup("g"+index)
      .setPosition(int(x+parent.x*parent.scaleFactorX), int(y+parent.y*parent.scaleFactorY))
        .setSize(int(width*parent.scaleFactorX), int(height*parent.scaleFactorY))
          .setColorBackground(color(255, 255, 0, 200)) //background color transparent
            .setColorForeground(color(255, 255, 0, 250)) //color for eg scroll bars etc
              .setColorActive(color(255, 255, 0, 250))
                //.addCloseButton()
                .hideArrow()
                  .disableCollapse()
                    .setLabel("");

    //the actual note part
    note = controlP5.addTextarea("fullnote"+index)
      .setLabel("")
        .setPosition(0, (30*parent.scaleFactorY))
          .setSize(int(width*parent.scaleFactorX), int((height-30)*parent.scaleFactorY))
            .setText(noteText)
              .setFont(new ControlFont(font, 12))
                //.setFont(createFont("FFScala", int(18.0*parent.fontScale)))
                //.setLineHeight(14)
                .setColor(color(0)) //TEXTCOLOR
                  .setColorBackground(color(255, 255, 0, 200)) //background color transparent
                    .setColorForeground(color(255, 255, 0, 100)) //color for eg scroll bars etc
                      .setMoveable(false)
                        .setGroup(wholeNote);

    //text field for editing
    editNote = controlP5.addTextfield("note"+index)
      .setLabel("")
        .setPosition(0, 0)
          .setSize(int(width*parent.scaleFactorX), int(30*parent.scaleFactorY))
            .setText("")
              .setFont(new ControlFont(font, 18))
                //.setLineHeight(14)
                .setColor(color(0)) //TEXTCOLOR
                  .setColorActive(color(255, 255, 0, 200))
                    .setColorBackground(color(255, 255, 0, 200)) //background color transparent
                      .setColorForeground(color(255, 255, 0, 100)) //color for eg scroll bars etc
                        .setMoveable(false)
                          .setGroup(wholeNote);
  }


  void hide() {
    println("Hiding note!");
    wholeNote.hide();
  }

  void show() {
    wholeNote.show();
  }
}

