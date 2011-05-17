class TweetSetManager{

ArrayList<TweetSet> tweetSets;
PVector origin;
PVector buttonDim;  
PVector removeCircleDim;
float buttonDist;
int mouseOverRemoveBox = -1;
int mouseOverBaseButton = -1;
    
TweetSetManager(){

  tweetSets = new ArrayList<TweetSet>(); 
  origin = new PVector(width-260, 130);
  buttonDim = new PVector(180, 40);
  removeCircleDim = new PVector(20,20);
  buttonDist = 8.0;
}  
   
 
void draw()
{
  text("Results", origin.x - 1, origin.y - 12);
  
  
  mouseOverRemoveBox = -1;
  mouseOverBaseButton = -1;
  
for (TweetSet a: tweetSets)
  {   
  a.getButtonPosY().update();   //update the tweetSet's interpolator (y pos of button)
    
  PVector buttonPos = new PVector(origin.x, a.getButtonPosY().value);
  PVector removeCirclePos = new PVector(buttonPos.x + buttonDim.x - 13, buttonPos.y + 13);
    
  color buttonColour = color(247,247,247); 
  color removeCircleColour = color(247,247,247); 
  
  rect(removeCirclePos.x, removeCirclePos.y, 4, 4);
  // -------- If mouse is over remove box, process! --------
   if(  ( abs(mouseX - removeCirclePos.x) < 10) && (abs(mouseY - removeCirclePos.y) < 10) )
      {
        removeCircleColour = color(red(removeCircleColour) * 1.3, green(removeCircleColour) * 1.3, blue(removeCircleColour) * 1.3 );    
        mouseOverRemoveBox = a.getId();
      }
   
  // -------- If mouse is over button in general, process! --------

    else if(  (mouseX > buttonPos.x) && (mouseX < buttonPos.x + buttonDim.x)   && (mouseY > buttonPos.y) && (mouseY < buttonPos.y + buttonDim.y)  )
        {
          buttonColour = color(red(buttonColour) * 1.3, green(buttonColour) * 1.3, blue(buttonColour) * 1.3 );    
          removeCircleColour = color(red(removeCircleColour) * 1.3, green(removeCircleColour) * 1.3, blue(removeCircleColour) * 1.3 );
          mouseOverBaseButton = a.getId();
        }
             
        
  // -------- Draw the button outline --------
  stroke(181, 184, 188);
  strokeWeight(1.5);
  fill(buttonColour);
  //rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y);
  rrect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y, 10.0f, 2.4f, "");
  
  
  // -------- Draw the tweet box colour  --------
  
  stroke(150);
  strokeWeight(1);
  fill(a.getColour());
  rect(buttonPos.x + 8, buttonPos.y + 8, 11, 11);

  
  // -------- Draw the button text --------
  textAlign(LEFT, CENTER);
  fill(40);
  text(a.getSearchTerms(), buttonPos.x + 30, buttonPos.y + (buttonDim.y / 2.0));
  
  
    // -------- Draw remove box --------
  
  stroke(220);
  
  strokeWeight(0);
  if(mouseOverRemoveBox == a.getId())  //if mouse over, add outline
      strokeWeight(1);


  fill(removeCircleColour);
  //rect(removeBoxPos.x, removeBoxPos.y, removeBoxDim.x, removeBoxDim.y);
  ellipse(removeCirclePos.x, removeCirclePos.y, removeCircleDim.x, removeCircleDim.y); 
  
  fill(0);
  text("x",  removeCirclePos.x - 4.0, removeCirclePos.y - 1.0);
    
  textAlign(LEFT, LEFT);
  }
  
  
  //reset for other draw functions
  strokeWeight(1);
  stroke(181, 184, 188);  
  
}
 
 
  
void processMouse()
{
  if(mouseOverRemoveBox >= 0)
  {
  println("Over remove box : " + mouseOverRemoveBox);  
    
  //loop through tweet sets, find the one that has id = mouseOverRemoveBox and remove it!
  for (TweetSet a: tweetSets)
    {
    if(a.getId() == mouseOverRemoveBox)
      {
      tweetSets.remove(a);
      colours.add(a.getColour());
      reallocateIds();  //tweetSet has been removed, reallocate id's for correct button drawing
      break;
      }  
    }
  }
}



// --------- When a tweetSet is deleted, we need to reallocate Id's to each tweetSet, so that they are drawn correctly as buttons)

void reallocateIds()
{
int newId = 0;

  for (TweetSet a: tweetSets)
    {
    a.setId(newId); 
    a.getButtonPosY().target(origin.y + (buttonDim.y * newId) + (buttonDist * newId));
    newId++;
    }
}
 
 
 
 
 
void addTweetSet(TweetSet newTweetSet)
{
  int theId = tweetSets.size();
  
 //give this new tweet set a unique id 
 newTweetSet.setId(theId);
 newTweetSet.getButtonPosY().set(origin.y + (buttonDim.y * theId) + (buttonDist * theId) - buttonDim.y);
 newTweetSet.getButtonPosY().target(origin.y + (buttonDim.y * theId) + (buttonDist * theId));

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
