<?php

require_once('feedKeys.php');
require_once('JSONContentProxy.php');

//possible API commands
define('API_COMMAND_ERROR','error');


define('API_COMMAND_IS_SERVER_REACHABLE','isServerReachable');
define('API_KEY_IS_SERVER_REACHABLE','status');
define('API_RESPONSE_SERVER_OK','ok');
define('API_RESPONSE_SERVER_ERROR','error');

define('API_COMMAND_GET_DATA_FOR_FIRST_RUN','getDataForTheFirstRun');
define('API_COMMAND_GET_SINGLE_ARTICLE','getSingleArticle');
define('API_COMMAND_GET_MORE_ARTICLES_FOR_CATEGORY','getMoreArticlesForCategory');
define('API_COMMAND_GET_LATEST_ARTICLES_FOR_CATEGORY','getLatestArticlesForCategory');
define('API_COMMAND_GET_SET_OF_MOSAIC_IMAGES','getSetOfMosaicImages');
define('API_COMMAND_GET_MORE_TUMBLR_ARTICLES','getMoreTumblrArticles');
define('API_COMMAND_GET_LATEST_TUMBLR_ARTICLES','getLatestTumblrArticles');


//-- general
define('GET_ACTION','action');
define('CURRENT_CATEGORY_ID','categoryId');
define('NUMBER_OF_RESULTS_TO_BE_RETURNED','numberOfResultsToReturn');
define('ARTICLE_ID','articleId');

//-- search
define('SEARCH_QUERY','query');
define('SEARCH_OFFSET','searchOffset');

//-- article list updates
define('DATE_OF_NEWEST_ARTICLE','dateOfNewestArticle');
define('DATE_OF_OLDEST_ARTICLE','dateOfOldestArticle');



//--------------------------
$finalJSONArrayForExport = array();

$contentProxy = new JSONContentProxy();

$apiCommand = $_GET[GET_ACTION];


if(strcmp($apiCommand,API_COMMAND_IS_SERVER_REACHABLE)==0)
{
	//TODO: define when the server is defined as not reachable
	$finalJSONArrayForExport[API_KEY_IS_SERVER_REACHABLE] = API_RESPONSE_SERVER_OK;
}
//in case error happens, return it to the user!
// $finalJSONArrayForExport[TL_ERROR] = YES;
// $finalJSONArrayForExport[TL_ERROR_MESSAGE] = 'unknown_api_command';

//this is combined data from more commands
//that should be returned the first time a user opens the app
else if(strcmp($apiCommand,API_COMMAND_GET_DATA_FOR_FIRST_RUN)==0)
{
	$categoriesList = array();
	$articlesForFirstRun = array();
	
	//1. get categories list
	$categoriesList = $contentProxy->getJSONReadyCategories();
	$finalJSONArrayForExport[TL_META_INFORMATION][TL_CATEGORIES_LIST] = $categoriesList;
		
	//2. get latest articles
	$articlesForFirstRun = $contentProxy->getJSONReadyLatestArticlesForCategory(ID_FOR_HOME_CATEGORY);
	$finalJSONArrayForExport[TL_ARTICLES] = $articlesForFirstRun;
	
	$finalJSONArrayForExport['temp_command'] = 'API_COMMAND_GET_DATA_FOR_FIRST_RUN';
	
}


//this is called when the user wants to get more articles
//of a specific category, home being -1

/*			
- get updated articles 
	- PARAMS:
		- NAME: category_id / VALUE: (int) or (string) with Category id, "home" for home articles 
		- NAME: pDateOfOldestArticle / VALUE: (dateformat TBD)
		- NAME: numberOFResultsToBeReturned  / VALUE: (int) number of articles to be returned
*/

else if(strcmp($apiCommand,API_COMMAND_GET_LATEST_ARTICLES_FOR_CATEGORY)==0)
{
	$arrayWithMorePosts = array();
	
	if(isset($_GET[CURRENT_CATEGORY_ID]))
	{
		//input parameters
		$pCategoryId = $_GET[CURRENT_CATEGORY_ID];
	
		//optional parameters
		$pNumberOfResultsToBeReturned = $_GET[NUMBER_OF_RESULTS_TO_BE_RETURNED];
	
		//---------------------------------------------------------------------	
		// sleep(1);
	
		//get the array with articles
		$arrayWithMorePosts = $contentProxy->getJSONReadyLatestArticlesForCategory($pCategoryId, $pDateOfOldestArticle);
	
		// no articles found, do something
		if(count($arrayWithMorePosts)==0)
		{
			$finalJSONArrayForExport['no_more_posts'] = true;
		}
		else
		{
			$finalJSONArrayForExport[TL_ARTICLES] = $arrayWithMorePosts;
			$finalJSONArrayForExport[TL_META_INFORMATION][TL_OVERWRITE] = true;
		}	
	}
	else
	{
		
		$finalJSONArrayForExport['error_description'] = 'category_id_not_set';
	}
	
}

//this is called when the user wants to get more articles
//of a specific category, home being -1

