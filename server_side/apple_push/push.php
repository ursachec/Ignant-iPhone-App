<?php
require_once("../feedKeys.php");


// APNs Push testen auf Token
$deviceToken = 'fb0cb5a6 a3aef678 614e481a 9bb896d2 9aac619e 826caf07 97ce53eb 78ee2a6f'; // Hier das Device-Token angeben, ist 64-stellig
 
$deviceTokenClemens = '1f4a23e9 43df08ba 9c3ea415 19be3a02 cd8a8789 7c0756a2 0444c459 8be0daf2';


$deviceTokens = array($deviceToken, $deviceTokenClemens);

// Payload erstellen und JSON codieren
// $payload['aps'] = array('alert' => 'Hi Clemens!', 'badge' => 1, 'sound' => 'default');
$payload['aps'] = array('alert' => '☞ Jasmine Deporta | New Fotos', 'badge' => 0);
$payload['articleId'] = 'jasmine_deporta';

$payload = json_encode($payload);


$apnsHost = 'gateway.sandbox.push.apple.com';
$apnsPort = 2195;
$apnsCert = 'push_dev_cert_and_key.pem';
 
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
