#!/bin/bash

USERNAME=`cat /root/.rackspace/login | awk '{print $1}'`
KEY=`cat /root/.rackspace/login | awk '{print $2}'`
CREDENTIALS_FILE="/root/.rackspace/credentials"

curl -s -H"X-Auth-User: $USERNAME" -H"X-Auth-Key: $KEY" https://auth.api.rackspacecloud.com/v1.0 -D $CREDENTIALS_FILE
chmod 600 $CREDENTIALS_FILE
dos2unix $CREDENTIALS_FILE
cat $CREDENTIALS_FILE

