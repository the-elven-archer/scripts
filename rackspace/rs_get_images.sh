#!/bin/bash

#Get Rackspace credentials needed ########
CREDENTIALS="/root/.rackspace/credentials"
TOKEN=`cat $CREDENTIALS | grep "Auth-Token" | awk '{print $2}'`
MANAGEMENT_URL=`cat $CREDENTIALS | grep "Server-Management-Url" | awk '{print $2}'`
###########################################
QUERY_URL=$MANAGEMENT_URL/images

echo "----- Server Images -----"
curl -s -H"X-Auth-Token: `echo $TOKEN`"  $QUERY_URL | sed "s/},{/\\n/g" | sed "s/\[/\\n/g" | sed "s/\]//g" | sed "s/{//g" | sed "s/}//g" | sed "s/\"//g"| awk -F"," '{print $1" - "$2}'


echo "--------------------------"
