<?php


class MixedImage extends IgnantObject implements JSONexportableObject
{
	public $url;
	public $base64Representation;
	
	public function __construct( $pImageId=0, $pImageUrl = '', $pImageBase64Representation='', $pImageDescription = '' ){
		$this->id = $pImageId;
		$this->url = $pImageUrl;
		$this->base64Representation = $pImageBase64Representation;
		$this->description = $pImageDescription;
	}

	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[IMAGE_ID]=$this->id;
		$returnArray[IMAGE_URL]=$this->url;
		$returnArray[IMAGE_BASE64_REPRESENTATION]=$this->base64Representation;
		$returnArray[IMAGE_DESCRIPTION]=$this->description;
		return $returnArray;
	}
};

?>