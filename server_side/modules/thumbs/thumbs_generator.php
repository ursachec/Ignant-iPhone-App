<?php

require_once('../../generalConstants.php');
require_once('../../feedKeys.php');

require_once("../../wp_config.inc.php");
require_once('../db/dbq_general.php');

require_once('../db/dbq_articles.php');
require_once('../db/dbq_notifications.php');
require_once('../db/dbq_categories.php');

function createthumb($name, $filename, $new_w = 0, $new_h = 0){
		
	$fn = basename($name);
	if (preg_match('/jpg|jpeg/',$fn)){
		$src_img=imagecreatefromjpeg($name);
	}
	if (preg_match('/png/',$fn)){
		$src_img=imagecreatefrompng($name);
	}
		
	if(!$src_img)
	{
		die('could not create image object');
	}

	$image_sizes = getimagesize($name);
	$old_w = $image_sizes[0];
	$old_h = $image_sizes[1];

	$thumb_w = $new_w;

	if($new_h==0)
		$thumb_h = $old_h * $new_w / $old_w;
	else
		$thumb_h = $new_h;

	$dst_img=ImageCreateTrueColor($thumb_w,$thumb_h);
	imagecopyresampled($dst_img,$src_img,0,0,0,0,$thumb_w,$thumb_h,$old_w,$old_h); 

	if(!$dst_img)
	{
		die('could not create trueColorImage');
	}

	imagepng($dst_img,$filename); 

	imagedestroy($dst_img); 
	imagedestroy($src_img); 
}

function createSlideshowImageThumbs()
{
	print "create slideshow image thumbs";
	
}

function createMosaicImageThumbs($startPosition, $batchSize, $newWidth = 200, $sourceDir = '', $destinationDir = '', $dbh = null)
{		
	if($dbh==null)
	{
		bloatedPrint("database handler is null (startPosition: $startPosition)...");
		return;
	}
	
	$qString = "SELECT wm.`mosaic_post_id`, wm.`post_id`, wp.`meta_value` FROM wp_posts_mosaic AS wm 
	LEFT JOIN wp_postmeta AS wp ON wm.`mosaic_post_id` = wp.`post_id` AND wp.`meta_key` = '_wp_attached_file' ";
	$qString .= " LIMIT ".$startPosition.",".$batchSize;
	
	$stmt = $dbh->prepare($qString);
	$stmt->execute();
	$posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
	foreach($posts as $p)
	{
		$pid = $p['post_id'];
    	$mid = $p['mosaic_post_id'];
		$meta_value = $p['meta_value'];
		
		print "create image thumb for pid: $pid | mid: $mid | sourceDir: $sourceDir | meta_value: $meta_value \n ";
	  	//createImageThumb($pid, $mid, $newWidth, $sourceDir, $destinationDir);
	}
	$startPosition+=$batchSize;
	
	if(count($posts)>0  && $startPosition<30)
	{			
		createMosaicImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir, &$dbh);
	}
	
	bloatedPrint("finished recursion with startPosition: $startPosition");
	return;	
}

function createArticleImageThumbs($startPosition, $batchSize, $newWidth = 200, $sourceDir = '', $destinationDir = '', $dbh = null)
{
	global $includedCategoriesPDOString;
	
	if($dbh==null)
	{
		bloatedPrint("database handler is null (startPosition: $startPosition)...");
		return;
	}
	
	bloatedPrint("(createArticleThumbs startPosition: $startPosition )...");
	
	$qString = "SELECT 
			pt.`post_name`, pt.`id` AS 'post_id', pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`guid` AS 'post_url', pt.`post_content` AS 'post_content', wpm.`meta_value` AS 'img_url', wpm.`post_id` AS 'meta_id'
			FROM wp_posts AS pt 
			LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
			LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
			LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = (SELECT meta_value FROM wp_postmeta AS pm WHERE pm.`meta_key`='_thumbnail_id' AND pm.`post_id`=pt.`ID`) AND wpm.`meta_key` = '_wp_attached_file'
			WHERE pt.`post_status` = 'publish'
			AND pt.`post_type` = 'post'
			AND pt.`post_parent` = 0
			AND pt.`post_date` > '".POSTS_DATE_AFTER."'
			AND tr.`term_taxonomy_id` IN (".$includedCategoriesPDOString.")";
	
	$qString .= " ORDER BY pt.`post_date` DESC";	
	$qString .= " LIMIT ".$startPosition.",".$batchSize;
	$qString .= ";";
	
	$stmt = $dbh->prepare($qString);
	$stmt->execute();
	$posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
	foreach($posts as $p)
	{
    	$pid = $p['post_id'];
    	$iid = $p['img_url'];
	  	createImageThumb($pid, $iid, $newWidth, $sourceDir, $destinationDir);
	}
	$startPosition+=$batchSize;
	
	if(count($posts)>0  && $startPosition<30)
	{
		createArticleImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir, &$dbh);
	}
	
	bloatedPrint("finished recursion with startPosition: $startPosition");
	return;
}

