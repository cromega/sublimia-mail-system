#!/bin/bash -e

rsyslogd
postfix -c /etc/postfix start
authdaemond start
imapd-ssl start