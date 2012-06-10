<?php

require_once('./feedKeys.php');

require_once('classes/IgnantInterfaces.php');
require_once('classes/IgnantObject.php');
require_once('classes/LightArticle.php');
require_once('classes/RelatedArticle.php');
require_once('classes/Article.php');
require_once('classes/BasicImage.php');
require_once('classes/Base64Image.php');
require_once('classes/RemoteImage.php');
require_once('classes/MixedImage.php');
require_once('classes/Template.php');
require_once('classes/Category.php');

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function encode_img($img)
{
    $fd = fopen ($img, 'rb');
    $size=filesize ($img);
    $cont = fread ($fd, $size);
    fclose ($fd);
    $encimg = base64_encode($cont);
    return $encimg;
}

function createBase64Image($id = '', $imageDescription = 'default', $imageFilename = '')
{
	if($id=='' || $imageFilename=='') return null;
	return new Base64Image($id, encode_img($imageFilename) , $imageDescription);
}

function createRemoteImage($pImageId= '', $pImageUrl='', $pImageDescription = '' )
{
	if($pImageId=='' || $pImageUrl=='') return null;
	return new RemoteImage($pImageId, $pImageUrl , $pImageDescription);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// TESTING THE json representations

// $imagecode = encode_img('allandale_01.jpg'); // to encode the image
// $thumgImage = new MixedImage('allandale_01','',encode_img('allandale_01.jpg'),'');


//test JSON representation for the Category() class
$cat = new Category(1,'Kunst','KunstDescription');

//test JSON representation for the Template() class
$template = new Template(1,'template_light');
	
//remoteimage	
$remoteImage = new RemoteImage(1, 'http://www.google.at/logo.gif', 'some image description');
	
//base64 image
$base64Image = new Base64Image(1, $imagecode, 'some image description');
	
//test JSON representation for the LightArticle() class
$lightArticle = new LightArticle(1, 'LightArticle', '2009-10-8', null);


//----------------------------------------------------------------------------------------

//load categories list
$categories = array(
		new Category(1,'Kunst','KunstDescription'), 
		new Category(2,'Design','DesignDescription'), 
		new Category(3,'Fotografie','FotografieDescription'), 
		new Category(4,'Architektur','ArchitekturDescription'),
		new Category(5,'Video','VideoDescription'),
		new Category(6,'Sonstiges','SonstigesDescription'),
		new Category(7,'Monifaktur','MonifakturDescription'),
		new Category(8,'Ignant.TV','Ignant.TVDescription') 		
);


$testImagesDirectory = 'test_images/big/';
$testImagesSuffix = '_big';
$testImagesExtension = 'jpg';


class LightArticlesTest
{
	public function getAllCategories()
	{
		global $categories;		
		return $categories;
	}

	public function getRelatedArticlesForArticleId($articleID='')
	{
		global $testImagesDirectory;
		global $testImagesSuffix;
		global $testImagesExtension;
		
		$relatedArticlesArray = array();
		
		
		//!!!!!!!!!!!!!!!!!!!!!!
		//TODO: add method to LightArticle: getRelatedArticle() !
		
		//------
		$imageDirectoryPath = $testImagesDirectory.'lego_pre'.$testImagesSuffix.'.'.$testImagesExtension;
		$base64Image = createBase64Image('imagine', 'Some image description', $imageDirectoryPath);
		 $relatedArticlesArray[] = new RelatedArticle('imagine', 'Imagine', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)),$this->getCategoryWithId(6), $base64Image);
		
		//------
		$tempArticleId = 'hui_yi';
		$base64Image2 = createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'hui_pre'.$testImagesSuffix.'.'.$testImagesExtension);
		 $relatedArticlesArray[] = new RelatedArticle($tempArticleId, 'Huy Yi', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)),$this->getCategoryWithId(3), $base64Image2);
		
		//------
		$imageDirectoryPath3 = $testImagesDirectory.'elodie_pre'.$testImagesSuffix.'.'.$testImagesExtension;
		$base64Image3 = createBase64Image('elodie_antoine', 'Some image description', $imageDirectoryPath3);
		
		 $relatedArticlesArray[] = new RelatedArticle('elodie_antoine', 'Elodie Antoine', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)),$this->getCategoryWithId(1), $base64Image3);
		
		
		return $relatedArticlesArray;
	}
	
	
	public function getRemoteImagesForArticleId($articleID='')
	{
		$remoteImagesArray = array();
		
		if( strcmp($articleID,'cecilia_paredes')==0) 
		{
						
			$remoteImagesArray[] = new RemoteImage('cecilia_01','http://www.ignant.de/wp-content/uploads/2012/02/cecilia01.jpg','descriptiondescription', 720, 725);
			$remoteImagesArray[] = new RemoteImage('cecilia_02','http://www.ignant.de/wp-content/uploads/2012/02/cecilia02.jpg','descriptiondescription', 720, 653);
			$remoteImagesArray[] = new RemoteImage('cecilia_03','http://www.ignant.de/wp-content/uploads/2012/02/cecilia03.jpg','descriptiondescription', 720, 720);
			$remoteImagesArray[] = new RemoteImage('cecilia_04','http://www.ignant.de/wp-content/uploads/2012/02/cecilia04.jpg','descriptiondescription', 720, 679);
			$remoteImagesArray[] = new RemoteImage('cecilia_05','http://www.ignant.de/wp-content/uploads/2012/02/cecilia05.jpg','descriptiondescription', 720, 720);
			$remoteImagesArray[] = new RemoteImage('cecilia_06','http://www.ignant.de/wp-content/uploads/2012/02/cecilia06.jpg','descriptiondescription', 720, 720);
			$remoteImagesArray[] = new RemoteImage('cecilia_07','http://www.ignant.de/wp-content/uploads/2012/02/cecilia07.jpg','descriptiondescription', 720, 727);
			$remoteImagesArray[] = new RemoteImage('cecilia_08','http://www.ignant.de/wp-content/uploads/2012/02/cecilia08.jpg','descriptiondescription', 720, 806);
		
					
		}
		else if( strcmp($articleID,'hui_yi')==0) 
		{	
				$remoteImagesArray[] = new RemoteImage('hui_yi_01','http://www.ignant.de/wp-content/uploads/2012/03/hui1.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_02','http://www.ignant.de/wp-content/uploads/2012/03/hui2.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_03','http://www.ignant.de/wp-content/uploads/2012/03/hui3.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_04','http://www.ignant.de/wp-content/uploads/2012/03/hui4.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_05','http://www.ignant.de/wp-content/uploads/2012/03/hui5.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_06','http://www.ignant.de/wp-content/uploads/2012/03/hui6.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_07','http://www.ignant.de/wp-content/uploads/2012/03/hui7.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_08','http://www.ignant.de/wp-content/uploads/2012/03/hui8.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('hui_yi_09','http://www.ignant.de/wp-content/uploads/2012/03/hui9.jpg','descriptiondescription');

		}
		
		else if( strcmp($articleID,'imagine')==0) 
		{	
				$remoteImagesArray[] = new RemoteImage('imagine_01','http://www.ignant.de/wp-content/uploads/2012/03/lego_01.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_02','http://www.ignant.de/wp-content/uploads/2012/03/lego_02.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_03','http://www.ignant.de/wp-content/uploads/2012/03/lego_03.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_04','http://www.ignant.de/wp-content/uploads/2012/03/lego_04.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_05','http://www.ignant.de/wp-content/uploads/2012/03/lego_05.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_06','http://www.ignant.de/wp-content/uploads/2012/03/lego_06.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_07','http://www.ignant.de/wp-content/uploads/2012/03/lego_07.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('imagine_08','http://www.ignant.de/wp-content/uploads/2012/03/lego_08.jpg','descriptiondescription');

		}

		else if( strcmp($articleID,'elodie_antoine')==0) 
		{	
				$remoteImagesArray[] = new RemoteImage('elodie_antoine_01','http://www.ignant.de/wp-content/uploads/2012/03/elodie_1.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('elodie_antoine_02','http://www.ignant.de/wp-content/uploads/2012/03/elodie_2.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('elodie_antoine_03','http://www.ignant.de/wp-content/uploads/2012/03/elodie_3.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('elodie_antoine_04','http://www.ignant.de/wp-content/uploads/2012/03/elodie_4.jpg','descriptiondescription');
				$remoteImagesArray[] = new RemoteImage('elodie_antoine_05','http://www.ignant.de/wp-content/uploads/2012/03/elodie_5.jpg','descriptiondescription');
		}

		else if( strcmp($articleID,'mark_powell')==0)
		{			
			
			$remoteImagesArray[] = new RemoteImage('mark_powell_01','http://www.ignant.de/wp-content/uploads/2012/02/envelope-01.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_02','http://www.ignant.de/wp-content/uploads/2012/02/envelope-02.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_03','http://www.ignant.de/wp-content/uploads/2012/02/envelope-03.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_04','http://www.ignant.de/wp-content/uploads/2012/02/envelope-04.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_05','http://www.ignant.de/wp-content/uploads/2012/02/envelope-05.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_06','http://www.ignant.de/wp-content/uploads/2012/02/envelope-06.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_07','http://www.ignant.de/wp-content/uploads/2012/02/envelope-07.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_08','http://www.ignant.de/wp-content/uploads/2012/02/envelope-08.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('mark_powell_09','http://www.ignant.de/wp-content/uploads/2012/02/envelope-09.jpg','descriptiondescription');
			
		}
		
		else if( strcmp($articleID,'swellendamm_haus')==0)
		{
			
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_01','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-01.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_02','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-02.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_03','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-03.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_04','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-04.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_05','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-05.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_06','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-06.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_07','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-07.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_08','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-08.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('swellendamm_haus_09','http://www.ignant.de/wp-content/uploads/2012/02/swellendam-09.jpg','descriptiondescription');
			
			
		}
		
		else if( strcmp($articleID,'ashkan_honarvar')==0)
		{
			
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_01','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar1.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_02','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar2.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_03','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar3.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_04','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar4.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_05','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar5.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_06','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar6.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_07','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar7.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_08','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar8.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('ashkan_honarvar_08','http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar9.jpg','descriptiondescription');
			
		}
		
		else if( strcmp($articleID,'henrique_oliveira')==0)
		{
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_01','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira1.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_02','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira2.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_03','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira3.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_04','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira4.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_05','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira5.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_06','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira6.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_07','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira7.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('henrique_oliveira_08','http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira8.jpg','descriptiondescription');
			
		}
		
		else if( strcmp($articleID,'alicia')==0)
		{
						
			$remoteImagesArray[] = new RemoteImage('alicia_01','http://www.ignant.de/wp-content/uploads/2012/01/alicia01.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_02','http://www.ignant.de/wp-content/uploads/2012/01/alicia02.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_03','http://www.ignant.de/wp-content/uploads/2012/01/alicia03.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_04','http://www.ignant.de/wp-content/uploads/2012/01/alicia04.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_05','http://www.ignant.de/wp-content/uploads/2012/01/alicia05.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_06','http://www.ignant.de/wp-content/uploads/2012/01/alicia06.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_07','http://www.ignant.de/wp-content/uploads/2012/01/alicia07.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('alicia_08','http://www.ignant.de/wp-content/uploads/2012/01/alicia08.jpg','descriptiondescription');
			
			
		}
		
		else if( strcmp($articleID,'brian')==0)
		{
			$remoteImagesArray[] = new RemoteImage('brian_01','http://www.ignant.de/wp-content/uploads/2012/02/Brian_01.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_02','http://www.ignant.de/wp-content/uploads/2012/02/Brian_02.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_03','yyyyyyyyy','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_04','http://www.ignant.de/wp-content/uploads/2012/02/Brian_04.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_05','http://www.ignant.de/wp-content/uploads/2012/02/Brian_05.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_06','http://www.ignant.de/wp-content/uploads/2012/02/Brian_06.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_07','http://www.ignant.de/wp-content/uploads/2012/02/Brian_07.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('brian_08','http://www.ignant.de/wp-content/uploads/2012/02/Brian_08.jpg','descriptiondescription');
			
		}
		
		else if( strcmp($articleID,'wood')==0)
		{
			$remoteImagesArray[] = new RemoteImage('wood_01','http://www.ignant.de/wp-content/uploads/2012/02/wood_01.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_02','http://www.ignant.de/wp-content/uploads/2012/02/wood_02.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_03','http://www.ignant.de/wp-content/uploads/2012/02/wood_03.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_04','http://www.ignant.de/wp-content/uploads/2012/02/wood_04.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_05','http://www.ignant.de/wp-content/uploads/2012/02/wood_05.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_06','http://www.ignant.de/wp-content/uploads/2012/02/wood_06.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_07','http://www.ignant.de/wp-content/uploads/2012/02/wood_07.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_08','http://www.ignant.de/wp-content/uploads/2012/02/wood_08.jpg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('wood_09','http://www.ignant.de/wp-content/uploads/2012/02/wood_09.jpg','descriptiondescription');
			
		}
		
		else if( strcmp($articleID,'martins_edgar')==0)
		{
			$remoteImagesArray[] = new RemoteImage('martins_01','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar01.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_02','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar02.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_03','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar03.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_04','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar04.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_05','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar05.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_06','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar06.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_07','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar07.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_08','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar08.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_09','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar09.jpeg','descriptiondescription');
			$remoteImagesArray[] = new RemoteImage('martins_10','http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgar10.jpeg','descriptiondescription');
			
	
		}
		
		
		return $remoteImagesArray;
	}
	
	
	public function getTestDescriptionTextForArticleId($articleID='')
	{
		
	
		if( strcmp($articleID,'mark_powell')==0)
		return 'Mark Powell zeichnet Menschen der älteren Generation auf gebrauchte Briefumschläge. Dabei benutzt er nichts außer Papier und Kugelschreiber. Powell bannt auf eine fast nostalgische Art und Weise die ausdrucksstarken Gesichter, Falten und Runzeln seiner Motive auf das Briefpapier. Dabei kommen die Gesichter auf den benutzen Umschlägen besonders gut zur Geltung und verbinden sich zu einer gutmütigen Dokumentation des kontinuierlichen Zerfalls.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'hui_yi')==0) 
		return 'Hui Yi thematisiert in ihren Fotografien Mädchenträume. Sie konzentriert sich auf die Erwartungen und Fantasien von jungen Frauen in verschiedenen Altersstufen. In ihnen vertrauten Umgebungen sollen die Mädchen ihre inneren Welten erkunden. Hui Yis Fotografien schlagen damit eine Brücke zwischen der realen Welt und dem Innenleben der Protagonisten. Die dabei entstehenden Szenen muten als eine Mischung von Fantasien verschiedener Entwicklungsstufen surreal bis märchenhaft an.';
		
		
		//---------------------------------------------
		else if( strcmp($articleID,'imagine')==0) 
		return '\'Imagine\' heißt die neue Kampagne von dem dänischen Spielzeughersteller LEGO. Sie wurde von der Hamburger Werbeagentur Jung von Matt umgesetzt und zeigt die Hauptdarsteller von Cartoonserien wie Simpsons, Turtles, Southpark oder Asterix und Obelix. Die einzelnen Charaktere wurden sehr minimalistisch mit wenigen LEGO Steinen nachgebaut und sind für den ein oder anderen wohl erst auf den zweiten Blick zu erkennen.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'elodie_antoine')==0) 
		return 'Elodie Antoine kreiert Objekte und Landschaften aus Faden. Aus haushaltsüblichem schwarzen Bindfaden entstehen unter ihren Händen Kräne, Zäune, Brücken und Schornsteine. Antoine benutzt in ihren Arbeiten gerne Alltagsgegenstände und transformiert sie in etwas ganz neues, das ihnen weder in Form noch Funktion entspricht.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'cecilia_paredes')==0) 
		return 'Cecilia Paredes verschmilzt mit der Wand. Die peruanische Künstlerin bemalt ihren Körper so, dass sie eins wird mit dem Muster der Tapete im Hintergrund. Manchmal mit bloßem Auge kaum mehr erkennbar, stellt sie mit ihren Arbeiten die menschliche Identität in Frage und bewegt sich irgendwo zwischen Sein und Schein. Paredes experimentiert mit der Verschmelzung ihres Körpers mit seiner Umgebung. Sie macht damit auf die menschliche Suche nach seinem Platz im Leben sowie die Vergänglichkeit seiner physikalischen Form aufmerksam.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'swellendamm_haus')==0) 
		return 'Das ‘Swellendamm Haus’ liegt an der Spitze Südafrikas in einer Hügellandschaft aus saftigem Grün und den grenzenlosen Weiten des umliegenden Nationalparks. Von den Einheimischen als ‘God´s Window’ bezeichnet, ist die unmittelbare Nähe zur Wiege des Lebens beinahe spürbar.

			Von der simplen Schönheit der Umgebung inspiriert, entwarf der Architekt Georg van Gass das hufeisenförmige Haus. Er nutzte dabei klare Formen und einfache Materialien, um den Bau bestmöglich in die Landschaft zu integrieren. Ein weiteres Anliegen war, das Haus nachhaltig zu gestalten, so dass es mit der üppigen Natur in harmonischem Einklang existieren kann. Das Haus setzt sich aus drei kastenförmigen Gebäuden zusammen, welche einen großzügigen Innenhof umschließen. Das größte der drei Gebäude beherbergt die Gemeinschaftsräume und lässt sich nach allen Seiten hin öffnen. Die beiden schmaleren Formen dagegen stellen in einer höhlenartigen Gemütlichkeit Schlaf- und Badezimmer bereit sowie auf einer Seite ein kleines Heimkino. Die Hufeisenform öffnet sich einseitig zu einer beindruckenden Sicht auf die umliegenden Berge und begibt sich in einen scheinbaren Dialog zwischen Himmel und Erde.';
			
		//---------------------------------------------
		else if( strcmp($articleID,'ashkan_honarvar')==0) 
		return 'In der Serie ‘Faces’ veranschaulicht der Künstler Ashkan Honarvar seine Suche nach der Identität und den physischen sowie auch psychologischen Wunden, unter denen die Soldaten nach dem Krieg jahrelang leiden. Honarvars greift auf existierende Bilder zurück, die verstümmelte Soldaten des ersten Weltkrieges zeigen und kreiert daraus neue verstörende, makabere Bildnisse. Schönheit soll sich in unterschiedlichster Gestalt zeigen, allerdings bezweifelt man dies bei solchen Bildnissen. Doch Hinarvar beschreibt eine unbestreitbare Schönheit, wenn man bereit ist, die dunklen Seiten der menschlichen Natur zu akzeptieren.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'alicia')==0) 
		return 'Alicia Kwade ist mit der Kunst aufgewachsen und hat selbige in Berlin studiert. Durch die Galerie ihres Vaters kam sie schon früh in Kontakt mit der Szene und bald stand für die junge Kwade fest, dass auch sie ihr Leben dem kreativen Schaffen widmen möchte. Ihre Arbeiten sind inspiriert von Ideen. Ideen, die sie in Büchern, von der Wissenschaft, durch Naturphänomene oder das Weltgeschehen erhält.

			Durch die intensive Auseinandersetzung mit den unterschiedlichsten Themengebieten kommen immer wieder Fragen auf, mit denen sie sich in ihren Arbeiten kritisch auseinandersetzt. Für den Betrachter werden dabei auf bildhafte, oft ironische Weise zentrale Inhalte und Gedankengänge transparent dargestellt. Ihre Werke beschränken sich auf kein bestimmtes Genre. Die Übergänge von Video, Bildhauerei und Installationen sind fließend.

			Im Jahre 2008 erhielt Kwade den Piepenbrock-Preis für Skulptur, verbunden mit einer Gastprofessur an der UdK Berlin.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'brian')==0) 
		return 'Im vergangenen Jahr berichteten wir schon einmal über die Arbeiten von Brian Dettmer. Dettmer verarbeitet alte Bücher, vorzugsweise Enzyklopädien, Wörterbücher oder Lexika zu Kunstwerken. Er schenkt dem Medium Buch damit neue Aufmerksamkeit und macht die unzähligen Informationen darin auf ungewohnte Weise sichtbar.

			Informationsflüsse haben, durch das Zeitalter des Internets, eine neue physikalische Form angenommen und hinterlassen das greifbare Buch als Zeitzeugen vergangener Tage. Die unsichtbaren Datenströme des Worldwide Web übernehmen und hinterlassen keinerlei Spur in der realen Welt. So mag das Buch mit seine Informationen vielleicht veraltet sein aber es ist beständig, während Informationen im Internet ungreifbar verschwinden und für immer verloren gehen.

			Seine neusten Werke werden ab heute unter dem Titel ‘Textonomy’ in der Toomey Tourell Gallery in San Francisco gezeigt.

			‘The richness and depth of the book is universally respected yet often undiscovered as the monopoly of the form and relevance of the information fades over time. The book’s intended function has decreased and the form remains linear in a non-linear world. By altering physical forms of information and shifting preconceived functions, new and unexpected roles emerge. This is the area I currently operate in. Through meticulous excavation or concise alteration I edit or dissect communicative objects or systems such as books, maps, tapes and other media. The medium’s role transforms. Its content is recontextualized and new meanings or interpretations emerge.’';
		
		//---------------------------------------------	
		else if( strcmp($articleID,'wood')==0) 
		return 'Den Fokus seiner Arbeit legt der junge Künstler Geordie Wood aus Brooklyn, New York auf Portraitaufnahmen und Modefotografie. Schon kurz nach seinem Abschluss in Fotojournalismus und Studiofotografie an der Syrancuse University arbeitete er für namhafte Publikationen wie Complex oder das WAD Magazine.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'martins_edgar')==0) 
		return 'Der verbaute Blick aus seinem Atelier der University of Sao Paulo, bescherte dem damaligen Student der bildenen Kunst, Henrique Oliveira eine künstlerische Wende. Über einen längeren Zeitraum konnte er beobachten, wie sich die Beschaffenheit eines hölzernen Bauzaunes, der sich vor dem Fenster des Ateliers befand, veränderte und sich aufgrund der Witterung in mehrere Schichten spaltete und verschiedene Holztönungen zum Vorschein kamen.

			Da ihn dieser Prozess, den er von der Malerei kannte, faszinierte, sammelte er nach Auflösung der Baustelle das Holz ein und verwendete es in seiner ersten Installation. Er suchte nach grafischen Elementen und Formen auf Bildern, die er dann in die dritte Dimension übertrug. Damit schuf er eine Verbindung zwischen der Malerei und seinen dreidimensionalen Kunstwerken. Seine Installationen reiften zu riesigen aufwendigen Konstruktionen, die teilweise von Stützwänden und anderen Stützkonstruktionen gehalten werden. Für die Oberfläche der Arbeiten benutzt er weiterhin hauptsächlich aufgesammeltes Holz von Bauzäunen, die in den Straßen Sao Paulos reichlich vertreten sind.';
		
		//---------------------------------------------
		else
		return 'Stefano Bellamoli experimentierte f&#252;r seine Arbeit &#8216;More light to come&#8217; mit Formen aus Licht. Sein Ziel war es, &#252;ber Kritzeleien und Muster hinaus, dreidimensionale Objekte zu erschaffen. Daf&#252;r hat er sich unter die Erde begeben. Abgeschirmt von allen anderen Lichtquellen entstanden in den dunklen Gew&#246;lben Spiralen und K&#228;fige aus Licht. Geheimnisvoll muten die Kreationen unter';
	}
	
	
	//get the category id for a given parameter
	public function getCategoryWithId($categoryId = ID_FOR_HOME_CATEGORY){

		global $categories;
		
		if($categoryId === '' || $categoryI<0 ) return null;

		foreach($categories as $oneCategory )
		{
			if($oneCategory->id == $categoryId)
			return $oneCategory;
		}
		
		return null;
	}
	
	
	public function getJSONReadyArrayForArticleForId($articleId = '')
	{
		$articleArray =  null;
		$oneArticle = null;
		$oneArticle = $this->getLightArticleForArticleId($articleId);
		$articleArray = ($oneArticle == null) ?  array() : $oneArticle->getArrayForJSONEncoding();
		
		return $articleArray;
	}
		
	public function getLightArticlesArray(){
		
		$lightArticles = array();
		
		global $testImagesDirectory;
		global $testImagesSuffix;
		global $testImagesExtension;
		$shouldIncludeImageBase64 = true;
		
		$tempArticleId = null;
		
		//set up articles
		$lightArticles = array();
		$tempArticleId = 'cecilia_paredes';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'CECILIA PAREDES', date('Y-m-d', mktime(0, 0, 0, 2, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image('cecilia_paredes', 'Some image description',$testImagesDirectory.'cecilia_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId),  $this->getCategoryWithId(1),$tempArticleUrl);
		
		$tempArticleId = 'mark_powell';
		$tempArticleUrl = 'http://www.ignant.de/2011/04/27/mark-powell/';
		$lightArticles[] = new LightArticle($tempArticleId, 'MARK POWELL', date('Y-m-d', mktime(0, 0, 0, 2, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'mark_powell_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(1),$tempArticleUrl);
		
		$tempArticleId = 'swellendamm_haus';
		$tempArticleUrl = 'http://www.ignant.de/2012/01/05/allandale-house/';
		$lightArticles[] = new LightArticle($tempArticleId, 'SWELLENDAMM HAUS', date('Y-m-d', mktime(0, 0, 0, 2, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'swellendam_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(2),$tempArticleUrl);
		
		$tempArticleId = 'ashkan_honarvar';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/02/ashkan-honarvar-2/';
		$lightArticles[] = new LightArticle($tempArticleId, 'ASHKAN HONARVAR', date('Y-m-d', mktime(0, 0, 0, 1, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'ashkan_honarvar_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(2),$tempArticleUrl);
		
		$tempArticleId = 'alicia';
		$tempArticleUrl = 'http://www.ignant.de/2012/01/31/alicia-kwade/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Alicia', date('Y-m-d', mktime(0, 0, 0, 1, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'alicia_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(3),$tempArticleUrl);
		
		$tempArticleId = 'brian';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/02/brian-dettmer-2/';
		$lightArticles[] = new LightArticle($tempArticleId, 'BRIAN', date('Y-m-d', mktime(0, 0, 0, 1, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'brian_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(3),$tempArticleUrl);
		
		$tempArticleId = 'henrique_oliveira';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/02/henrique-oliveira/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Henrique Oliviera', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'henrique_oliveira_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'wood';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/01/geordie-wood/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Wood', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'wood_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'martins_edgar';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/01/edgar-martins/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Martins Edgar', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'martins_edgar_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(5),$tempArticleUrl);
		
		$tempArticleId = 'imagine';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Imagine', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'lego_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(5),$tempArticleUrl);
		
		$tempArticleId = 'elodie_antoine';
		$tempArticleUrl = 'http://www.ignant.de/2012/03/16/imagine/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Elodie Antoine', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'elodie_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'hui_yi';
		$tempArticleUrl = 'http://www.ignant.de/2012/03/19/hui-yi/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Huy Yi', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'hui_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_2';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 2', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_2_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_2_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'test_3';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 3', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_3_img', 'http://www.ignant.de/wp-content/uploads/2012/06/socialnetwork03.jpg', 'test_3_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'test_4';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 4', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_4_img', 'http://www.ignant.de/wp-content/uploads/2012/06/urbangreen02a.jpg', 'test_4_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'test_5';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 5', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_5_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_5_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'test_6';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 6', date('Y-m-d', mktime(0, 0, 0, 2, 1, 2012)), createRemoteImage('test_6_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_6_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'test_7';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 7', date('Y-m-d', mktime(0, 0, 0, 2, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_8';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 8', date('Y-m-d', mktime(0, 0, 0, 2, 1, 2012)), createRemoteImage('test_8_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_8_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'test_9';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 9', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_10';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 10', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_11';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 11', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_12';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 12', date('Y-m-d', mktime(0, 0, 0, 12, 12, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_13';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 13', date('Y-m-d', mktime(0, 0, 0, 12, 12, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_14';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 14', date('Y-m-d', mktime(0, 0, 0, 12, 12, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		return $lightArticles;
		
	}	
	
	public function getLightArticleForArticleId($articleId = ''){
		
		$lightArticles = $this->getLightArticlesArray();
		
		//iterate the articles and return the one that matches the id
		foreach($lightArticles as $lightArticle)
		{
			if(strcmp($lightArticle->id,$articleId)==0){
				return $lightArticle; break;
			}
		}
		
		//no articles found with articleId
		return null;
	}
	
	public function getMoreTumblrPosts($pTimestamp=0, $limit=10)
	{
		$moreTumblrPosts = array();
		
		if($pTimestamp==0) return $moreTumblrPosts;
		
		//read contents from saved tumblr file into string
		$tumblrContentString = null;
		
		$myFile = "tumblrDataDump.txt";
		$fh = fopen($myFile, 'r');
		$tumblrContentString = fread($fh, filesize($myFile));
		fclose($fh);
		
		//read all the posts from the saved file
		$jsonObject = json_decode($tumblrContentString);
		$postsFromSavedFile = $jsonObject->{TL_POSTS};
		
		//retrieve $limit posts after the given timestamp
		$validCounter = 1;
		
		if(is_array($postsFromSavedFile) && count($postsFromSavedFile)>0)
		foreach($postsFromSavedFile as $onePost)
		{
			if($validCounter>$limit) break;
			
			if($onePost->{TUMBLR_POST_PUBLISHING_DATE}<$pTimestamp){
				$moreTumblrPosts[] = $onePost;
				$validCounter++;
			}
		}
		
		return $moreTumblrPosts;
	}
	
	public function getMoreArticlesForCategory($pCategoryId = 0, $pDateOfLatestArticle = '0000-00-00'){
		$latestArticlesArray = array();
		
		if (strcmp($pCategoryId,ID_FOR_HOME_CATEGORY)==0) 
		{
			$latestArticlesArray[] = $this->getLightArticleForArticleId('imagine');
			$latestArticlesArray[] = $this->getLightArticleForArticleId('hui_yi');
			$latestArticlesArray[] = $this->getLightArticleForArticleId('elodie_antoine');
			
		}
		else if(strcmp($pCategoryId,"4")==0)
		{
			$latestArticlesArray[] = $this->getLightArticleForArticleId('test_12');
			$latestArticlesArray[] = $this->getLightArticleForArticleId('test_13');
			$latestArticlesArray[] = $this->getLightArticleForArticleId('test_14');
			
			
		}
		
		
		
		
		
			
		return $latestArticlesArray;
	}
	
	public function getLastestArticlesForCategory($pCategoryId = 0){
		$latestArticlesArray = array();
		
		//WARNING: just temp, just for testing
		$tempArticles = 8;	
		
		//-------
		$lightArticles = $this->getLightArticlesArray();
		
		//iterate the articles and return the one that matches the id
		$counter = 0;
		foreach($lightArticles as $lightArticle)
		{
			if($counter>$tempArticles) break;
			
			//only select articles with that specific category id
			if($lightArticle->rCategory->id==$pCategoryId || $pCategoryId==ID_FOR_HOME_CATEGORY)
			{
				$latestArticlesArray[] = $lightArticle;
				$counter++;
			}
		}
		
		return $latestArticlesArray;
	}
	
	public function printJSONForRandomLightArticles($shouldIncludeImageBase64 = false, $saveToFile = false, $fileName = 'dump_LightArticlesTest.txt'){
		
		$finalJSONArrayForExport = array();
		
		//load meta data
		$finalJSONArrayForExport[TL_META_INFORMATION][TL_OVERWRITE] = YES;
		$finalJSONArrayForExport[TL_META_INFORMATION][TL_CATEGORIES_LIST] = $categories;
		
		//-------------------------
		$lightArticles = $this->getLightArticlesArray();
		
		
		//load light articles
		$lightArticlesForExport = array();
		foreach($lightArticles as $article)
		{
			$lightArticlesForExport[] = $article->getArrayForJSONEncoding();
			$jsonExportString.= $article->getJSONRepresentation();
		}
		$finalJSONArrayForExport[TL_ARTICLES] = $lightArticlesForExport;
		
		//encode the final Array and print it our
		$jsonExportString = json_encode($finalJSONArrayForExport);
		// print $jsonExportString;
		
		//save the file if necessary
		if($saveToFile){
			$fp = fopen($fileName, 'w');
			fwrite($fp, utf8_encode($jsonExportString));
			fclose($fp);
		}	
	}	
}

// $lightArticlesTest = new LightArticlesTest();
// $lightArticlesTest->printJSONForRandomLightArticles(true);

?>