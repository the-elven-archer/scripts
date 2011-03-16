#!/bin/bash

# Set te limit variables...
LIMIT=10 # %Util limit to be supported
LOADED_QTY=3 # Qty of times that the LIMIT will be supported

TIME_UNIT=1 # Check iostat ever N seconds
SAMPLES=10 # Samples to take from iostat


# For every sample... (sed mumbo jumbo included, fuxing IFS -.-)
for i in `iostat -xm $TIME_UNIT $SAMPLES | grep sd | awk '{print $1" "$11}' | sed "s/ /_/"`
do
	# Take the disk id...
	DISK=`echo $i | awk -F"_" '{print $1}'`
	# ...and the %util value
	UTIL=`echo $i | awk -F"_" '{print $2}' | awk -F"." '{print $1}'`
# debug...
#echo "$DISK -> $UTIL"
	# if the %util is greater than our util limit...
	if [ "$UTIL" -gt "$LIMIT" ];
	then
	# ... we'll keep an eye on this sample
		ERROR_LIST="$ERROR_LIST\n$DISK $UTIL"
	fi
done

# Oh yes, crappy sample sorting...
LISTITA=`echo -e $ERROR_LIST | grep sd| awk '{print $1}'| sort | uniq -c `

# debug
#echo $LISTITA

# Save the old ifs... I'm a li'l coward ^_^
OLD_IFS=$IFS
# Changing to carriage return (I don't know why this didn't work before)
IFS="\n"

if [ "$LISTITA" ];
then
# For every row in the "strange" sample list...
for item in $LISTITA
do
# debug
#echo $item
	# Take the qty of times that it borked...
	QTY=`echo $item | awk '{print $1}'`
	#...and who's the guilty one
	BAD_DISK=`echo $item | awk '{print $2}'`
# debug
#echo "$BAD_DISK fallo $QTY veces"

	#... The moment of the truth... If the qty of times that it borked is greater than our tolerance u.u
	if [ "$QTY" -gt "$LOADED_QTY" ];
        then
		#... bad bad disk!
                #echo "$BAD_DISK fallo $QTY veces"
		#logger -t iostat_check -p local3.info "$BAD_DISK %svctm was higher than $LIMIT percent $QTY times!... Please check!"
		echo "$BAD_DISK svctm was greater than $LIMIT $QTY times"
		exit 2
	else
		echo "OK|iostat is Happy!"
		exit 0
        fi
	
done
else
echo "OK|iostat is Happy!"
exit 0

fi

#... I've told you that I'm a li'l coward? Restoring the default IFS
IFS=$OLD_IFS
