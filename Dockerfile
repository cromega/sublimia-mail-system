FROM alpine:3.16.2

LABEL maintainer="crome@moronia.hu"

RUN apk add --no-cache bash postfix cyrus-sasl rsyslog dovecot dovecot-lmtpd shadow openssl ca-certificates

COPY postfix /etc/sublimia/postfix/
COPY dovecot /etc/sublimia/dovecot/
COPY scripts/ /

RUN addgroup vmail && \
    mkdir -p /var/mail

CMD ["bash", "-c", "/start.sh"]
