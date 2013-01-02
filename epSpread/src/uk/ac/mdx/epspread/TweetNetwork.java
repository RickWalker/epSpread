package uk.ac.mdx.epspread;
class TweetNetwork {

	Integer userId;
	TweetSet tweetSet;

	TweetNetwork(Integer _userId, TwitterFilteringComponent parent,
			TwitterFiltering gp) {

		userId = _userId;
		tweetSet = new TweetSet("", 0, "", parent, gp);
	}

	Integer getUserId() {
		return userId;
	}

	void setUserId(Integer _id) {
		userId = _id;
	}

	TweetSet getTweetSet() {
		return tweetSet;
	}
}
