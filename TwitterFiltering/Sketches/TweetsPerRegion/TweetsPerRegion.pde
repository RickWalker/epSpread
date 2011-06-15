import geomerative.*;
import de.bezier.data.sql.*;
import java.util.ArrayList;

SQLite db;

//lat and lon of top left of vastopolis map
float topleft_lat = 42.3017;
float topleft_lon = 93.5673;
float bottomright_lat = 42.1609;
float bottomright_lon = 93.1923;

DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd HH:mm");
//Note : are intervals inclusive or exclusive?
DateTime startDate = (new DateTime(2011, 4, 30, 0, 0, 0, 0)).minus(Period.hours(1));
DateTime endDate = (new DateTime(2011, 5, 20, 23, 59, 0, 0)).plus(Period.hours(1));

PrintWriter output;

// -------- Region class --------

class Region {

  RShape regionShape;  //stores shape of region
  String regionName;   //stores name of region
  color regionColour;  //stores colour of region
  int tweetCount;
  int totalCount;
  ArrayList<Integer> tweetCountDays;
  ArrayList<Integer> tweetCountHours;

  //constructor
  Region(RShape _theShape, String _theName, color _theColour) 
  { 
    regionShape = _theShape;
    regionName = _theName;
    regionColour = _theColour;
    tweetCount = 0;
    totalCount = 0;

    tweetCountDays = new ArrayList<Integer>();
    tweetCountHours = new ArrayList<Integer>();

    for (int i=0; i<21+1; i++)
      tweetCountDays.add(0);

    for (int j=0; j<505; j++)
      tweetCountHours.add(0);
  }  


  void draw()
  {
    regionShape.draw();
  }


  String getName() {
    return regionName;
  }

  color getColour() {
    return regionColour;
  }


  ArrayList<Integer> getTweetCountDays() {
    return tweetCountDays;
  }
  
  ArrayList<Integer> getTweetCountHours() {
    return tweetCountHours;
  }

  void incrementTweetCount() {
    tweetCount++;
  }

  void incrementTweetCountForDay(Integer dayIndex) {
    tweetCountDays.set(dayIndex, tweetCountDays.get(dayIndex)+1);
    totalCount++;
  }

  void incrementTweetCountForHour(Integer hourIndex) {
    tweetCountHours.set(hourIndex, tweetCountHours.get(hourIndex)+1);
    totalCount++;
  }


  Integer getTweetCount() {
    return tweetCount;
  }

Integer getTotalTweetCount(){
 return totalCount; 
}

  boolean contains(PVector coord) {

    if (regionShape.contains(coord.x, coord.y))
      return true;
    else
      return false;
  }
}

// ---------------------------------













RShape villa, suburbia, eastside, lakeside, southville, plainville, smogtown, westside, cornertown, northville, riverside, uptown, downtown, river;

ArrayList<Region> regions = new ArrayList<Region>();

