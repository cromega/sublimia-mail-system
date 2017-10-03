#!/bin/bash

check() {
  local port=$1

  nc -z localhost $port
  ret=$?

  if [ $ret -ne 0 ]; then
    echo "connection to port $port failed, killing container"
    exit 100
  fi
}

rsyslogd
postfix -c /etc/postfix start
imapd-ssl start
authdaemond start

sleep 5

while true; do
  check 25
  check 587
  check 993

  sleep 30
done
