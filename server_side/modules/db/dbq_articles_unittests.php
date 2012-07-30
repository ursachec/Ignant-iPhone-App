<?php

require_once('../../classes/IgnantInterfaces.php');
require_once('../../classes/IgnantObject.php');
require_once('../../classes/LightArticle.php');
require_once('../../classes/RelatedArticle.php');
require_once('../../classes/Article.php');
require_once('../../classes/BasicImage.php');
require_once('../../classes/Base64Image.php');
require_once('../../classes/RemoteImage.php');
require_once('../../classes/MixedImage.php');
require_once('../../classes/Template.php');
require_once('../../classes/Category.php');
require_once('../../classes/MosaicEntry.php');

require_once('../../feedKeys.php');
require_once('../../generalConstants.php');
require_once("../../wp_config.inc.php");

require_once('./dbq_general.php');
require_once('./dbq_categories.php');
require_once('./dbq_articles.php');


$s = '<!--:de-->Der Fotograf <a href="http://www.christofferrelander.com/">Christoffer Relander</a> veröffentlichte gerade seine neuste Fotoserie unter dem Namen \'We Are Nature\'. Christoffer ist Grafik Designer und fotografischer Autodidakt aus Finnland, Raseborg. Im Sommer 2009 begann er zu fotografieren und hat seitdem einen ganz eigenen Stil entwickelt, viel experimentiert, an zahlreichen Ausschreibungen teilgenommen sowie eigene Projekte verfolgt. Die Serie \'We Are Nature\' zeigt doppel- und dreifach Überblendungen, die alle in der Kamera selbst, einer Nikon D700 entstanden sind. Christoffer legt die Silhouetten verschiedener Personen über Motive aus der Natur und erschafft damit seine Serie in einem schlichten aber wunderschönen schwarz-weiß Stil. 

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature01.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature02.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature03.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature04.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature05.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature06.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature07.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature08.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature09.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature10.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature11.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature12.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature13.jpeg"  />

<p style="text-align: center;"><small>All images © <a href="http://www.christofferrelander.com/">Christoffer Relander</a> | Via: <a href="http://illusion.scene360.com/art/31154/blending-into-nature/">Illusion</a></small></p><!--:--><!--:en-->Photographer <a href="http://www.christofferrelander.com/">Christoffer Relander</a> just finished a new series of photograps called \'We Are Nature\'. Christoffer is graphic designer and self-taught photographer from Finland, Raseborg. He started photographing the summer of 2009. Since then he has been doing assignments and a lot of personal projects. In his latest series he is developping his double and triple exposures that are all done in-camera with a Nikon D700. He is blending different people with nature photography in a simple but beautiful black and white style. 

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature01.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature02.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature03.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature04.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature05.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature06.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature07.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature08.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature09.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature10.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature11.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature12.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature13.jpeg"  />

<p style="text-align: center;"><small>All images © <a href="http://www.christofferrelander.com/">Christoffer Relander</a> | Via: <a href="http://illusion.scene360.com/art/31154/blending-into-nature/">Illusion</a></small></p><!--:-->';



$sWithMore = '<!--:de-->Der <a href="http://www.haberdash.se/en/">Haberdash</a> liegt im Stadtteil Södermalm und damit im Studenten/Arbeiterviertel. Haberdash ist ein noch relativ junges Herrenbekleidungsgeschäft, das gleich zwei Mal in Stockholm vertreten ist. Obwohl es ausschließlich Herrenausstattung (also nichts für mich) gibt hat es mir der Laden angetan.<!--:--><!--:en--><a href="http://www.haberdash.se/en/">Haberdash</a> is located in the Södermalm district, which is the students and worker area. Haberdash is a rather new shop providing mens clothing and accessories. They have a beautiful collection of modern classics. <!--:-->

