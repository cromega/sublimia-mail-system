#!/bin/bash -ex

/runall.sh

# SMTP TLS
echo 127.0.0.1 test.sublimia.nl >> /etc/hosts
echo quit | openssl s_client -connect localhost:587 -starttls smtp 2>&1 | grep "Verify return code: 0 (ok)"

# SMTP AUTH
sqlite3 "$MAIL_DB_PATH" 'INSERT INTO mailboxes VALUES ("test@test.com", "{SHA256}n4bQgYhMfWWaL+qgxVrQFaO/TxsrC4Is0V1sFbDwCgg=", "test.com/test", CURRENT_TIMESTAMP, 5000, 5000);'

(echo -e "ehlo test@test.com\r\nAUTH PLAIN dGVzdEB0ZXN0LmNvbQB0ZXN0QHRlc3QuY29tAHRlc3Q="; sleep 1) | openssl s_client -connect localhost:587 -starttls smtp 2>&1 | grep "235 2.7.0 Authentication successful"

echo -e "\n\nALL OK\n\n"
