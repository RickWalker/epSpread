class TweetSetManager{

ArrayList<TweetSet> tweetSets;
PVector origin;
PVector buttonDim;  
PVector removeCircleDim;
PVector optionButtonDim;
PVector pointsOptionPos;
PVector heatmapOptionPos;


float buttonDist;
int maxTweetSets;
int mouseOverRemoveBox = -1;
int mouseOverBaseButton = -1;
boolean mouseOverPointsOptionButton = false;
boolean mouseOverHeatmapOptionButton = false;

boolean b_heatmapViewActive = false;
boolean b_pointsViewActive = true;


int optionButtonsOffset = 40;
    
TweetSetManager(){

  tweetSets = new ArrayList<TweetSet>(); 
  origin = new PVector(width-260, 130);
  buttonDim = new PVector(180, 40);
  
  removeCircleDim = new PVector(20,20);
  optionButtonDim = new PVector(88, 40);
  buttonDist = 8.0;
  maxTweetSets = 10;
}  
   
 
void draw()
{
  text("Results", origin.x - 1, origin.y - 12);
  float alphaCol = 255;
  mouseOverRemoveBox = -1;
  mouseOverBaseButton = -1;  
  mouseOverPointsOptionButton = false;
  mouseOverHeatmapOptionButton = false;   
  

  // -------- Draw the background pane --------
  
   strokeWeight(1);
   stroke(200);
   fill(225 - 5, 228 - 5, 233 - 5);
     
   for(int i=0; i<maxTweetSets; i++)
     rrect(origin.x, origin.y + (buttonDim.y * i) + (buttonDist * i), 
     buttonDim.x, buttonDim.y, 10.0f,  2.4f, "");    
    
   pointsOptionPos = new PVector(origin.x, optionButtonsOffset + origin.y + (optionButtonDim.y * maxTweetSets+1) + (buttonDist * maxTweetSets+1));
   heatmapOptionPos = new PVector(origin.x + optionButtonDim.x + 5, optionButtonsOffset + origin.y + (optionButtonDim.y * maxTweetSets+1) + (buttonDist * maxTweetSets+1));
   
  // -------- Draw view options buttons --------    
    
    float pointsOptionButtonAlpha = 255 * 1.0;
    float heatmapOptionButtonAlpha = 255 * 1.0;
    
    if(b_pointsViewActive == false)
        pointsOptionButtonAlpha = 255 * 0.3;
      
     if(b_heatmapViewActive == false)
        heatmapOptionButtonAlpha = 255 * 0.3;
    
    color pointsOptionButtonColour = color(247,247,247, pointsOptionButtonAlpha); 
    color heatmapOptionButtonColour = color(247,247,247, heatmapOptionButtonAlpha); 
    
    
    if(  (mouseX > pointsOptionPos.x) && (mouseX < pointsOptionPos.x + optionButtonDim.x)   && (mouseY > pointsOptionPos.y) && (mouseY < pointsOptionPos.y + optionButtonDim.y)  )
      {
        pointsOptionButtonColour = color(red(pointsOptionButtonColour) * 2.3, green(pointsOptionButtonColour) * 2.3, blue(pointsOptionButtonColour) * 2.3, pointsOptionButtonAlpha);    
        mouseOverPointsOptionButton = true;
      }

    if(  (mouseX > heatmapOptionPos.x) && (mouseX < heatmapOptionPos.x + optionButtonDim.x)   && (mouseY > heatmapOptionPos.y) && (mouseY < heatmapOptionPos.y + optionButtonDim.y)  )
      {
        heatmapOptionButtonColour = color(red(heatmapOptionButtonColour) * 2.3, green(heatmapOptionButtonColour) * 2.3, blue(heatmapOptionButtonColour) * 2.3, heatmapOptionButtonAlpha);    
        mouseOverHeatmapOptionButton = true;
      }
    
    strokeWeight(1.5);
    stroke(181, 184, 188, alphaCol);
    
    fill(pointsOptionButtonColour);
    rrect(pointsOptionPos.x, pointsOptionPos.y, optionButtonDim.x, optionButtonDim.y, 10.0f,  2.4f, "");  
    
    fill(heatmapOptionButtonColour);
    rrect(heatmapOptionPos.x, heatmapOptionPos.y, optionButtonDim.x, optionButtonDim.y, 10.0f,  2.4f, "");  
    
    
    textAlign(LEFT, CENTER);
    fill(50,50,50,pointsOptionButtonAlpha);
    text("Points", pointsOptionPos.x + 20, pointsOptionPos.y + (optionButtonDim.y / 2.0));
    fill(50,50,50,heatmapOptionButtonAlpha);
    text("Heatmap", heatmapOptionPos.x + 10, heatmapOptionPos.y + (optionButtonDim.y / 2.0));
    textAlign(LEFT, LEFT);
   
    fill(76, 86, 108);
    text("Options", pointsOptionPos.x, pointsOptionPos.y - 12); 
   


  // -------- Loop through tweetSets --------  
    
for (TweetSet a: tweetSets)
  {   
  if(!a.isActive())
    alphaCol = 255 * 0.3;  
  else
    alphaCol = 255;
       
  PVector buttonPos = new PVector(origin.x, a.getButtonPosY().value);
  PVector removeCirclePos = new PVector(buttonPos.x + buttonDim.x - 12, buttonPos.y + 13);     
  color buttonColour = color(247,247,247, alphaCol); 
  color removeCircleColour = color(247,247,247, alphaCol); 
        
  a.getButtonPosY().update();   //update the tweetSet's interpolator (y pos of button)
  
  if(a.getRegularExpressionSymbol() == "*")
  {
    buttonColour = color(210,242,210, alphaCol);
    removeCircleColour = color(210,242,210, alphaCol);
    
  }

  
  // -------- If mouse is over remove box, process! --------
  
   if(  ( abs(mouseX - removeCirclePos.x) < 10) && (abs(mouseY - removeCirclePos.y) < 10) )
      {
        removeCircleColour = color(red(removeCircleColour) * 2.3, green(removeCircleColour) * 2.3, blue(removeCircleColour) * 2.3, 255 * 0.6 );    
        mouseOverRemoveBox = a.getId();
      }
   
  // -------- If mouse is over button in general, process! --------

    else if(  (mouseX > buttonPos.x) && (mouseX < buttonPos.x + buttonDim.x)   && (mouseY > buttonPos.y) && (mouseY < buttonPos.y + buttonDim.y)  )
        {
          buttonColour = color(red(buttonColour) * 1.05, green(buttonColour) * 1.05, blue(buttonColour) * 1.05, alphaCol );    
          removeCircleColour = color(red(removeCircleColour) * 1.05, green(removeCircleColour) * 1.05, blue(removeCircleColour) * 1.05, alphaCol );
          mouseOverBaseButton = a.getId();
        }
             
        
  // -------- Draw the button outline --------
  stroke(181, 184, 188, alphaCol);
  strokeWeight(1.5);
  fill(buttonColour);
  //rect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y);
  rrect(buttonPos.x, buttonPos.y, buttonDim.x, buttonDim.y, 10.0f, 2.4f, "");
  
  
  // -------- Draw the tweet box colour  --------
  
  stroke(150,150,150,alphaCol);
  strokeWeight(1);
  color tweetSetColour = a.getColour();
  fill(red(tweetSetColour), green(tweetSetColour), blue(tweetSetColour), alphaCol);
  rect(buttonPos.x + 8, buttonPos.y + 8, 11, 11);

  
  // -------- Draw the button text --------
  textAlign(LEFT, CENTER);
  fill(40,40,40, alphaCol);
  text(a.getSearchTerms(), buttonPos.x + 30, buttonPos.y + (buttonDim.y / 2.0));
  
  
  // ------- Draw the crossover percentage ----------
    
  if(a.getNumberOfCrossoverMatches() > 0)
  {
  float percentageMatch = (a.getNumberOfCrossoverMatches() / float(numberSelected)) * 100.0f;
  
  fill(100,100,100,alphaCol);
  text(nf(percentageMatch, 1, 1) + "%", buttonPos.x + buttonDim.x + 10, buttonPos.y + (buttonDim.y / 2.0));
  }
  
  // -------- Draw remove box --------
  
  stroke(220,220,200,alphaCol);
  
  strokeWeight(0);
  if(mouseOverRemoveBox == a.getId())  //if mouse over, add outline
      strokeWeight(1);


  fill(removeCircleColour);
  //rect(removeBoxPos.x, removeBoxPos.y, removeBoxDim.x, removeBoxDim.y);
  ellipse(removeCirclePos.x, removeCirclePos.y, removeCircleDim.x, removeCircleDim.y); 
  
  fill(0,0,0, alphaCol);
  text("x",  removeCirclePos.x - 4.0, removeCirclePos.y - 1.0);
    
  textAlign(LEFT, LEFT);
  }
  
  
  //reset for other draw functions
  strokeWeight(1);
  stroke(181, 184, 188);  
  
}
 

boolean isHeatmapViewActive(){
 return b_heatmapViewActive; 
}

boolean isPointsViewActive(){
 return b_pointsViewActive; 
} 
 
 
  
void processMouse()
{
  
  
// -------- If user clicked on options button, select --------  
  
  if(mouseOverPointsOptionButton) {
    b_pointsViewActive = true;
    b_heatmapViewActive = false;
  }
  
   if(mouseOverHeatmapOptionButton)
  {
    b_pointsViewActive = false;
    b_heatmapViewActive = true;
  }
  
  
    
  if(mouseOverRemoveBox >= 0) {
  println("Over remove box : " + mouseOverRemoveBox);  
    
  //loop through tweet sets, find the one that has id = mouseOverRemoveBox and remove it!
  for (TweetSet a: tweetSets)
    if(a.getId() == mouseOverRemoveBox) {
      tweetSets.remove(a);
      colours.add(a.getColour());
      reallocateIds();  //tweetSet has been removed, reallocate id's for correct button drawing
      break;
      }
  }
  else
    if(mouseOverBaseButton >= 0) {
      
     for (TweetSet a: tweetSets)
        if(a.getId() == mouseOverBaseButton) {
          a.setActive(!a.isActive());  //activate or de-activate tweetSet
          break;
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
 
int getMaxTweetSets()
{
 return maxTweetSets; 
}
 
 
ArrayList<TweetSet> getTweetSetList()
{
  return tweetSets;
}
 
 
  
}
