<?php

function newPDOConnection(){
	return new PDO("mysql:host=".MYSQL_DB_SERVER.";dbname=".MYSQL_DB_NAME, MYSQL_USER, MYSQL_PASS);
}




?>