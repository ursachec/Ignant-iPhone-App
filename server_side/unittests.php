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
require_once('classes/MosaicEntry.php');

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
		new Category(8,'Ignant.TV','Ignant.TVDescription'),
		new Category(9,'IgnanTravel','IgnantTRAVEL.Description'),		
		new Category(10,'Aicuisine','Aicuisine.Description'),
		new Category(11,'Daily Basics','Daily Basics.Description')
);


$testImagesDirectory = 'test_images/big/';
$testImagesSuffix = '_big';
$testImagesExtension = 'jpg';


function get_path_info()
{
    if( ! array_key_exists('PATH_INFO', $_SERVER) )
    {
        $pos = strpos($_SERVER['REQUEST_URI'], $_SERVER['QUERY_STRING']);
    
        $asd = substr($_SERVER['REQUEST_URI'], 0, $pos - 2);
        $asd = substr($asd, strlen($_SERVER['SCRIPT_NAME']) + 1);
        
        return $asd;    
    }
    else
    {
       return trim($_SERVER['PATH_INFO'], '/');
 
   }
}

class LightArticlesTest
{
	public function getVideoLinkForArticleId($articleID='')
	{	
		$path_parts = pathinfo($_SERVER['SCRIPT_NAME']);
		$script_dir = $path_parts['dirname'];
		$videosDir = 'http://'.$_SERVER['SERVER_NAME'].$script_dir.'/test_videos';
		
		$videoLinks = array();
		$videoLinks['itv_kjosk']=$videosDir.'/kjosk/prog_index.m3u8';
		$videoLinks['itv_disco_ball']=$videosDir.'/live_disco_ball/prog_index.m3u8';
		
		foreach ($videoLinks as $article_id => $article_link) {
			if(strcmp($articleID, $article_id)==0)
			return $article_link;
		}
		
		return null;
	}
	
