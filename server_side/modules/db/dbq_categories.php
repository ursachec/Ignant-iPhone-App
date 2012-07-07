<?php

function fetchIgnantCategories()
{
	$categories = array();
	
	
	$con = mysql_connect(MYSQL_DB_SERVER, MYSQL_USER, MYSQL_PASS);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}

	$db_selected = mysql_select_db(MYSQL_DB_NAME, $con);
	if (!$db_selected) {
	    die ('Could not select DB : ' . mysql_error());
	}
	
	$query = sprintf("SELECT ts.name AS '%s', tt.term_taxonomy_id AS '%s' FROM wp_term_taxonomy AS tt INNER JOIN wp_terms AS ts ON tt.term_id = ts.term_id AND tt.taxonomy = 'category' ORDER BY ts.name;", DB_FETCH_KEY_CATEGORY_NAME, DB_FETCH_KEY_CATEGORY_ID);
	
	$res = mysql_query($query);
	if (!$res) {
	    $message  = 'Ungültige Abfrage: ' . mysql_error() . "\n";
	    $message .= 'Gesamte Abfrage: ' . $query;
	    die($message);
	}
	
	while($c = mysql_fetch_assoc($res))
	{
		$categories[] = $c;
	}
	
	mysql_free_result($res);
	mysql_close($con);
	
	return $categories;
}

?>