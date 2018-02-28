#!/bin/bash
set -x

AWS_REGION=ap-northeast-1
AWS_PROFILE=dev
AWS_CMDPREFIX="aws --region ${AWS_REGION} --profile ${AWS_PROFILE}"

ASG_GROUPNAME=mobility-dfs-dev-asg-1
MIN_SIZE=2
MAX_SIZE=2

ECS_CLUSTERNAME=mobility-dfs-cluster-dev-1
ECS_SERVICENAME=mobility-dfs-service
DESIRED_COUNT=1

AUTOSCALING_START=$(eval "${AWS_CMDPREFIX} autoscaling update-auto-scaling-group --auto-scaling-group-name ${ASG_GROUPNAME} --min-size ${MIN_SIZE} --max-size ${MAX_SIZE}")
echo "AWS command: ${AUTOSCALING_START}"

sleep 120

ECSSERVICE_START=$(eval "${AWS_CMDPREFIX} ecs update-service --cluster ${ECS_CLUSTERNAME} --service ${ECS_SERVICENAME} --desired-count ${DESIRED_COUNT}")
echo "AWS command: ${ECSSERVICE_START}"
