#!/bin/bash
set -e
.  ./test.sh &
echo "world"
while :
do
sleep 10
done
