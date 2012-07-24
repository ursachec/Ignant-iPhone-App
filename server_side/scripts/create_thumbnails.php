<?php

function createthumb($name, $filename, $new_w = 0, $new_h = 0){
	$system=explode('.',$name);
	if (preg_match('/jpg|jpeg/',$system[1])){
		$src_img=imagecreatefromjpeg($name);
	}
	if (preg_match('/png/',$system[1])){
		$src_img=imagecreatefrompng($name);
	}

  if(!$src_img)
  {
    die('could not create image object');
  }
  

  $image_sizes = getimagesize($name);
  $old_w = $image_sizes[0];
  $old_h = $image_sizes[1];

  $thumb_w = $new_w;

  if($new_h==0)
    $thumb_h = $old_h * $new_w / $old_w;
  else
    $thumb_h = $new_h;

  $dst_img=ImageCreateTrueColor($thumb_w,$thumb_h);
	imagecopyresampled($dst_img,$src_img,0,0,0,0,$thumb_w,$thumb_h,$old_w,$old_h); 
  if (preg_match("/png/",$system[1]))
  {
	  imagepng($dst_img,$filename); 
  } else {
	  imagejpeg($dst_img,$filename); 
  }

  imagedestroy($dst_img); 
  imagedestroy($src_img); 
}

// Max vert or horiz resolution
createthumb('pics/carapicuibapre.jpg','thumbs/tn_carapicuibapre.jpg',200);



?>