	public function getThumbLinkForArticleId($articleID='')
	{
			$thumbLinks = array();
		
			$thumbLinks['henrique_oliveira']='http://www.ignant.de/wp-content/uploads/2012/02/henrique-oliveira_pre.jpg';
			$thumbLinks['mark_powell']='http://www.ignant.de/wp-content/uploads/2012/06/evanspre.jpg';
			$thumbLinks['hui_yi']='http://www.ignant.de/wp-content/uploads/2012/03/huipre.jpg';
			$thumbLinks['imagine']='http://www.ignant.de/wp-content/uploads/2012/03/lego_pre.jpg';
			$thumbLinks['elodie_antoine']='http://www.ignant.de/wp-content/uploads/2012/03/elodie_pre.jpg';
			$thumbLinks['cecilia_paredes']='http://www.ignant.de/wp-content/uploads/2012/02/ceciliapre.jpg';
			$thumbLinks['swellendamm_haus']='http://www.ignant.de/wp-content/uploads/2012/02/swellendam-pre.jpg';
			$thumbLinks['ashkan_honarvar']='http://www.ignant.de/wp-content/uploads/2012/02/ashkan-honarvar_pre.jpg';
			$thumbLinks['alicia']='http://www.ignant.de/wp-content/uploads/2012/01/aliciapre.jpg';
			$thumbLinks['brian']='http://www.ignant.de/wp-content/uploads/2012/02/Brian_pre1.jpg';
			$thumbLinks['wood']='http://www.ignant.de/wp-content/uploads/2012/02/wood_pre.jpg';
			$thumbLinks['martins_edgar']='http://www.ignant.de/wp-content/uploads/2012/02/Martins.Edgarpre.jpeg';
			$thumbLinks['monifaktur_cd']='http://www.ignant.de/wp-content/uploads/2013/05/mon_pre.jpg';
		
		$thumbLinks['monifaktur_cards']='http://www.ignant.de/2011/08/15/moni-spielt-mit-offenen-karten/';
			$thumbLinks['monifaktur_49']='http://www.ignant.de/wp-content/uploads/2012/11/kleines-YouTube.jpg';
				$thumbLinks['monifaktur_48']='http://www.ignant.de/wp-content/uploads/2011/10/Moniversum-copy.jpg';
				$thumbLinks['monifaktur_cards']='http://www.ignant.de/wp-content/uploads/2012/08/karten-klein.jpg';

			$thumbLinks['aicuisine_steak_sandwich']='http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-pre.jpg';
			$thumbLinks['ignantravel_riche_stockholm']='http://www.ignant.de/wp-content/uploads/2012/06/travel6.jpg';
			
			$thumbLinks['itv_kjosk']='http://www.ignant.de/wp-content/uploads/2011/10/kjosk_pre2.jpg';
			$thumbLinks['itv_disco_ball']='http://www.ignant.de/wp-content/uploads/2011/10/brunokol_pre.jpg';
			
			
			
			$thumbLinks['test_2']='http://www.ignant.de/wp-content/uploads/2012/06/osma_pre.jpg';
			$thumbLinks['test_3']='http://www.ignant.de/wp-content/uploads/2012/06/flickr_friday_07.06.pre_.jpg';
			$thumbLinks['test_4']='http://www.ignant.de/wp-content/uploads/2012/06/hoeckelpre.jpg';
			$thumbLinks['test_5']='http://www.ignant.de/wp-content/uploads/2012/06/face.jpg';
			$thumbLinks['test_6']='http://www.ignant.de/wp-content/uploads/2012/06/urbangreenpre.jpg';
			$thumbLinks['test_7']='http://www.ignant.de/wp-content/uploads/2012/06/herdernpre.jpg';
			$thumbLinks['test_8']='http://www.ignant.de/wp-content/uploads/2012/06/ignant_finding_pre.jpg';
			$thumbLinks['test_9']='http://www.ignant.de/wp-content/uploads/2012/06/streetfurniturepre.jpg';
			$thumbLinks['test_10']='http://www.ignant.de/wp-content/uploads/2012/06/Verities_pre.jpg';
			$thumbLinks['test_11']='http://www.ignant.de/wp-content/uploads/2012/06/drawingmachine_pre.jpg';
			$thumbLinks['test_12']='http://www.ignant.de/wp-content/uploads/2012/06/housec_pre2.jpg';
			$thumbLinks['test_13']='http://www.ignant.de/wp-content/uploads/2012/06/mirrorhouse_pre.jpg';
			$thumbLinks['test_14']='http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-pre.jpg';
						
			foreach ($thumbLinks as $article_id => $article_link) {
				if(strcmp($articleID, $article_id)==0)
				return $article_link;
			}
						
			return;
	}
	
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
	
	
	//probably better to get it for category id
	public function getTestTemplateForArticleId($articleID='')
	{
		if( strcmp($articleID,'monifaktur_cd')==0 || strcmp($articleID,'monifaktur_49')==0 || strcmp($articleID,'monifaktur_48')==0 || strcmp($articleID,'monifaktur_cards')==0)
			return FK_ARTICLE_TEMPLATE_MONIFAKTUR;
		
		else if(strcmp($articleID,'aicuisine_steak_sandwich')==0 )
			return FK_ARTICLE_TEMPLATE_AICUISINE;
		
		else if(strcmp($articleID,'ignantravel_riche_stockholm')==0 )
			return FK_ARTICLE_TEMPLATE_ITRAVEL;	
			

		else if(strcmp($articleID,'itv_kjosk')==0 || strcmp($articleID,'itv_disco_ball')==0 )
			return FK_ARTICLE_TEMPLATE_VIDEO;
			
			
		else
			return FK_ARTICLE_TEMPLATE_DEFAULT;
	}
			
			
	public function getTestDescriptionTextForArticleId($articleID='')
	{
		
		if( strcmp($articleID,'mark_powell')==0)
		return 'Eindrucksvolle Portraitaufnahmen von dem mexikanischen Fotografen <a href="http://markalor.com/" target="_blank">Mark Powell</a>. Mir ist es noch nie so schwer gefallen eine passende Auswahl an Bildern zu finden, weshalb ihr unbedingt auch seine Homepage besuchen solltet. Es lohnt sich!<!--more-->';
		
		//---------------------------------------------
		else if( strcmp($articleID,'hui_yi')==0) 
		return '<a href="http://www.flickr.com/photos/yihuisu0830/">Hui Yi</a> thematisiert in ihren Fotografien Mädchenträume. Sie konzentriert sich auf die Erwartungen und Fantasien von jungen Frauen in verschiedenen Altersstufen. In ihnen vertrauten Umgebungen sollen die Mädchen ihre inneren Welten erkunden. Hui Yis Fotografien schlagen damit eine Brücke zwischen der realen Welt und dem Innenleben der Protagonisten. <!--more-->Die dabei entstehenden Szenen muten als eine Mischung von Fantasien verschiedener Entwicklungsstufen surreal bis märchenhaft an.<br /><em>These pictures are about the dreams of girls, focusing on their expectations and fantasies at different ages. The photographer made the girls explore their inner world by putting them in familiar environment. Thus photography becomes the bridge between reality and the inner world. The photographer created surrealistic fairytale scenes by putting a mixture of fantasies at different ages in one picture.</em>';
		
		//---------------------------------------------
		else if( strcmp($articleID,'imagine')==0) 
		return '"Imagine" heißt die neue Kampagne von dem dänischen Spielzeughersteller <a href="http://www.lego.com/de-DE/default.aspx?domainredir=www.lego.de">LEGO</a>. Sie wurde von der Hamburger Werbeagentur <a href="http://www.jvm.com/">Jung von Matt</a> umgesetzt und zeigt die Hauptdarsteller von Cartoonserien wie Simpsons, Turtles, Southpark oder Asterix und Obelix. <!--more-->Die einzelnen Charaktere wurden sehr minimalistisch mit wenigen LEGO Steinen nachgebaut und sind für den ein oder anderen wohl erst auf den zweiten Blick zu erkennen.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'elodie_antoine')==0) 
		return '<a href="http://elodieantoine.be/">Elodie Antoine</a> kreiert Objekte und Landschaften aus Faden. Aus haushaltsüblichem schwarzen Bindfaden entstehen unter ihren Händen Kräne, Zäune, Brücken und Schornsteine. Antoine benutzt in ihren Arbeiten gerne Alltagsgegenstände und transformiert sie in etwas ganz neues, das ihnen weder in Form noch Funktion entspricht.<!--more--> <br /><em>Elodie Antoine strives for taking complete possession of the space, placing objects in a way which seems as if they self-generated there. She uses textiles in order to create a universe made of organic and vegetable matter where all the items, with their peculiar shapes, seem to be in a state of progression. She explores the potential of materials by allowing them to multiply and outgrow in a way that is natural to them, but which she nonetheless cleverly controls.</em>';
		
		//---------------------------------------------
		else if( strcmp($articleID,'cecilia_paredes')==0) 
		return '<a href="http://www.ceciliaparedes.com/">Cecilia Paredes</a> verschmilzt mit der Wand. Die peruanische Künstlerin bemalt ihren Körper so, dass sie eins wird mit dem Muster der Tapete im Hintergrund. Manchmal mit bloßem Auge kaum mehr erkennbar, stellt sie mit ihren Arbeiten die menschliche Identität in Frage und bewegt sich irgendwo zwischen Sein und Schein. <!--more-->Paredes experimentiert mit der Verschmelzung ihres Körpers mit seiner Umgebung. Sie macht damit auf die menschliche Suche nach seinem Platz im Leben sowie die Vergänglichkeit seiner physikalischen Form aufmerksam.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'swellendamm_haus')==0) 
		return 'Das "Swellendamm Haus" liegt an der Spitze Südafrikas in einer Hügellandschaft aus saftigem Grün und den grenzenlosen Weiten des umliegenden Nationalparks. Von den Einheimischen als "God´s Window" bezeichnet, ist die unmittelbare Nähe zur Wiege des Lebens beinahe spürbar. <!--more--><br />Von der simplen Schönheit der Umgebung inspiriert, entwarf der Architekt <a href="http://www.gass.co.za/">Georg van Gass</a> das hufeisenförmige Haus. Er nutzte dabei klare Formen und einfache Materialien, um den Bau bestmöglich in die Landschaft zu integrieren. Ein weiteres Anliegen war, das Haus nachhaltig zu gestalten, so dass es mit der üppigen Natur in harmonischem Einklang existieren kann. Das Haus setzt sich aus drei kastenförmigen Gebäuden zusammen, welche einen großzügigen Innenhof umschließen. Das größte der drei Gebäude beherbergt die Gemeinschaftsräume und lässt sich nach allen Seiten hin öffnen. Die beiden schmaleren Formen dagegen stellen in einer höhlenartigen Gemütlichkeit Schlaf- und Badezimmer bereit sowie auf einer Seite ein kleines Heimkino. Die Hufeisenform öffnet sich einseitig zu einer beindruckenden Sicht auf die umliegenden Berge und begibt sich in einen scheinbaren Dialog zwischen Himmel und Erde.';
		
		
		//---------------------------------------------
		else if( strcmp($articleID,'ashkan_honarvar')==0) 
		return 'In der Serie "Faces" veranschaulicht der Künstler <a href="http://www.ashkanhonarvar.com/">Ashkan Honarvar</a> seine Suche nach der Identität und den physischen sowie auch psychologischen Wunden, unter denen die Soldaten nach dem Krieg jahrelang leiden. Honarvars greift auf existierende Bilder zurück, die verstümmelte Soldaten des ersten Weltkrieges zeigen und kreiert daraus neue verstörende, makabere Bildnisse. <!--more-->Schönheit soll sich in unterschiedlichster Gestalt zeigen, allerdings bezweifelt man dies bei solchen Bildnissen. Doch Hinarvar beschreibt eine unbestreitbare Schönheit, wenn man bereit ist, die dunklen Seiten der menschlichen Natur zu akzeptieren.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'alicia')==0) 
		return '<a href="http://www.alicjakwade.com/">Alicia Kwade</a> ist mit der Kunst aufgewachsen und hat selbige in Berlin studiert. Durch die Galerie ihres Vaters kam sie schon früh in Kontakt mit der Szene und bald stand für die junge Kwade fest, dass auch sie ihr Leben dem kreativen Schaffen widmen möchte. Ihre Arbeiten sind inspiriert von Ideen. Ideen, die sie in Büchern, von der Wissenschaft, durch Naturphänomene oder das Weltgeschehen erhält. <!--more--><br />Durch die intensive Auseinandersetzung mit den unterschiedlichsten Themengebieten kommen immer wieder Fragen auf, mit denen sie sich in ihren Arbeiten kritisch auseinandersetzt. Für den Betrachter werden dabei auf bildhafte, oft ironische Weise zentrale Inhalte und Gedankengänge transparent dargestellt. Ihre Werke beschränken sich auf kein bestimmtes Genre. Die Übergänge von Video, Bildhauerei und Installationen sind fließend. <br />Im Jahre 2008 erhielt Kwade den Piepenbrock-Preis für Skulptur, verbunden mit einer Gastprofessur an der UdK Berlin.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'brian')==0) 
		return 'Im vergangenen Jahr berichteten wir schon einmal über die Arbeiten von <a href="http://www.ignant.de/2011/03/01/brian-dettmer/">Brian Dettmer</a>. Dettmer verarbeitet alte Bücher, vorzugsweise Enzyklopädien, Wörterbücher oder Lexika zu Kunstwerken. Er schenkt dem Medium Buch damit neue Aufmerksamkeit und macht die unzähligen Informationen darin auf ungewohnte Weise sichtbar. <!--more--><br />Informationsflüsse haben, durch das Zeitalter des Internets, eine neue physikalische Form angenommen und hinterlassen das greifbare Buch als Zeitzeugen vergangener Tage. Die unsichtbaren Datenströme des Worldwide Web übernehmen und hinterlassen keinerlei Spur in der realen Welt. So mag das Buch mit seine Informationen vielleicht veraltet sein aber es ist beständig, während Informationen im Internet ungreifbar verschwinden und für immer verloren gehen. <br />Seine neusten Werke werden ab heute unter dem Titel "Textonomy" in der <a href="http://www.toomey-tourell.com/">Toomey Tourell Gallery</a> in San Francisco gezeigt.<br /><em>"The richness and depth of the book is universally respected yet often undiscovered as the monopoly of the form and relevance of the information fades over time. The book’s intended function has decreased and the form remains linear in a non-linear world. By altering physical forms of information and shifting preconceived functions, new and unexpected roles emerge. This is the area I currently operate in. Through meticulous excavation or concise alteration I edit or dissect communicative objects or systems such as books, maps, tapes and other media. The medium’s role transforms. Its content is recontextualized and new meanings or interpretations emerge."</em>';
			
		//---------------------------------------------	
		else if( strcmp($articleID,'wood')==0) 
		return 'Den Fokus seiner Arbeit legt der junge Künstler <a href="http://geordiewood.com/">Geordie Wood</a> aus Brooklyn, New York auf Portraitaufnahmen und Modefotografie. Schon kurz nach seinem Abschluss in Fotojournalismus und Studiofotografie an der Syrancuse University arbeitete er für namhafte Publikationen wie Complex oder das WAD Magazine. <!--more-->';
		
		//---------------------------------------------
		else if( strcmp($articleID,'martins_edgar')==0) 
		return '<a href="http://www.edgarmartins.com/">Edgar Martins</a> Fotoserie "The Time Machine: An Incomplete and Semi-Objective Survey of Hydropower Stations"  zeigt Wasserkraftwerke, die zwischen 1950 und 1970 in Portugal entstanden sind. Die dokumentarisch aufgebaute Serie weckt Erinnerungen an vergangene, aufregende Zeiten technischer Innovationen und Science-Fiction ähnlicher Zukunftsvisionen. <!--more--><br />Heute, Jahrzehnte später, sind wir in der schillernden Zukunftsfantasie angekommen und stellen fest, dass die malerischen Vorstellungen von Mensch und Maschine, vereint in einer fruchtbaren Symbiose nicht unbedingt wahr geworden sind. Arbeitsplätze, die für hunderte von Menschen geplant waren, haben nicht viel mehr regelmäßige Besucher als einige Spezialisten, Sicherheitskräfte und das Reinigungspersonal. Wohnräume, erdacht für die Masse an Menschen, die dort Arbeiten finden sollten, bleiben unwirtlich und unbewohnt. Die Fotografien weisen auf die paradoxe Beziehung zwischen Mensch und Maschine hin und dienen als Zeugnis unerfüllter Hoffnungen.';
		
		//---------------------------------------------
		else if( strcmp($articleID,'monifaktur_cards')==0)
		return '	Einige Zeit habe ich mich nun fleißig mit Bube, Dame, König, Ass beschäftigt und sie ins Heute gebracht. Dann verzog ich mich in mein Kartenhäuschen, sammelte, malte, collagierte, kämpfte mit Computer und Scanner, schmiss die Karten, nahm sie wieder auf. Heute ist es nun endlich soweit: Mein Kartenblatt (anders) ist fertig!  <!--more--> 
		<br />
			Welche Gedanken so dahinter stecken, habe ich im Anschluss mal zusammengefasst (natürlich nur einen Bruchteil, eigentlich ist es ein Monifest). Wer eins haben möchte, geht in unseren heute frisch eröffneten Laden gleich hier im Block, der <a href="http://www.ignant.de/mshop/" target="_blank"><strong>iGNANT SHOP</strong></a>.<br />
			<img src="http://www.ignant.de/wp-content/uploads/2012/08/bube1.jpg" width="310" />
			<img src="http://www.ignant.de/wp-content/uploads/2012/08/dame.jpg" width="310" />
			<img src="http://www.ignant.de/wp-content/uploads/2012/08/koenig.jpg" width="310" />
			<img src="http://www.ignant.de/wp-content/uploads/2012/08/asse.jpg" width="310" />
			<br />
			Fertig.
			Danke für die Aufmerksamkeit!
			Bestens, Monja // MONIFAKTUR
		';
		
		//---------------------------------------------
		else if( strcmp($articleID,'monifaktur_cd')==0)
		return '	Die Compact Disc ist eine kompakte Scheibe, die Anfang der 80er Jahre zur digitalen Speicherung von Musik eingeführt wurde, <del datetime="2012-05-22T12:36:12+00:00">um jede bereits veröffentlichte Musik nochmal gewinnbringend veröffentlichen zu können</del> und die Schallplatte ablösen sollte. Die CD wird nun mehr und mehr von der MP3 abgelöst, und sehr bald, wenn überhaupt, nur noch als Datenträger oder Frisbee genutzt. <!--more-->
<br />
			Da ein baldiger Umzug vor der Tür steht, habe ich gestern meine letzten CDs aussortiert. Die fünf, die übrig geblieben sind, wurden heute von<a href="http://hamakaaa.tumblr.com/"> Eric Tiedt</a> und mir visualisiert und auf diesen Rolingen verewigt. Auch wenn die Musik dahinter eher fraglich ist, so verbindet jeder große Erinnerungen mit den ersten CD Käufen und stundenlangem Suchen bei WOM. Hier seht ihr eine kleine Auswahl unserer Hommage an die CD. Wer eine davon haben will, hinterlässt einen Kommentar mit seinem Lieblings-CD Hit.
			<br />
			<em>In the beginning of the 80s the Compact Disc was invented to save digital data <del datetime="2012-05-22T12:36:12+00:00"> and to sell music again that had already been on the market</del> and to replace disk records. Today the CD is more and more driven out of the market by the MP3 format and will soon only be used to carry data or serve as a frisbee.</em>
<br />
			<em>As I am moving in a couple of days I decided to sort out my last CDs. The five CDs left were visualized by me and <a href="http://hamakaaa.tumblr.com/">Eric Tiedt</a> and immortalized on these blank discs. Although the music on our CDs might be questionable there are still some nice memories linked to it like buying your first disc or spending hours and hours in the CD shop around the corner to find the right album. Below you can find a small selection of our homage to the CD. If you would like to have one please drop a comment naming your favourite CD-Hit.</em>
<br />
			<img src="http://www.ignant.de/wp-content/uploads/2013/05/CD11.jpg" alt="" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2013/05/CD2.jpg" alt="" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2013/05/CD3.jpg" alt="" width="310" />
			<p style="text-align: center;">Vielen Dank an <a href="https://www.facebook.com/SharpieDeutschland">Sharpie</a>, die uns mit feinen Fine-Linern versorgt haben!</p>
			<p style="text-align: center;"><img src="http://www.ignant.de/wp-content/uploads/2013/05/Sharpie.jpg" alt="" /></p>';
		
		//---------------------------------------------
		else if( strcmp($articleID,'monifaktur_49')==0)
		return 'Vor 500 Jahren studierten Zeichner die Natur. So kennen wir den <a href="http://de.wikipedia.org/wiki/Feldhase_%28D%C3%BCrer%29" target="blank"><em>Feldhasen</em></a>, 1502, oder das <a href="http://de.wikipedia.org/wiki/Rhinocerus" target="blank"><em>Rhinocerus</em></a>, 1515 von Albrecht Dürer. Heute begegnen uns Tiere statt in naturgetreuer, detaillierter Studie auf dem Papier viel öfter verpixelt, überzüchtet, oder auch unglaublich witzig in YouTube Videos auf dem Bildschirm. <!--more--> Einer der ersten welterobernden Tier-Kurzfilme war sicher der <a href="http://www.youtube.com/results?search_query=sneezing+panda&oq=sneezing&aq=0&aqi=g10&aql=&gs_sm=e&gs_upl=4660l5825l0l6623l8l7l0l0l0l0l218l961l1.5.1l7l0" target="blank"><em>Sneezing Baby Panda</em></a>, 2006 von jimvwmoss (123 Millionen mal geschaut). Viele Videos folgten. Ich habe mir ein paar herausgesucht und untersucht, Ahnen geforscht, mit Tierpsychologen analysiert, bin an Orte des Geschehen gereist und habe zahllose Kommentare gelesen. Daraus entstanden ist meine Naturstudie 2.0, oder auch "Eine YouTube-Studie".<br /><img src="http://www.ignant.de/wp-content/uploads/2012/11/YouTubeNo1MonjaGentschow1.jpg" width="100%" class="alignnone size-full wp-image-28449" /><br /><em>"Dramatic Maki"</em>, 2011, Monja Gentschow<br />Quelle: <a href="http://www.youtube.com/watch?v=14alLh3LglQ" target="blank"><strong>www.youtube.com/watch?v=14alLh3LglQ</strong></a><br /><br></br><img src="http://www.ignant.de/wp-content/uploads/2012/11/YouTubeNo2MonjaGentschow.jpg" width="100%" class="alignnone size-full wp-image-28451" /><br /><em>"Baby Monkey (Going Backwards On A Pig)"</em>, 2011, Monja Gentschow<br />Quelle: <a href="http://www.youtube.com/watch?v=5_sfnQDr1-o" target="blank"><strong>www.youtube.com/watch?v=5_sfnQDr1-o</strong></a><br></br><img src="http://www.ignant.de/wp-content/uploads/2012/11/YouTubeNo3MonjaGentschow1.jpg" width="100%" class="alignnone size-full wp-image-28455" /><br /><em>"The OMG Cat"</em>, 2011, Monja Gentschow<br />Quelle: <a href="http://www.youtube.com/watch?v=C_S5cXbXe-4" target="blank"><strong>www.youtube.com/watch?v=C_S5cXbXe-4</strong></a><br></br><img src="http://www.ignant.de/wp-content/uploads/2012/11/YouTubeNo5MonjaGentschow.jpg" width="100%" class="alignnone size-full wp-image-28457" /><br /><em>"Denver Official Guilty!"</em>, 2011, Monja Gentschow<br />Quelle: <a href="http://www.youtube.com/watch?v=B8ISzf2pryI" target="blank"><strong>www.youtube.com/watch?v=B8ISzf2pryI</strong></a><br></br><img src="http://www.ignant.de/wp-content/uploads/2012/11/YouTubeNo4MonjaGentschow.jpg" width="100%" class="alignnone size-full wp-image-28459" /><br /><em>"Dramatic Chipmunk"</em>, 2011, Monja Gentschow<br />Quelle: <a href="http://www.youtube.com/watch?v=a1Y73sPHKxw" target="blank"><strong>www.youtube.com/watch?v=a1Y73sPHKxw</strong></a><br></br>:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::AUFGEPASST:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: Von jedem dieser Tiere gibt es 20 Prints, signiert und nummeriert, ca. 20x30cm auf hochwertigen Büttenpapier für 15 Euro inkl. Versand.<br />Wer ich eins haben oder verschenken möchte, schicke eine Mail an <strong>Monifaktur@ignant.de</strong>.<br />Beste Grüße,<br />Monja';
		
		//---------------------------------------------
		else if( strcmp($articleID,'monifaktur_48')==0)
		return 'Kapitel 1: Drei kleine Fakten über große Schriftsteller und Dichter. <!--more--><br /><br /><img src="http://www.ignant.de/wp-content/uploads/2012/10/1.jpg" /><img src="http://www.ignant.de/wp-content/uploads/2012/10/Homo-Faber-Castell.jpg" width="100%" /><br/><br/><img src="http://www.ignant.de/wp-content/uploads/2012/10/22.jpg" /><img src="http://www.ignant.de/wp-content/uploads/2011/10/Goethe-goeht-spazieren.gif" alt="" title="Goethe-goeht-spazieren"  width="100%" /><br/><br/><img src="http://www.ignant.de/wp-content/uploads/2012/10/31.jpg" /><img src="http://www.ignant.de/wp-content/uploads/2012/10/schiller-schillt.gif"  width="100%" /><br />Fortsetzung folgt!<br />Eure Monja';
		
		
		
		//---------------------------------------------
		else if( strcmp($articleID,'ignantravel_riche_stockholm')==0)
		return '	Das Restaurant <a href="http://riche.se/">Riche</a> gehört zu Stockholms feinsten Adressen. Im Riche zu Gast zu sein ist ein besonderes Erlebnis deswegen empfehle ich euch euren Sparstrumpf einzupacken um dort ein typisch schwedisches Dinner zu genießen. <!--more-->

			Im Riche kann man tagsüber essen sowie Abends an der Bar ein paar Drinks zu sich nehmen. Ich komme zum Mittagessen und auf der Karte muss ich nicht lange suchen, denn was mir als erstes ins Auge springt sind Köttbullar, die ich normalerweise als Hackbällchen aus dem IKEA kenne. Genau das bekomme ich dann auch zusammen mit Kartoffelbrei, Gürkchen und Preiselbeeren serviert. Meine schwedische Begleitung erklärt mir, dass Köttbullar tatsächlich keine Touristenfalle sind, sondern mindestens einmal die Woche auf schwedischen Esstischen stehen. Ansonsten kommt bei den Nordmännern viel Fisch und Meerestiere auf den Tisch.

			Abgesehen vom leckeren Essen gefällt mir im Riche das Ambiente sehr gut. Es herrscht eine entspannte Stimmung und überall im Restaurant sind kleine Kunstinstallationen versteckt wie ein Monitor, der eine Miniatur der Waschräume zeigt oder einen Stuhl, der die Wand erklimmt. Auch einen Blick in die Küche darf ich werfen, in der die Köche gekonnt die Pfannen schwingen. Nach Beenden meiner Entdeckungstour im Riche verlasse ich die Räume mit einem glücklichen Magen und dem Wunsch ein paar Köttbullar in meiner Jackentasche nach Hause zu schmuggeln.

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_01.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_02.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_03.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_04.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_05.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_06.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_07.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_08.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_09.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_10.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_11.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_12.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_13.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_14.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_15.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_16.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_17.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_18.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_19.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_20.jpg" width="310" />

			<img src="http://www.ignant.de/wp-content/uploads/2012/06/riche_21.jpg" width="310" />

			<em>The restaurant <a href="http://riche.se/">Riche</a> is one of Stockholms most exclusive addresses. Being guest at Riche is something special so I would recommend to rob your piggy bank and go there to enjoy a typical Swedish dish. After a look at the menu I get to my decision pretty fast. I need to try Köttbullar that I know as meatballs from the cafeteria in IKEA. And this is exactly what I find later on my plate, served with pickled cucumber and cranberries. My Swedish companion explains me that Köttbullar are really no tourist trap but you will also find them regularly on the table of Swedish homes. Otherwise they also eat a lot of fish and seafood. </em>

			<em>Besides the delicious food at Riche I really like the atmosphere. It is very laid back and the interior is mixed with small art installations like a screen showing a miniature of the bathrooms and a chair climbing up the wall. I can also take a glance in the kitchen and watch the chef working. After my little tour through the restaurant and the bar I leave the rooms with a happy belly and wish I could take some Köttbullar with me in my pocket.</em>
			<p style="text-align: center;"><strong>Opening hours:</strong>
			Mon 7.30-24  · Tue-Fri 7.30-02  · Sat 12-02  · Sun 12-00

			<p style="text-align: center;"><strong>Address:</strong>
			Restaurang Riche  · Birger Jarlsgatan 4  · 11434 Stockholm

			<p style="text-align: center;"><strong>Contact:</strong>
			Tel: 08-545 035 60 · Mail: info@riche.se · Web: <a href="http://riche.se">www.riche.se</a></p>

			<p style="text-align: center;"><small>Text &amp; pictures by <a href="http://carolinekurze.tumblr.com/">Caroline Kurze</a></small></p>';
		
		
		//---------------------------------------------
		else if( strcmp($articleID,'aicuisine_steak_sandwich')==0)
		return 'Heute bei <a href="http://aicuisine.com/">Aicuisine</a> mal ein etwas einfacheres Rezept, dessen Besonderheit im Detail liegt. Die Zutatenliste für 2 Personen ist relativ überschaubar, 4 Scheiben Weissbrot, am besten französisches Landbrot, Butter, etwas geraspelte Karotten, 2 Scheiben Steak, Fenchel, Pilze und noch 4 Scheiben Käse, am Besten würziger wie Cheddar oder Gruyere. <!--more-->Pfeffer, Salz, Petersilie und Zucker braucht ihr ebenfalls noch. Einen Bunsenbrenner wie für Creme Brulee braucht ihr auch noch, dazu später mehr.

		<em>Todays <a href="http://aicuisine.com/">Aicuisine</a> recipe is quite simple with some character in the details. The list of ingredients for 2 people is quite short. All you need are 4 slices of white bread, preferrably french country bread, butter, grated carrots, 2 steak, fennel, mushrooms and 4 slices cheese, I recommend sharp cheese, like Cheddar or Gruyere. Pepper, salt, parsley and sugar are the spices you need. You will also need a Bunsen burner, but more on that later.</em>

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-01.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-02.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-03.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-04.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-05.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-06.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-07.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-08.jpg" width="310" alt="" />

		<img src="http://www.ignant.de/wp-content/uploads/2012/06/steak-sandwich-09.jpg" width="310" alt="" />

		Brot mit Butter beschmieren und die geraspelten Karotten draufgeben. Nun den Fenchel aufschneiden und als erstes bei mittlerer Hitze in der Pfanne anbraten, bis er leicht braun ist, dann die Pilze hinzugeben und mit Salz, Pfeffer und etwas Petersilie weitere 5-10 min anbraten. In der Zwischenzeit auch das Steak mit etwas Salz und Pfeffer von beiden Seiten anbraten bis der gewünschte Grad erreicht ist.

		Nachdem ich neulich mal für Creme Brulee so einen kleinen Bunsenbrenner gekauft habe, wollte ich schon seit langem Mal Fleisch damit karamellisieren. Dies passierte nun mit einer Seite des Steak. Einfach etwas Zucker (ich hab hier eine Orangen-Ingwer-Zucker-Mischung verwendet) über eine Seite des Steak geben und mit dem Bunsenbrenner solange bearbeiten, bis der Zucker anfängt braun zu werden.

		Nun alles auf die Brotscheiben stapeln, den Käse zuletzt. Die süße Seite des Steak am Besten auf den Fenchel, weil beides zusammen wirklich toll im Geschmack ist! Das ganze nun in einem Kontaktgrill (ich nutze gerade mein Waffeleisen um Sandwiches zu grillen, das geht auch super!) solange grillen bis das Brot schön goldbraun ist und der Käse anfängt zu zerlaufen. Dann servieren und geniessen!

		<em>Cover the bread with some butter and put the grated carrots on it. Cut the Fennel into its layers and start roasting it at medium heat, after a few minutes add the mushrooms and spice with pepper, salt and parsley. Roast for another 5-10 minutes. In the meantime grill the steaks with a bit salt and pepper to you preferred grade. After I bought this Bunsen burner the other day for Creme Brulee I always wanted to use it on meat, too. So I decided to caramelise the steak from one side. Just put sugar (I used orange ginger sugar to spice it up a bit) on a side and burn until the sugar gets brown.</em>

		<em> </em>

		<em>Now layer everything on the bread, finish with the cheese and put the sweet side of the steak against the fennel as the 2 together make a wonderful taste! Now grill the sandwich (I always use my waffle iron for that which works pretty well!) until the bread is golden brown and the cheese melts. Now serve and enjoy!</em>
		<p style="text-align: center;"><strong><a href="http://aicuisine.com/">Click here</a> for more recipes and inspirational stories about food!</strong></p>';
		
		//---------------------------------------------
		else if( strcmp($articleID,'itv_disco_ball')==0)
		return 'Die nächste <a href="http://www.theavantgardediaries.com/">THE AVANT/GARDE DIARIES</a> Folge steht an. Wir haben an einem sonnigen Nachmittag den Grafiker, Künstler und Designer Bruno Kolberg in seinem Atelier in Berlin Schöneberg besucht, wo er uns einen Einblick in seine Arbeitswelt gegeben hat. Zum Thema "Avantgarde" fiel ihm Bella Berlin ein, die für ihre extravaganten Auftritte als lebende Discokugel bekannt ist. <!--more-->Aufgrund eines ausgefallenen Zuges trafen wir Bella spontan in der Nähe des Berliner Hauptbahnhofs. Dort erzählte sie uns im Interview wie ihre Karriere im Nachtleben begann, was sie heute macht und wie ihre Auftritte als lebende Discokugel aussehen.

		<em>Bruno Kolberg was born in Kreuzberg, which makes him one of the few true Berliners left among the creative freelancers in the city. The autodidact works as a graphic designer, illustrator and tape artist and founded the studio Sueper Design together with fellow artist Bodo Hoebing.</em>

		<em>“In a visual sense,” Bruno says “avant-garde, are things that are new, that amaze you, that move you when you see them”. That’s what he experienced when he saw the living disco ball-performance by Bella Berlin for the first time. “I was in a in a small illegal club when suddenly lasers flashed up and she came on stage in her disco ball outfit. The room fell silent and everyone was stunned because nobody there has ever seen anything like this before.”</em>

		<em> </em>

		<em> </em>

		<em>The girl in the disco ball costume is native Berliner “Bella Berlin”, co-founder of music label R.O.T. that among others produced German band MIA. After ten years in the music business she realized that she wanted to move on and developed several dance performances. When dancing on stage with her tight suit covered all over with small mirrors, she becomes another person. Bella says that she has several personalities, but her disco-ball character is probably her most famous one. “I am art,” she claims and it becomes visible: When she rhythmically moves her body to electronic music so the reflecting laser-lights turn her body into a kaleidoscope connecting darkness and light, she absorbs herself totally in her alter ego and evokes a truly magical atmosphere.</em>

		Credits: Clemens Poloczek (Kamera/Schnitt), Marcus Werner (Kamera), Björn Baasner (Kamera), BUNNYSTRIPES (Musik)
		';
		
		
		//---------------------------------------------
		else if( strcmp($articleID,'itv_kjosk')==0)
		return 'Nach einer kleinen Pause gibt es heute mal wieder zur Abwechslung Content, der von uns produziert wurde. Nach den 6 "Wørk in Progress" Episoden folgt nun eine Kooperation mit <a href="http://www.theavantgardediaries.com/">THE AVANT/GARDE DIARIES</a>. Zweimal pro Woche erscheinen dort neue Videos, in denen Künstler, Designer, Fotografen etc. aus Paris, New York und Berlin Personen oder andere Gegenstände vorstellen, die ihrer Meinung nach avantgarde sind. <!--more--><br /><br />Für diese Folge, die den Namen "Pretty Easy To Explain" trägt, trafen wir die <a href="http://www.kjosk.com/">KJOSK</a> Betreiberin Rosmarie Köckenberger in Berlin Kreuzberg. Sie sprach mit uns über die Idee hinter dem Kiosk auf vier Rädern und erklärt warum <a href="http://balestraberlin.com/">Balestra Berlin</a> ihrer Meinung nach avantgarde ist.<br /><em>Hidden in a 600 square meter big garden in Berlins’ neighborhood Kreuzberg, Rosmarie Köckenberger welcomes her guests, friends and residents to have a coffee and a warm chat in her KJOSK. An almost 50 year old, white painted double-decker bus is used as a mom-and-pop store where people can play Super Mario together, eat local sausages and have a after work beer.Rosmarie offers with her KJOSK a special place, overgrown with greens, to settle back from the bustle of a big city in a familiar atmosphere.<br /><br />From this point of view she introduces Balestra, a Berlin based agency. Not quit an event nor an advertising agency, Rosmarie appreciates „the perfect mixture of working with friends, having fun and professional work which is the most important part of a good collaboration”. In a time when more and more people work long hours and have less time for friends and family Balestra tries to make room for exactly those elements by incorporating them in their work ethic.” This way of working makes the agency so avant-garde and leads to successful projects such as The Kubik, an outdoor light and room installation and one of the most famous projects by Balestra.</em><br /><br />In den kommenden Wochen und Monaten werden wir nun immer wieder einzelne Folgen für <a href="http://www.theavantgardediaries.com/">THE AVANT/GARDE DIARIES</a> produzieren, die dann auch teilweise hier bei iGNANT gefeatured werden. Die restlichen Clips könnt ihr euch <a href="http://www.theavantgardediaries.com/">hier</a> anschauen. Wir sind natürlich sehr gespannt, wie euch das Video gefällt und freuen uns auf Feedback.<br /><br />Credits: Clemens Poloczek (Regie/Kamera), Björn Baasner (Kamera), Nico Nierman (Assistenz), BUNNYSTRIPES (Musik)';
		
		//---------------------------------------------
		else
		return '<a href="http://www.ignant.de/">link to the homepage</a>';
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
		$shouldIncludeImageBase64 = false;
		
		$tempArticleId = null;
		
		//set up articles
		$lightArticles = array();
		$tempArticleId = 'cecilia_paredes';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'CECILIA PAREDES', date('Y-m-d', mktime(0, 0, 0, 2, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image('cecilia_paredes', 'Some image description',$testImagesDirectory.'cecilia_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId),  $this->getCategoryWithId(1),$tempArticleUrl);
		
		$tempArticleId = 'mark_powell';
		$tempArticleUrl = 'http://www.ignant.de/2011/04/27/mark-powell/';
		$lightArticles[] = new LightArticle($tempArticleId, 'MARK POWELL', date('Y-m-d', mktime(0, 0, 0, 2, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'mark_powell_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(1),$tempArticleUrl);
		
		$tempArticleId = 'swellendamm_haus';
		$tempArticleUrl = 'http://www.ignant.de/2012/01/05/allandale-house/';
		$lightArticles[] = new LightArticle($tempArticleId, 'SWELLENDAMM HAUS', date('Y-m-d', mktime(0, 0, 0, 2, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'swellendam_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(2),$tempArticleUrl);
		
		$tempArticleId = 'ashkan_honarvar';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/02/ashkan-honarvar-2/';
		$lightArticles[] = new LightArticle($tempArticleId, 'ASHKAN HONARVAR', date('Y-m-d', mktime(0, 0, 0, 1, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'ashkan_honarvar_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(2),$tempArticleUrl);
		
		$tempArticleId = 'alicia';
		$tempArticleUrl = 'http://www.ignant.de/2012/01/31/alicia-kwade/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Alicia', date('Y-m-d', mktime(0, 0, 0, 1, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'alicia_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(3),$tempArticleUrl);
		
		$tempArticleId = 'brian';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/02/brian-dettmer-2/';
		$lightArticles[] = new LightArticle($tempArticleId, 'BRIAN', date('Y-m-d', mktime(0, 0, 0, 1, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'brian_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(3),$tempArticleUrl);
		
		$tempArticleId = 'henrique_oliveira';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/02/henrique-oliveira/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Henrique Oliviera', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'henrique_oliveira_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'wood';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/01/geordie-wood/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Wood', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'wood_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'martins_edgar';
		$tempArticleUrl = 'http://www.ignant.de/2012/02/01/edgar-martins/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Martins Edgar', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'martins_edgar_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(5),$tempArticleUrl);
		
		$tempArticleId = 'imagine';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Imagine', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'lego_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(5),$tempArticleUrl);
		
		$tempArticleId = 'elodie_antoine';
		$tempArticleUrl = 'http://www.ignant.de/2012/03/16/imagine/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Elodie Antoine', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'elodie_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'hui_yi';
		$tempArticleUrl = 'http://www.ignant.de/2012/03/19/hui-yi/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Huy Yi', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'hui_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'monifaktur_cards';
		$tempArticleUrl = 'http://www.ignant.de/2011/08/15/moni-spielt-mit-offenen-karten/';
		$lightArticles[] = new LightArticle($tempArticleId, '#47 MONIFAKTUR- EIN KARTENBLATT (ANDERS)', date('Y-m-d', mktime(0, 0, 0, 4, 15, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(7),$tempArticleUrl);
		
		$tempArticleId = 'monifaktur_cd';
		$tempArticleUrl = 'http://www.ignant.de/2012/05/23/eine-hommage-an-die-cd/';
		$lightArticles[] = new LightArticle($tempArticleId, 'EINE HOMMAGE AN DIE CD', date('Y-m-d', mktime(0, 0, 0, 3, 23, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(7),$tempArticleUrl);
		
		$tempArticleId = 'monifaktur_49';
		$tempArticleUrl = 'http://www.ignant.de/2011/11/21/49-monifaktur-eine-youtube-studie/';
		$lightArticles[] = new LightArticle($tempArticleId, '#49 MONIFAKTUR- EINE ‘YOUTUBE-STUDIE’', date('Y-m-d', mktime(0, 0, 0, 11, 21, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(7),$tempArticleUrl);
		
		$tempArticleId = 'monifaktur_48';
		$tempArticleUrl = 'http://www.ignant.de/2011/10/14/48-monifaktur-das-moniversum-kapitel-1/';
		$lightArticles[] = new LightArticle($tempArticleId, '#48 MONIFAKTUR- DAS MONIVERSUM, KAPITEL 1', date('Y-m-d', mktime(0, 0, 0, 10, 14, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(7),$tempArticleUrl);
		
		$tempArticleId = 'aicuisine_steak_sandwich';
		$tempArticleUrl = 'http://www.ignant.de/2012/06/19/grilled-fennel-mushroom-steak-sandwich/';
		$lightArticles[] = new LightArticle($tempArticleId, 'GRILLED FENNEL MUSHROOM STEAK SANDWICH', date('Y-m-d', mktime(0, 0, 0, 6, 11, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(10),$tempArticleUrl);
		
		$tempArticleId='ignantravel_riche_stockholm';
		$tempArticleUrl = 'http://www.ignant.de/2012/06/13/riche-stockholm/';
		$lightArticles[] = new LightArticle($tempArticleId, 'RICHE · STOCKHOLM', date('Y-m-d', mktime(0, 0, 0, 13, 6, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(9),$tempArticleUrl);

		$tempArticleId = 'itv_kjosk';
		$tempArticleUrl = 'http://www.ignant.de/2011/10/05/i-tv-kjosk-balestra-berlin/';
		$lightArticles[] = new LightArticle($tempArticleId, 'I.TV: KJOSK & Balestra Berlin', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		$tempArticleId = 'itv_disco_ball';
		$tempArticleUrl = 'http://www.ignant.de/2011/10/14/i-tv-bruno-kolberg-bella-berlin/';
		$lightArticles[] = new LightArticle($tempArticleId, 'I.TV: BRUNO KOLBERG & BELLA BERLIN', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some image description',$testImagesDirectory.'moniversum_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(8),$tempArticleUrl);
		
		
		
		
		$tempArticleId = 'test_2';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 2', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_2_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_2_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_3';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 3', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_3_img', 'http://www.ignant.de/wp-content/uploads/2012/06/socialnetwork03.jpg', 'test_3_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_4';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 4', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_4_img', 'http://www.ignant.de/wp-content/uploads/2012/06/urbangreen02a.jpg', 'test_4_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_5';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 5', date('Y-m-d', mktime(0, 0, 0, 3, 2, 2012)), createRemoteImage('test_5_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_5_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_6';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 6', date('Y-m-d', mktime(0, 0, 0, 2, 1, 2012)), createRemoteImage('test_6_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_6_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_7';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 7', date('Y-m-d', mktime(0, 0, 0, 2, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_8';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 8', date('Y-m-d', mktime(0, 0, 0, 2, 1, 2012)), createRemoteImage('test_8_img_id', 'http://www.ignant.de/wp-content/uploads/2012/06/herdern01.jpg', 'test_8_desc' ), null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(6),$tempArticleUrl);
		
		$tempArticleId = 'test_9';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 9', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_10';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 10', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_11';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 11', date('Y-m-d', mktime(0, 0, 0, 1, 1, 2012)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_12';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 12', date('Y-m-d', mktime(0, 0, 0, 12, 12, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_13';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 13', date('Y-m-d', mktime(0, 0, 0, 12, 12, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
		$tempArticleId = 'test_14';
		$tempArticleUrl = 'www.ignant.de/2012/02/03/cecilia-paredes/';
		$lightArticles[] = new LightArticle($tempArticleId, 'Test 14', date('Y-m-d', mktime(0, 0, 0, 12, 12, 2011)), $shouldIncludeImageBase64 ? createBase64Image($tempArticleId, 'Some test image description',$testImagesDirectory.'test_pre'.$testImagesSuffix.'.'.$testImagesExtension) : null, null,$this->getTestDescriptionTextForArticleId($tempArticleId), $this->getTestTemplateForArticleId($tempArticleId), $this->getRemoteImagesForArticleId($tempArticleId), $this->getRelatedArticlesForArticleId($tempArticleId), $this->getCategoryWithId(4),$tempArticleUrl);
		
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
		
		if($fh==FALSE)
		print("could not open tumblr data dump...\n");
		
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

	public function getBatchOfRandomMosaicEntries()
	{
		$returnArray = array();
		$validCounter = 0;
		
		$allMosaicEntries = $this->getMosaicEntriesArray();
		$numberOfEntriesToReturn = 15;
		$maxIndex = count($allMosaicEntries)-1;
		
		if(is_array($allMosaicEntries) && count($allMosaicEntries)>0)
		foreach($allMosaicEntries as $oneMosaic)
		{
			if($validCounter>$numberOfEntriesToReturn) break;
			
			$returnArray[] = $oneMosaic;
			$validCounter++;
		}
		
		
		return $returnArray;
	}
	
	public function getMosaicEntriesArray(){
		
		
		$mosaicEntries = array();
		
		$tempArticleId = 'cecilia_paredes';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'henrique_oliveira';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'mark_powell';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'imagine';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'elodie_antoine';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'swellendamm_haus';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'ashkan_honarvar';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'alicia';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'brian';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'wood';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'martins_edgar';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_3';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_4';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_5';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_6';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_7';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_8';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_9';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_10';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_11';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_12';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_13';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		$tempArticleId = 'test_14';
		$mosaicEntries[] = $this->getMosaicEntryForArticleId($tempArticleId);
		
		
		return $mosaicEntries;
	}
	
	public function getMosaicEntryForArticleId($articleId = '')
	{
		$mosaicEntry = NULL;
		
		if(strlen($articleId)==0)
		return NULL;
		
		$tempArticleUrl = $this->getThumbLinkForArticleId($articleId);
		$tempArticleId = $articleId;
		$tempArticleWidth = 200;
		$tempArticleHeight = 200;
		$mosaicEntry = new MosaicEntry($tempArticleUrl, $tempArticleId, $tempArticleWidth, $tempArticleHeight);
		
		return $mosaicEntry;
		
	}
}

?>