<!--more--><!--:de--> Er präsentiert mit Liebe zum Detail Marken, die hochwertige Kleidung mit Fokus auf Beständigkeit und Qualität herstellen. Er hat eine ausgesuchte Selektion traditioneller, kleiner Unternehmen, die Wert auf Nachhaltigkeit und Verarbeitung ihrer Produkte legen. Das seit 1936 in Schweden beheimatete Familienunternehmen Hestra ist zu finden genauso wie das dänische Traditionsunternehmen S.N.S. oder Filson, die seit 1879 Taschen herstellen. Außerdem dort entdeckt: T-Shirts des seit 1911 in Deutschland ansässigen Traditionsunternehmens Merz b. Schwanen. Im Haberdash kann man bewusst shoppen und tolle Produkte in stilsicherem Ambiente finden.

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash01.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash02.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash03.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash04.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash05.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash06.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash07.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash08.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash09.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash10.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash11.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash12.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash13.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash14.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash15.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash16.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash17.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash18.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash19.jpg"  />

<p style="text-align: center;"><strong>Öffnungszeiten:</strong>
Mon - Fr 11:30 - 18:30  · Sa 11:30 - 17:00  · So 12:00 - 16:00

<p style="text-align: center;"><strong>Adresse:</strong>
Haderdash  · Kocksgatan 17  · 116 24 Stockholm

<p style="text-align: center;"><strong>Kontakt:</strong>
Tel: 0046840815014 · Mail: kocksgatan17@haberdash.se · Web: <a href="http://www.haberdash.se/en/">www.haberdash.se</a></p>

<p style="text-align: center;"><small>Text &amp; pictures by <a href="http://carolinekurze.tumblr.com/">Caroline Kurze</a></small></p><!--:--><!--:en-->With a passion for detailing and high quality garments they offer a selection of sustainable products as you can wear them for years without getting tired of them or the need to replace them. Their idea is to find brands with established reputations for quality products, an international vision, and an eye not just for immediate consumption, but for long-term value. 
You can find the traditional swedish brand Hestra ort he danish knitting company S.N.S as well as Flison, making bags since 1870. If you like shopping in a warm and sincere atmosphere and if you are interested in good quality and modern style you should go there.

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash01.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash02.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash03.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash04.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash05.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash06.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash07.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash08.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash09.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash10.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash11.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash12.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash13.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash14.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash15.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash16.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash17.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash18.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Haberdash19.jpg"  />

<p style="text-align: center;"><strong>Opening hours:</strong>
Mon - Fri 11.30 - 18.30  · Sat 11.30 - 17.00  · Sun 12.00 - 16.00

<p style="text-align: center;"><strong>Address:</strong>
Haderdash  · Kocksgatan 17  · 116 24 Stockholm

<p style="text-align: center;"><strong>Contact:</strong>
Tel: 0046840815014 · Mail: kocksgatan17@haberdash.se · Web: <a href="http://www.haberdash.se/en/">www.haberdash.se</a></p>

<p style="text-align: center;"><small>Text &amp; pictures by <a href="http://carolinekurze.tumblr.com/">Caroline Kurze</a></small></p><!--:-->';

$sAicuisine = '<!--:de-->Letzte Woche habe ich mir etwas Hilfe in die <a href="http://aicuisine.com/">Aicuisine</a> eingeladen, Stephanie und mein Patensohn Victor standen mir tatkräftig zur Seite bei der Zubereitung einer neuen Idee: Mango Spargel Lasagne Bolognese! <!--:--><!--:en-->Last week I invited my friend Stephanie and her son, my dear godson, to help me cook my newly invented Lasagne recipe. <!--:--><!--more--><!--:de--> 

<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-12.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-13.jpg" />

Es ist immer noch Spargelzeit und da ich gerade Tomaten und deren Saft, auf denen normalerweise die Bolognese basiert nicht sonderlich spannend finde wurden die kurzerhand gegen Mangos eingetauscht. Hier das Rezept:

<strong>Bolognese</strong>

· 500g Rinderhackfleisch
· 1 Mango
· Saft von 2 Orangen
· 2 EL Mango Ingwer Chutney
· Petersilie
· Minze
· 1 rote Zwiebel
· Olivenöl
· Weisswein
· 1 EL Speisestärke
· Salz, Pfeffer, Chili, \'Schätze der Karibik\' von Herbaria

