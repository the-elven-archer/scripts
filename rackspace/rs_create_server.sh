#!/bin/bash

#Get Rackspace credentials needed ########
CREDENTIALS="/root/.rackspace/credentials"
TOKEN=`cat $CREDENTIALS | grep "Auth-Token" | awk '{print $2}'`
MANAGEMENT_URL=`cat $CREDENTIALS | grep "Server-Management-Url" | awk '{print $2}'`
###########################################
FLAVOR_COMMAND=rs_get_flavors.sh
IMAGES_COMMAND=rs_get_images.sh

#Creation Arguments
SERVER_NAME="$1"
SERVER_IMAGE="$2"
SERVER_FLAVOR="$3"



# Crappy argument check
if [ -z "$SERVER_NAME" ]
then
	echo "You missed the Server Name!"
	echo "Server Name:"
	read SERVER_NAME
	if [ -z "$SERVER_NAME" ]
	then
		echo "Abort"
		exit
	fi
#	echo "Usage: rs_create_server.sh SERVER_NAME SERVER_IMAGE_ID SERVER_FLAVOR_ID"
#	exit
fi
if [ -z "$SERVER_IMAGE" ]
then
	echo "You missed the Image ID!"
	$IMAGES_COMMAND
	echo "Choose the Image ID:"
	read SERVER_IMAGE
	if [ -z "$SERVER_IMAGE" ]
	then
		echo "Abort"
		exit
	fi
#        echo "Usage: rs_create_server.sh SERVER_NAME SERVER_IMAGE_ID SERVER_FLAVOR_ID"
#        exit
fi
if [ -z "$SERVER_FLAVOR" ]
then
        echo "You missed the Flavor ID!"
	$FLAVOR_COMMAND
	echo "Choose the Flavor ID:"
	read SERVER_FLAVOR
	if [ -z "$SERVER_FLAVOR" ]
	then
		echo "Abort"
		exit
	fi
#        echo "Usage: rs_create_server.sh SERVER_NAME SERVER_IMAGE_ID SERVER_FLAVOR_ID"
#        exit
fi

echo $SERVER_NAME
#echo $SERVER_IMAGE
$IMAGES_COMMAND | grep "id:$SERVER_IMAGE "
#echo $SERVER_FLAVOR
$FLAVOR_COMMAND | grep "id:$SERVER_FLAVOR "
QUERY_URL=$MANAGEMENT_URL/servers

echo "----- Creating server $SERVER_NAME... "
curl -s -X POST -H"X-Auth-Token: `echo $TOKEN`"  -H "Content-type: application/json" -d "{\"server\" : {\"name\" : \"$SERVER_NAME\",\"imageId\" : $SERVER_IMAGE,\"flavorId\" : $SERVER_FLAVOR,}}" $QUERY_URL | sed "s/,\"/\\n/g" | sed "s/\[/\\n/g" | sed "s/\]//g" | sed "s/{//g" | sed "s/}//g" | sed "s/\"//g"| sed "s/addresses:public/addresses:\npublic/g" | awk -F"," '{print $1" "$2}'
echo "----- Done"

