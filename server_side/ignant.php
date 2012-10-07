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
define('API_COMMAND_SHOULD_RELOAD_FIRST_RUN_DATA','getShouldReloadDataForTheFirstRun');
define('API_COMMAND_APP_STORE_LINK','asl');

define('API_COMMAND_TEST','test');

//-- general
define('GET_ACTION','action');
define('LANGUAGE_PARAM','lang');
define('DEFAULT_LANGUAGE','en');
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
$acceptedLanguages = array('de','en');

function getCategories()
{
	global $contentProxy;
	return $contentProxy->getJSONReadyCategories();
}

function getContentLanguage($pLanguage)
{
	global $acceptedLanguages;
	if(isset($pLanguage) && $pLanguage!='' && in_array($pLanguage, $acceptedLanguages)){
		return $pLanguage;
	}	
	
	return DEFAULT_LANGUAGE;
}


//set the right HTTP headers
header('Content-Type: application/json');


//handling API calls
if(strcmp($apiCommand,API_COMMAND_IS_SERVER_REACHABLE)==0)
{
	//TODO: define when the server is defined as not reachable
	$finalJSONArrayForExport[API_KEY_IS_SERVER_REACHABLE] = API_RESPONSE_SERVER_OK;
}

else if(strcmp($apiCommand,API_COMMAND_APP_STORE_LINK)==0)
{
	
	//header('Location: itms-apps://ax.itunes.apple.com/app/instapaper/id288545208?mt=8');
	header('Location: itms-apps://ax.itunes.apple.com/app/ignant/id500183975?ls=1&mt=8');
	
	//TODO: define when the server is defined as not reachable
	//$finalJSONArrayForExport[API_KEY_IS_SERVER_REACHABLE] = API_RESPONSE_SERVER_OK;
	
	exit;
}

else if(strcmp($apiCommand, API_COMMAND_SHOULD_RELOAD_FIRST_RUN_DATA)==0)
{
	//TODO: update date before uploading
	$referenceAPIUpdate = mktime(0, 0, 0, 10, 7, 2012);
	$lastFetch = $_GET[TL_LAST_FIRST_DATA_FETCH];

	$shouldReload = false;
	if ($referenceAPIUpdate!=0 && $lastFetch<$referenceAPIUpdate) {
		$shouldReload = true;
	}

	$finalJSONArrayForExport[TL_SHOULD_FETCH_FIRST_DATA] = $shouldReload;
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
	
	$finalJSONArrayForExport[API_KEY_DID_REGISTER_FOR_NOTIFICATIONS] = $dTInDB;	

}

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
			$finalJSONArrayForExport[TL_NO_POSTS] = true;
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
		$finalJSONArrayForExport[TL_NO_POSTS] = true;
	}
	else
	{
		$finalJSONArrayForExport[TL_ARTICLES] = $arrayWithMorePosts;
		$finalJSONArrayForExport[TL_META_INFORMATION][TL_OVERWRITE] = true;
	}	
}

else if(strcmp($apiCommand,API_COMMAND_GET_SINGLE_ARTICLE)==0)
{
	//input parameters
	$pArticleID = $_GET[ARTICLE_ID];
	
	//---------------------------------------------------------------------
	//article found
	$oneArticle = null;
	
	// $oneArticle = $contentProxy->getJSONReadyArrayForArticleWithId($pArticleID);
	$oneArticle = $contentProxy->tGetJSONReadyArrayForArticleWithId($pArticleID, getContentLanguage($_GET[LANGUAGE_PARAM]));

	if($oneArticle==null)
	{
		
		$finalJSONArrayForExport[TL_NO_POSTS] = true;
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
		$finalJSONArrayForExport[TL_NO_POSTS] = true;
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
		$finalJSONArrayForExport[TL_NO_POSTS] = true;
	}
	else
	{
		$finalJSONArrayForExport[TL_POSTS] = $moreTumblrPosts;
	}
}

else if(strcmp($apiCommand,API_COMMAND_GET_LATEST_TUMBLR_ARTICLES)==0)
{	
	$latestTumblrPosts = array();
	$latestTumblrPosts = $contentProxy->getJSONReadyArrayForLatestTumblr();
	
	if(!is_array($latestTumblrPosts) || count($latestTumblrPosts)==0)
	{
		$finalJSONArrayForExport[TL_NO_POSTS] = true;
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

?>