Hackfleisch, jeweils gehackte Zwiebeln, Petersilie und Minze kurz in einem großen Topf in Olivenöl anbraten bis das Fleisch sein gerade seine rote Farbe verliert und dann vom Kochfeld nehmen. Mit Salz und Pfeffer würzen. Mango in Würfel schneiden und 2 Orangen auspressen. Den Saft mit 2 TL \'Schätze der Karibik\' und 1 TL Chilipulver mischen. Mangos, den Orangensaft und 2 EL Mango Ingwer Chutney zum Fleisch geben und bei mittlerer Hitze ca. 30min köcheln lassen. Nach ca. 10 min 1 EL Speisestärke hinzugeben, damit der Fleischbrei etwas andickt und besser auf der Lasagne verteilbar ist. Ab und zu umrühren.

<strong>Sauce Bechamel
</strong>
· 500ml Milch
· 30g Butter
· 40g Mehl
· 2 EL Zitronensaft
· Salz, Pfeffer, Muskatnuss

Die Butter auf kleiner Flamme in einem Topf zerlassen bis sie klar wird. Dann das Mehl mit einem Schneebesen einrühren bis es vollständig aufgelöst ist. Die Milch hinzufügen und bei mittlerer Hitze unter konstantem Rühren 30 min weiterköcheln damit die Sauce den Mehlgeschmack verliert. Am Ende dann Zitronensaft dazugeben und mit Salz, Pfeffer und Muskatnuss abschmecken.

<strong>Lasagne</strong>

· 4-6 Lasagne Platten, je nach Größe der Auflaufform
· Grüner Spargel
· Butterflocken
· 300g Gruyère
· Bolognese
· Sauce Bechamel

Den Ofen auf 180°C vorheizen. Nun den Spargel im unteren 3/4 schälen und den Gruyère raspeln. Auflaufform mit Butter einfetten. Dann eine Schicht Blognese auf den Boden geben und die erste Schicht Lasagne Platten darauf. Dann wieder eine Schicht Bolognese und auf diese die erste Schicht Bechamel. Dann immer wieder eine Platte und Bolognese und Bechamel. Auf die letzte Platte kommt nur Bechamel, schon etwas Käse und der grüne Spargel. Auf den Spargel dann die Butterflocken verteilen und großzügig den Gruyère verteilen. Das Ganze kommt dann bei 180°C solange in den Ofen bis der Käse goldbraun ist, das müssten in etwa so 30min sein.

Lasagne sofort servieren und als Getränk dazu empfehle ich Weissweinschorle mit gefrorenen Himbeeren. Guten Appetit!

<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-02.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-03.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-04.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-05.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-06.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-07.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-08.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-09.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-10.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-11.jpg" />

<p style="text-align: center;"><strong><a href="http://aicuisine.com/">Click here</a> for more recipes and inspirational stories about food!</strong></p><!--:--><!--:en-->

<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-12.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-13.jpg" />

As its still asparagus time and I kind of lost interest in tomatoes for the moment I replaced them as a base for the bolognese with Mangos. Here\'s the recipe:

<strong>Bolognese</strong>

· 500g minced beef
· 1 mango
· juice of 2 oranges
· 2 table spoons mango ginger chutney
· parsley
· mint
· 1 red onion
· olive oil
· white wine
· 1 table spoon corn starch
· salt, pepper, chili, \'Treasures of the carribean\' from Herbaria

Shortly roast minced beef, onions, parsley and mint in a big pot until the meat loses red colour. Spice with salt and pepper and take away from the stove for a moment. Cut the Mango in small pieces and squeeze Oranges. Mix the juice with 2 tea spoons \'Treasures of the carribean\', 2 table spoons mango ginger chutney and 1 tea spoon chili powder. Now put everything to the beef mix and cook at medium temperature for another 30 minutes. Add 1 table spoon corn starch after 10 minutes to thicken the mix. Stirr every once in a while.

<strong>Sauce Bechamel
</strong>
· 500ml milk
· 30g butter
· 40g flour
· 2 table spoons lemon juice
· salt, pepper, nutmeg

Heat butter on low temperature until clear. Mix in the flour with a whire wisk until smooth. Now add the milk and cook at medium heat for 30 minutes to loose the flour taste and get it thicker. Stirr constantly. After 30 minutes add lemon juice and season to taste with salt, pepper and nutmeg.

<strong>Lasagne</strong>

· 4-6 sheets of lasagne
· green asparagus
· butter flakes
· 300g Gruyère
· bolognese
· sauce bechamel

