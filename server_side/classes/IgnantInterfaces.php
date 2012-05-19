<?php
interface JSONexportableObject
{
	public function getJSONRepresentation();
	public function getArrayForJSONEncoding();
}
?>