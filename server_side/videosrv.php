<?php

//get device information maybe
require_once('generalConstants.php');
require_once('feedKeys.php');
require_once('JSONContentProxy.php');

$contentProxy = new JSONContentProxy();

if(!isset($_GET[FK_ARTICLE_ID]) || $_GET[FK_ARTICLE_ID]=='')
exit;

$articleId = $_GET[FK_ARTICLE_ID];
$videoLink = '';

$videoLink = $contentProxy->getVideoUrlForArticleId($articleId);	

if($videoLink!=null)
header("Location: $videoLink");

exit;


?>