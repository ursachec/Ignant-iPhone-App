<?php
class IgnantObject
{
	public $objectType;
	
	public function getJSONRepresentation()
	{
		return json_encode($this->getArrayForJSONEncoding());
	}
}
?>