#!/bin/bash


subj="/C=GB/ST=London/L=London/O=sublimia/OU=sublimia/CN=localhost"
openssl req -x509 -newkey rsa:4096 -nodes -subj $subj -keyout /etc/sublimia/key.pem -out /etc/sublimia/cert.pem -days 365
cat /etc/sublimia/key.pem >> /etc/sublimia/cert.pem
#openssl dhparam 1024 > /etc/sublimia/dhparams.pem

exec /start.sh


