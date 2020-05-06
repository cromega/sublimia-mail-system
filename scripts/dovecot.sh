#!/bin/bash -e

stop() {
  echo "container stopping, exiting."

  dovecot stop
  exit 100
}

rsyslogd

tail -F /var/log/mail.log &

dovecot -c /etc/sublimia/dovecot/dovecot.conf

trap stop SIGINT
trap stop SIGHUP
trap stop SIGTERM

while true; do
  sleep 1
done

