<?php

require_once('feedKeys.php');
require_once('unittests.php');

$testingUnit = new LightArticlesTest();


class JSONContentProxy{
	
	//----------
	function getJSONReadyCategories()
	{
		global $testingUnit;
		
		$categoriesArray = array();
		
		$testCategories = array();
		$testCategories = $testingUnit->getAllCategories();
		if(is_array($testCategories) && count($testCategories)>0)
		foreach($testCategories as $oneCategory){
			$categoriesArray[] = $oneCategory->getArrayForJSONEncoding();
		};
		
		return $categoriesArray;
	}
	
	//----------
	function getJSONReadyArrayForArticleWithId($articleId = '')
	{
		global $testingUnit;
		$articleArray = $testingUnit->getJSONReadyArrayForArticleForId($articleId);
		return $articleArray;
	}
	
	//----------
	function getJSONReadyLatestArticlesForCategory($pCategoryId = '')
	{
		global $testingUnit;
		
		$articlesArray = array();
		$testArticles = $testingUnit->getLastestArticlesForCategory($pCategoryId);
		
		if(is_array($testArticles) && count($testArticles)>0)			
		foreach($testArticles as $oneArticle){
			
			$oneArticle->setIsForHomeCategory($pCategoryId);
			$articlesArray[] = $oneArticle->getArrayForJSONEncoding();
		};
		
		return $articlesArray;
	}
		
	//----------
	function getJSONReadyArrayForMorePosts($pCategoryId='', $pDateOfOldestArticle='0000-00-00' )
	{
		global $testingUnit;
		
		//TODO: check if category id exists
		
		$articlesArray = array();
		
		$testMorePostsForCategory = $testingUnit->getMoreArticlesForCategory($pCategoryId, $pDateOfOldestArticle);
		if(is_array($testMorePostsForCategory) && count($testMorePostsForCategory)>0)
		foreach($testMorePostsForCategory as $oneArticle){
			$oneArticle->setIsForHomeCategory($pCategoryId);
			$articlesArray[] = $oneArticle->getArrayForJSONEncoding();
		};
	
		return $articlesArray;
	}

	function getJSONReadyArrayForMoreTumblr($pTimestamp = 0, $limit = 10)
	{
		global $testingUnit;
		$moreTumblPostsArray = array();		
		$moreTumblPostsArray = $testingUnit->getMoreTumblrPosts($pTimestamp, $limit);
		return $moreTumblPostsArray;
	}
	
	function getJSONReadyArrayForLatestTumblr($limit = 20)
	{
		$responseFromTumblrApiArray = array();	
		$postProcessedResponseFromTumblrAPI = array();
			// http://api.tumblr.com/v2/blog/ignant.tumblr.com/posts?api_key=I5QACSezTzCjvkHXaiEaXrD3t9cb8Ahmpyv7MqGIRPhdEfg2Yw&limit=20
		//get the JSON from the Tumblr API
		$url = "http://api.tumblr.com/v2/blog/ignant.tumblr.com/posts?limit=100&api_key=I5QACSezTzCjvkHXaiEaXrD3t9cb8Ahmpyv7MqGIRPhdEfg2Yw";

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL,$url); // set url to post to
		curl_setopt($ch, CURLOPT_FAILONERROR, 1);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);// allow redirects
		curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
		curl_setopt($ch, CURLOPT_TIMEOUT, 3); // times out after 4s
		$result = curl_exec($ch); // run the whole process
		curl_close($ch);
		
		//extract the posts from the returned JSON
		$responseFromTumblrJSON = json_decode($result, true);
		$postsFromTumblrAPI = $responseFromTumblrJSON['response']['posts'];
		
		//filter the relevant information from the posts
		$filteredInformationPosts = array();
		
		if(is_array($postsFromTumblrAPI) && count($postsFromTumblrAPI)>0)
		foreach($postsFromTumblrAPI as $post){
			$newPost = array();
			$newPost[TUMBLR_POST_PUBLISHING_DATE] = $post['timestamp'];
			$newPost[TUMBLR_POST_IMAGE_URL] = $post['photos'][0]["alt_sizes"][2]["url"];
			$filteredInformationPosts[] = $newPost;	
		}
		
		//filter the posts to get after lastTumblrPosts
		$numberOfPostsToReturn = 0;
		
		if(is_array($filteredInformationPosts) && count($filteredInformationPosts)>0)
		foreach($filteredInformationPosts as $post){
			
			if($numberOfPostsToReturn>$limit)
			break;
			
			//jump over articles that are newer than $pTimestampOfLastPost
			if($pTimestampOfLastTumblrPost!=0 && $post[TUMBLR_POST_PUBLISHING_DATE]>$pTimestampOfLastTumblrPost)
			continue;
			
			//add post to the return array
			$postProcessedResponseFromTumblrAPI[] = $post;
			$numberOfPostsToReturn++;
		}
		
		$returnArray = $postProcessedResponseFromTumblrAPI;
		return $returnArray;
	}
		
};

?>