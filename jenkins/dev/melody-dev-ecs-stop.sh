#!/bin/bash
set -x

AWS_REGION=ap-northeast-1
AWS_PROFILE=dev
AWS_CMDPREFIX="aws --region ${AWS_REGION} --profile ${AWS_PROFILE}"
ENV_VERSION=`aws route53 list-resource-record-sets --hosted-zone-id Z1250UHLISUGOP --query "ResourceRecordSets[?Name == 'api-dev.melody.use1.dev.aws.asurion.net.']" | grep Value | awk '{print $2}' | sed 's/use1//g' | awk '{gsub(/[^0-9 ]/,"")}1'`

ASG_GROUPNAME=melody-asg-dev-${ENV_VERSION}
MIN_SIZE=0
MAX_SIZE=0

ECS_CLUSTERNAME=melody-cluster-dev-${ENV_VERSION}
DESIRED_COUNT=0

for i in melody-assets melody-funding melody-financier melody-common melody-lease melody-portfolio

do

ECS_SERVICENAME=$i

ECSSERVICE_STOP=$(eval "${AWS_CMDPREFIX} ecs update-service --cluster ${ECS_CLUSTERNAME} --service ${ECS_SERVICENAME} --desired-count ${DESIRED_COUNT}")
echo "AWS command: ${ECSSERVICE_STOP}"

done

sleep 120

AUTOSCALING_STOP=$(eval "${AWS_CMDPREFIX} autoscaling update-auto-scaling-group --auto-scaling-group-name ${ASG_GROUPNAME} --min-size ${MIN_SIZE} --max-size ${MAX_SIZE}")
echo "AWS command: ${AUTOSCALING_STOP}"
