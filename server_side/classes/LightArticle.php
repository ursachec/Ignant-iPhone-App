<?php


class LightArticle extends IgnantObject implements JSONexportableObject
{
	public $id;
	public $title;
	public $publishingDate;
	public $thumbImage;
	public $template;
	public $descriptionText;
	public $isArticleForHomeCategory;
	public $remoteImages;
	public $relatedArticles;
	
	public $rCategory;
	public $webLink;
	
	public function __construct($pArticleId = 0, $pArticleTitle='', $pArticlePublishingDate='', $pArticleThumbImage=null,$pArticleTemplate = null, $pArticleDescriptionText = '', $pTemplate = FK_ARTICLE_TEMPLATE_DEFAULT, $pRemoteImages = array(),$pRelatedArticles = array(), $pArticleCategory = null, $pWebLink = null){
		$this->id = $pArticleId;
		$this->title = $pArticleTitle;
		$this->publishingDate = $pArticlePublishingDate;
		$this->thumbImage = $pArticleThumbImage;
		$this->template = $pArticleTemplate;
		$this->descriptionText = $pArticleDescriptionText;
		
		$this->remoteImages = $pRemoteImages;
		
		$this->relatedArticles = $pRelatedArticles;
		
		$this->rCategory = $pArticleCategory;
		
		$this->webLink = $pWebLink;
		
		$this->template = $pTemplate;
		
		//default values
		$this->isArticleForHomeCategory = false;
	}
		
	public function getAsRelatedArticle()
	{
		$relatedArticle = null;
		$relatedArticle = new RelatedArticle($this->id, $this->title, $this->publishingDate,$this->rCategory, $this->thumbImage);
		return $relatedArticle;
	}
	public function setIsForHomeCategory($categoryId = '')
	{
		$this->isArticleForHomeCategory = ($categoryId==ID_FOR_HOME_CATEGORY);	
	}
	
	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[FK_ARTICLE_TYPE] = IGNANT_OBJECT_TYPE_LIGHT_ARTICLE;
		$returnArray[FK_ARTICLE_ID]=$this->id;
		$returnArray[FK_ARTICLE_TITLE]=$this->title;
		$returnArray[FK_ARTICLE_PUBLISHING_DATE]=$this->publishingDate;
		$returnArray[FK_ARTICLE_DESCRIPTION_TEXT]=$this->descriptionText;
		$returnArray[FK_ARTICLE_TEMPLATE]=$this->template;
		$returnArray[FK_ARTICLE_WEB_LINK]=$this->webLink;
		
		
		//is article for home category
		$returnArray[FK_ARTICLE_SHOW_ON_HOME_CATEGORY] = (bool)$this->isArticleForHomeCategory;
			
		//thumb image
 		
		$includeThumb = true;
		if($this->thumbImage!=null && $includeThumb)
 		$returnArray[FK_ARTICLE_THUMB_IMAGE]=$this->thumbImage->getArrayForJSONEncoding();
		
		//remote images
		if(is_array($this->remoteImages) && count($this->remoteImages)>0)
		{
			$remoteImagesForJSONEncoding = $this->remoteImages;
	
			foreach($remoteImagesForJSONEncoding as $aImage){
				if($aImage!=null && is_object($aImage))
				$returnArray[FK_ARTICLE_REMOTE_IMAGES][]=$aImage->getArrayForJSONEncoding();
			}
		}
		
		//related articles
		if(is_array($this->relatedArticles))
		{
			$relatedArticlesForJSONEncoding = $this->relatedArticles;
	
			foreach($relatedArticlesForJSONEncoding as $aRelatedArticle){
				if($aRelatedArticle!=null)
				$returnArray[FK_ARTICLE_RELATED_ARTICLES][]=$aRelatedArticle->getArrayForJSONEncoding();
			}
		}
 
		//category
		if($this->rCategory!=null)
		{
			$returnArray[FK_ARTICLE_CATEGORY_ID]=$this->rCategory->id;
			$returnArray[FK_ARTICLE_CATEGORY_NAME]=$this->rCategory->name;
		}
		
		return $returnArray;
	}
};

?>