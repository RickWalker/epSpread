class Tweet{
  
String mText;  
PVector mLocation;
DateTime mDate;
int userId;
boolean b_selected;
  
Tweet(){
  
  mText = "blah";
  mLocation = new PVector(0,0);
  //mDate = 0.0f;
  userId = -1;
  b_selected = false;
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
