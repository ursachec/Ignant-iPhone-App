<?php
/*

//TODO: problem on mosaic ('got you need an internet connection for that' on the wrong time)
*/

// TL_RETURN_MOSAIC_IMAGE | TL_RETURN_RELATED_IMAGE | TL_RETURN_CATEGORY_IMAGE | TL_RETURN_DETAIL_IMAGE | TL_RETURN_SLIDESHOW_IMAGE


function getThumbLinkForPostIdAndType($postid=0, $type = null)
{
	global $GL_THUMB_FOLDERS;
	
	if($postid==0 || $type=='')
	{
		die("getThumbLinkForPostIdAndType post id or type not set\n");
		return;
	}
	
	$subFolder = '';
	$subFolder = $GL_THUMB_FOLDERS[$type];
	if(!$subFolder)
	{
		die("getThumbLinkForPostIdAndType unknown image type\n");		
	}
	
	$thumbImageSrc = ROOT_THUMB_FOLDER.$subFolder.$postid.'.'.THUMB_IMAGE_EXT;
		
	if(@fopen($thumbImageSrc,"r")==true)
	{
		return $thumbImageSrc;
	}	
	
	return null;
}


function getThumbLinkForSlideshowPostId($slideshowPostId = '', $imgType = '', $dbh = null)
{	
	if($dbh==null)
	{
		print("null database handler\n");
		return '';
	}
	
	$qString = "SELECT wp_posts.`guid` AS 'img_url' FROM wp_posts WHERE `wp_posts`.id=:pId AND `wp_posts`.post_type='attachment'  LIMIT 1;";
	
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':pId', $slideshowPostId, PDO::PARAM_INT);

	$stmt->execute();
	$p = $stmt->fetch(PDO::FETCH_ASSOC);
	
	if(!$p)
		return '';
	
	$thumbLink = getThumbLinkForPostIdAndType($slideshowPostId, $imgType);
	if($thumbLink)
		return $thumbLink;
	
	$imgUrl = utf8_encode($p['img_url']);
	
	return $imgUrl;
}

function getThumbLinkForMosaicId($mosaicPostId='', $dbh = null)
{
	if($dbh==null)
	{
		print("null database handler\n");
		return '';
	}
	
	$qString = "SELECT wm.`mosaic_post_id`, wm.`post_id`, wpm.`meta_key`, wpm.`meta_value` AS 'img_url' FROM 
		wp_posts_mosaic AS wm
		LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = wm.`mosaic_post_id`
		WHERE wm.`post_id` = :mpId
		AND wpm.`meta_key` = '_wp_attached_file' LIMIT 1";
	
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':mpId', $mosaicPostId, PDO::PARAM_INT);
	
	$stmt->execute();
	$p = $stmt->fetch(PDO::FETCH_ASSOC);
	
	if(!$p)
		return '';
		
	$mpid = $p['mosaic_post_id'];
	$pid = $p['post_id'];
	
	$thumbLink = getThumbLinkForPostIdAndType($pid, TL_RETURN_MOSAIC_IMAGE);
	if($thumbLink)
		return $thumbLink;
	
	$imgUrl = ROOT_IMAGE_FOLDER.$p['img_url'];
	
	return $imgUrl;
}

function getThumbLinkForArticleId($articleId = '', $imgType = '', $dbh = null)
{	
	if($dbh==null)
	{
		print("null database handler\n");
		return '';
	}
	
	$qString = "SELECT wp_postmeta.`meta_value` AS 'img_url' FROM wp_postmeta WHERE wp_postmeta.`post_id` = (SELECT meta_value FROM wp_postmeta AS pm WHERE pm.`meta_key`='_thumbnail_id' AND pm.`post_id`=:pId ) AND wp_postmeta.`meta_key` = '_wp_attached_file' LIMIT 1;";
	
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':pId', $articleId, PDO::PARAM_INT);

	$stmt->execute();
	$p = $stmt->fetch(PDO::FETCH_ASSOC);
	
	if(!$p)
		return '';
	
	$thumbLink = getThumbLinkForPostIdAndType($articleId, $imgType);
	if($thumbLink)
		return $thumbLink;
	
	$imgUrl = utf8_encode(ROOT_IMAGE_FOLDER.$p['img_url']);
	
	return $imgUrl;
}

