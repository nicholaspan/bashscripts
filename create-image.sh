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

# This will run the actual AMI creation command
echo "Creating AMI for instance $1"
aws ec2 create-image --instance-id $1 --name "$AMI_ID" --description "$AMI_DESCRIPTION"

# This will let the user know the command had a successful response code
if [ $? -eq 0 ]; then
	echo "AMI creation of $1 has been successful"
fi
