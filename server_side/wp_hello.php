<?php
require_once('wp_config.inc.php');

function textForLanguage($str, $lang)
{
	$results = array();
	$needle = "<!--";

	//check if there is a localization string present, if not, just return same string
	if( strstr($str, $needle)!==FALSE )
	{
		preg_match("/(<!--:$lang-->)([-_·a-zA-Z0-9 ]*)(<!--:-->)/", $str, $results);
		return $results[2];
	}
	else
	{
		return $str;
	}
}

function textForLanguageTests()
{
	$textDE = "lang_de";
	$textEN = "lang_en";	

	//run a test to choose between de and en
	$textOne = sprintf("<!--:de-->%s<!--:--><!--:en-->%s<!--:-->", $textDE, $textEN);
	$t1en = textForLanguage($textOne,'en');
	if(strcmp($t1en, $textEN)!=0) die('textForLanguageTest failed (1)');

	//run a test where there is no localized text
	$textTwo = "Swellendaum Haus in Great Britain";
	$t2en = textForLanguage($textTwo, 'en');
	if(strcmp($t2en, $textTwo)!=0) die('textForLanguageTest failed (2)');
}

textForLanguageTests();



$con = mysql_connect("localhost",MYSQL_USER,MYSQL_PASS);
if (!$con)
{
 	die('Could not connect: ' . mysql_error());
}

$db_selected = mysql_select_db(MYSQL_DB_NAME, $con);
if (!$db_selected) {
	die ('Kann foo nicht benutzen : ' . mysql_error());
}




$query = sprintf("SELECT p.post_content, p.ID, t.slug
FROM wp_posts AS p
INNER JOIN wp_postmeta AS pm ON p.ID = pm.post_id
INNER JOIN wp_term_relationships AS tr ON p.ID = tr.object_id
INNER JOIN wp_term_taxonomy AS tt ON tr.term_taxonomy_id = tt.term_taxonomy_id
INNER JOIN wp_terms AS t ON tt.term_id = t.term_id
WHERE p.post_type = 'my-own-post-type'
   AND p.post_status = 'publish'
   AND t.slug IN
      ('art', 'category-2', 'category-3', 'category-4', 'category-5')
   AND
   (
      ( pm.meta_key = 'exclude' AND pm.meta_value <> '$id' )
         OR ( pm.meta_key = 'include' AND pm.meta_value = '$id' )
         OR ( pm.meta_key <> 'exclude' AND pm.meta_value <> 'include' )
   ) LIMIT 10;"
);

$query = "SELECT ts.name AS 'name', tt.term_taxonomy_id AS 'id' FROM wp_term_taxonomy AS tt INNER JOIN wp_terms AS ts ON tt.term_id = ts.term_id AND tt.taxonomy = 'category';";

$res = mysql_query($query);
if (!$res) {
    $message  = 'Ungültige Abfrage: ' . mysql_error() . "\n";
    $message .= 'Gesamte Abfrage: ' . $query;
    die($message);
}

$activeLang = 'en';	
while($post = mysql_fetch_assoc($res))
{
	// $pT = textForLanguage($post['post_title'], $activeLang);
	var_dump($post);
	print "<br />";

	// print "onepost: ".$pT."<br />";
}


mysql_free_result($res);

mysql_close($con);
?>
