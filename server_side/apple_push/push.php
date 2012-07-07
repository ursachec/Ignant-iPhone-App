<?php
require_once("../feedKeys.php");

$development = false;

// APNs Push testen auf Token
$deviceToken = '3ace0f88fa09da19d6097a87eef6be4a1ffef55be9276c597b70278d86d36dcc'; // Hier das Device-Token angeben, ist 64-stellig
 
$deviceTokenClemens = '1f4a23e9 43df08ba 9c3ea415 19be3a02 cd8a8789 7c0756a2 0444c459 8be0daf2';


$deviceTokens = array($deviceToken, $deviceTokenClemens);

// Payload erstellen und JSON codieren
$payload['aps'] = array('alert' => '☞ Jasmine Deporta | New Fotos', 'badge' => 0);
$payload['articleId'] = 'jasmine_deporta';

$payload = json_encode($payload);


$apnsHost = $development ? 'gateway.sandbox.push.apple.com' : 'gateway.push.apple.com';
$apnsPort = 2195;
$apnsCert = $development ? 'push_dev_cert_and_key.pem' : 'push_prod_cert_and_key.pem';
 
// Stream erstellen
$streamContext = stream_context_create();

stream_context_set_option($streamContext, 'ssl', 'local_cert', $apnsCert);


$apns = stream_socket_client('ssl://' . $apnsHost . ':' . $apnsPort, $error, $errorString, 2, STREAM_CLIENT_CONNECT, $streamContext);

if ($apns)
{
	foreach($deviceTokens as $tok ){
		// Nachricht erstellen und senden
		  $apnsMessage = chr(0) . chr(0) . chr(32) . pack('H*', str_replace(' ', '', $tok)) . chr(0) . chr(strlen($payload)) . $payload;
		  fwrite($apns, $apnsMessage);
	}

  // Verbindung schliessen
  fclose($apns);
}
else
{
  echo "Fehler!";
  var_dump($error);

  var_dump($errorString);

}

?>
