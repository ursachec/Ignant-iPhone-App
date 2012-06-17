<?php

class MosaicEntry extends IgnantObject implements JSONexportableObject
{
	public $url;
	public $articleId;
	public $width;
	public $height;
	
	public function __construct($pUrl = '', $pArticleId = '', $pWidth = 0, $pHeight = 0){
		$this->url = $pUrl;
		$this->articleId = $pArticleId;
		$this->width = $pWidth;
		$this->height = $pHeight;
	}

	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[MOSAIC_ENTRY_ARTICLE_ID]=$this->articleId;
		$returnArray[MOSAIC_ENTRY_URL]=$this->url;
		$returnArray[MOSAIC_ENTRY_WIDTH]=$this->width;
		$returnArray[MOSAIC_ENTRY_HEIGHT]=$this->height;
		
		return $returnArray;
	}
};

?>