Preheat the oven to 180°C. Peel asparagus, leave out the top quarter. Butter the casserole. Now add one layer of bolognese to it and add one layer of lasagne sheets. Cover that with another layer of bolognese and the first layer of sauce bechamel. Not continue with sheet of lasagne, bolognese and bechamel and so on. Cover the last sheet of lasagne with only sauce bechamel and bits of the minced Gruyère. Add asparagus on top and the butter flakes. Now cover generously with the rest of the cheese. Put into the oven for about 30 minutes until the cheese gets golden brown. Serve immediately and I recommend sparkling wine with frozen raspberries to it. Enjoy your meal!

<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-02.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-03.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-04.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-05.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-06.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-07.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-08.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-09.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-10.jpg" />
<img src="http://www.ignant.de/wp-content/uploads/2012/06/lasagne-aicuisine-11.jpg" />

<p style="text-align: center;"><strong><a href="http://aicuisine.com/">Click here</a> for more recipes and inspirational stories about food!</strong></p><!--:-->';

$sMoreNoTranslation = 'Die in New York ansässige Künstlerin <a href="http://www.maureendrennan.net/">Maureen Drennan</a> portraitierte mit ihrer Serie \'Meet Me in the Green Glen\' über mehrere Saisonzeiten hinweg den Arbeitsalltag des kalifornischen Cannabis-Bauern Ben. Ihre Fotografien gehen über die schlichte Dokumentation der Arbeitsprozesse hinaus und ermöglichen einen intimen Blick auf das Leben Bens in sozialer Abgeschiedenheit. <!--more-->
Nicht nur die Weite der umliegenden Felder trennen seine Farm und ihn von der Außenwelt. Mit dem Anbau von Cannabis bewegt er sich mehr oder minder legal in den strikten Richtlinien der kalifornischen Gesetze, die Anbau, Ernte,Vertrieb und Konsum zu medizinischen Zwecken erlauben, überschreitet damit aber die Grenzen der gesellschaftlichen Akzeptanz. Das <em>grüne Gold</em> ist die finanziell ertragreichste Nutzpflanze des Staates und unterfüttert damit umso mehr ihr zweischneidiges Bild. 

Maureen Drennan interessiert weniger das Abbild des Farmers als Profiteur dieses Systems als die Kontraste, die sein Leben widerspiegeln. Wenn für einen Monat im Jahr die jungen Erntehelfer mit ihm eine lose Gemeinschaft bilden, konzentriert sich nach der langen Zeit des einsame Züchtens und Pflegens alles auf diesen belebenden Moment. Inspiriert von den amerikanischen Schriftstellen Flannery O’ Connor und Annie Proulx verschmelzen das Portrait der Landschaft und das des Farmers zu einer Symbiose aus Einsamkeit und Zufriedenheit zugleich.

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_01.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_02.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_03.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_09.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_04.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_05.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_06.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_07.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/01/drennan_08.jpg" />

<small><p style="text-align: center">All images © <a href="http://www.maureendrennan.net/">Maureen Drennan</a></small>';

$sSpecificArticleWeAreNature = '<!--:de-->Der Fotograf <a href="http://www.christofferrelander.com/">Christoffer Relander</a> veröffentlichte gerade seine neuste Fotoserie unter dem Namen \'We Are Nature\'. Christoffer ist Grafik Designer und fotografischer Autodidakt aus Finnland, Raseborg. Im Sommer 2009 begann er zu fotografieren und hat seitdem einen ganz eigenen Stil entwickelt, viel experimentiert, an zahlreichen Ausschreibungen teilgenommen sowie eigene Projekte verfolgt. <!--:--><!--:en-->Photographer <a href="http://www.christofferrelander.com/">Christoffer Relander</a> just finished a new series of photograps called \'We Are Nature\'. Christoffer is graphic designer and self-taught photographer from Finland, Raseborg. He started photographing the summer of 2009. Since then he has been doing assignments and a lot of personal projects. <!--:--><!--more--><!--:de-->Die Serie \'We Are Nature\' zeigt doppel- und dreifach Überblendungen, die alle in der Kamera selbst, einer Nikon D700 entstanden sind. Christoffer legt die Silhouetten verschiedener Personen über Motive aus der Natur und erschafft damit seine Serie in einem schlichten aber wunderschönen schwarz-weiß Stil. 

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature01.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature02.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature03.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature04.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature05.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature06.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature07.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature08.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature09.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature10.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature11.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature12.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature13.jpeg"  />

