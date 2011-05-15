class HeatmapOverlay {

  float[] overlay;
  int gridres;
  float [] xpos; 
  float [] ypos; 
  float max_intensity;
  float smoothingLength = 30;
 // float [][] values;

  HeatmapOverlay() {
    gridres = 100;
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
    for (int x = 0; x < gridres; x++) {
      for (int y = 0; y < gridres; y++) {
        //fill( map(overlay[x][y], 0, max_intensity, 0, 255), 0, 0, map(overlay[x][y], 0, max_intensity, 0, 255));
        //noStroke();
        float v = overlay[y*gridres+x];
        if (v != 0.0) {
          //println("Drawing!");
          stroke(map(v, 0, max_intensity, 37, 2), 50, 50, map(v, 0, max_intensity, 2, 40));
          //noStroke();
          fill(map(v, 0, max_intensity, 37, 2), 50, 50, map(v, 0, max_intensity, 2, 40));
          rect(x*boxsize_x, y*boxsize_y, imgX/gridres-1, imgY/gridres-1);
          //point(x*boxsize_x, y*boxsize_y);
        }
      }
    }
    colorMode(RGB, 255);
  }

  void createSurface(int w, int ht, ArrayList<Tweet> tweets) {
    //clear old surface

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
      if (dateSelection.contains(tweets.get(i).mDate)) {
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

