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

function newPDOConnection(){
	return new PDO("mysql:host=".MYSQL_DB_SERVER.";dbname=".MYSQL_DB_NAME, MYSQL_USER, MYSQL_PASS);
}

function getThumbLinkForArticleId($articleId = '')
{
	$baseLink = 'http://www.ignant.de/wp-content/uploads/';
	$s = '%pre%';
	
	$con = mysql_connect(MYSQL_DB_SERVER, MYSQL_USER, MYSQL_PASS);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}

	$db_selected = mysql_select_db(MYSQL_DB_NAME, $con);
	if (!$db_selected) {
	    die ('Could not select DB : ' . mysql_error());
	}
	
	$query = sprintf("SELECT wp_posts.guid AS 'img_url' FROM wp_posts WHERE post_type = 'attachment' AND post_parent = %d AND post_title LIKE '%s' LIMIT 1;", (int)$articleId, $s);
	
	$res = mysql_query($query);
	if (!$res) {
	    $message  = 'Ungültige Abfrage: ' . mysql_error() . "\n";
	    $message .= 'Gesamte Abfrage: ' . $query;
	    die($message);
	}
	
	// print "<br />".$query."<br />";
	
	$meta = mysql_fetch_assoc($res);
	if($meta==false)
		return '';
	
	$imgUrl = $meta['img_url'];
	
	
	mysql_free_result($res);
	mysql_close($con);
	
	return $imgUrl;
}


function fetchLatestArticlesForCategory($category = ID_FOR_HOME_CATEGORY)
{		
	$posts = array();
	
	$con = mysql_connect(MYSQL_DB_SERVER, MYSQL_USER, MYSQL_PASS);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}

	$db_selected = mysql_select_db(MYSQL_DB_NAME, $con);
	if (!$db_selected) {
	    die ('Could not select DB : ' . mysql_error());
	}
	
	if($category==ID_FOR_HOME_CATEGORY){
		$query = sprintf("SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name' 
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		WHERE pt.`post_status` = 'publish'
		ORDER BY pt.`post_date` DESC LIMIT 10;");
	}
	else
	{
		$query = sprintf("SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name' 
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		WHERE pt.`post_status` = 'publish' 
		AND tr.`term_taxonomy_id` = %d 
		ORDER BY pt.`post_date` DESC LIMIT 10;", (int)$category);
	}
	
	// print "<br />Query: ".$query."<br />";
	
	$res = mysql_query($query);
	if (!$res) {
	    $message  = 'Ungültige Abfrage: ' . mysql_error() . "\n";
	    $message .= 'Gesamte Abfrage: ' . $query;
	    die($message);
	}
	
	while($p = mysql_fetch_assoc($res))
	{
		$posts[] = $p;
	}
	
	mysql_free_result($res);
	mysql_close($con);
	
	return $posts;
}


function getLatestArticlesForCategory($cat = 0, $lang = 'de')
{
	
	$lightArticles = array();
	$posts = fetchLatestArticlesForCategory($cat);
	foreach($posts as $p){

		$postId = $p['id'];
		$postTitle =  utf8_encode(textForLanguage($p['post_title'], $lang));
		$postDate = strtotime($p['post_date_gmt']);
		$postDescription = 'Description for this article'; //textForLanguage($p['post_content'], $lang);
		$postTemplate = 'default';
		$postRemoteImages = fetchRemoteImagesForArticleID($postId);
		$postRelatedArticles = fetchRelatedArticlesForArticleID($postId);
		$postCategory = new Category($p['category_id'], $p['category_name'],'');
		$postUrl = 'http://www.google.de';
		
		if(strlen($postTitle) == 0)
		{
			// print "post title".$p['post_title']."<br />";
			
			continue;
			
		}
		else
		{
			// print "post title".$postTitle."<br />";
			
		}
				
		$lightArticles[] = new LightArticle($postId, $postTitle, $postDate, null, null, $postDescription, $postTemplate, $postRemoteImages, $postRelatedArticles, $postCategory, $postUrl); 
		
	}
	
	return $lightArticles;
}


function getMoreArticlesForCategory($pCategoryId, $pDateOfOldestArticle)
{
	
	
	
}

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
		$remoteImagesArray[] = new RemoteImage($articleId.'_'.$counter,$iUrl, '');
	}
	
	$dbh = null;
	
	return $remoteImagesArray;
}

function fetchRelatedArticlesForArticleID($articleId = '')
{
	$relatedArticles = array();
			
	return $relatedArticles;
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

?>