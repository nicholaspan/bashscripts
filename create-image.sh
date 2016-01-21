#!/bin/bash

# 
# Script in charge of performing AMI creation of instance.
# This should be used on an instance with the AWS CLI installed on
# 
# $ create-image <instance-id>
#

INSTANCE_ID=$1
AMI_ID="$INSTANCE_ID-backup-`date +"%D"`"
AMI_DESCRIPTION="Backup of instance $INSTANCE_ID on `date +"%D"`"
OLD_AMI="$INSTANCE_ID-backup-`date +"%D" --date '6 days ago'`"

# This will run the actual AMI creation command
echo "Creating AMI for instance $1"
aws ec2 create-image --instance-id $1 --name "$AMI_ID" --description "$AMI_DESCRIPTION"

# This will let the user know the command had a successful response code
if [ $? -eq 0 ]; then
	echo "AMI creation of $1 has been successful"
fi

# This will check for AMI's older than 5 days ago

echo "Checking for AMI's of instance $1 older than 5 days"

aws ec2 describe-images --filters "Name=name,Values=$OLD_AMI" | grep -i imageid | cut -d'"' -f4 > /tmp/amiid.txt

image_id=`cat /tmp/amiid.txt`
lines=`wc -l /tmp/amiinfo.txt | cut -d' ' -f1`

# Will only execute if an image is found
if [ "$lines" -gt "0" ] ; then

	#This will find the snapshots associated with the image
	aws ec2 describe-images --image-ids "$image_id" | grep -i snap | cut -d'"' -f4 > /tmp/snapids.txt

	#This deregisters the old image
	echo "Deregistering image $OLD_AMI"
	aws ec2 deregister-image --image-id "$image_id"

	
	#This will remove the snapshots associated with the image
	for i in `cat /tmp/snapids.txt`
		do
	aws ec2 delete-snapshot --snapshot-id $i
	done
fi
