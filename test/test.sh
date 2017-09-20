#!/bin/bash -ex

/runall.sh

# SMTP TLS
echo 127.0.0.1 test.sublimia.nl >> /etc/hosts
echo quit | openssl s_client -connect test.sublimia.nl:587 -starttls smtp 2>&1 | grep "Verify return code: 0 (ok)"

sqlite3 "$MAIL_DB_PATH" 'INSERT INTO mailboxes VALUES ("test@sublimia.nl", "{SHA256}n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=", "sublimia.nl/test/", CURRENT_TIMESTAMP, 5000, 5000);'

# SMTP AUTH
(echo -e "EHLO test@test.com\r\nAUTH PLAIN dGVzdEBzdWJsaW1pYS5ubAB0ZXN0QHN1YmxpbWlhLm5sAHRlc3Q="; sleep 1) | openssl s_client -connect localhost:587 -starttls smtp 2>&1 | grep "235 2.7.0 Authentication successful"

# SMTP delivery
sendmail -F test@test.com test@sublimia.nl < /root/test/test.mail
sleep 1
cat /var/mail/sublimia.nl/test/new/* | grep "This is a test email"



# IMAP TLS
echo | openssl s_client -connect test.sublimia.nl:993 | grep "Verify return code: 0 (ok)"


echo -e "\n\nALL OK\n\n"
