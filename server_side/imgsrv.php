<?php
/*
this script will server as a content deliverer for the ignant iphone app
*/


//get device information maybe

require_once('feedKeys.php');
require_once('JSONContentProxy.php');

$contentProxy = new JSONContentProxy();

if(!isset($_GET[FK_ARTICLE_ID]) || $_GET[FK_ARTICLE_ID]=='')
exit;

$articleId = $_GET[FK_ARTICLE_ID];

$thumbLink = $contentProxy->getThumbUrlForArticleId($articleId);

if(strlen($thumbLink)<=0)
exit;

header("Location: $thumbLink");

exit;


?>