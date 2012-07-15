<?php
/*
require_once('../../feedKeys.php');

require_once('../../classes/IgnantInterfaces.php');
require_once('../../classes/IgnantObject.php');
require_once('../../classes/LightArticle.php');
require_once('../../classes/RelatedArticle.php');
require_once('../../classes/Article.php');
require_once('../../classes/BasicImage.php');
require_once('../../classes/Base64Image.php');
require_once('../../classes/RemoteImage.php');
require_once('../../classes/MixedImage.php');
require_once('../../classes/Template.php');
require_once('../../classes/Category.php');
require_once('../../classes/MosaicEntry.php');

require_once('../../wp_config.inc.php');
*/

function getThumbLinkForArticleId($articleId = '')
{
	$baseLink = 'http://www.ignant.de/wp-content/uploads/';
	
	$dbh = newPDOConnection();
	
	$qString = "SELECT wp_postmeta.`meta_value` AS 'img_url' FROM wp_postmeta WHERE wp_postmeta.`post_id` = (SELECT meta_value FROM wp_postmeta AS pm WHERE pm.`meta_key`='_thumbnail_id' AND pm.`post_id`=:pId ) AND wp_postmeta.`meta_key` = '_wp_attached_file' LIMIT 1;";
	
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':pId', $articleId, PDO::PARAM_INT);

	$stmt->execute();
	$p = $stmt->fetch(PDO::FETCH_ASSOC);
	
	$imgUrl = $baseLink.$p['img_url'];
	
	$dbh = null;
	
	return $imgUrl;
}

function getArticleWithId($articleId = '', $lang = 'de')
{
	$lightArticle = null;
	
	$p = fetchArticleWithId($articleId);
	$relatedArticles = fetchRelatedArticlesForArticleID($articleId, 3);
	
	$postId = $p['id'];
	$postTitle =  utf8_encode(textForLanguage($p['post_title'], $lang));
	$postDate = strtotime($p['post_date_gmt']);
	$postDescription = utf8_encode(descriptionForLanguage($p['post_content'], $lang));

	$postRemoteImages = fetchRemoteImagesForArticleID($postId);
	$postRelatedArticles = array();
	$postRelatedArticles[] = $relatedArticles[0];
	$postRelatedArticles[] = $relatedArticles[1];
	$postRelatedArticles[] = $relatedArticles[2];
	
	$postCategory = new Category($p['category_id'], $p['category_name'],'');
	$postTemplate = getArticleTemplateForCategoryId($postCategory->id);
	$postUrl = 'http://www.google.de';

	 $lightArticle = new LightArticle($postId, $postTitle, $postDate, null, null, $postDescription, $postTemplate, 	$postRemoteImages, $postRelatedArticles, $postCategory, $postUrl); 
	
	return $lightArticle;
}

function fetchArticleWithId($articleId = 0, $dbh = null)
{
	$p = array();
	
	$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();
	

	$dbh = newPDOConnection();
	
	$qString = "SELECT 
	pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`post_content` AS 'post_content', 
	tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name' 
	FROM wp_posts AS pt 
	LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
	LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
	LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
	WHERE pt.`post_status` = 'publish'
	AND pt.`post_type` = 'post'
	AND pt.`post_parent` = 0
	AND pt.`id` = :pId
	AND tr.`term_taxonomy_id` IN (".$includedCategoriesPDOString.") LIMIT 1;";
	
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':pId', $articleId, PDO::PARAM_INT);

	$stmt->execute();
	$p = $stmt->fetch(PDO::FETCH_ASSOC);
	
	
	$dbh = null;
	
	return $p;
}

