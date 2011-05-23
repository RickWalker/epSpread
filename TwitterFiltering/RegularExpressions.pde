





boolean matchesRegularExpression(String _theText, String _RESymbol)
{
String[] symptomsDict = {"fatigue", "vomit", "vomitting", "flu", "the flu", "cold", "headache", "a headache", "fever", "chills", "breathing", "cough", "coughing", "a dry cough", "nausea", "diarrhea", "sweats", "the sweats", "ache", "stomach ache", "throwing up", "coughing up", "bleeding", "back pain", "abdomen pain", "ab pain", "chest pain"};
String[] adjectivesDict = {"bad", "horrible", "nasty", "terrible", "terible", "annoying", "attrocious", "painful", "severe", "extremely painful"};  // how would I get this to be an optional extra?

//Build regular expressions
String symptomString = createREMatchString(symptomsDict);
String adjectiveString = createREMatchString(adjectivesDict);  //not used
String optionalAdjectives = "(" + adjectiveString + "\\s)?";

String regularExpression = "(just got|trouble|have been|these|case of the|caught|caught a|with the a|getting a|has a|has|have|caught a|I have a|I have|I cought a|I got a|I am|this|come down with a|come down with|come down with a|difficulty|difficult to)\\s" + optionalAdjectives + symptomString + "\\s*";    


boolean found = PerformPatternMatch(_theText, regularExpression);
  
  if(found)
   return true;
 else
   return false;
 
}




// --------- Takes a list of words and returns a string of them seperated by '|' -------------
String createREMatchString(String[] theList)
{
  String resultString = "(";
  
 for(int j=0; j<theList.length; j++){
 if(j<theList.length-1)
   resultString += theList[j] + "|";
 else
   resultString += theList[j];
}

  resultString += ")";
  
  return resultString;
}



boolean PerformPatternMatch(String theText, String re)
{
  
  //Do some natural language processing!   
final int flags = Pattern.CASE_INSENSITIVE;
Pattern pattern = Pattern.compile(re, flags);
Matcher matcher =  pattern.matcher(theText);  

while (matcher.find()) {
  return true;
  }

return false;  
}
