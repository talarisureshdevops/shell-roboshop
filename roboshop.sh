#!/bin/bash/
SG_ID="sg-07718e2f0115aadf5" #replace with your ID
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z0692071PCP0NH1SHCGI"
DOMAIN_NAME="laddudevops86.fun"

for instance in $@
do
INSTAND_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]"\
  --query 'Instances[0].InstanceId' \
  --output text)

  if [ $instance=="frontend" ]; then
    IP=$(aws ec2 describe-instances \
  --instance-ids $INSTAND_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

  RECORD_NAME="$instance.$DOMAIN_NAME" #laddudevops86.fun
  
  else 
  IP=$(aws ec2 describe-instances \
  --instance-ids $INSTAND_ID \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text
  )
  RECORD_NAME="$instance.$DOMAIN_NAME" #laddudevops86.fun
  fi
  echo "IP Adress: $IP"
  
  aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            { "Value": "'$IP'" }
          ]
        }
      }
    ]
  }'
  echo "record updated for dollar instances"
done 