/*			
- get updated articles 
	- PARAMS:
		- NAME: category_id / VALUE: (int) or (string) with Category id, "home" for home articles 
		- NAME: pDateOfOldestArticle / VALUE: (dateformat TBD)
		- NAME: numberOFResultsToBeReturned  / VALUE: (int) number of articles to be returned
*/

else if(strcmp($apiCommand,API_COMMAND_GET_MORE_ARTICLES_FOR_CATEGORY)==0)
{
	//input parameters
	$pCategoryId = $_GET[CURRENT_CATEGORY_ID];
	$pDateOfOldestArticle = $_GET[DATE_OF_OLDEST_ARTICLE];
	
	//optional parameters
	$pNumberOfResultsToBeReturned = $_GET[NUMBER_OF_RESULTS_TO_BE_RETURNED];
	
	//---------------------------------------------------------------------	
	sleep(1);
	
	//get the array with articles
	$arrayWithMorePosts = $contentProxy->getJSONReadyArrayForMorePosts($pCategoryId, $pDateOfOldestArticle);
	
	// no articles found, do something
	if(count($arrayWithMorePosts)==0)
	{
		$finalJSONArrayForExport['no_more_articles'] = true;
	}
	else
	{
		$finalJSONArrayForExport[TL_ARTICLES] = $arrayWithMorePosts;
		$finalJSONArrayForExport[TL_META_INFORMATION][TL_OVERWRITE] = true;
	}	
}


//this is called mostly when a related article has been tapped on
/*
- load one article (used when browsing in the related articles section)
	- PARAMS:
		- NAME: article_id / VALUE: (int) or (string) with the article id
*/

else if(strcmp($apiCommand,API_COMMAND_GET_SINGLE_ARTICLE)==0)
{
	//input parameters
	$pArticleID = $_GET[ARTICLE_ID];
	
	//---------------------------------------------------------------------
	//article found
	$oneArticle = null;
	
	$oneArticle = $contentProxy->getJSONReadyArrayForArticleWithId($pArticleID);
	
	
	$finalJSONArrayForExport['temp_command'] = 'API_COMMAND_GET_SINGLE_ARTICLE';

	if($oneArticle==null)
	{
		
		$finalJSONArrayForExport['no_article_found'] = 'YEPP';
	}
	else
	{
		$finalJSONArrayForExport[TL_SINGLE_ARTICLE] = $oneArticle;
	}
}
else if(strcmp($apiCommand,API_COMMAND_GET_SET_OF_MOSAIC_IMAGES)==0)
{
	//input parameters
	$pArticleID = $_GET[ARTICLE_ID];
	
	//---------------------------------------------------------------------

	// $finalJSONArrayForExport[TL_META_INFORMATION][TL_OVERWRITE] = true;
	// $finalJSONArrayForExport[TL_ERROR] = true;
	// $finalJSONArrayForExport[TL_ERROR_MESSAGE] = 'invalid_article_id';
	
	//make sure articleId properly escapes characters, and so on
	
	sleep(1);
	
	//article found
	$oneArticle = null;
	$oneArticle = $contentProxy->getJSONReadyArrayForArticleWithId($pArticleID);
	
	$finalJSONArrayForExport['temp_command'] = 'API_COMMAND_GET_SET_OF_MOSAIC_IMAGES';

	if($oneArticle==null)
	{
		
		$finalJSONArrayForExport['no_article_found'] = 'YEPP';
	}
	else
	{
		$finalJSONArrayForExport[TL_SINGLE_ARTICLE] = $oneArticle;
	}
}

else if(strcmp($apiCommand,API_COMMAND_GET_MORE_TUMBLR_ARTICLES)==0)
{
	//input parameters
	$pTimestamp = $_GET[DATE_OF_OLDEST_ARTICLE];
		
	//---------------------------------------------------------------------
	$moreTumblrPosts = array();	
	$moreTumblrPosts =	$contentProxy->getJSONReadyArrayForMoreTumblr($pTimestamp,10);
	
	if(!is_array($moreTumblrPosts) || count($moreTumblrPosts)<=0)
	{
		$finalJSONArrayForExport['no_article_found'] = 'YEPP';
	}
	else
	{
		$finalJSONArrayForExport[TL_POSTS] = $moreTumblrPosts;
	}
}

/**
 * get the latest 20 articles and return them to the app
 * the app should then compare the latest saved posts and add the ones that are newer
 */
else if(strcmp($apiCommand,API_COMMAND_GET_LATEST_TUMBLR_ARTICLES)==0)
{	
	$latestTumblrPosts = array();
	$latestTumblrPosts = $contentProxy->getJSONReadyArrayForLatestTumblr();
	
	if(!is_array($latestTumblrPosts) || count($latestTumblrPosts)==0)
	{
		$finalJSONArrayForExport['no_article_found'] = 'YEPP';
	}
	else
	{
		$finalJSONArrayForExport[TL_POSTS] = $latestTumblrPosts;
	}
}


else
{
	$finalJSONArrayForExport[TL_ERROR] = true;
	$finalJSONArrayForExport[TL_ERROR_MESSAGE] = 'unknown_api_command';	
}

//print out the arry
$jsonExportString = json_encode($finalJSONArrayForExport);	
print $jsonExportString;

?>