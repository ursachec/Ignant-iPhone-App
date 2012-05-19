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
		foreach($testingUnit->getAllCategories() as $oneCategory){
			$categoriesArray[] = $oneCategory->getArrayForJSONEncoding();
		};
		return $categoriesArray;
	}
	
	//----------
	function getJSONReadyArrayForArticleWithId($articleId = '')
	{
		
		global $testingUnit;
		
		//TODO: check if category id exists
		//TODO: no article id, return that
		
		$articleArray = $testingUnit->getJSONReadyArrayForArticleForId($articleId);
		
		return $articleArray;
	}
	
	//----------
	function getJSONReadyLatestArticlesForCategory($pCategoryId = '')
	{
		global $testingUnit;
		
		$articlesArray = array();
		foreach($testingUnit->getLastestArticlesForCategory() as $oneArticle){
			$articlesArray[] = $oneArticle->getArrayForJSONEncoding();
		};
		
		return $articlesArray;
	}
	
	
	//----------
	function getJSONReadyArrayForMorePosts($pCategoryId='', $pDateOfOldestArticle='0000-00-00' )
	{
		
		$pCategoryId = $_GET[CATEGORY_ID];
		$pDateOfOldestArticle = $_GET[DATE_OF_OLDEST_ARTICLE];
		
		
		//TODO: check if category id exists
		
		
		//TODO: no more articles found, return this result
		
	
		$returnArray = array('what?'=>'morePosts');
		return $returnArray;
	}

	function getJSONReadyArrayForMoreTumblr($pTimestampOfLastTumblrPost = 0, $limit = 10)
	{
		$responseFromTumblrApiArray = array();	
		$postProcessedResponseFromTumblrAPI = array();
		
		//get the JSON from the Tumblr API
		$url = "http://api.tumblr.com/v2/blog/ignant.tumblr.com/posts?api_key=I5QACSezTzCjvkHXaiEaXrD3t9cb8Ahmpyv7MqGIRPhdEfg2Yw";

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
		foreach($postsFromTumblrAPI as $post){
			$newPost = array();
			$newPost[TUMBLR_POST_PUBLISHING_DATE] = $post['timestamp'];
			$newPost[TUMBLR_POST_IMAGE_URL] = $post['photos'][0]["alt_sizes"][2]["url"];
			$filteredInformationPosts[] = $newPost;	
		}
		
		//filter the posts to get after lastTumblrPosts
		$numberOfPostsToReturn = 0;
		foreach($filteredInformationPosts as $post){
			
			if($numberOfPostsToReturn>$limit)
			break;
			
			//jump over articles that are newer than $pTimestampOfLastPost
			if($pTimestampOfLastTumblrPost!=0 && $post['timestamp']>$pTimestampOfLastTumblrPost)
			continue;
			
			//add post to the return array
			$postProcessedResponseFromTumblrAPI[] = $post;
			$numberOfPostsToReturn++;
		}
		
		$returnArray = $postProcessedResponseFromTumblrAPI;
		return $returnArray;
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
		foreach($postsFromTumblrAPI as $post){
			$newPost = array();
			$newPost[TUMBLR_POST_PUBLISHING_DATE] = $post['timestamp'];
			$newPost[TUMBLR_POST_IMAGE_URL] = $post['photos'][0]["alt_sizes"][2]["url"];
			$filteredInformationPosts[] = $newPost;	
		}
		
		//filter the posts to get after lastTumblrPosts
		$numberOfPostsToReturn = 0;
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