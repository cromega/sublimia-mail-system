#!/bin/bash -ex

cd "$(dirname "$0")"

for sql in *.sql; do sqlite3 "$MAIL_DB_PATH" < $sql; done


