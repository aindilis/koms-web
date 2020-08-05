#!/bin/bash

source /var/lib/myfrdcsa/codebases/independent/koms-web/config.sh

# put this little guard (koms) here so if KOMSWebPerlScript is undefined it doesn't kill your whole system
ps auxwww | grep koms | grep "$KOMSWebPerlScript" | awk '{print $2}' | grep . | xargs kill -9
ps auxwww | grep "/usr/bin/python3 /usr/bin/mitmproxy -s $KOMSWebScript" | awk '{print $2}' | grep . | xargs kill -9
ps auxwww | grep "./script/koms" | awk '{print $2}' | grep . | xargs kill -9