<p style="text-align: center;"><small>All images © <a href="http://www.christofferrelander.com/">Christoffer Relander</a> | Via: <a href="http://illusion.scene360.com/art/31154/blending-into-nature/">Illusion</a></small></p><!--:--><!--:en-->In his latest series he is developping his double and triple exposures that are all done in-camera with a Nikon D700. He is blending different people with nature photography in a simple but beautiful black and white style. 

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature01.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature02.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature03.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature04.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature06.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature07.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature08.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature10.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature12.jpeg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nature13.jpeg"  />

<p style="text-align: center;"><small>All images © <a href="http://www.christofferrelander.com/">Christoffer Relander</a> | Via: <a href="http://illusion.scene360.com/art/31154/blending-into-nature/">Illusion</a></small></p><!--:-->';


$sWithIframe = '<!--:de-->Notizzettel sind tolle Gedächtnisstützen, doch was nutzt es, wenn man sie nicht sieht? Das kann mit der \'Luminaire Post\' der brasilianischen Designer des <a href="http://www.estudioninho.com/">Studio Ninho</a> nicht passieren. Die Lampe wurde aus zwei verschiedenen Ideen geboren: dem Recycling von gebrauchtem Kork sowie dem Wunsch einen zusätzlichen Nutzen für eine Tischleuchte zu kreieren. <!--:--><!--:en-->Brazilian designers of <a href="http://www.estudioninho.com/">Studio Ninho</a> created the \'Luminaire Post\'. The \'Luminaire Post\' was conceived of two distinct ideas: an unconventional use of recycled cork and the addition of a new function to a table lamp. The result: the creation of a luminaire that uses cork as structure and cork sheet as a dome. <!--:--><!--more--><!--:de-->Das Resultat war der Entwurf der \'Luminaire Post\', die fast vollständig aus Kork besteht und außerdem als Pinboard für Notizen dient. Der Kork kreiert nicht nur einen interessanten Lichteffekt, die Lampe kann fast spielerisch zusammengesetzt und genutzt werden. Der Herstellungsprozess der Lampe ist einfach, kostengünstig und nutzt nachhaltige Materialien, um Abfall, Kosten und Energie zu sparen.

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-1.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-2.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-3.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-4.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-5.jpg" />

<iframe src="http://player.vimeo.com/video/38194410?title=0&amp;byline=0&amp;portrait=0&amp;color=ffffff" width="720" height="405" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

<p style="text-align: center;"><small>All images © <a href="http://www.estudioninho.com/">Studio Ninho</a></small></p><!--:--><!--:en-->Thus, not only does it create an interesting light effect, but it also has ludic aspects in its use and assembling. In a simple and fast way, using pins and fittings, the user assembles the \'Luminaire Post\', that also works as a notice board. The manufacture process is simple, cheap and uses sustainable materials, aiming at the reduction of waste, costs and impacts on production.

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-1.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-2.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-3.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-4.jpg" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/Post-Luminaire-5.jpg" />

<iframe src="http://player.vimeo.com/video/38194410?title=0&amp;byline=0&amp;portrait=0&amp;color=ffffff" width="720" height="405" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>

<p style="text-align: center;"><small>All images © <a href="http://www.estudioninho.com/">Studio Ninho</a></small></p>
<!--:-->';

$sDanCretu = '<!--:de-->Der Fotograf und Visual Artist <a href="http://dancretu.tumblr.com/">Dan Cretu</a> kreiert Alltagsobjekte aus Gemüse und Früchten. Mit seinen Skulpturen verwandelt Dan Nahrungsmittel, die bei uns regelmäßig auf den Tisch kommen zu Objekten mit Wiedererkennungswert. <!--:--><!--:en-->Photographer and visual artist <a href="http://dancretu.tumblr.com/">Dan Cretu</a> recreates everyday objects out of fruits and vegetables. With his sculptures, Dan transforms common everyday eatables into recognizable objects. Thus a couple of oranges become a bike, cucumber is used for building a camera and popcorn transforms to a smiling face. <!--:--><!--more--><!--:de-->So werden aus ein paar Orangen ein Fahrrad, aus einer Salatgurke wird eine Kamera und Popcorn türmt sich zu einem lächelnden Gesicht auf.

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story01.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story02.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story03.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story04.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story05.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story06.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story07.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story08.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story09.jpg"  />

