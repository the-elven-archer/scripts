#!/bin/bash

#Get Servername
SERVER=$1
#
#HOSTFILE=/etc/hosts
KEYFILE=/root/.ssh/id_rsa.pub
RS_SCRIPT_PATH=/root/
RS_INTERFACE_SCRIPT=rshybridnetworkconfig-v1.1.sh
RS_GATEWAYS_FILE=gateways.txt

if [ -z $SERVER ]
then
	echo "Usage:"
	echo -e "rs_standarize_server.sh SERVER_NAME\n"
	exit
fi

#CHECK_EXIST=`cat /etc/hosts | grep $SERVER`
#EXIST=$?
#
#if [ $EXIST == "0" ]
#then
#	echo "Host exists in $HOSTFILE"
#else
#	echo "Host doesn't exists in $HOSTFILE"
#fi

function copy_key() {
	echo -e "Copying root key to $SERVER..."
	ssh-copy-id -i $KEYFILE $SERVER
	ITS_OK=$?
	if [ $ITS_OK == "0" ]
	then
		echo -e "\nEverything seems to went fine...\n"
	else
		echo -e "Uh oh... There's something wrong\nCheck if the password or the keyfile is ok\n"
		exit
	fi
}

function close_network() {
	echo -e "Bringing down server's public eth and changing default GW..."
	echo -e "This step is very \"sensible\". You may lose network connectivity to the servers\nIf anything wrong happens, go to the online webconsole and check the gateways"
	echo -e "Do you want to continue?\n[y/N]"
	read continue
	case $continue in
	y)
		echo -e "Copying Scripts..."
		chmod +x $RS_SCRIPT_PATH$RS_INTERFACE_SCRIPT
		scp $RS_SCRIPT_PATH$RS_INTERFACE_SCRIPT $RS_SCRIPT_PATH$RS_GATEWAYS_FILE root@$SERVER:/root
		chmod -x $RS_SCRIPT_PATH$RS_INTERFACE_SCRIPT
		sleep 1
		echo -e "Changing gateways... Cross your fingers..."
		ssh root@$SERVER /root/$RS_INTERFACE_SCRIPT
		sleep 1
		echo -e "Done..."
	;;
	n)
		echo -e "Aborting!"
	;;
	*)
		echo -e "Wrong answer, aborting!"
	;;
	esac
}

copy_key
close_network
