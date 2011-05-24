class Tweet{
  
String mText;  

PVector mLocation;
DateTime mDate;
int userId;
boolean b_selected;
color tweetSetColour;
Integrator alphaVal;
  
Tweet(){
  
  mText = "blah";
  mLocation = new PVector(0,0);
  //mDate = 0.0f;
  userId = -1;
  b_selected = false;
  tweetSetColour = color(0,0,0);
  alphaVal = new Integrator(255);
}



void setAlphaTarget(float value){
 alphaVal.target(value); 
}


Integrator getAlphaIntegrator(){
 return alphaVal; 
}

float getAlpha(){
 return alphaVal.value; 
}


void setTweetSetColour(color _theColour){
 tweetSetColour = _theColour; 
}

color getTweetSetColour(){
 return tweetSetColour; 
}


void setText(String someText){
 mText = someText; 
}

void setDate(DateTime d){
  mDate = new DateTime(d);
  //println("mDate is " + mDate);
}

void setLocation(PVector coords){
 mLocation.x = coords.x;
 mLocation.y = coords.y;
}

void setUserId(int id){
 userId = id; 
}

int getUserId(){
 return userId; 
}


PVector getLocation(){
 return mLocation;
}


String getText(){
  return mText;
}
  

  
  
void setSelected(boolean val){
  b_selected = val;
}


boolean isSelected(){
 return b_selected; 
}
  
}