<p style="text-align: center;"><small>All images © <a href="http://dancretu.tumblr.com/">Dan Cretu</a></small></p>
<!--:--><!--:en-->

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story01.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story02.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story03.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story04.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story05.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story06.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story07.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story08.jpg"  />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/food-story09.jpg"  />

<p style="text-align: center;"><small>All images © <a href="http://dancretu.tumblr.com/">Dan Cretu</a></small></p><!--:-->';

$sItravel = '<!--:de-->Für iGNANTravel reise ich nach Australien und werde fünf Tage im <a href="http://www.tourismnt.com.au/"> Nothern Territory </a> verbringen. Ich frage mich, ob ich das Jetlag überhaupt überwunden habe, bevor es schon wieder zurück geht. Bisher gefällt es mir hier sehr gut und ich habe viel gesehen und erlebt (bin ja mehr oder weniger 21 Stunden am Tag wach). <!--:--><!--:en-->I am in Australia for iGNANTravel. I will spent five days in the <a href="http://www.tourismnt.com.au/"> Nothern Territory </a> and I wonder if I will have overcome the jetlag before flying back again. So far I am really enjoying it and have already seen a lot (because I am practically 21 hours awake a day). <!--:--><!--more--><!--:de-->Hier der erste Sweetspot in Darwin, den ich euch gerne zeigen möchte:

Darwin ist die nördlichste Stadt im <a href="http://www.tourismnt.com.au/"> Nothern Territory </a> von Australien. Einem Stamm der Aboriginals, den <em>Larrakia people</em>, gehört das meiste Land in und um Darwin ursprünglich. Während einer Batji Tour (batji means good), zeigte uns Robbie, der in echt Padj Padj Janama Penanke Ngamatuawia, einsern harte Bäume und kaut dabei auf heilenden schwarz-grünen Ameisen. Am Ende der Tour kommen wir an eine versteckte Küste, die vor allem den <em>Larrakia women</em> als spirituelle Oase und Ort des Friedens dienen soll: Der Lameroo Beach. Neben tiefer Glückseeligkeit habe ich dort auch unzählige dieser wunderbaren Steine gefunden. Da der Ort als Ganzes aufgefasst und gesehen werden muss und soll, gibt es hier ein paar Nahaufnahmen. Wer hat nur all diese Steine gebatikt?

<img src="http://www.ignant.de/wp-content/uploads/2012/07/batikcoast.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/nah22.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nah4.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/stein1.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/nah61.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/stockstein1.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/nah51.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/steini1.jpg" alt="" />

Die Lehm-Steine formten und färbten sich wohl vor rund 120 Millionen Jahren im inneren Gestein am Grund des Meeres. Heißes Quellwasser muss durch kleine Löcher gelangt sein und hat dort Eisen und Mangan Verbindungen abgelagert. Durch Schwefelgase in der Atmopsphäre wurden die Färbungen permanent \'eingebrannt\'. Danke Mutter Natur für dieses Phänomen.

Erfahrt mehr über das Northern Territory <a href="http://www.tourismnt.com.au/"> <strong>hier</strong></a>.

<p style="text-align: center;"><small>Text &amp; pictures by <a href="http://www.monjagentshow.com/"> Monja Gentschow </a></small></p><!--:--><!--:en-->Here is the first sweetspot I have found in Darwin:

Darwin is the northest city in the <a href="http://www.tourismnt.com.au/"> Nothern Territory </a> of Australia. Most of the land in and around Darwin originally belongs to a tribe of the Aboriginals, the <em>Larrakia people</em>. While a Batji-Tour (batji means good) through the nature of the city, Robbie who\'s real (short version) name is Padj Padj Janama Penanke Ngamatuawia, showed us around and talked about iron wooded trees while chewing on heeling black and green ants. Our tour ended on a coast named Lameroo Beach. It\'s bound to be a sacred site and spiritual place for Larrakia women to take a bath and find peace. Besides deep happiness I also found an endless number of these beautiful stones. For that the coast should be perceived as a whole (and in real), I will show you some close-up shots here. I am wondering, who has batiked all these stones?

<img src="http://www.ignant.de/wp-content/uploads/2012/07/batikcoast.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/nah22.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2012/07/nah4.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/stein1.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/nah61.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/stockstein1.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/nah51.jpg" alt="" />

<img src="http://www.ignant.de/wp-content/uploads/2013/07/steini1.jpg" alt="" />

