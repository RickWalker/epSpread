class Tweet{
  
String mText;  
PVector mLocation;
float mDate;
  
Tweet(){
  
  mText = "blah";
  mLocation = new PVector(0,0);
  mDate = 0.0f;
}

void setText(String someText){
 mText = someText; 
}

void setLocation(PVector coords){
 mLocation.x = coords.x;
 mLocation.y = coords.y;
}

PVector getLocation(){
 return mLocation;
}


String getText(){
 return mText;
}
  
  
}
