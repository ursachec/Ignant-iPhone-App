<?php

require_once('feedKeys.php');
require_once('unittests.php');

$testingUnit = new LightArticlesTest();


class JSONContentProxy{
	
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
	function getJSONReadyArrayForFirstRun()
	{
		//TODO: return categories list
		
		//TODO: return moreposts for first run
	
		$returnArray = array('what?'=>'firstRun');
		return $returnArray;
	
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

		
};

?>