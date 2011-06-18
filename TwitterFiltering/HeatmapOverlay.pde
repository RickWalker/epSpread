class HeatmapOverlay {

  float[] overlay;
  int gridres;
  float [] xpos; 
  float [] ypos; 
  float max_intensity;
  float smoothingLength = 30;
  TwitterFilteringComponent parent;
  // float [][] values;

  HeatmapOverlay(TwitterFilteringComponent parent) {
    this.parent = parent;
    gridres = 50;
    overlay = new float[gridres*gridres];
    //values = new float[gridres][gridres];
  }

  void draw() {
    //draw overlay!
    //createSurface(imgX, imgY, tweets);
    float boxsize_x = imgX/float(gridres);
    float boxsize_y = imgY/float(gridres);
    //println(max_intensity);
    colorMode(HSB, 50);
    for (int y = 0; y < gridres-1; y++) {
      for (int x = 0; x < gridres-1; x++) {

        //fill( map(overlay[x][y], 0, max_intensity, 0, 255), 0, 0, map(overlay[x][y], 0, max_intensity, 0, 255));
        //noStroke();
        float v = overlay[y*gridres+x];
        if (v != 0.0) {
          //println("Drawing!");
          //stroke(map(v, 0, max_intensity, 37, 2), 50, 50, map(v, 0, max_intensity, 2, 40));
          noStroke();
          //old version
          //fill(map(v, 0, max_intensity, 37, 2), 50, 50, map(v, 0, max_intensity, 2, 40));
          //rect(x*boxsize_x + imgPos.x, y*boxsize_y + imgPos.y, imgX/gridres-1, imgY/gridres-1);
          //new version, attempts to shade
          beginShape(TRIANGLES);
          fill(map(v, 0, max_intensity, 37, 2), 50, 50, map(v, 0, max_intensity, 2, 40));
          vertex(x*boxsize_x + parent.imgPos.x, y*boxsize_y + parent.imgPos.y);

          fill(map(overlay[y*gridres+x+1], 0, max_intensity, 37, 2), 50, 50, map(overlay[y*gridres+x+1], 0, max_intensity, 2, 40));
          vertex((x+1)*boxsize_x + parent.imgPos.x, y*boxsize_y + parent.imgPos.y);

          fill(map(overlay[(y+1)*gridres+x], 0, max_intensity, 37, 2), 50, 50, map(overlay[(y+1)*gridres+x], 0, max_intensity, 2, 40));
          vertex(x*boxsize_x + parent.imgPos.x, (y+1)*boxsize_y + parent.imgPos.y);

          vertex(x*boxsize_x + parent.imgPos.x, (y+1)*boxsize_y + parent.imgPos.y);

          fill(map(overlay[(y+1)*gridres+x+1], 0, max_intensity, 37, 2), 50, 50, map(overlay[(y+1)*gridres+x+1], 0, max_intensity, 2, 40));
          vertex((x+1)*boxsize_x + parent.imgPos.x, (y+1)*boxsize_y + parent.imgPos.y);

          fill(map(overlay[y*gridres+x+1], 0, max_intensity, 37, 2), 50, 50, map(overlay[y*gridres+x+1], 0, max_intensity, 2, 40));
          vertex((x+1)*boxsize_x + parent.imgPos.x, y*boxsize_y + parent.imgPos.y);
          endShape();

          //point(x*boxsize_x, y*boxsize_y);
        }
      }
    }
    colorMode(RGB, 255);
  }

  void createSimpleSurface(int w, int ht, ArrayList<Tweet> tweets) {
    //gridres = 50;
    Arrays.fill(overlay, 0.0);
    //float [] masses = new float[tweets.size()];
    //Arrays.fill(masses, 0.0);
    int xval, yval;
    max_intensity = 0;
    for (int i = 0; i < tweets.size(); i++) {
      if (parent.dateSelection.contains(tweets.get(i).mDate)) {
        xval = int(map(tweets.get(i).mLocation.x, 0, w, 0, gridres-1));
        yval = int(map(tweets.get(i).mLocation.y, 0, ht, 0, gridres-1));
        /* //what region is this in?
         Region r = findRegion(tweets.get(i));
         if (r==null) {
         println("can't find region for " + tweets.get(i));
         }
         //what time is it sent?
         boolean nighttime;
         if (tweets.get(i).mDate.getHourOfDay() <8 || tweets.get(i).mDate.getHourOfDay() >6) {
         nighttime = true;
         }
         else {
         nighttime = false;
         }
         
         //so, what weighting should it have?
         float weighting=0.0;
         if (r!=null) {
         if (nighttime) {
         weighting = 1.0 / (float) r.residents;
         }
         else {
         weighting = 1.0/(float) r.daytimePopulation;
         }
         }
         
         //println(tweets.get(i).mLocation.x + " " + tweets.get(i).mLocation.y + " and " + xval+ " " + yval);
         overlay[yval*gridres + xval] += weighting;//1;
         //       println(overlay[yval*gridres + xval]);
         max_intensity = max(overlay[yval*gridres + xval], max_intensity);*/
      }
    }
  }

  void updateTweetCounts(Tweet t, HashMap<Region, Integer> daytimeTweets, HashMap<Region, Integer> nighttimeTweets, boolean nighttime) {
    if (nighttime) {
      if (nighttimeTweets.containsKey(t.tweetRegion)) {
        nighttimeTweets.put(t.tweetRegion, nighttimeTweets.get(t.tweetRegion)+1);
      }
      else {
        nighttimeTweets.put(t.tweetRegion, 1);
      }
    }
    else {
      if (daytimeTweets.containsKey(t.tweetRegion)) {
        daytimeTweets.put(t.tweetRegion, daytimeTweets.get(t.tweetRegion)+1);
      }
      else {
        daytimeTweets.put(t.tweetRegion, 1);
      }
    }
  }

  void createWeightedSurface(int w, int ht, ArrayList<Tweet> tweets) {
    //clear old surface
    //gridres= 50;
    println("Creating surface!");
    println(parent.dateSelection);
    float boxsize_x = w;
    float boxsize_y = ht;
    //println("box size is " + boxsize_x + " " + boxsize_y);
    float [] masses = new float[tweets.size()];
    //Arrays.fill(masses, 0.0);
    Arrays.fill(overlay, 0.0);
    xpos = new float[tweets.size()];
    ypos = new float[tweets.size()];
    //keep count of tweets so I can sanity check:
    HashMap<Region, Integer> daytimeTweets = new HashMap<Region, Integer>();
    HashMap<Region, Integer> nighttimeTweets = new HashMap<Region, Integer>();
    for (int i = 0; i < tweets.size(); i++) {
      ypos[i] = tweets.get(i).mLocation.y; 
      xpos[i] = tweets.get(i).mLocation.x;

      //float weighting=0.0;
      if (tweets.get(i).tweetRegion!=null) { //do we have a region? if not, default weight
        boolean nighttime;
        if (tweets.get(i).mDate.getHourOfDay() <8 || tweets.get(i).mDate.getHourOfDay() >18) {       //what time is it sent?
          nighttime = true;
        }
        else {
          nighttime = false;
        }
        if (nighttime) {
          masses[i] = 1.0 / (float) tweets.get(i).tweetRegion.residents; //resident weighting!
        }
        else {
          masses[i] = 1.0/(float) tweets.get(i).tweetRegion.daytimePopulation; //daytime weighting
        }
        if (parent.dateSelection.contains(tweets.get(i).mDate)) {
          updateTweetCounts(tweets.get(i), daytimeTweets, nighttimeTweets, nighttime);
          //println(tweets.get(i));
        }
      }
      else {
        masses[i] = 1.0/50000000.0; //very low!
      }
    }
    println("Day time tweet counts: " + daytimeTweets);
    println("Night time tweet counts: " + nighttimeTweets);    

    max_intensity = Float.MIN_VALUE;
    //creates the surface
    double tweet_density = 100000.0;
    //double cinema_mass=100.0;
    double r_cloud = boxsize_x;
    double r_cloud_y = boxsize_y;
    double h = smoothingLength;//r_cloud / 20.0; //smoothing length
    double twoh = 2 * h;//2*smoothing length (kernel radius)
    double hi1 = 1.0/h; // 1/hi
    double hi21 = hi1 * hi1; //1/h^2
    int npixx = gridres - 1;
    int npixy = gridres - 1;
    double xmin = 0;
    double ymin = 0;

    double pixwidth = r_cloud / (float) npixx;
    double pixheight = r_cloud_y / (float) npixy;
    //println("pixwidth is " + pixwidth);
    double ypix;
    int ipix, jpix, ipixmin, ipixmax, jpixmin, jpixmax;
    double dy, dy2;
    double [] dx2i=new double[npixx+1];
    double qq, qq2, wab;
    double w_j;
    double termnorm, term;

    for (int i = 0 ; i < tweets.size() ; i++) {
      //ipixmin is the minimum x value that this cinema affects
      //so need to find the coordinates of the point twoh miles west of it, then take xmin from that?
      if (parent.dateSelection.contains(tweets.get(i).mDate)) {
        //ipixmin = (int) ((cinemaLocations[i].lat - twoh - xmin) / pixwidth_i);
        ipixmin = (int) ((xpos[i] - twoh) / pixwidth);
        jpixmin = (int) ((ypos[i] - twoh) / pixheight);
        ipixmax = (int) ((xpos[i] + twoh) / pixwidth) + 1;
        jpixmax = (int) ((ypos[i] + twoh) / pixheight) + 1;

        //println(ipixmin + " " + ipixmax + " " + jpixmin + " " + jpixmax);

        if (ipixmin<0) ipixmin = 0;
        if (jpixmin<0) jpixmin = 0;
        if (ipixmax>npixx) ipixmax = npixx;
        if (jpixmax>npixy) jpixmax = npixy;

        for (ipix=ipixmin;ipix<=ipixmax;ipix++) {
          dx2i[ipix]=(((ipix-0.5)*pixwidth - xpos[i]) * ( (ipix-0.5) * pixwidth - xpos[i]))*hi21; // + dz2;
          //println("dx2i is " + dx2i[ipix]);
        }

        //assume total'mass' 100 and each 'density' is 50
        //eventually, mass = , density = showings per day per screen
        w_j = (masses[i] / tweets.size())/(hi1 * hi21);
        //println("w_j is " + w_j);
        termnorm = 10./(7.*PI)*w_j;
        term = termnorm;

        for (jpix=jpixmin;jpix<=jpixmax;jpix++) {
          ypix=ymin+(jpix-0.5)*pixheight;
          dy=ypix-ypos[i];
          dy2=dy*dy*hi21;
          for (ipix=ipixmin;ipix<=ipixmax;ipix++) {
            qq2=dx2i[ipix] + dy2;
            //SPH Cubic spline
            //if in range
            if (qq2<4.0) {
              qq=Math.sqrt(qq2);
              if (qq<1.0) {
                wab=(1.-1.5*qq2 + 0.75*qq*qq2);
              }
              else { 
                wab=0.25*(2.-qq)*(2.-qq)*(2.-qq);
              }						
              overlay[jpix*gridres + ipix]+= term*wab;
              max_intensity = max(overlay[jpix*gridres + ipix], max_intensity);
            }
          }
        }
      }
    }
    double zmin = 0;
    double zmax = max_intensity;

    //now that we have the grid, generate contours!
    //mangle array back into 2D
    //double [][] values = new double[gridres][gridres];
    /*for (int x = 0 ; x< gridres; x++) {
     for (int y = 0; y<gridres; y++) {
     //println(x +" " + y + " " + gridres);
     values[x][y] =overlay[y*gridres+x];
     //println(values[x][y]);
     }
     }*/
    println("Max intensity is " + max_intensity);
  }


  void createSurface(int w, int ht, ArrayList<Tweet> tweets) {
    //clear old surface
    gridres= 50;
    float boxsize_x = w;
    float boxsize_y = ht;
    //println("box size is " + boxsize_x + " " + boxsize_y);
    float [] masses = new float[tweets.size()];
    Arrays.fill(masses, 1.0);
    Arrays.fill(overlay, 0.0);
    xpos = new float[tweets.size()];
    ypos = new float[tweets.size()];
    for (int i = 0; i < tweets.size(); i++) {
      ypos[i] = tweets.get(i).mLocation.y; //distanceBetween(zerozero, new PVector(cinemaLocations[i].lat, zerozero.lon));
      //if (tweets.get(i).mLocation.y > zerozero.y)
      //  tweets.get(i).mLocation.y *= -1;

      xpos[i] = tweets.get(i).mLocation.x;//distanceBetween(zerozero, new Location(zerozero.lat, cinemaLocations[i].lon)); //need signed distance!
      //if (tweets.get(i).mLocation.x < zerozero.x)
      //  xpos[i] *= -1;
      //println(xpos[i] + " " + ypos[i]);
    }

    max_intensity = Float.MIN_VALUE;
    //creates the surface
    double tweet_density = 100000.0;
    //double cinema_mass=100.0;
    double r_cloud = boxsize_x;
    double r_cloud_y = boxsize_y;
    double h = smoothingLength;//r_cloud / 20.0; //smoothing length
    double twoh = 2 * h;//2*smoothing length (kernel radius)
    double hi1 = 1.0/h; // 1/hi
    double hi21 = hi1 * hi1; //1/h^2
    int npixx = gridres - 1;
    int npixy = gridres - 1;
    double xmin = 0;
    double ymin = 0;

    double pixwidth = r_cloud / (float) npixx;
    double pixheight = r_cloud_y / (float) npixy;
    //println("pixwidth is " + pixwidth);
    double ypix;
    int ipix, jpix, ipixmin, ipixmax, jpixmin, jpixmax;
    double dy, dy2;
    double [] dx2i=new double[npixx+1];
    double qq, qq2, wab;
    double w_j;
    double termnorm, term;

    for (int i = 0 ; i < tweets.size() ; i++) {
      //ipixmin is the minimum x value that this cinema affects
      //so need to find the coordinates of the point twoh miles west of it, then take xmin from that?
      if (parent.dateSelection.contains(tweets.get(i).mDate)) {
        //ipixmin = (int) ((cinemaLocations[i].lat - twoh - xmin) / pixwidth_i);
        ipixmin = (int) ((xpos[i] - twoh) / pixwidth);
        jpixmin = (int) ((ypos[i] - twoh) / pixheight);
        ipixmax = (int) ((xpos[i] + twoh) / pixwidth) + 1;
        jpixmax = (int) ((ypos[i] + twoh) / pixheight) + 1;

        //println(ipixmin + " " + ipixmax + " " + jpixmin + " " + jpixmax);

        if (ipixmin<0) ipixmin = 0;
        if (jpixmin<0) jpixmin = 0;
        if (ipixmax>npixx) ipixmax = npixx;
        if (jpixmax>npixy) jpixmax = npixy;

        for (ipix=ipixmin;ipix<=ipixmax;ipix++) {
          dx2i[ipix]=(((ipix-0.5)*pixwidth - xpos[i]) * ( (ipix-0.5) * pixwidth - xpos[i]))*hi21; // + dz2;
          //println("dx2i is " + dx2i[ipix]);
        }

        //assume total'mass' 100 and each 'density' is 50
        //eventually, mass = , density = showings per day per screen
        w_j = (masses[i] / tweets.size())/(hi1 * hi21);
        //println("w_j is " + w_j);
        termnorm = 10./(7.*PI)*w_j;
        term = termnorm;

        for (jpix=jpixmin;jpix<=jpixmax;jpix++) {
          ypix=ymin+(jpix-0.5)*pixheight;
          dy=ypix-ypos[i];
          dy2=dy*dy*hi21;
          for (ipix=ipixmin;ipix<=ipixmax;ipix++) {
            qq2=dx2i[ipix] + dy2;
            //SPH Cubic spline
            //if in range
            if (qq2<4.0) {
              qq=Math.sqrt(qq2);
              if (qq<1.0) {
                wab=(1.-1.5*qq2 + 0.75*qq*qq2);
              }
              else { 
                wab=0.25*(2.-qq)*(2.-qq)*(2.-qq);
              }						
              overlay[jpix*gridres + ipix]+= term*wab;
              max_intensity = max(overlay[jpix*gridres + ipix], max_intensity);
            }
          }
        }
      }
    }
    double zmin = 0;
    double zmax = max_intensity;

    //now that we have the grid, generate contours!
    //mangle array back into 2D
    //double [][] values = new double[gridres][gridres];
    /*for (int x = 0 ; x< gridres; x++) {
     for (int y = 0; y<gridres; y++) {
     //println(x +" " + y + " " + gridres);
     values[x][y] =overlay[y*gridres+x];
     //println(values[x][y]);
     }
     }*/
    println("Max intensity is " + max_intensity);
  }
}