The claystones were formed and coloured about 120 million years ago in the sediments of the inland sea. Hot springwater must have passed through the holes of the stones, so that iron and maganese compound were able to deposit. The colours were then fixed by atmospheric oxygen and sulphide gas. Thanks nature for this phenomenon.

For more information about the Northern Territory, click <a href="http://www.tourismnt.com.au//"> <strong>here </strong></a>.

<p style="text-align: center;"><small>Text &amp; pictures by <a href="http://www.monjagentshow.com/"> Monja Gentschow </a></small></p><!--:-->';

$sDummy = '<!--:de-->DeutsCH <img src="www.google.at" /><p>asdsadasdassad</p><!--:--><!--:en-->ENGLISH<!--:--><!--more--><!--:de-->MORE_DEUTSCHDEUTSCH<!--:--><!--:en-->MORE_ENGLISH<!--:-->';


header('Content-type: text/plain');
	
	
	
// $s || $sWithMore || $sDummy || $sAicuisine || $sMoreNoTranslation || $sSpecificArticleWeAreNature || $sWithIframe || $sDanCretu || $sItravel

//$lang = $_GET['lang'];

//$resS = descriptionForLanguage($sItravel, $lang);
//print $resS;

function descriptionForLanguageUnitTests()
{
	$testsFailed = 0;
	$testsPassed = 0;
	
	$s_no_tags_de_en = 'DEUTSCH<br /><em>ENGLISH</em>';
	$s_no_tags_de_en_and_more = 'DEUTSCH<br /><em>ENGLISH</em><!--more-->MORE DEUTSCH <em>MORE ENGLISH</em>';
	$s_de_en_no_more = '<!--:de-->DEUTSCH<!--:--><!--:en-->ENGLISH<!--:-->';
	$s_de_en_more_de_en = '<!--:de-->DEUTSCH<!--:--><!--:en-->ENGLISH<!--:--><!--more--><!--:de-->MORE_DEUTSCH<!--:--><!--:en-->MORE_ENGLISH<!--:-->';
	
	if(strcmp(descriptionForLanguage($s_no_tags_de_en_and_more, 'de'), 'DEUTSCH<br /><em>ENGLISH</em>MORE DEUTSCH <em>MORE ENGLISH</em>') == 0) 
	{ 
		$testsPassed++;
	}
	else $testsFailed++;
	
	if(strcmp(descriptionForLanguage($s_no_tags_de_en, 'de'), 'DEUTSCH<br /><em>ENGLISH</em>') == 0) 
	{ 
		$testsPassed++;
	}
	else $testsFailed++;

	if(strcmp(descriptionForLanguage($s_de_en_no_more, 'de'), 'DEUTSCH') == 0) 
	{ 
		$testsPassed++;
	}
	else 
		$testsFailed++;
	
	if(strcmp(descriptionForLanguage($s_de_en_more_de_en, 'de'), 'DEUTSCHMORE_DEUTSCH') == 0) 
	{ 
		$testsPassed++;
	}
	else $testsFailed++;
	
	print "\n".descriptionForLanguage($s_no_tags_de_en_and_more_with_tags, 'de')."\n";
	
	print "\n<br />testsPassed: ".(int)$testsPassed." // testsFailed: ".(int)$testsFailed." <br />\n";
}


// $before = microtime(true);
$testArticles = getArticlesForCategory($pCategoryId, 0, $pLanguage, $numberOfArticles);
// $after = microtime(true);
// echo "<br />".($after-$before) . " sec/getArticlesForCategory\n"."<br />";

function fetchRelatedArticlesUnittests()
{	
	$numberOfReturns = array(0, 0, 0);
	$fetches = 12;
	for($i=0; $i<$fetches; $i++ )
	{
		$before = microtime(true);
		
		$relatedArticles = fetchRelatedArticlesForArticleID('19534', 3);
		$c = count($relatedArticles);
		$numberOfReturns[$c] = $numberOfReturns[$c]+1;
		
		$after = microtime(true);
		print "\n".($after-$before)." ms";
	}
	
	var_dump($numberOfReturns);
}

$s = '<!--:de-->Google 2012<!--:--><!--:en-->Google 2012<!--:-->';
$t = textForLanguage($s, 'en');
print $t;

//fetchRelatedArticlesUnittests();

?>