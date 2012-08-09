<?php
$tg_path = dirname(__FILE__).'/';

require_once($tg_path.'../../feedKeys.php');
require_once($tg_path.'../../generalConstants.php');

require_once($tg_path."../../wp_config.inc.php");





require_once($tg_path.'../db/dbq_general.php');
require_once($tg_path.'../db/dbq_articles.php');
require_once($tg_path.'../db/dbq_notifications.php');
require_once($tg_path.'../db/dbq_categories.php');




/*

*/

function getRandomImagePostId($postId=0, $dbh=null)
{
	if($postId==0)
	{
		bloatedPrint("skipping getRandomImagePostId, invalid id given postId: $postId...");
		return;
	}
	
	$qString = "SELECT pt.`id` AS 'post_id', pt.`guid` AS 'img_url' FROM wp_posts AS pt WHERE pt.`post_type` = 'attachment' AND pt.`post_parent` = :pid ORDER BY RAND() LIMIT 1;";
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':pid', $postId, PDO::PARAM_INT);
	$stmt->execute();
	
	$randomImagePost = $stmt->fetch(PDO::FETCH_ASSOC);
	
	return $randomImagePost['post_id'];
}

function insertOneMosaicEntry($mosaicPostId = 0, $postId = 0, $dbh = null)
{	
	if($dbh==null)
	{
		bloatedPrint("database handler is null...");
		return;
	}
	
	if($mosaicPostId==0 || $postId==0)
	{
		bloatedPrint("skipping entry, invalid id given postId: $postId // mosaicPostId: $mosaicPostId ...");
		return;
	}
			
	$qString = "INSERT INTO wp_posts_mosaic(`mosaic_post_id`,`post_id`) VALUES(:mid, :pid);";
	
	$stmt = $dbh->prepare($qString);
	$stmt->bindParam(':mid', $mosaicPostId, PDO::PARAM_INT);
	$stmt->bindParam(':pid', $postId, PDO::PARAM_INT);
	
	$stmt->execute();
}

function clearAllMosaicEntries($dbh = null)
{
	if($dbh==null)
	{
		bloatedPrint("database handler is null (startPosition: $startPosition)...");
		return;
	}
	
	$qString = "TRUNCATE wp_posts_mosaic;";
	
	$stmt = $dbh->prepare($qString);
	$stmt->execute();
	
	print "\ntruncated mosaic entries table...\n";
	
	return;	
}

function createMosaicEntries($startPosition, $batchSize, $dbh = null)
{
	global $includedCategoriesPDOString;
	
	if($dbh==null)
	{
		bloatedPrint("database handler is null (startPosition: $startPosition)...");
		return;
	}
	
	bloatedPrint("createMosaicEntries (startPosition: $startPosition )...");
	
	$qString = "SELECT 
			pt.`post_name`, pt.`id` AS 'post_id', pt.`post_title` AS 'post_title', pt.`post_date_gmt`, pt.`guid` AS 'post_url', pt.`post_content` AS 'post_content', wpm.`meta_value` AS 'img_url', wpm.`post_id` AS 'meta_id'
			FROM wp_posts AS pt 
			LEFT JOIN wp_term_relationships AS tr ON pt.`id` = tr.`object_id` 
			LEFT JOIN wp_term_taxonomy AS tt ON tt.`term_taxonomy_id` = tr.`term_taxonomy_id` 
			LEFT JOIN wp_postmeta AS wpm ON wpm.`post_id` = (SELECT meta_value FROM wp_postmeta AS pm WHERE pm.`meta_key`='_thumbnail_id' AND pm.`post_id`=pt.`ID`) AND wpm.`meta_key` = '_wp_attached_file'
			LEFT JOIN wp_postmeta AS wpm2 ON wpm2.`post_id` = pt.`id` AND (wpm2.`meta_key` = 'nsfw' OR wpm2.`meta_key` = 'notmobile' )
			WHERE pt.`post_status` = 'publish'
			AND pt.`post_type` = 'post'
			AND pt.`post_parent` = 0
			AND wpm2.`meta_value` IS NULL
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
		$mid = getRandomImagePostId($pid, &$dbh);
		
		insertOneMosaicEntry($mid, $pid, &$dbh);
	}
	$startPosition+=$batchSize;
	
	if(count($posts)>0 && $startPosition<MAX_NUMBER_OF_FILE_TO_CREATE)
	{
		createMosaicEntries(&$startPosition, $batchSize, &$dbh);
	}
	
	//bloatedPrint("finished recursion with startPosition: $startPosition");
	return;
}


parse_str(implode('&', array_slice($argv, 1)), $_GET);

$max = 0;
if(isset($_GET['max']))
	$max = $_GET['max'];
else
	$max = 50;

define('MAX_NUMBER_OF_FILE_TO_CREATE', $max);

header('Content-type:text/plain');

bloatedPrint("\nstarting running mosaic generator...");

$before = microtime(true);

$includedCategoriesPDOString = getIgnantCategoriesAsPDOString();
$dbh = newPDOConnection();
$startPosition = 0;
$batchSize = 20;

//clearAllMosaicEntries(&$dbh);

createMosaicEntries(&$startPosition, $batchSize, &$dbh);

$after = microtime(true);
bloatedPrint("execution time: ".($after-$before). " s");
bloatedPrint("finished running mosaic generator...");

$dbh = null;

?>