function shouldIncludeImagesInHTMLForCategoryId($categoryId = -1)
{
	if ($categoryId==860) {
		return true;
	}
	return true;
}

function getArticleWithId($articleId = '', $lang = 'de')
{
	$lightArticle = null;
	
	$p = fetchArticleWithId($articleId);
	$relatedArticles = fetchRelatedArticlesForArticleID($articleId, 3, $lang);
	
	$postId = $p['id'];
	$postTitle =  utf8_encode(textForLanguage($p['post_title'], $lang));
	$postDate = strtotime($p['post_date_gmt']);

	$shouldIncludeImagesInHTML = shouldIncludeImagesInHTMLForCategoryId($p['category_id']);
	$postDescription = base64_encode(utf8_encode(cleanedDescriptionForLanguage($p['post_content'], $lang, $shouldIncludeImagesInHTML)));

	//post images
	//$remoteImagesForArticleDescription = getRemoteImagesForArticleDescription($postId, $p['post_content'], $lang);
	
	$remoteImagesForArticleDescription = fetchRemoteImagesIdsForArticleDescription($postId, $p['post_content'], $lang);
	
	//$postRemoteImages = fetchRemoteImagesForArticleID($postId);
	$postRemoteImages = $remoteImagesForArticleDescription;
	
	
	$postRelatedArticles = array();
	$postRelatedArticles[] = $relatedArticles[0];
	$postRelatedArticles[] = $relatedArticles[1];
	$postRelatedArticles[] = $relatedArticles[2];
	
	$postCategory = new Category($p['category_id'], $p['category_name'],'');
	$postTemplate = getArticleTemplateForCategoryId($postCategory->id);
	$postUrl = $p['post_url'];
	$postVideoEmbedCode = base64_encode(prepareVideoEmbedCode($p['video']));
	
	 $lightArticle = new LightArticle($postId, $postTitle, $postDate, null, null, $postDescription, $postTemplate, 	$postRemoteImages, $postRelatedArticles, $postCategory, $postUrl, $postVideoEmbedCode); 
	
	return $lightArticle;
}

