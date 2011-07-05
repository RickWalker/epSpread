/*
 * Copyright 2007 Yusuke Yamamoto
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;


ConfigurationBuilder cb = new ConfigurationBuilder();
cb.setDebugEnabled(true)
  .setOAuthConsumerKey("YukNm11Flwf24JXvDnsKWg")
  .setOAuthConsumerSecret("8MLtfdY3Kae2gdM8gP9BfkhsTaFYyk3Oe9dyxk6tEA")
  .setOAuthAccessToken("15186962-AFo9FZVMekYzOmteRK2rQ8XRjINDZWcR4K6pTGMJ0")
  .setOAuthAccessTokenSecret("uC1ABlqyBDnj0fZEAMsrNusfxUMzQMEzoKtdJps8w");
  
TwitterFactory tf = new TwitterFactory(cb.build());
Twitter twitter = tf.getInstance();

try { 
    List<Status> statuses = twitter.getFriendsTimeline();
    System.out.println("Showing friends timeline.");
    for (Status status : statuses) {
        println(status.getUser().getName() + ":" + status.getText());
    }
}
catch (TwitterException e) {
  println(e.getStatusCode());
}
