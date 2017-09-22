#!/bin/bash

rsyslogd
postfix -c /etc/postfix start
imapd-ssl start
authdaemond start

sleep 5

while true; do
  nc -z localhost 25
  ret=$?
  if [ $ret -eq 0 ]; then
    sleep 30
  else
    exit 100
  fi
done
