class TweetSetManager{

ArrayList<TweetSet> tweetSets;
PVector origin;
PVector buttonDim;  
float buttonDist;
int uniqueID_counter = 0;
    
TweetSetManager(){

  tweetSets = new ArrayList<TweetSet>(); 
  origin = new PVector(width-210, 80);
  buttonDim = new PVector(180, 40);
  buttonDist = 8.0;
}  
   
 
void draw()
{

for (TweetSet a: tweetSets)
  {  
  PVector buttonPos = new PVector(origin.x, origin.y + (buttonDim.y * a.getId()) + (buttonDist * a.getId()));
  
  color buttonColour = color(255,255,255); //blank
  
  // -------- If mouse is over button, colour differently! --------
  if(  (mouseX > buttonPos.x) && (mouseX < buttonPos.x + buttonDim.x)   && (mouseY > buttonPos.y) && (mouseY < buttonPos.y + buttonDim.y)  )
        {
          buttonColour = color(180,180,180);    
        }
        else
        {
          buttonColour = color(160,160,160);   
        }
        
  // -------- Draw the button outline --------
  stroke(0);
  strokeWeight(2);
  fill(buttonColour);
  rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y);
  
  // -------- Draw button colour --------
  
  stroke(50);
  strokeWeight(2);
  fill(a.getColour());
  rect(buttonPos.x + 8, buttonPos.y + 8, 11, 11);
  
  // -------- Draw the button text --------
  textAlign(LEFT, CENTER);
  fill(255,255,255);
  text(a.getSearchTerms(), buttonPos.x + 30, buttonPos.y + (buttonDim.y / 2.0));
  
  
    // -------- Draw button colour --------
  
  PVector removeBoxPos = new PVector(buttonPos.x + buttonDim.x - 15, buttonPos.y);
  PVector removeBoxDim = new PVector(15,15);
  stroke(50);
  strokeWeight(2);
  fill(200);
  rect(removeBoxPos.x, removeBoxPos.y, removeBoxDim.x, removeBoxDim.y);
  fill(0);
  text("x",  removeBoxPos.x + 4.0, removeBoxPos.y + 6.0);
  
  
  
  
  textAlign(LEFT, LEFT);
  }
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
void addTweetSet(TweetSet newTweetSet)
{
 //give this new tweet set a unique id 
 newTweetSet.setId(uniqueID_counter);
 uniqueID_counter++;

 tweetSets.add(newTweetSet); 
}


int getTweetSetListSize()
{
 return tweetSets.size(); 
}
 
 
ArrayList<TweetSet> getTweetSetList()
{
  return tweetSets;
}
 
 
  
}
