class TweetSetManager{

ArrayList<TweetSet> tweetSets;
PVector origin;
PVector buttonDim;  
PVector removeBoxDim;
float buttonDist;
int mouseOverRemoveBox = -1;
int mouseOverBaseButton = -1;
    
TweetSetManager(){

  tweetSets = new ArrayList<TweetSet>(); 
  origin = new PVector(width-210, 80);
  buttonDim = new PVector(180, 40);
  removeBoxDim = new PVector(15,15);
  buttonDist = 8.0;
}  
   
 
void draw()
{
  
  mouseOverRemoveBox = -1;
  mouseOverBaseButton = -1;
  
for (TweetSet a: tweetSets)
  {   
  a.getButtonPosY().update();   //update the tweetSet's interpolator (y pos of button)
    
  PVector buttonPos = new PVector(origin.x, a.getButtonPosY().value);
  PVector removeBoxPos = new PVector(buttonPos.x + buttonDim.x - 23, buttonPos.y + 7);
    
  color buttonColour = color(200,200,200); 
  color removeBoxColour = color(170,170,170);  
  
  // -------- If mouse is over remove box, process! --------
   if(  (mouseX > removeBoxPos.x) && (mouseX < removeBoxPos.x + removeBoxDim.x)   && (mouseY > removeBoxPos.y) && (mouseY < removeBoxPos.y + removeBoxDim.y)  )
      {
        removeBoxColour = color(red(removeBoxColour) * 1.3, green(removeBoxColour) * 1.3, blue(removeBoxColour) * 1.3 );    
        mouseOverRemoveBox = a.getId();
      }
   
  // -------- If mouse is over button in general, process! --------

    else if(  (mouseX > buttonPos.x) && (mouseX < buttonPos.x + buttonDim.x)   && (mouseY > buttonPos.y) && (mouseY < buttonPos.y + buttonDim.y)  )
        {
          buttonColour = color(red(buttonColour) * 1.1, green(buttonColour) * 1.1, blue(buttonColour) * 1.1 );    
          mouseOverBaseButton = a.getId();
        }
             
        
  // -------- Draw the button outline --------
  stroke(50);
  strokeWeight(2);
  fill(buttonColour);
  //rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y);
  rrect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y, 10.0f, 2.4f, "");
  
  
  // -------- Draw base button  --------
  
  stroke(50);
  strokeWeight(2);
  fill(a.getColour());
  rect(buttonPos.x + 8, buttonPos.y + 8, 11, 11);
 
 
 
  
  // -------- Draw the button text --------
  textAlign(LEFT, CENTER);
  fill(40);
  text(a.getSearchTerms(), buttonPos.x + 30, buttonPos.y + (buttonDim.y / 2.0));
  
  
    // -------- Draw remove box --------
  
  stroke(50);
  strokeWeight(2);
  fill(removeBoxColour);
  rect(removeBoxPos.x, removeBoxPos.y, removeBoxDim.x, removeBoxDim.y);
 

  
  fill(0);
  text("x",  removeBoxPos.x + 3.5, removeBoxPos.y + 6.0);
    
  textAlign(LEFT, LEFT);
  }
  
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