function fetchArticlesForCategory($category = ID_FOR_HOME_CATEGORY, $timeAfter = 0, $numberOfArticles = 10)
{	
	$debug_function = false;
	
	if($debug_function)
		print "<br />category: $category | timeAfter: $timeAfter<br />";
	
	$posts = array();	
	
	$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();
	
	$dateAfter = date('Y-m-d');
	if($timeAfter!=0)
		$dateAfter =  date('Y-m-d', $timeAfter);
	
	if($timeAfter<0)
		return $posts;
	
	$dbh = newPDOConnection();
	
	
	if($category==ID_FOR_HOME_CATEGORY)
	{	
		
		$qString = "SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name' 
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		WHERE pt.`post_status` = 'publish'
		AND pt.`post_type` = 'post'
		AND pt.`post_parent` = 0
		AND pt.`post_date` <= :aDate
		AND tr.`term_taxonomy_id` IN (".$includedCategoriesPDOString.")";
		
		$qString .= " ORDER BY pt.`post_date` DESC";	
		$qString .= " LIMIT ".$numberOfArticles;
		$qString .= ";";
		
		$stmt = $dbh->prepare($qString);
		$stmt->bindParam(':aDate', $dateAfter, PDO::PARAM_STR, 12);				
	}
	else
	{
		$qString = "SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name' 
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		WHERE pt.`post_status` = 'publish'
		AND pt.`post_parent` = 0
		AND pt.`post_type` = 'post' 
		AND tr.`term_taxonomy_id` = :id 
		AND pt.`post_date` <= :aDate
		AND tr.`term_taxonomy_id` IN (".$includedCategoriesPDOString.") ";
		
		$qString .= " ORDER BY pt.`post_date` DESC";
		$qString .= " LIMIT ".$numberOfArticles;
		$qString .= ";";
		
		$stmt = $dbh->prepare($qString);
		$stmt->bindParam(':id', $category, PDO::PARAM_INT);
		$stmt->bindParam(':aDate', $dateAfter, PDO::PARAM_STR, 12);
	}
	
	$stmt->execute();
	while($p = $stmt->fetch(PDO::FETCH_ASSOC))
	{
		$posts[] = $p;
	}
	
	$dbh = null;
	
	return $posts;
}


function getArticlesForCategory($cat = 0, $tOfOldestArticle = 0 , $lang = 'de', $numberOfArticles = 10)
{
	$lightArticles = array();
	
	$posts = fetchArticlesForCategory($cat, $tOfOldestArticle, $numberOfArticles);
	$relatedArticles = fetchRelatedArticlesForArticleID($postId, count($posts)*3);
	
	// $before = microtime(true);
	$i = 0;
	foreach($posts as $p){

		$postId = $p['id'];
		$postTitle =  utf8_encode(textForLanguage($p['post_title'], $lang));
		$postDate = strtotime($p['post_date_gmt']);
		$postDescription = utf8_encode(descriptionForLanguage($p['post_content'], $lang));

		$postRemoteImages = fetchRemoteImagesForArticleID($postId);
		$postRelatedArticles = array();
		$postRelatedArticles[] = $relatedArticles[$i];
		$postRelatedArticles[] = $relatedArticles[$i+1];
		$postRelatedArticles[] = $relatedArticles[$i+2];
		$i+=3;
		
		$postCategory = new Category($p['category_id'], $p['category_name'],'');
		$postTemplate = getArticleTemplateForCategoryId($postCategory->id);
		$postUrl = 'http://www.google.de';
		
		if(strlen($postTitle) == 0)
		{	
			continue;
		}
				
		 $lightArticles[] = new LightArticle($postId, $postTitle, $postDate, null, null, $postDescription, $postTemplate, $postRemoteImages, $postRelatedArticles, $postCategory, $postUrl); 
	}
	
	// $after = microtime(true);
	// echo "<br />".($after-$before) . " sec/foreach\n"."<br />";
	
	return $lightArticles;
}

//TODO: DO A BETTER JOB IDENTIFING THE main images!!!
function fetchRemoteImagesForArticleID($articleId = '')
{
	$remoteImagesArray = array();
	
	$id = (int)$articleId;
	$dbh = newPDOConnection();
	
	$stmt = $dbh->prepare("SELECT wp_posts.guid AS 'img_url' FROM wp_posts WHERE post_type = 'attachment' AND post_parent = :id LIMIT 20;");
	$stmt->bindParam(':id', $id, PDO::PARAM_INT);
	$stmt->execute();
	
	$images = $stmt->fetchAll();
	
	$counter = 0;
	foreach($images as $i)
	{
		$iUrl = $i['img_url'];
		if( strstr(basename($iUrl), 'pre')==false)
		{
			$remoteImagesArray[] = new RemoteImage($articleId.'_'.$counter,$iUrl, '');
		}
	}
	
	$dbh = null;
	
	return $remoteImagesArray;
}

