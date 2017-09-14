FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_PACKAGES "bash vim postfix postfix-sqlite libsasl2-2 courier-imap sqlite3"
ENV MAIL_DB_PATH /etc/postfix/mail.db

RUN apt-get update && apt-get -y install --no-install-recommends $INSTALL_PACKAGES

ADD postfix /etc/postfix/
ADD certs /root/certs/
RUN /root/certs/install.sh

ADD sql /root/sql/
RUN /root/sql/create.sh

RUN service postfix reload

