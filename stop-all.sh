#!/bin/bash

source /var/lib/myfrdcsa/codebases/independent/koms-web/config.sh

ps auxwww | grep "$KOMSWebPerlScript" | awk '{print $2}' | grep . | xargs kill -9
ps auxwww | grep "/usr/bin/python3 /usr/bin/mitmproxy -s $KOMSWebScript" | awk '{print $2}' | grep . | xargs kill -9
ps auxwww | grep "./script/koms" | awk '{print $2}' | grep . | xargs kill -9
