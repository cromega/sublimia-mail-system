#!/bin/bash

for port in $1; do
  nc -z localhost $port || exit 1
done
