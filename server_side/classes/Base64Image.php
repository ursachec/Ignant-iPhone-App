<?php

class Base64Image extends BasicImage implements JSONexportableObject
{
	public $base64Representation;
	
	public function __construct( $pImageId='image_id', $pImageBase64Representation='', $pImageDescription = '' ){
		$this->id = $pImageId;
		$this->base64Representation = $pImageBase64Representation;
		$this->description = $pImageDescription;
	}

	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[IMAGE_TYPE] = IGNANT_OBJECT_TYPE_BASE64_IMAGE;
		$returnArray[IMAGE_ID]=$this->id;
		$returnArray[IMAGE_DESCRIPTION]=$this->description;
		$returnArray[IMAGE_BASE64_REPRESENTATION]=$this->base64Representation;
		
		
		// $returnArray[IMAGE_BASE64_REPRESENTATION]="AAQQAA\//j\/";
		return $returnArray;
	}
}

?>