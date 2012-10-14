#!/bin/bash

PHP_SCRIPT_LOG="/www/htdocs/w00d3020/ignantblog/app/cronjobs/script.log"

MODULES_DIR="/www/htdocs/w00d3020/ignantblog/app/modules"
MOSAIC_SCRIPT_DIR="$MODULES_DIR/mosaic/mosaic_generator.php"
THUMB_SCRIPT_DIR="$MODULES_DIR/thumbs/thumbs_generator.php"
NOTIFICATIONS_SCRIPT_DIR="$MODULES_DIR/"

BATCH=20
SLEEP_FOR=1

NOW=$(date)

echo "\n##########################################" >> $PHP_SCRIPT_LOG
echo "starting ignant cronjob... ($NOW)" >> $PHP_SCRIPT_LOG
echo '##########################################' >> $PHP_SCRIPT_LOG

php $MOSAIC_SCRIPT_DIR max=$BATCH >> $PHP_SCRIPT_LOG ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=detailImg max=$BATCH >> $PHP_SCRIPT_LOG ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=mosaicImg max=$BATCH >> $PHP_SCRIPT_LOG ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=relatedImg max=$BATCH >> $PHP_SCRIPT_LOG ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=slideshowImg max=$BATCH >> $PHP_SCRIPT_LOG ;

echo '##########################################' >> $PHP_SCRIPT_LOG
echo 'finished running ignant cronjob.' >> $PHP_SCRIPT_LOG
echo "##########################################\n" >> $PHP_SCRIPT_LOG

