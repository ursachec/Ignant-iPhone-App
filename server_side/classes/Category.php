<?php

class Category extends IgnantObject implements JSONexportableObject
{
	public $id;
	public $name;
	public $description;
	
	public function __construct( $pCategoryId=0, $pCategoryName = '', $pCategoryDescription='' ){
		$this->id = $pCategoryId;
		$this->name = $pCategoryName;
		$this->description = $pCategoryDescription;
	}
	
	//TODO: implement this better, using constants
	public function isHomeCategory()
	{
		return ($this->id==ID_FOR_HOME_CATEGORY);
	}
	
	public function getArrayForJSONEncoding()
	{		
		$returnArray = array();
		$returnArray[CATEGORY_TYPE] = IGNANT_OBJECT_TYPE_CATEGORY;
		$returnArray[CATEGORY_ID]=$this->id;
		$returnArray[CATEGORY_NAME]=$this->name;
		$returnArray[CATEGORY_DESCRIPTION]=$this->description;
		return $returnArray;
	}
};

?>