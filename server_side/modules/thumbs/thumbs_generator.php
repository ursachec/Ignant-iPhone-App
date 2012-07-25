<?php

require_once('../../feedKeys.php');

require_once("../../wp_config.inc.php");
require_once('../db/dbq_general.php');

require_once('../db/dbq_articles.php');
require_once('../db/dbq_notifications.php');
require_once('../db/dbq_categories.php');

//first get list of articles + img_urls to convert and save
//
//make a directory for the thumbs
//
//start generating thumbs in batches of N
//save them all to the same directory, under the article id .EXT name


function createthumb($name, $filename, $new_w = 0, $new_h = 0){
	$system=explode('.',$name);
	if (preg_match('/jpg|jpeg/',$system[1])){
		$src_img=imagecreatefromjpeg($name);
	}
	if (preg_match('/png/',$system[1])){
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

	imagepng($dst_img,$filename); 

	imagedestroy($dst_img); 
	imagedestroy($src_img); 
}

function createSlideshowImageThumbs()
{
	
	
}

function createMosaicImageThumbs($startPosition, $batchSize, $newWidth = 200, $sourceDir = '', $destinationDir = '', $dbh = null)
{
	if($dbh==null)
	{
		bloatedPrint("database handler is null (startPosition: $startPosition)...");
		return;
	}
	
	$qString = "SELECT `mosaic_post_id`,`post_id` FROM wp_posts_mosaic ";
	$qString .= " LIMIT ".$startPosition.",".$batchSize;
	
	$stmt = $dbh->prepare($qString);
	$stmt->execute();
	$posts = $stmt->fetchAll(PDO::FETCH_ASSOC);
	foreach($posts as $p)
	{
		$pid = $p['post_id'];
    	$mid = $p['mosaic_post_id'];
	  	createOneArticleImageThumb($pid, $mid, $newWidth, $sourceDir, $destinationDir, $dbh);
	}
	$startPosition+=$batchSize;
	
	if(count($posts)>0  && $startPosition<30)
	{
		createMosaicImageThumbs(&$startPosition, $batchSize, $newWidth , &$dbh);
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
	  	createOneArticleImageThumb($pid, $iid, $newWidth, $sourceDir, $destinationDir, $dbh);
	}
	$startPosition+=$batchSize;
	
	if(count($posts)>0  && $startPosition<30)
	{
		createArticleImageThumbs(&$startPosition, $batchSize, $newWidth , &$dbh);
	}
	
	bloatedPrint("finished recursion with startPosition: $startPosition");
	return;
}

function createOneArticleImageThumb($articleId=0, $imageUrl = '', $newWidth = 200, $sourceDir='', $destinationDir = '',  $dhb=null)
{
	$sourceImage = $sourceDir.'carapicuibapre.jpg';
	$destinationImage = $destinationDir.$articleId.'.png';
	
	//TODO: check permissions
	if(@fopen($destinationImage,"r")==true)
	{
		print("thumb image already exists, skipping articleId: $articleId // imageUrl: $imageUrl...\n");
	}
	else
	{
		print("creating one article Image thumb, articleId: $articleId // imageUrl: $imageUrl\n");
		createthumb($sourceImage, $destinationImage,$newWidth);
	}
}

header('Content-type:text/plain');

bloatedPrint("started generating thumbs...");

$before = microtime(true);


// TL_RETURN_MOSAIC_IMAGE 
// TL_RETURN_RELATED_IMAGE 
// TL_RETURN_CATEGORY_IMAGE 
// TL_RETURN_DETAIL_IMAGE 
// TL_RETURN_SLIDESHOW_IMAGE 

$imageType = TL_RETURN_CATEGORY_IMAGE;


$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();

$dbh = newPDOConnection();
$startPosition = 0;
$batchSize = 20;

$newWidth = 0;
$doubleWidth = true;

$sourceDir = 'pics/';
$destinationDirRoot = '/Users/cvursache/privat/temp/';
$destinationDir = $destinationDirRoot;

if(strcmp($imageType,TL_RETURN_MOSAIC_IMAGE)==0)
{
	$newWidth = 100 * 2;
	$destinationDir .= 'mosaic/'; 
}
else if(strcmp($imageType,TL_RETURN_RELATED_IMAGE)==0)
{
	$newWidth = 100 * 2;
	$destinationDir .= 'related/';
}
else if(strcmp($imageType,TL_RETURN_CATEGORY_IMAGE)==0)
{
	$newWidth = 149 * 2;
	$destinationDir .= 'category/';
}	
else if(strcmp($imageType,TL_RETURN_DETAIL_IMAGE)==0)
{
	$newWidth = 310;
	$destinationDir .= 'detail/';
}	
else if(strcmp($imageType,TL_RETURN_SLIDESHOW_IMAGE)==0)
{
	$newWidth = 100;
	$destinationDir .= 'slideshow/';
}
		
createArticleImageThumbs(&$startPosition, $batchSize, $newWidth, $sourceDir, $destinationDir,  &$dbh);

$after = microtime(true);
bloatedPrint("execution time: ".($after-$before). " s");
bloatedPrint("finished running thumbs generator...");

$dbh = null;


//create thumbs for mosaic
//create thumbs for related
//create thumbs for category view
//create thumbs for detail vc


?>