function createImageThumb($articleId=0, $imageUrl = '', $newWidth = 200, $sourceDir='', $destinationDir = '')
{
	$sourceImage = $sourceDir.$imageUrl;
	$destinationImage = $destinationDir.$articleId.'.png';
	
	//TODO: check permissions
	if(@fopen($destinationImage,"r")==true)
	{
		print("thumb image already exists, skipping articleId: $articleId // imageUrl: $imageUrl...\n");
	}
	else
	{
		print("creating one article Image thumb, articleId: $articleId // imageUrl: $imageUrl // destination: $destinationImage\n");
		createthumb($sourceImage, $destinationImage,$newWidth);
	}
}

// TL_RETURN_MOSAIC_IMAGE | TL_RETURN_RELATED_IMAGE | TL_RETURN_CATEGORY_IMAGE | TL_RETURN_DETAIL_IMAGE | TL_RETURN_SLIDESHOW_IMAGE

parse_str(implode('&', array_slice($argv, 1)), $_GET);

if(isset($_GET[TL_RETURN_IMAGE_TYPE]) && $_GET[TL_RETURN_IMAGE_TYPE]!=''){
	$imageType = $_GET[TL_RETURN_IMAGE_TYPE];
}
else{
	bloatedPrint("Image category not set, exiting.");
	return;
}

//temp
$imageType = TL_RETURN_RELATED_IMAGE;

header('Content-type:text/plain');	
bloatedPrint("started generating thumbs...");

$before = microtime(true);

$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();

$dbh = newPDOConnection();


$startPosition = 0;
$batchSize = 20;

$newWidth = 0;
$doubleWidth = true;

$sourceDir = '';
$destinationDirRoot = '';


$debug = false;

if($debug)
{
	$sourceDir = 'pics/';
	$destinationDirRoot = '/Users/cvursache/privat/temp/';
}
else
{
	$sourceDir = '/www/htdocs/w00d3020/ignantblog/wp-content/uploads/';
	$destinationDirRoot = '/www/htdocs/w00d3020/ignantblog/app/img/';	
}

$destinationDir = $destinationDirRoot;

if(strcmp($imageType,TL_RETURN_MOSAIC_IMAGE)==0)
{
	$newWidth = 100 * 2;
	$destinationDir .= 'mosaic/'; 
	
	createMosaicImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir,  &$dbh);
}
else if(strcmp($imageType,TL_RETURN_RELATED_IMAGE)==0)
{
	$newWidth = 100 * 2;
	$destinationDir .= 'related/';
	
	createArticleImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir,  &$dbh);
	
}
else if(strcmp($imageType,TL_RETURN_CATEGORY_IMAGE)==0)
{
	$newWidth = 149 * 2;
	$destinationDir .= 'category/';
	
	createArticleImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir,  &$dbh);
}	
else if(strcmp($imageType,TL_RETURN_DETAIL_IMAGE)==0)
{
	$newWidth = 310;
	$destinationDir .= 'detail/';
	
	createArticleImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir,  &$dbh);
}	
else if(strcmp($imageType,TL_RETURN_SLIDESHOW_IMAGE)==0)
{
	$newWidth = 100;
	$destinationDir .= 'slideshow/';

	createSlideshowImageThumbs();
}

$after = microtime(true);
bloatedPrint("execution time: ".($after-$before). " s");
bloatedPrint("finished running thumbs generator...");

$dbh = null;
?>
