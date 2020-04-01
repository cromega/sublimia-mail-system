FROM alpine:3.11

LABEL maintainer="crome@moronia.hu"

RUN apk add --no-cache bash postfix rsyslog dovecot dovecot-lmtpd shadow openssl ca-certificates

ADD postfix /etc/sublimia/postfix/
ADD dovecot /etc/sublimia/dovecot/

ADD scripts/ /

CMD ["bash", "-c", "/start.sh"]
