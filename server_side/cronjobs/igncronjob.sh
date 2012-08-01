#!/bin/bash
echo '##########################################'
echo 'starting ignant cronjob...'
echo '##########################################'

PHP_SCRIPT_LOG="script.log"

MODULES_DIR="/www/htdocs/w00d3020/ignantblog/app/modules"
MOSAIC_SCRIPT_DIR="$MODULES_DIR/mosaic/mosaic_generator.php"
THUMB_SCRIPT_DIR="$MODULES_DIR/thumbs/thumbs_generator.php"
NOTIFICATIONS_SCRIPT_DIR="$MODULES_DIR/"

BATCH=20
SLEEP_FOR=1

php $MOSAIC_SCRIPT_DIR max=$BATCH ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=detailImg max=$BATCH ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=mosaicImg max=$BATCH ;
sleep $SLEEP_FOR ;
php $THUMB_SCRIPT_DIR imgType=relatedImg max=$BATCH ;


echo '##########################################'
echo 'finished running ignant cronjob.'
echo '##########################################'

