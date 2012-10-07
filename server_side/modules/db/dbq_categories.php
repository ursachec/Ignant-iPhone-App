<?php

function getArticleTemplateForCategoryId($categoryId = 0)
{
	$template = FK_ARTICLE_TEMPLATE_DEFAULT;
	
	if($categoryId==870)
		$template = FK_ARTICLE_TEMPLATE_ITRAVEL;
		
	else if($categoryId==869)
		$template = FK_ARTICLE_TEMPLATE_AICUISINE;
		
	else if($categoryId==860)
		$template = FK_ARTICLE_TEMPLATE_MONIFAKTUR;
		
	else if($categoryId==861)
		$template = FK_ARTICLE_TEMPLATE_VIDEO;
	
	else if($categoryId==859)
		$template = FK_ARTICLE_TEMPLATE_IGNANTV;
	
	else if($categoryId==868)
		$template = FK_ARTICLE_TEMPLATE_DAILYBASICS;
		
	
	return $template;
;}

function getExcludedCategoriesDBQueryString()
{
	$excludedCategoryIds = getExcludedCategories();
	$excludePDOParamString = '';
	$c=0;
	foreach($excludedCategoryIds as $id)
	{	
		if($c!=0)
			$excludePDOParamString.=',';
			
		$excludePDOParamString .= $id;
		$c++;
	}
	
	return $excludePDOParamString;
}
 
//this function returns the id's of categories to be excluded
function getExcludedCategories()
{
	//Arcademi 862
	//Aicuisine 869
	//Allgemein 1 - ok -- 
	//Other 7 --
	//Fil-in 857 --
	//Behind the blog 855 --
	//Interview 858 --
	//Video 861
	//Monifaktur 860
	//Daily Basics 868
	//Creative Match 894
	
	$categories = array(1,7,862,857,855,858, 860, 894);
	return $categories;
}

function getIgnantCategoriesAsPDOString()
{
	$categoriesPDOString = '';	
	$dbCategories = fetchIgnantCategories();
	
	$a=0;
	foreach($dbCategories as $c)
	{		
		if($a!=0)
			$categoriesPDOString.=',';
			
		$categoriesPDOString .=  $c[DB_FETCH_KEY_CATEGORY_ID];
		$a++;
	}
	
	return $categoriesPDOString;
}


function fetchIgnantCategories($con = null)
{
	$categories = array();
	
	$excludeCategoryIdsString = getExcludedCategoriesDBQueryString();
	
	if($con==null)
		$dbh = newPDOConnection();
	else
		$dbh = $con;
	
	$stmt = $dbh->prepare("SELECT ts.name AS '".DB_FETCH_KEY_CATEGORY_NAME."', tt.term_taxonomy_id AS '".DB_FETCH_KEY_CATEGORY_ID."' FROM wp_term_taxonomy AS tt 
	INNER JOIN wp_terms AS ts ON tt.term_id = ts.term_id 
		AND tt.taxonomy = 'category' 
		AND tt.term_taxonomy_id NOT IN (".$excludeCategoryIdsString.")
		ORDER BY ts.name;");

	$stmt->execute();

	while($c = $stmt->fetch())
		$categories[] = $c;
	
	if($con==null)
		$dbh = null;
	
	return $categories;
}


?>