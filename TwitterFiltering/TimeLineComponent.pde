class TimeLineComponent {
  //idea is that we can 'stick' other visualisations to this timeline together with annotations to tell a story
  TwitterFiltering parent;
  int x, y, width, height;
  PVector originalSize; //for scaling!
  PVector smallVizSize;
  TwitterFilteringComponent currentLarge;
  int lineStart, lineStop, lineY;
  float scaleFactorX, scaleFactorY;
  float fontScale;

  List<TwitterFilteringComponent> timePoints;// llyrComponent;

  TimeLineComponent(TwitterFiltering parent, int x, int y, int width, int height) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    originalSize = new PVector(1280, 800);

    scaleFactorX = 1.0;
    scaleFactorY = 1.0; //change eventually!
    smallVizSize = new PVector(300, 250);

    lineStart = int(x + 150*scaleFactorX);
    lineStop = int(x + width - 150*scaleFactorX);
    lineY = height/2;
    fontScale = min(scaleFactorX, scaleFactorY);
    timePoints = new ArrayList<TwitterFilteringComponent>();
    timePoints.add(new TwitterFilteringComponent(this, 50, int(lineY-smallVizSize.y*1.5), int(smallVizSize.x), int(smallVizSize.y)));
  }

  void arrangeTimePoints() {
  }

  void draw() {
    if (currentLarge == null) {
      //draw the actual timeline
      drawTimeLine();
      //draw visualisations!
      for (TwitterFilteringComponent a: timePoints) {
        a.draw();
        drawLinksTo(a);
        //moveToPosition(a);
      }
    }
    else {
      currentLarge.draw();
    }
  }

  void drawTimeLine() {
    //draw the base timeline


      int minorTickHeight = int(20*scaleFactorY);
    int majorTickHeight = int(40*scaleFactorY);
    strokeWeight(10);
    stroke(0);
    line(lineStart, lineY, lineStop, lineY);
    //draw days
    int maxDays = Days.daysBetween(minDate, maxDate).getDays();
    //println("Interval  is " + fullTimeInterval);
    //println("Period is " + Days.daysBetween(minDate, maxDate).getDays());
    //println("Max days is " + maxDays);

    DateTime tempdt = new DateTime(minDate);
    String previousMonth = minDate.monthOfYear().getAsText();
    int monthStart = lineStart;
    textAlign(CENTER, TOP);

    for (int a = 0; a<=maxDays; a++) {
      //println(a);
      int tx = int(map(a, 0, maxDays, lineStart, lineStop));
      //draw tick
      strokeWeight(1);
      line(tx, lineY, tx, lineY+minorTickHeight);
      //draw label
      textSize(14*fontScale);
      tempdt = minDate.plus(Period.days(a));
      fill(0);
      if (tempdt.dayOfMonth().get() == 1) {
        //special case!
        text(tempdt.dayOfMonth().getAsString(), tx, lineY + majorTickHeight);
      }
      else {
        text(tempdt.dayOfMonth().getAsString(), tx, lineY + minorTickHeight);
      }
      //check if need to draw monthName
      if (!previousMonth.equals(tempdt.monthOfYear().getAsText())) {
        //draw some visual markers!
        //line(monthStart, lineY, monthStart, lineY+majorTickHeight);
        line(tx, lineY, tx, lineY+majorTickHeight);
        //position halfway between monthStart and tx, draw monthname
        textSize(18*fontScale);
        text(previousMonth, (tx+monthStart)/2, lineY+minorTickHeight + 2*(textAscent() + textDescent()));
        previousMonth = tempdt.monthOfYear().getAsText();
      }
    }
    //draw final month!
    textSize(18*fontScale);
    text(tempdt.monthOfYear().getAsText(), (lineStop+monthStart)/2, lineY+minorTickHeight + 2*(textAscent() + textDescent()));
  }

  void moveToPosition(TwitterFilteringComponent t) {
    //moves component to a position above the middle of its range
    float maxX = map(t.dateSelection.getEnd().getDayOfYear(), minDate.getDayOfYear(), maxDate.getDayOfYear(), lineStart, lineStop);
    float minX = map(t.dateSelection.getStart().getDayOfYear(), minDate.getDayOfYear(), maxDate.getDayOfYear(), lineStart, lineStop);
    //if (t.x != int((maxX+minX)/2)-t.width/2) {
    t.moveTo(int((maxX+minX)/2-smallVizSize.x/2), t.y);
    //}
  }
  void drawLinksTo(TwitterFilteringComponent t) {
    noStroke();
    fill(128, 128);
    //draw links from timeline to this component
    beginShape(POLYGON);
    vertex(map(t.dateSelection.getStart().getDayOfYear(), minDate.getDayOfYear(), maxDate.getDayOfYear(), lineStart, lineStop), lineY);
    vertex(t.x, t.y+t.height);
    vertex(t.x+t.width, t.y+t.height);
    vertex(map(t.dateSelection.getEnd().getDayOfYear(), minDate.getDayOfYear(), maxDate.getDayOfYear(), lineStart, lineStop), lineY);
    endShape();
  }

  void controlEvent(ControlEvent theControlEvent) {

    for (TwitterFilteringComponent a: timePoints) {
      if (a.hasMouseOver()) {
        a.controlEvent(theControlEvent);
      }
    }
  }

  void mousePressed() {
    if (currentLarge !=null) {
      if (mouseEvent.getClickCount()==2) {
        //shrink it back down!
        currentLarge.setSize(300, 250);
        moveToPosition(currentLarge);
        currentLarge = null;
      }
      else {
        currentLarge.mousePressed();
      }
    }
    else {
      for (TwitterFilteringComponent a: timePoints) {
        if (mouseEvent.getClickCount()==2 && a.hasMouseOver()) {
          println("<double click> on " + a);
          a.moveTo(0, 0);
          a.setSize(width, height);
          currentLarge = a;
          break;
        }
        else if (a.hasMouseOver()) {
          a.mousePressed();
        }
      }
    }
  }


  void mouseReleased() {
    for (TwitterFilteringComponent a: timePoints) {
      if (a.hasMouseOver()) {
        a.mouseReleased();
      }
    }
  }
}

