<?php

class RelatedArticle extends IgnantObject implements JSONexportableObject
{
	public $id;
	public $title;
	public $publishingDate;
	public $base64Thumbnail;
	
	public $rCategory;
	
	public function __construct($pArticleId = 0, $pArticleTitle='', $pArticlePublishingDate='', $pArticleCategory = null, $pBase64Thumbnail=null){
		$this->id = $pArticleId;
		$this->title = $pArticleTitle;
		$this->publishingDate = $pArticlePublishingDate;
		$this->base64Thumbnail = $pBase64Thumbnail;
		
		$this->rCategory = $pArticleCategory;
	}
	
	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[FK_ARTICLE_TYPE] = IGNANT_OBJECT_TYPE_RELATED_ARTICLE;
		$returnArray[FK_ARTICLE_ID]=$this->id;
		$returnArray[FK_ARTICLE_TITLE]=$this->title;
		$returnArray[FK_ARTICLE_PUBLISHING_DATE]=$this->publishingDate;
		$returnArray[FK_ARTICLE_CATEGORY_TEXT]=$this->descriptionText;
		
		//base64 thumbnail image
		if($this->base64Thumbnail!=null)
		$returnArray[FK_ARTICLE_BASE64_THUMBNAIL]=$this->base64Thumbnail->base64Representation;
		
		//category
		if($this->rCategory!=null)
		{
			$returnArray[FK_ARTICLE_CATEGORY_TEXT]=$this->rCategory->name;
		}
		
		return $returnArray;
	}
};

?>