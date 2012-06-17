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


//get device information maybe

require_once('feedKeys.php');
require_once('JSONContentProxy.php');

$contentProxy = new JSONContentProxy();


if(!isset($_GET[FK_ARTICLE_ID]) || $_GET[FK_ARTICLE_ID]=='')
exit;

$articleId = $_GET[FK_ARTICLE_ID];
$thumbLink = '';


if(isset($_GET[TL_RETURN_MOSAIC_IMAGE]) && $_GET[TL_RETURN_MOSAIC_IMAGE]=='')
{
	$shouldReturnMosaicImage = $_GET[TL_RETURN_MOSAIC_IMAGE];
	if(!_bool($shouldReturnMosaicImage))
	return;
	
	$thumbLink = $contentProxy->getMosaicImageUrlForArticleId($articleId);	
	
}
else
{
	$thumbLink = $contentProxy->getThumbUrlForArticleId($articleId);	
}


if(strlen($thumbLink)<=0)
exit;

header("Location: $thumbLink");

exit;


?>