function fetchRandomArticles($numberOfArticles = 3, $categoryId = ID_FOR_HOME_CATEGORY)
{
	$debug_function = false;
	
	if($debug_function)
		print "<br />category: $category | timeAfter: $timeAfter<br />";
	
	$posts = array();	
	$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();
	
	$dateAfter = '2010-1-1';
	$dbh = newPDOConnection();
	
	$qString = "SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name' 
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		WHERE pt.`post_status` = 'publish'
		AND pt.`post_type` = 'post'
		AND pt.`post_parent` = 0
		AND pt.`post_date` > ".$dateAfter."
		AND tt.`term_taxonomy_id` IN (".$includedCategoriesPDOString.")
		ORDER BY RAND() LIMIT ".$numberOfArticles.";";
	
	$stmt = $dbh->prepare($qString);		
	
	$stmt->execute();
	
	while($p = $stmt->fetch(PDO::FETCH_ASSOC))
	{
		$posts[] = $p;
	}
	
	$dbh = null;
	
	return $posts;
}

function fetchRelatedArticlesForArticleID($articleId = '', $numberOfArticles = 3)
{	
	$relatedArticlesArray = array();
	
	// return $relatedArticlesArray;
	
	//!!!!!!!!!!!!!!!!!!!!!!
	//TODO: add method to LightArticle: getRelatedArticle() !
	
	$posts = fetchRandomArticles($numberOfArticles);
	
	foreach($posts as $p){

		$postId = $p['id'];
		$postTitle =  utf8_encode(textForLanguage($p['post_title'], $lang));
		$postDate = strtotime($p['post_date_gmt']);
		$postCategory = new Category($p['category_id'], $p['category_name'],'');
		
		if(strlen($postTitle) == 0)
		{			
			continue;
		}
		
				
		$relatedArticlesArray[] = new RelatedArticle($postId, $postTitle,  $postDate, $postCategory, null);
	}
			
	return $relatedArticlesArray;
}


function textForLanguage($str, $lang)
{
	$results = array();
	$needle = "<!--";

	//check if there is a localization string present, if not, just return same string
	if( strstr($str, $needle)!==FALSE )
	{
		preg_match("/(<!--:$lang-->)([-_·a-zA-Z0-9 ]*)(<!--:-->)/", $str, $results);
		return $results[2];
	}
	else
	{
		return $str;
	}
}

function descriptionForLanguage($str, $language)
{
	$results = array();
	$moreResults = array();
	$needleEN = "<!--:en";
	$needleDE = "<!--:de";
	$needleMORE = "<!--more";
	$returnString = '';
	$moreReturnString = '';
	
	//check if there is a localization string present, if not, just return same string
	if( strstr($str, $needleEN)!==FALSE || strstr($str, $needleDE)!==FALSE )
	{		
		preg_match("/(<!--:$language-->)(.*)(<!--:-->)/ismU", $str, $results);
		$regMatch = $results[2];		
		$returnString = removeImgTags($regMatch);
		$returnString = nl2br($returnString);
		
		$moreString = preg_match("/(<!--more-->.*<!--:$language-->)(.*)(<!--:-->)/ismU", $str, $moreResults);
		$moreRegMatch = $moreResults[2];
		$moreReturnString = removeImgTags($moreRegMatch);
		$moreReturnString = nl2br($moreReturnString);
		
		return $returnString.$moreReturnString;
	}
	else
	{
		$str = removeImgTags($str);
		$str = nl2br($str);
		return $str;
	}
}
function removeImgTags($string)
{
	$str = "";
	$str = preg_replace('/<img.*<\/p>/si', "", $string);
	// $str = preg_replace('/<img.*>/i', "", $string);
	
	return $str;
}

?>