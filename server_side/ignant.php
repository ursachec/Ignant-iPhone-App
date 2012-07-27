<?php

require_once('feedKeys.php');
require_once('generalConstants.php');
require_once('JSONContentProxy.php');


//possible API commands
define('API_COMMAND_ERROR','error');


define('API_COMMAND_IS_SERVER_REACHABLE','isServerReachable');
define('API_KEY_IS_SERVER_REACHABLE','status');
define('API_RESPONSE_SERVER_OK','ok');
define('API_RESPONSE_SERVER_ERROR','error');

/* register for notifications */
define('API_COMMAND_FOR_NOTIFICATIONS','registerForNotifications');
define('API_KEY_DID_REGISTER_FOR_NOTIFICATIONS','didRegister');
define('API_KEY_REGISTER_FOR_NOTIFICATIONS_DEVICE_TOKEN','deviceToken');

/* possible API commands */
define('API_COMMAND_GET_DATA_FOR_FIRST_RUN','getDataForTheFirstRun');
define('API_COMMAND_GET_SINGLE_ARTICLE','getSingleArticle');
define('API_COMMAND_GET_MORE_ARTICLES_FOR_CATEGORY','getMoreArticlesForCategory');
define('API_COMMAND_GET_LATEST_ARTICLES_FOR_CATEGORY','getLatestArticlesForCategory');
define('API_COMMAND_GET_SET_OF_MOSAIC_IMAGES','getSetOfMosaicImages');
define('API_COMMAND_GET_MORE_TUMBLR_ARTICLES','getMoreTumblrArticles');
define('API_COMMAND_GET_LATEST_TUMBLR_ARTICLES','getLatestTumblrArticles');

define('API_COMMAND_TEST','test');

//-- general
define('GET_ACTION','action');
define('LANGUAGE_PARAM','lang');
define('DEFAULT_LANGUAGE','de');
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


function getContentLanguage($pLanguage)
{
	if(isset($pLanguage) && $pLanguage!='')
		return $pLanguage;
		
	return DEFAULT_LANGUAGE;
}

if(strcmp($apiCommand,API_COMMAND_IS_SERVER_REACHABLE)==0)
{
	//TODO: define when the server is defined as not reachable
	$finalJSONArrayForExport[API_KEY_IS_SERVER_REACHABLE] = API_RESPONSE_SERVER_OK;
}

else if(strcmp($apiCommand,API_COMMAND_FOR_NOTIFICATIONS)==0)
{
	$dTInDB = false;
	$pDeviceToken = $_GET[API_KEY_REGISTER_FOR_NOTIFICATIONS_DEVICE_TOKEN];
	
	
	if($pDeviceToken!='')
	{		
		$dTInDB = $contentProxy->saveDeviceToken($pDeviceToken, getContentLanguage($_GET[LANGUAGE_PARAM]));
		//if $dTInDB is TRUE, all is fine, otherwise an error has occured
	}
	
	if($dTInDB)
	{
		$finalJSONArrayForExport[API_KEY_DID_REGISTER_FOR_NOTIFICATIONS] = true;	
	}
	else
	{
		$finalJSONArrayForExport[API_KEY_DID_REGISTER_FOR_NOTIFICATIONS] = false;
	}
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
	$numberOfArticles = 40;
	$articlesForFirstRun = $contentProxy->tGetJSONReadyLatestArticlesForCategory(ID_FOR_HOME_CATEGORY, getContentLanguage($_GET[LANGUAGE_PARAM]), $numberOfArticles);
	$finalJSONArrayForExport[TL_ARTICLES] = $articlesForFirstRun;
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
		//sleep(4);
	
		//get the array with articles
		$numberOfArticles = 20;
		$arrayWithMorePosts = $contentProxy->tGetJSONReadyLatestArticlesForCategory($pCategoryId, getContentLanguage($_GET[LANGUAGE_PARAM]), $numberOfArticles);
	
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
	// sleep(4);
	
	//get the array with articles
	$arrayWithMorePosts = $contentProxy->tGetJSONReadyArrayForMorePosts($pCategoryId, $pDateOfOldestArticle, getContentLanguage($_GET[LANGUAGE_PARAM]));
	
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
	
	// $oneArticle = $contentProxy->getJSONReadyArrayForArticleWithId($pArticleID);
	$oneArticle = $contentProxy->tGetJSONReadyArrayForArticleWithId($pArticleID);

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
	
	//---------------------------------------------------------------------
	$moreMosaicPosts = array();	
	$moreMosaicPosts =	$contentProxy->tGetJSONReadyArrayForRandomMosaicEntries();

	
	if(!is_array($moreMosaicPosts) || count($moreMosaicPosts)<=0)
	{
		$finalJSONArrayForExport['no_article_found'] = 'YEPP';
	}
	else
	{
		$finalJSONArrayForExport[TL_MOSAIC_ENTRIES] = $moreMosaicPosts;
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

else if(strcmp($apiCommand,API_COMMAND_TEST)==0)
{
	
	$s = getIgnantCategoriesAsPDOString();
	print '<br />categories as string: |'.$s."| <br />";
	
}

else
{
	$finalJSONArrayForExport[TL_ERROR] = true;
	$finalJSONArrayForExport[TL_ERROR_MESSAGE] = 'unknown_api_command';	
}

//print out the arry
$jsonExportString = json_encode($finalJSONArrayForExport);	
print $jsonExportString;


function testGetArticles()
{
	global $contentProxy;
	$before = microtime(true);
	$articlesForFirstRun = $contentProxy->tGetJSONReadyLatestArticlesForCategory(ID_FOR_HOME_CATEGORY);
	$after = microtime(true);
	echo "<br />(totaltime:".($after-$before) . ")s<br />";
}

?>