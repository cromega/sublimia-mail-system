#!/bin/bash

bootstrap() {
  addgroup vmail
  chown -R vmail:vmail /var/mail

  if [ ! -f /etc/sublimia/dhparams.pem ]; then
    openssl dhparam 2048 > /etc/sublimia/dhparams.pem
  fi
}

create_user_db() {
  touch /etc/sublimia/mailboxes
  local gid=$(getent group vmail | cut -d: -f3)

  env | grep SUBLIMIA_MAIL_USER | while read user; do
    local user=$(echo $user | cut -d= -f2 | tr ":" " ")
    read name pw <<< $(echo $user)
    echo "$name:$(mkpasswd $pw):vmail:$gid::::" >> /etc/sublimia/mailboxes
  done
}

create_domains() {
  echo $SUBLIMIA_MAIL_DOMAINS > /etc/sublimia/domains
}

check() {
  local port=$1

  nc -z localhost $port
  ret=$?

  if [ $ret -ne 0 ]; then
    echo "connection to port $port failed, killing container"
    exit 100
  fi
}

bootstrap
create_domains
create_user_db

rsyslogd
dovecot -c /etc/sublimia/dovecot/dovecot.conf
postfix -c /etc/sublimia/postfix start

touch /.ready

sleep 5

while true; do
  check 25
  check 143
  check 587

  sleep 30
done
