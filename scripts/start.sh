#!/bin/bash -e

service=$1

gen_dh() {
  if [ ! -f /etc/sublimia/dhparams.pem ]; then
    openssl dhparam 2048 > /etc/sublimia/dhparams.pem
  fi
}

create_domains() {
  echo $SUBLIMIA_MAIL_DOMAINS > /etc/sublimia/domains
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

stop() {
  case $service in
    postfix)
      postfix stop
      ;;
    dovecot)
      dovecot stop
      ;;
    *)
      echo service=$service. wtf.
      exit 1
  esac
}


gen_dh
create_domains
create_user_db

rsyslogd

tail -F /var/log/mail.log &

case $service in
  postfix)
    postfix -c /etc/sublimia/postfix start
    ;;
  dovecot)
    dovecot -c /etc/sublimia/dovecot/dovecot.conf
    ;;
  *)
    echo service=$service. wtf.
    exit 1
esac

trap stop SIGINT
trap stop SIGHUP
trap stop SIGTERM

while true; do
  sleep 1
done
