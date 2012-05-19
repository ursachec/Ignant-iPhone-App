<?php

//debug variables
$lastNumberOfTotalPosts = 0;
$simpleCounter = 0;
$numberOfDroppedRequests = 0;
$lastUsedOffset = 0;

//other variables
$limit = 20;
$loadedPosts = 0;
$offset = 0;
$filteredInformationPosts = array();

$fileName = 'tumblrDataDump.txt';
$saveToFile = true;

printf("Downloading tumblr data...\n");

$time_start = microtime(true);

do
{
		$offset = $simpleCounter*$limit+$diffForTotalPosts;
		$lastUsedOffset = $offset;
		
		printf("\ndownloading one set of posts... (dropped: %d, loaded: %d, totalposts: %d, offset: %d)",$numberOfDroppedRequests, $loadedPosts, $lastNumberOfTotalPosts, $offset);
		
		//set up the GET request
		$url = "http://api.tumblr.com/v2/blog/ignant.tumblr.com/posts?api_key=I5QACSezTzCjvkHXaiEaXrD3t9cb8Ahmpyv7MqGIRPhdEfg2Yw&offset=".$offset;
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL,$url);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
		curl_setopt($ch, CURLOPT_TIMEOUT, 3); 
		$result = curl_exec($ch);
		curl_close($ch);

		//extract the posts from the returned JSON
		$responseFromTumblrJSON = json_decode($result, true);
		$postsFromTumblrAPI = $responseFromTumblrJSON['response']['posts'];
		$totalNumberOfPosts = $responseFromTumblrJSON['response']['total_posts'];
		
		//save the difference and try again if the number of total posts has changed
		$diffForTotalPosts = $lastNumberOfTotalPosts==0 ? 0 : $totalNumberOfPosts-$lastNumberOfTotalPosts;
		if($lastNumberOfTotalPosts!=0 && $diffForTotalPosts!=0){
			$numberOfDroppedRequests++;
			continue;
		}
		
		//filter the relevant information from the posts
		foreach($postsFromTumblrAPI as $post){
			$newPost = array();
			$newPost['publishingDate'] = $post['timestamp'];
			$newPost['imageUrl'] = $post['photos'][0]["alt_sizes"][2]["url"];
			$filteredInformationPosts[] = $newPost;	
		}
		
		//append the filtered posts to the file
		if($saveToFile){
			$fp = fopen($fileName, 'w');
			fwrite($fp, utf8_encode(json_encode($filteredInformationPosts)));
			fclose($fp);
		}
		
		//set necessary variables @ end of the loop
		$loadedPosts = count($filteredInformationPosts);
		$lastNumberOfTotalPosts = $totalNumberOfPosts;
		
		$simpleCounter++;		
}
while($loadedPosts<$lastNumberOfTotalPosts && $totalNumberOfPosts-$offset>limit);

$time_end = microtime(true);
$time = $time_end - $time_start;

printf("Finished downloading tumblr data in %d seconds.\n",$time);
printf("Number of posts downloaded (%d) .\n", $loadedPosts);

?>