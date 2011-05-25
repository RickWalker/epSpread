class TweetNetwork{
  
Integer userId;
TweetSet tweetSet;
  
TweetNetwork(Integer _userId){

userId = _userId;  
tweetSet = new TweetSet("", color(0,0,0), "");
}  
  
  
Integer getUserId(){
return userId;
}  
  
void setUserId(Integer _id) {
userId = _id;
} 

TweetSet getTweetSet(){
return tweetSet;
}  
  
  
}
