<?php
	
define('POSTS_DATE_AFTER','2011-5-5');

//define thumb image constants

define('ROOT_THUMB_FOLDER','http://www.ignant.de/app/img/');
define('ROOT_IMAGE_FOLDER','http://www.ignant.de/wp-content/uploads/');

define('THUMB_IMAGE_EXT','png');

define('THUMB_FOLDER_MOSAIC','mosaic/');
define('THUMB_FOLDER_RELATED','related/');
define('THUMB_FOLDER_CATEGORY','category/');
define('THUMB_FOLDER_DETAIL','detail/');
define('THUMB_FOLDER_SLIDESHOW','slideshow/');

$GL_THUMB_FOLDERS = array(TL_RETURN_MOSAIC_IMAGE => THUMB_FOLDER_MOSAIC, 
				TL_RETURN_RELATED_IMAGE => THUMB_FOLDER_RELATED,
				TL_RETURN_CATEGORY_IMAGE => THUMB_FOLDER_CATEGORY,
				TL_RETURN_DETAIL_IMAGE => THUMB_FOLDER_DETAIL,
				TL_RETURN_SLIDESHOW_IMAGE => THUMB_FOLDER_SLIDESHOW );
				
?>