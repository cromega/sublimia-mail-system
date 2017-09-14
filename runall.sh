#!/bin/bash -e

rsyslogd
postfix -c /etc/postfix start
saslauthd -a pam
authdaemond start
