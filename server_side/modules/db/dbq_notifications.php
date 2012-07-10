<?php

function validateLang($lang)
{
	if(strlen($lang)<4 && strlen($lang)>0 )
		return true;
	
	return false;
}

function validateDeviceToken($t)
{
	//TODO: write better validation maybe
	if(strlen($t)==64)
		return true;

	return false;	
}

function saveDeviceTokenForNotifications($deviceToken='', $lang='')
{			
		if(!validateDeviceToken($deviceToken) || !validateLang($lang))
		{
			//TODO: log invalid device token - trigger some alarm if too often
			return false;
		}
	
		$con = mysql_connect(MYSQL_DB_SERVER, MYSQL_USER, MYSQL_PASS);
		if (!$con)
		{
		  die('Could not connect: ' . mysql_error());
		}

		$db_selected = mysql_select_db(MYSQL_DB_NAME, $con);
		if (!$db_selected) {
		    die ('Kann foo nicht benutzen : ' . mysql_error());
		}
		
		$query = sprintf("SELECT token FROM app_device_tokens WHERE token='%s' LIMIT 1",
		    mysql_real_escape_string($deviceToken));
		
		$res = mysql_query($query);
		if (!$res) {
		    $message  = 'Ungültige Abfrage: ' . mysql_error() . "\n";
		    $message .= 'Gesamte Abfrage: ' . $query;
		    die($message);
		}
		
		$numRows = mysql_num_rows($res);		
		
		//if device Token isn't yet in the DB, save it
		if($numRows==0)
		{
			$insQuery = sprintf("INSERT INTO `app_device_tokens` (
			`id` ,
			`token` ,
			`language`
			)
			VALUES (
			NULL ,  '%s',  '%s'
			);", mysql_real_escape_string($deviceToken), mysql_real_escape_string($lang));
			
			if( !mysql_query($insQuery))
			{
				return false;
			}
			
			return true;
		}
		else
		{
			return true;
		}

		mysql_free_result($res);
		mysql_close($con);
}

?>