function fetchArticleWithId($articleId = 0, $dbh = null)
{
	$p = array();
	
	$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();
	
	$dbh = newPDOConnection();
	
	$qString = "SELECT 
	pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`guid` AS 'post_url', pt.`post_content` AS 'post_content', 
	tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name', wpm.`meta_value` AS 'video'
	FROM wp_posts AS pt 
	LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
	LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
	LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
	LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = pt.`id` AND wpm.`meta_key` = 'video'
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

function fetchArticlesForCategory($category = ID_FOR_HOME_CATEGORY, $timeBefore = 0, $numberOfArticles = 10)
{	
	$debug_function = false;
	
	if($debug_function)
		print "<br />category: $category | timeAfter: $timeAfter<br />";
	
	$posts = array();	
	
	$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();
	
	$dateAfter = '';
	$defaultTime = mktime(0, 0, 0, date("m"), date("d")+1, date("y"));
	$dateBefore = date('Y-m-d', $defaultTime);
	if($timeBefore!=0)
		$dateBefore =  date('Y-m-d', $timeBefore);
	
	if($timeBefore<0)
		return $posts;
	
	$dbh = newPDOConnection();
	
	
	if($category==ID_FOR_HOME_CATEGORY)
	{	
		
		$qString = "SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`guid` AS 'post_url', pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name', wpm.`meta_value` AS 'video'
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = pt.`id` AND wpm.`meta_key` = 'video'
		LEFT JOIN wp_postmeta AS wpm2 ON wpm2.`post_id` = pt.`id` AND (wpm2.`meta_key` = 'nsfw' OR wpm2.`meta_key` = 'notmobile' )
		WHERE pt.`post_status` = 'publish'
		AND pt.`post_type` = 'post'
		AND pt.`post_parent` = 0
		AND pt.`post_date` <= :aDate
		AND pt.`post_date` > IF(tr.`term_taxonomy_id`=860,'".POSTS_DATE_AFTER_FOR_MONIFACTORY."','".POSTS_DATE_AFTER."')
		AND wpm2.`meta_value` IS NULL
		AND tr.`term_taxonomy_id` IN (".$includedCategoriesPDOString.")";
		
		$qString .= " ORDER BY pt.`post_date` DESC";	
		$qString .= " LIMIT ".$numberOfArticles;
		$qString .= ";";
		
		$stmt = $dbh->prepare($qString);
		$stmt->bindParam(':aDate', $dateBefore, PDO::PARAM_STR, 12);				
	}
	else
	{
		$qString = "SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`guid` AS 'post_url', pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name', wpm.`meta_value` AS 'video'
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = pt.`id` AND wpm.`meta_key` = 'video'
		LEFT JOIN wp_postmeta AS wpm2 ON wpm2.`post_id` = pt.`id` AND (wpm2.`meta_key` = 'nsfw' OR wpm2.`meta_key` = 'notmobile' )
		WHERE pt.`post_status` = 'publish'
		AND pt.`post_parent` = 0
		AND pt.`post_type` = 'post' 
		AND tr.`term_taxonomy_id` = :id 
		AND pt.`post_date` <= :aDate
		AND pt.`post_date` > IF(tr.`term_taxonomy_id`=860,'".POSTS_DATE_AFTER_FOR_MONIFACTORY."','".POSTS_DATE_AFTER."')
		AND wpm2.`meta_value` IS NULL
		AND tr.`term_taxonomy_id` IN (".$includedCategoriesPDOString.") ";
		
		$qString .= " ORDER BY pt.`post_date` DESC";
		$qString .= " LIMIT ".$numberOfArticles;
		$qString .= ";";
		
		$stmt = $dbh->prepare($qString);
		$stmt->bindParam(':id', $category, PDO::PARAM_INT);
		$stmt->bindParam(':aDate', $dateBefore, PDO::PARAM_STR, 12);
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
	$relatedArticles = fetchRelatedArticlesForArticleID($postId, count($posts)*3, $lang);
	
	$i = 0;
	foreach($posts as $p){

		$postId = $p['id'];
		$postTitle =  utf8_encode(textForLanguage($p['post_title'], $lang));
				
		$postDate = strtotime($p['post_date_gmt']);
		$shouldIncludeImagesInHTML = shouldIncludeImagesInHTMLForCategoryId($p['category_id']);	
		$postDescription = base64_encode(utf8_encode(cleanedDescriptionForLanguage($p['post_content'], $lang, $shouldIncludeImagesInHTML)));
			
		$remoteImagesForArticleDescription = fetchRemoteImagesIdsForArticleDescription($postId, $p['post_content'], $lang);
		$postRemoteImages = $remoteImagesForArticleDescription;
		
		$postRelatedArticles = array();
		$postRelatedArticles[] = $relatedArticles[$i];
		$postRelatedArticles[] = $relatedArticles[$i+1];
		$postRelatedArticles[] = $relatedArticles[$i+2];
		$i+=3;
		
		$postCategory = new Category($p['category_id'], $p['category_name'],'');
		$postTemplate = getArticleTemplateForCategoryId($postCategory->id);
		$postUrl = $p['post_url'];
					
		$postVideoEmbedCode = base64_encode(prepareVideoEmbedCode($p['video']));
		
		if(strlen($postTitle) == 0)
		{	
			continue;
		}
				
		 $lightArticles[] = new LightArticle($postId, $postTitle, $postDate, null, null, $postDescription, $postTemplate, $postRemoteImages, $postRelatedArticles, $postCategory, $postUrl, $postVideoEmbedCode); 
	}
	
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
	
	$dbh = newPDOConnection();
	
	$qString = "SELECT 
		pt.`post_name`, pt.`id`, pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`guid` AS 'post_url', pt.`post_content` AS 'post_content', 
		tr.`term_taxonomy_id` AS 'category_id', wt.`name` AS 'category_name', wpm.`meta_value` AS 'video'
		FROM wp_posts AS pt 
		LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
		LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
		LEFT JOIN wp_terms AS wt ON wt.`term_id` = tt.`term_id`
		LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = pt.`id` AND wpm.`meta_key` = 'video'
		LEFT JOIN wp_postmeta AS wpm2 ON wpm2.`post_id` = pt.`id` AND (wpm2.`meta_key` = 'nsfw' OR wpm2.`meta_key` = 'notmobile' )
		WHERE pt.`post_status` = 'publish'
		AND pt.`post_type` = 'post'
		AND pt.`post_parent` = 0
		AND pt.`post_date` > IF(tr.`term_taxonomy_id`=860,'".POSTS_DATE_AFTER_FOR_MONIFACTORY."','".POSTS_DATE_AFTER."')
		AND wpm2.`meta_value` IS NULL
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

function fetchRelatedArticlesForArticleID($articleId = '', $numberOfArticles = 3, $lang = 'en')
{	
	$relatedArticlesArray = array();
		
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

	if( strstr($str, $needle)!==FALSE )
	{
		//TODO: write a better regex, this is not good when article name includes a '<' character
		preg_match("/(<!--:$lang-->)([^<]*)(<!--:-->)/", $str, $results);		
		return $results[2];
	}
	
	return $str;
}

function cleanedDescriptionForLanguage($str, $language, $includeImages=false)
{
	$description = descriptionForLanguage($str, $language);
	
	$finalString = removeUnwantedHTML($description, $includeImages);
	$finalString = nl2br($finalString);
	
	return $finalString;
}

function descriptionForLanguage($str, $language)
{
	$results = array();
	$moreResults = array();
	$needleEN = "<!--:en";
	$needleDE = "<!--:de";
	$needleMORE = "<!--more";
	$moreString = "";
	$finalString = '';
	$returnString = '';
	$moreReturnString = '';
	
	$containsMoreString = false;
	$containsMoreString = (strstr($str, $needleMORE)!==FALSE);
	
	//check if there is a localization string present, if not, just return same string
	
	$finalMoreString = '';
	$finalPrefixString = '';
	
	//prepare the more string
	if( $containsMoreString )
	{		
		$mS = preg_match("/<!--more-->(.*)/is", $str, $moreResults);
		$moreString = $moreResults[1];	
		$finalMoreString = $moreString;
				
		if( strstr($moreString, $needleEN)!==FALSE || strstr($moreString, $needleDE)!==FALSE )
		{					
			preg_match("/(<!--:$language-->)(.*)(<!--:-->)/ismU", $moreString, $results);
			$finalMoreString = $results[2];			
		}
	}
	
	//prepare the prefix string
	if( strstr($str, $needleEN)!==FALSE || strstr($str, $needleDE)!==FALSE )
	{
		preg_match("/(<!--:$language-->)(.*)(<!--:-->)/ismU", $str, $results);
		$finalPrefixString = $results[2];
	}
	else if($containsMoreString)
	{
		$finalPrefixString = $str;
		
		preg_match("/^(.*)(<!--more-->.*$)/ismU", $str, $results);
		$finalPrefixString = $results[1];
	}
	else if(!$containsMoreString)
	{
		$finalPrefixString = $str;
	}
	
	$finalString = $finalPrefixString.$finalMoreString;
	
	return $finalString;
}

function fetchRemoteImagesIdsForArticleDescription($postId='', $articleDescription='', $language='de')
{
	if(strlen($postId)==0 || strlen($articleDescription)==0)
		return;
	
	$remoteImagesArray = array();
	
	$id = (int)$postId;
	$dbh = newPDOConnection();
	
	$query = "SELECT wp_posts.guid AS 'img_url', wp_posts.id AS 'img_post_id' FROM wp_posts WHERE post_type = 'attachment' AND post_parent = :id ";
	
	$imageLinks = getImageLinksForArticleDescription($articleDescription, $language);
	if(is_array($imageLinks) && count($imageLinks)>0)
	{
		$counter=0;
		foreach($imageLinks as $i)
		{
			if($counter>0)
				$linksQuerySubstring .= " OR ";
			
			$linksQuerySubstring .= " guid='".$i."' ";
		
			$counter++;
		}
		
		$query .= " AND ( ".$linksQuerySubstring." ) ";
	}
	
	
	$query .= " LIMIT 16;";
	
	$stmt = $dbh->prepare($query);
	$stmt->bindParam(':id', $id, PDO::PARAM_INT);
	$stmt->execute();
	
	$images = $stmt->fetchAll();
	
	$counter = 0;
	foreach($images as $i)
	{
		$iUrl = $i['img_url'];
		$iPostId = $i['img_post_id'];
		
		if( strstr(basename($iUrl), 'pre')==false)
		{
			$remoteImagesArray[] = new RemoteImage($postId.'_'.$counter,$iUrl, '',0,0,$iPostId);
		}
		$counter++;
	}
	
	$dbh = null;
	return $remoteImagesArray;
}

function getRemoteImagesForArticleDescription($postId='', $articleDescription='', $language='de')
{
	if(strlen($postId)==0 || strlen($articleDescription)==0)
		return;
		
	$postRemoteImages = array();
	$counter = 0;
	
	$imageLinks = getImageLinksForArticleDescription($articleDescription, $language);
	
	if(is_array($imageLinks) && count($imageLinks)>0)
	foreach($imageLinks as $i)
	{
		if( strstr(basename($i), 'pre')==false)
			$postRemoteImages[] = new RemoteImage($postId.'_'.$counter,$i, '');
		
		$counter++;
	}
	
	return $postRemoteImages;	
}

function getImageLinksForArticleDescription($articleDescription='', $language='de')
{
	if(strlen($articleDescription)==0)
		return; 
	
	$imageLinks = array();
	$desc = descriptionForLanguage($articleDescription, $language);
	preg_match_all("/<img.*[\/]?>[\n\r]*/i", $desc, $imgTags, PREG_SET_ORDER);
	foreach ($imgTags as $wert) {
		preg_match("/src=[\"\']([^\"\']*)[\"\']/", $wert[0], $results);	
		if(strlen($results[1])>0)
			$imageLinks[] = $results[1];
	}	
	
	return $imageLinks;
}

function removeUnwantedHTML($string, $includeImages=false)
{
	$s = $string;

	if (!$includeImages) {
		$s = removeImgTags($s);
	}
	
	$s = removeIframes($s);
	$s = removeLastParagraph($s);
	return $s;
}

function removeImgTags($string)
{
	$str = "";
	$str = preg_replace('/<img.*[\/]?>[\n\r]*/i', "", $string);
	return $str;
}
function removeEmptyLines($string)
{
	$str = "";
	$str = preg_replace("/(^[\r\n]*|[\r\n]+)[\s\t]*[\r\n]+$/m", "", $string);
	$str = rtrim($str);	
	return $str;
}

function removeLastParagraph($s)
{	
	$str = "";
	$str = rtrim($s);
	$str = preg_replace('/<p.*\/p>$/si', "", $str);
	return $str;	
}

function removeIframes($string)
{	
	$str = "";
	$str = preg_replace('/<iframe.*\/iframe>/si', "", $string);
	return $str;
}

function prepareVideoEmbedCode($embedCode)
{
	if($embedCode==null || strlen($embedCode)==0)
		return '';
	
	$str = '';
	$str = preg_replace('/width=["\'][0-9]*["\']/si', "width=\"310\"", $embedCode);
	$str = preg_replace('/height=["\'][0-9]*["\']/si', "height=\"202\"", $str);
	return $str;
}

?>