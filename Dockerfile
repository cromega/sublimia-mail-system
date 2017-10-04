FROM debian:stretch

LABEL maintainer="crome@moronia.hu"

ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_PACKAGES "bash vim postfix postfix-sqlite sasl2-bin libsasl2-modules courier-imap courier-authlib-sqlite sqlite3 rsyslog ca-certificates"
ENV MAIL_DB_PATH /etc/postfix/mail.db.sqlite

RUN apt-get update && apt-get -y install --no-install-recommends $INSTALL_PACKAGES
RUN groupadd -g 5000 vmail && \
    useradd -d /var/mail -M -r -s /bin/false -u 5000 -g 5000 vmail && \
    chown -R vmail: /var/mail

# TODO remove this stuff
RUN apt-get install -y procps man file net-tools netcat tmux less strace

ADD postfix /etc/postfix/
ADD courier /etc/courier/
RUN mkdir -p /run/courier/authdaemon

ADD certs /root/certs/
RUN /root/certs/install.sh

ADD sql /root/sql/
RUN /root/sql/create.sh

ADD scripts/ /
ADD test /root/test/

CMD "/start.sh"
