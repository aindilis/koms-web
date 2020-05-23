#!/bin/sh

mitmproxy -R "/~s/first/worst"

# # put certs in trusted?
# sudo mkdir /usr/share/ca-certificates/extra
# sudo chown $USER.$USER /usr/share/ca-certificates/extra
# cp ~/.mitmproxy/* /usr/share/ca-certificates/extra
# cd /usr/share/ca-certificates/extra && openssl x509 -in mitmproxy-ca-cert.pem --inform PEM --out mitmproxy-ca-cert.crt
# cd /usr/share/ca-certificates/extra && openssl x509 -in mitmproxy-ca.pem --inform PEM --out mitmproxy-ca.crt
# sudo dpkg-reconfigure ca-certificates

# mkdir /usr/share/ca-certificates/extra
# cp ~/.mitmproxy/* /usr/share/ca-certificates/extra
# cd /usr/share/ca-certificates/extra && sudo openssl x509 -in mitmproxy-ca-cert.pem --inform PEM --out mitmproxy-ca-cert.crt
# cd /usr/share/ca-certificates/extra && sudo openssl x509 -in mitmproxy-ca.pem --inform PEM --out mitmproxy-ca.crt
# sudo dpkg-reconfigure ca-certificates
