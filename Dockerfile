FROM debian:buster

LABEL maintainer="crome@moronia.hu"

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_PACKAGES "bash vim postfix postfix-sqlite sasl2-bin courier-imap courier-authlib-sqlite sqlite3 rsyslog"
ENV MAIL_DB_PATH /etc/postfix/mail.db

RUN apt-get update && apt-get -y install --no-install-recommends $INSTALL_PACKAGES
RUN groupadd -g 5000 vmail && \
    useradd -d /var/mail -M -r -s /bin/false -u 5000 -g 5000 vmail && \
    chown -R vmail: /var/mail

ADD postfix /etc/postfix/
ADD sasl2 /etc/sasl2/

ADD certs /root/certs/
RUN /root/certs/install.sh

ADD sql /root/sql/
RUN /root/sql/create.sh
