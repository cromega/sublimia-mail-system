#!/bin/bash -e

stop() {
  echo "container stopping, exiting."

  postfix stop
  exit 100
}

rsyslogd

tail -F /var/log/mail.log &

postfix -c /etc/sublimia/postfix start

trap stop SIGINT
trap stop SIGHUP
trap stop SIGTERM

while true; do
  sleep 1
done

