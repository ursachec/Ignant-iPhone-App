<?php

/*

SELECT * FROM wp_posts AS pt 
LEFT JOIN wp_postmeta AS pm ON pt.`ID` = pm.`post_id` 
WHERE 
pt.`post_parent`=39912 
AND pt.`post_type`='attachment' 
ORDER BY RAND() LIMIT 1;



SELECT * FROM wp_posts_mosaic AS wpm LEFT JOIN wp_posts AS pt ON wpm.`mosaic_post_id` = pt.`ID` LEFT JOIN wp_postmeta AS pm ON pt.`ID` = pm.`post_id` WHERE pm.`meta_key`='_wp_attachment_metadata' ORDER BY RAND() LIMIT 5;

be careful on creating mosaic entries, date before / date after + excluded categories

*/

function fetchBatchOfRandomMosaicEntries($number=60)
{
	$mosaicEntries = array();
	
	$dbh = newPDOConnection();
	
	$qString = "SELECT wpm.`post_id` as 'post_id', pt.`guid` AS 'orig_img_url', pm.`meta_value` AS 'meta_value' FROM wp_posts_mosaic AS wpm LEFT JOIN wp_posts AS pt ON wpm.`mosaic_post_id` = pt.`ID` LEFT JOIN wp_postmeta AS pm ON pt.`ID` = pm.`post_id` WHERE pm.`meta_key`='_wp_attachment_metadata' ORDER BY RAND() LIMIT $number;";
	
	$stmt = $dbh->prepare($qString);
	
	$stmt->execute();
	$mosaicEntries = $stmt->fetchAll(PDO::FETCH_ASSOC);
	
	$dbh = null;
	
	
	return $mosaicEntries;
}


function getBatchOfRandomMosaicEntries()
{
	$returnMosaicObjects = array();
		
	$mosaicEntries = fetchBatchOfRandomMosaicEntries();
	
	//implements
	$newWidth = 200;
	foreach($mosaicEntries as $mE)
	{	
		$origImgLink = $mE['orig_img_url'];
		$origImgMetaInfo = unserialize($mE['meta_value']);
		$origImgWidth = $origImgMetaInfo['width'];
		$origImgHeight = $origImgMetaInfo['height'];
		
		//TODO: log this somewhere, it shouldn't happen!
		if($origImgWidth==0 || $origImgHeight==0)
			continue;
		
		$newHeight = $newWidth*$origImgHeight/$origImgWidth;
		$origPostId = $mE['post_id'];
				
		$returnMosaicObjects[] = new MosaicEntry($origImgLink, $origPostId, round($newWidth, 2), round($newHeight, 2));
	}
	
	return $returnMosaicObjects;
}

?>