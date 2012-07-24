<?php
/*
this script will server as a content deliverer for the ignant iphone app
*/

/**
 * Checks a variable if it is true or false, humanlike. 
 * We account for values as 'on', '1', '' and so on.    
 * Finally, for some reare occurencies we account with  
 * crazy logic to fit some arrays and objects.          
 *                                                      
 * @author Kim Steinhaug, <kim@steinhaug.com>           
 * @param mixed $var, the variable to check             
 *                                                      
 * Example:                                             
 * $test = 'true';                                      
 * if(_bool($test)){ echo 'true'; } else { echo 'false'; }
 */
function _bool($var){
  if(is_bool($var)){
    return $var;
  } else if($var === NULL || $var === 'NULL' || $var === 'null'){
    return false;
  } else if(is_string($var)){
    $var = trim($var);
    if($var=='false'){ return false;
    } else if($var=='true'){ return true;
    } else if($var=='no'){ return false;
    } else if($var=='yes'){ return true;
    } else if($var=='off'){ return false;
    } else if($var=='on'){ return true;
    } else if($var==''){ return false;
    } else if(ctype_digit($var)){
      if((int) $var)
        return true;
        else
        return false;
    } else { return true; }
  } else if(ctype_digit((string) $var)){
      if((int) $var)
        return true;
        else
        return false;
  } else if(is_array($var)){
    if(count($var))
      return true;
      else
      return false;
  } else if(is_object($var)){
    return true;// No reason to (bool) an object, we assume OK for crazy logic
  } else {
    return true;// Whatever came though must be something,  OK for crazy logic
  }
}

require_once('feedKeys.php');
require_once('JSONContentProxy.php');

require_once("wp_config.inc.php");

require_once('modules/db/dbq_general.php');
require_once('modules/db/dbq_articles.php');

$contentProxy = new JSONContentProxy();


if(!isset($_GET[FK_ARTICLE_ID]) || $_GET[FK_ARTICLE_ID]=='')
exit;

$articleId = $_GET[FK_ARTICLE_ID];
$thumbLink = '';
$imageType = '';

if(isset($_GET[TL_RETURN_IMAGE_TYPE]) && $_GET[TL_RETURN_IMAGE_TYPE]!='')
	$imageType = $_GET[TL_RETURN_IMAGE_TYPE];

if( strcmp($imageType, TL_RETURN_MOSAIC_IMAGE)==0 )
{	
	$thumbLink =  getThumbLinkForArticleId($articleId);
}

else if( strcmp($imageType, TL_RETURN_RELATED_IMAGE)==0 )
{	
	$path_parts = pathinfo($_SERVER['SCRIPT_NAME']);
	$imgDir = 'http://'.$_SERVER['SERVER_NAME'].'/img';
	$relatedImgDir = $imgDir.'/related';
	
	$tempArticleId = '39440';
	$thumbLink = $relatedImgDir.'/'.$tempArticleId.'.png';
	
	// $thumbLink =  getThumbLinkForArticleId($articleId);
}

else
{
	$thumbLink =  getThumbLinkForArticleId($articleId);
}

if(strlen($thumbLink)<=0)
exit;

header("Location: $thumbLink");

exit;
?>