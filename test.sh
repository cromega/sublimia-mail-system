#!/bin/bash -ex

/runall.sh

# SMTP TLS
echo 127.0.0.1 test.sublimia.nl >> /etc/hosts
echo "quit" | openssl s_client -starttls smtp -connect test.sublimia.nl:25 -quiet

echo
echo
echo ALL OK
