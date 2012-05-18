<?php

$startIndex = 0;
$stopIndex = 20;



$beginIndex = $startIndex;
$endIndex = $stopIndex;


$url = "http://api.tumblr.com/v2/blog/ignant.tumblr.com/posts?limit=100&api_key=I5QACSezTzCjvkHXaiEaXrD3t9cb8Ahmpyv7MqGIRPhdEfg2Yw";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL,$url); // set url to post to
curl_setopt($ch, CURLOPT_FAILONERROR, 1);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);// allow redirects
curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); // return into a variable
curl_setopt($ch, CURLOPT_TIMEOUT, 3); // times out after 4s
$result = curl_exec($ch); // run the whole process
curl_close($ch);

//extract the posts from the returned JSON
$responseFromTumblrJSON = json_decode($result, true);
$postsFromTumblrAPI = $responseFromTumblrJSON['response']['posts'];

//filter the relevant information from the posts
$filteredInformationPosts = array();
foreach($postsFromTumblrAPI as $post){
	$newPost = array();
	$newPost['timestamp'] = $post['timestamp'];
	$newPost['image'] = $post['photos'][0]["alt_sizes"][2];
	$filteredInformationPosts[] = $newPost;	
}

print $filteredInformationPosts;

?>