void setup()
{
  size(1800, 916);
  smooth();

  //setup database
  db = new SQLite( this, "../../VAST2011_MC1.sqlite" );  // open database file
  output = createWriter("hours.csv");

  RG.init( this );

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

  //VILLA
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

  //SUBURBIA
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

  //EASTSIDE
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

  //LAKESIDE
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

  //SOUTHVILLE
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

  //PLAINVILLE
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

  //SMOGTOWN
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

  //WESTSIDE
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

  //CORNERTOWN
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

  //NORTHVILLE
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

  //RIVERSIDE
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

  //UPTOWN
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

  //DOWNTOWN
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

  //RIVER
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


  //adding Regions to the Regions arrayList
  Region newRegion;



  newRegion = new Region( villa, "villa", color(255, 0, 0) );
  regions.add(newRegion);
  
  
  newRegion = new Region( suburbia, "suburbia", color(0, 255, 0) );
   regions.add(newRegion);

   newRegion = new Region( eastside, "eastside", color(0, 255, 0) );
   regions.add(newRegion);
   
   
   newRegion = new Region( lakeside, "lakeside", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( southville, "southville", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( plainville, "plainville", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( smogtown, "smogtown", color(255, 0, 0) );
   regions.add(newRegion);
   
   newRegion = new Region( westside, "westside", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( cornertown, "cornertown", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( northville, "northville", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( riverside, "riverside", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( uptown, "uptown", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( downtown, "downtown", color(0, 255, 0) );
   regions.add(newRegion);
   newRegion = new Region( river, "river", color(0, 255, 0) );
   regions.add(newRegion);
  


  println("Printing out the first region's name : " + regions.get(0).getName() );

  scrapeDatabase();
}

void draw()
{
  //background(255);

  fill(255);
  for (Region a:regions)
  {
    a.draw();
  }
}







void scrapeDatabase() {

  String granularity = "Hours";  
  
  if ( db.connect() )
  {
    print("Scraping database...");

    String sqlQuery = "SELECT * FROM micro2";
    // list table names
    db.query(sqlQuery);

    Interval dateSelection; 

    dateSelection = new Interval(startDate, endDate);

    println("number of hours : " + Hours.hoursIn(dateSelection).getHours());     

    //loop through database rows
    while (db.next ())
    {  
      PVector location = new PVector(0, 0);

      //get the lat and lon from this row
      location.x = db.getFloat("lon");
      location.y = db.getFloat("lat"); 
      DateTime thisDate  =fmt.parseDateTime(db.getString("date"));

      if (granularity == "Days")
      {
        Integer dayOfTweet = Days.daysIn(new Interval(startDate, thisDate)).getDays();

        for (Region reg: regions)
        {
          if ( reg.contains(mapCoordinates(location)))
          {
            reg.incrementTweetCount();  //found it! increment count for this region
            reg.incrementTweetCountForDay(dayOfTweet);

            break; //found it, so no need to look through other regions
          }
        }
      }
      
       if (granularity == "Hours")
      {
       Integer hourOfTweet = Hours.hoursIn(new Interval(startDate, thisDate)).getHours();

        for (Region reg: regions)
        {
          if ( reg.contains(mapCoordinates(location)))
          {
            reg.incrementTweetCount();  //found it! increment count for this region
            reg.incrementTweetCountForHour(hourOfTweet);

            break; //found it, so no need to look through other regions
          }
        }
      }
      
      
      
      
    }


    //uncomment this to draw all the tweets
    // fill(255,0,0);
    // rect(mapCoordinates(location).x, mapCoordinates(location).y, 10, 10);

    //look to see which region this tweet is in

    /*
      for(Region reg: regions)
     {
     if( reg.contains(mapCoordinates(location)))
     {
     reg.incrementTweetCount();  //found it! increment count for this region
     break; //found it, so no need to look through other regions
     }
     }
     */



    println("Finished");
    println();
  }


if(granularity == "Days"){
  //Print out the totals

    for (Region reg: regions) {
      output.print(reg.getName() + ",");
      print(reg.getName() + ",");
    }
    
    output.println();
    println();
      
    
    
    //println(reg.getName() + ",");
    for (int i=0; i<21; i++){
      for (Region reg: regions) 
       {
       output.print(reg.getTweetCountDays().get(i) + ",");
       print(reg.getTweetCountDays().get(i) + ",");
     }
     output.println();
     println();
  }
}

if(granularity == "Hours"){
  //Print out the totals

    for (Region reg: regions) {
      output.print(reg.getName() + ",");
      print(reg.getName() + ",");
    }
    
    output.println();
    println();

    //println(reg.getName() + ",");
    for (int i=0; i<505; i++){
      for (Region reg: regions) 
       {
       output.print(reg.getTweetCountHours().get(i) + ",");
       print(reg.getTweetCountHours().get(i) + ",");
     }
     output.println();
     println();
  }
}



for (Region reg: regions) 
       {
        print(reg.getName() + " " + reg.getTotalTweetCount()); 
        println();
       }



 output.flush(); // Write the remaining data
 output.close(); // Finish the file
}



PVector mapCoordinates(PVector coords)
{
  PVector result = new PVector(0.0f, 0.0f);
  result.x = map(coords.x, topleft_lon, bottomright_lon, 0, width);
  result.y = map(coords.y, topleft_lat, bottomright_lat, 0, height);

  return result;
}

