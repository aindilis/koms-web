#!/bin/bash

source /var/lib/myfrdcsa/codebases/independent/koms-web/config.sh

$KOMSWEB_DIR/stop-all.sh

cd $KOMSWEB_DIR/ && ./komsweb-agent.pl &
screen -dm bash -c "cd $KOMSWEB_DIR && mitmproxy -s $KOMSWebScript"
cd $KOMSWEB_DIR/koms && morbo ./script/koms daemon -l http://*:8081 &

## export FULL_HOSTNAME=`hostname -f`
## export HTTP_PROXY=https://$FULL_HOSTNAME:8080
## export HTTPS_PROXY=https://$FULL_HOSTNAME:8080
firefox -P mitmproxy &
