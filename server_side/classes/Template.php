<?php


class Template extends IgnantObject implements JSONexportableObject
{
	public $id;
	public $name;
	
	public function __construct( $pTemplateId=0, $pTemplateName = '' ){
		$this->id = $pTemplateId;
		$this->name = $pTemplateName;
	}
	
	public function getArrayForJSONEncoding()
	{
		$returnArray = array();
		$returnArray[TEMPLATE_TYPE] = IGNANT_OBJECT_TYPE_TEMPLATE;
		$returnArray[TEMPLATE_ID] = $this->id;
		$returnArray[TEMPLATE_NAME] = $this->name;
		return $returnArray;
	}
};
?>