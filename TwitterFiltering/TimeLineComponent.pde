class TimeLineComponent {
  //idea is that we can 'stick' other visualisations to this timeline together with annotations to tell a story
  TwitterFiltering parent;
  int x, y, width, height;
  DateTime timelineStartDate, timelineEndDate; //ARGH HACK TO TWEAK TIMELINE ZOOM
  PVector originalSize; //for scaling!
  PVector smallVizSize;
  TwitterFilteringComponent currentLarge = null;
  TwitterFilteringComponent currentDragging = null;
  PVector previousPos;
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
    originalSize = new PVector(1280, 720);
    timelineStartDate = (new DateTime(2011, 4, 29, 0, 0, 0, 0)); //hack for screenshots for now
    timelineEndDate = (new DateTime(2011, 5, 21, 0, 0, 0, 0));
    scaleFactorX = width/originalSize.x;
    scaleFactorY = height/originalSize.y; //change eventually!
    smallVizSize = new PVector(250*scaleFactorX, 150*scaleFactorY);

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
    background(130, 130, 130);
    if (currentLarge == null) {
      //draw the actual timeline
      for (TwitterFilteringComponent a: timePoints) {
        a.draw();
        drawLinksTo(a);
        //moveToPosition(a);
      }

      drawTimeLine();
      fixOverlaps();
      //draw visualisations!
    }
    else {
      currentLarge.draw();
    }
    //controlP5.draw();
  }

  void drawTimeLine() {
    //draw the base timeline


      int minorTickHeight = int(20*scaleFactorY);
    int majorTickHeight = int(40*scaleFactorY);
    strokeWeight(10);
    stroke(0);
    line(lineStart, lineY, lineStop, lineY);
    //draw days
    //int maxDays = Days.daysBetween(timelineStartDate, timelineEndDate).getDays();
    int maxHours = Hours.hoursBetween(timelineStartDate, timelineEndDate).getHours();
    //println("Interval  is " + fullTimeInterval);
    //println("Period is " + Days.daysBetween(minDate, maxDate).getDays());
    //println("Max days is " + maxDays);

    DateTime tempdt = new DateTime(timelineStartDate);
    String previousMonth = timelineStartDate.monthOfYear().getAsText();
    int previousDay=-1;//=tempdt.dayOfYear().get();
    int monthStart = lineStart;
    textAlign(CENTER, TOP);

    for (int a = 0; a<maxHours; a++) {
      //println(a);

      //draw label
      textFont(font);
      textSize(14*fontScale);

      if (tempdt.dayOfYear().get() != previousDay) {
        int tx = int(map(a, 0, maxHours, lineStart, lineStop));
        //draw tick
        strokeWeight(1);
        line(tx, lineY, tx, lineY+minorTickHeight);
        previousDay = tempdt.dayOfYear().get();
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
      tempdt = tempdt.plus(Period.hours(1));
    }
    //draw final day!
    line(lineStop, lineY, lineStop, lineY+minorTickHeight);
    if (tempdt.dayOfMonth().get() == 1) {
      //special case!
      text(tempdt.dayOfMonth().getAsString(), lineStop, lineY + majorTickHeight);
    }
    else {
      text(tempdt.dayOfMonth().getAsString(), lineStop, lineY + minorTickHeight);
    }
    //draw final month!
    textSize(18*fontScale);
    text(tempdt.monthOfYear().getAsText(), (lineStop+monthStart)/2, lineY+minorTickHeight + 2*(textAscent() + textDescent()));
  }

  void keyPressed() {
    if (currentLarge == null) {
      if (key == 'r') {
        saveFrame("VASTMC2-####.png");
      }
      else if (key == 'n') {
        addNew();
      }
    }
    else {
      if (key == 'S') {
        saveFrame("VASTMC2-large-####.png");
      }
    }
  }

  void moveToPosition(TwitterFilteringComponent t) {
    //moves component to a position above the middle of its range
    float maxX = map(getHourOfYear(t.dateSelection.getEnd()), getHourOfYear(timelineStartDate), getHourOfYear(timelineEndDate), lineStart, lineStop);
    float minX = map(getHourOfYear(t.dateSelection.getStart()), getHourOfYear(timelineStartDate), getHourOfYear(timelineEndDate), lineStart, lineStop);
    //if (t.x != int((maxX+minX)/2)-t.width/2) {
    t.moveTo(int((maxX+minX)/2-smallVizSize.x/2), int(previousPos.y));
    //}
  }
  void drawLinksTo(TwitterFilteringComponent t) {
    noStroke();
    fill(170, 170, 255, 130);
    int targetY;

    if (t.y < lineY) {
      targetY =  t.y + t.height;
    }
    else {
      targetY = t.y;
    }
    //println(t.y + " and " + targetY);
    //draw links from timeline to this component
    beginShape(POLYGON);
    vertex(map(getHourOfYear(t.dateSelection.getStart()), getHourOfYear(timelineStartDate), getHourOfYear(timelineEndDate), lineStart, lineStop), lineY);
    vertex(t.x, targetY);
    vertex(t.x+t.width, targetY);
    vertex(map(getHourOfYear(t.dateSelection.getEnd()), getHourOfYear(timelineStartDate), getHourOfYear(timelineEndDate), lineStart, lineStop), lineY);
    endShape();
  }

  int getHourOfYear(DateTime t) {
    return t.getDayOfYear()*24 + t.getHourOfDay();
  }

  void addNew() {
    //1 is above, -1 is below
    //so 0 goes above, 1 goes below, 2 goes above etc
    int side = int(pow(-1, timePoints.size()));
    if (side>0) {
      timePoints.add(new TwitterFilteringComponent(this, 50, int(lineY-smallVizSize.y*1.5), int(smallVizSize.x), int(smallVizSize.y)));
    }
    else {
      timePoints.add(new TwitterFilteringComponent(this, 50, int(lineY+smallVizSize.y*1.5-int(smallVizSize.y)), int(smallVizSize.x), int(smallVizSize.y)));
    }
  }
  void fixOverlaps() {
    /*for (TwitterFilteringComponent a: timePoints) {    
     for (TwitterFilteringComponent b: timePoints) {
     if (a!=b) {
     if (a.contains(b.x, b.y) || a.contains(b.x+width, b.y) || a.contains(b.x+width, b.y+height) || a.contains(b.x, b.y+height)) {
     if (a.doneResize && b.doneResize)
     if (b.y <lineY) {
     b.moveTo(b.x, int(b.y-smallVizSize.y-10));
     }
     else {
     b.moveTo(b.x, int(b.y+smallVizSize.y+10));
     }
     }
     }
     }
     }*/
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
        //generate thumbnail
        currentLarge.setSize(int(smallVizSize.x), int(smallVizSize.y));
        moveToPosition(currentLarge);
        currentLarge.currentTransitionState = MovementState.SHRINKING;
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
          previousPos = new PVector(a.x, a.y);
          a.moveTo(0, 0);
          a.setSize(width, height);
          currentLarge = a;
          a.currentTransitionState = MovementState.GROWING;
          break;
        }
        else if (a.hasMouseOver()) {
          //move middle to where the mouse is?
          println("Dragging " + a);
          currentDragging = a;
                currentDragging.currentTransitionState = MovementState.MOVING;
          //a.mousePressed();
        }
      }
    }
  }


  void mouseReleased() {
    if (currentDragging !=null){
      currentDragging.currentTransitionState = MovementState.SMALL;
      currentDragging = null;
      println("Stopped dragging");
    }
    for (TwitterFilteringComponent a: timePoints) {
      if (a.hasMouseOver()) {
        a.mouseReleased();
      }
    }
  }

  void mouseDragged() {
    if (currentDragging != null) {
      println("Moving!");
      //currentDragging.x = mouseX;
      //currentDragging.y = mouseY;//
      currentDragging.moveTo(mouseX, mouseY);
      println("x y are " + currentDragging.x + " and " + currentDragging.y);
    }
  }
}
