<?php

//ERRORS & WARNINGS
// define('WARNING_');

define('ID_FOR_HOME_CATEGORY',-1);


//TOP LEVEL
define('TL_SINGLE_ARTICLE','singleArticle');
define('TL_ARTICLES','articles');
define('TL_POSTS','posts');
define('TL_OVERWRITE','overwrite');
define('TL_ERROR','error');
define('TL_ERROR_MESSAGE','error_message');
define('TL_META_INFORMATION','meta_information');
define('TL_RESPONSE_STATUS','response_status');
define('TL_CATEGORIES_LIST','categories');


//GENERAL
define('IGNANT_OBJECT_TYPE_LIGHT_ARTICLE','light_article');
define('IGNANT_OBJECT_TYPE_RELATED_ARTICLE','related_article');
define('IGNANT_OBJECT_TYPE_FULL_ARTICLE','full_article');
define('IGNANT_OBJECT_TYPE_BASE64_IMAGE','base64_image');
define('IGNANT_OBJECT_TYPE_REMOTE_IMAGE','remote_image');
define('IGNANT_OBJECT_TYPE_TEMPLATE','template');
define('IGNANT_OBJECT_TYPE_CATEGORY','category');

//TUMBLR
define('TUMBLR_POST_PUBLISHING_DATE','publishingDate');
define('TUMBLR_POST_IMAGE_URL','url');



//ARTICLE
define('FK_ARTICLE_TYPE','type');
define('FK_ARTICLE_ID','articleId');
define('FK_ARTICLE_TITLE','title');
define('FK_ARTICLE_PUBLISHING_DATE','publishingDate');
define('FK_ARTICLE_THUMB_IMAGE','thumbImage');
define('FK_ARTICLE_REMOTE_IMAGES','remoteImages');
define('FK_ARTICLE_SHOW_ON_HOME_CATEGORY','shouldShowOnHomeCategory');
define('FK_ARTICLE_WEB_LINK','webLink');


define('FK_ARTICLE_CATEGORY_ID','categoryId');
define('FK_ARTICLE_CATEGORY_NAME','categoryName');

define('FK_ARTICLE_CATEGORY','rCategory');
define('FK_ARTICLE_TEMPLATE','rTemplate');
define('FK_ARTICLE_DESCRIPTION_TEXT','descriptionText');
define('FK_ARTICLE_DESCRIPTION_RICH_TEXT','descriptionRichText');
define('FK_ARTICLE_IMAGES','images');
define('FK_ARTICLE_RELATED_ARTICLES','relatedArticles');


//RELATED ARTICLE
define('FK_ARTICLE_CATEGORY_TEXT','categoryText');
define('FK_ARTICLE_BASE64_THUMBNAIL','base64Thumbnail');



//CATEGORY
define('CATEGORY_TYPE','type');
define('CATEGORY_ID','id');
define('CATEGORY_NAME','name');
define('CATEGORY_DESCRIPTION','description');

//IMAGE
define('IMAGE_TYPE','type');
define('IMAGE_ID','id');
define('IMAGE_DESCRIPTION','description');
define('IMAGE_BASE64_REPRESENTATION','base64Representation');
define('IMAGE_URL','url');

//TEMPLATE


?>