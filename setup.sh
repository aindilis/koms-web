#!/bin/sh

# # # ensure mitmproxy is installed

# # # create certs
# # mitmproxy --create-certs
# # sleep 5
# # killall -9 mitmproxy

# # sudo /etc/init.d/unilang start
# cd /var/lib/myfrdcsa/codebases/independent/koms-web/ && ./run.sh &

# # # set proxy accept cert
# export HTTP_PROXY=https://$HOSTNAME:8080
# export HTTPS_PROXY=https://$HOSTNAME:8080

# # # prompt user to accept the cert
# # CheckWithUser()

# # # launch browser and accept cert
# firefox -P KOMSWeb https://mitm.it &

# # sudo /etc/init.d/unilang start
# cd /var/lib/myfrdcsa/codebases/independent/koms-web/koms && ./run.sh &

# # # prompt user to continue to the page
# # GetSignalToProceed()
# firefox -P KOMSWeb -remote 'openUrl(https://debian.org/documentation/manuals)'
