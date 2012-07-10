<?php

//SELECT * FROM wp_posts AS pt WHERE pt.post_status = 'publish' ORDER BY post_date DESC LIMIT 10;

// SELECT * FROM wp_posts AS pt LEFT JOIN wp_term_relationships AS tr ON  WHERE pt.post_status = 'publish' ORDER BY post_date DESC LIMIT 10;

// SELECT * FROM wp_posts AS pt LEFT JOIN wp_term_relationships AS tr ON pt.id = tr.object_id  WHERE pt.post_status = 'publish' ORDER BY post_date DESC LIMIT 10;

require_once('../../wp_config.inc.php');

function fetchLatestArticlesForCategory()
{
	$posts = array();
	
	
	$con = mysql_connect(MYSQL_DB_SERVER, MYSQL_USER, MYSQL_PASS);
	if (!$con)
	{
	  die('Could not connect: ' . mysql_error());
	}

	$db_selected = mysql_select_db(MYSQL_DB_NAME, $con);
	if (!$db_selected) {
	    die ('Could not select DB : ' . mysql_error());
	}
	
	$query = sprintf("SELECT pt.id AS 'post_id' FROM wp_posts AS pt LEFT JOIN wp_term_relationships AS tr ON pt.id = tr.object_id  WHERE pt.post_status = 'publish' ORDER BY post_date DESC LIMIT 10;");
	
	$res = mysql_query($query);
	if (!$res) {
	    $message  = 'Ungültige Abfrage: ' . mysql_error() . "\n";
	    $message .= 'Gesamte Abfrage: ' . $query;
	    die($message);
	}
	
	while($p = mysql_fetch_assoc($res))
	{
		$posts[] = $p;
	}
	
	mysql_free_result($res);
	mysql_close($con);
	
	return $posts;
}

$posts = fetchLatestArticlesForCategory();
foreach($posts as $p){
	print $p['post_id']."<br />";
}


?>