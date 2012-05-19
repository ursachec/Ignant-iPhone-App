<?php
class Article extends LightArticle implements JSONexportableObject
{
	public $rCategory;
	public $rTemplate;
	public $descriptionText;
	public $descriptionRichText;
	public $images;
	public $relatedArticles;
	
	public function __construct( $pArticleId=0, $pArticleTitle = '', $pArticlePublishingDate = '', $pArticleCategory = null, $pArticleTemplate = null, $pArticleDescriptionText = '', $pArticleDescriptionRichText = '', $pArticleThumbImage = null, $pArticleImages = array(), $pArticleRelatedArticles = null ){
		
		$this->id = $pArticleId;
		$this->title = $pArticleTitle;
		$this->publishingDate = $pArticlePublishingDate;
		$this->rCategory = $pArticleCategory;
		$this->rTemplate = $pArticleTemplate;
		$this->descriptionText = $pArticleDescriptionText;
		$this->descriptionRichText = $pArticleDescriptionRichText;
		$this->title = $pArticleTitle;
		$this->thumbImage = $pArticleThumbImage;
		$this->images = $pArticleImages;
		$this->relatedArticles = $pArticleRelatedArticles;
	}
	
	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		
		//lightArticle properties
		$returnArray = array();
		$returnArray[FK_ARTICLE_TYPE] = IGNANT_OBJECT_TYPE_LIGHT_ARTICLE;
		$returnArray[FK_ARTICLE_ID]=$this->id;
		$returnArray[FK_ARTICLE_TITLE]=$this->title;
		$returnArray[FK_ARTICLE_PUBLISHING_DATE]=$this->publishingDate;
		$returnArray[FK_ARTICLE_THUMB_IMAGE]=$this->thumbImage->base64Representation;
		
		//fullArticle properties
		if($this->rCategory!=null)
		$returnArray[FK_ARTICLE_CATEGORY]=$this->rCategory->getArrayForJSONEncoding();
		
		if($this->rTemplate!=null)
		$returnArray[FK_ARTICLE_TEMPLATE]=$this->rTemplate->getArrayForJSONEncoding();
		
		$returnArray[FK_ARTICLE_DESCRIPTION_TEXT]=$this->descriptionText;
		$returnArray[FK_ARTICLE_DESCRIPTION_RICH_TEXT]=$this->descriptionRichText;
		
		if($this->images!=null)
		foreach($this->images as $aImage)
		{
			$returnArray[FK_ARTICLE_IMAGES][] = $aImage;
		}
		
		if($this->relatedArticles!=null)
		foreach($this->relatedArticles as $anArticle)
		{
			$returnArray[FK_ARTICLE_RELATED_ARTICLES][] = $anArticle;
		}
			
		return $returnArray;
	}
	
};

?>