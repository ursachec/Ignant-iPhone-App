<?php


class RemoteImage extends BasicImage implements JSONexportableObject
{
	public $url;
	
	public function __construct( $pImageId=0, $pImageUrl='', $pImageDescription = '', $pImageWidth='', $pImageHeight=''){
		$this->id = $pImageId;
		$this->url = $pImageUrl;
		$this->description = $pImageDescription;
		$this->width = $pImageWidth;
		$this->height = $pImageHeight;
	}

	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[IMAGE_TYPE] = IGNANT_OBJECT_TYPE_REMOTE_IMAGE;
		$returnArray[IMAGE_ID]=$this->id;
		$returnArray[IMAGE_URL]=$this->url;
		$returnArray[IMAGE_DESCRIPTION]=$this->description;
		$returnArray[IMAGE_WIDTH]=$this->width;
		$returnArray[IMAGE_HEIGHT]=$this->height;
		
		return $returnArray;
	}
}
?>