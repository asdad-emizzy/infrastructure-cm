#!/bin/bash
set -x

AWS_REGION=ap-northeast-1
AWS_PROFILE=dev
AWS_CMDPREFIX="aws --region ${AWS_REGION} --profile ${AWS_PROFILE}"

ASG_GROUPNAME=mobility-dfs-asg-dev
MIN_SIZE=1
MAX_SIZE=1

ECS_CLUSTERNAME=mobility-dfs-cluster-dev
ECS_SERVICENAME1=melody-api
#ECS_SERVICENAME2=mobility-dfs-service2
#ECS_SERVICENAME3=mobility-dfs-service1-ext
DESIRED_COUNT=1

AUTOSCALING_START=$(eval "${AWS_CMDPREFIX} autoscaling update-auto-scaling-group --auto-scaling-group-name ${ASG_GROUPNAME} --min-size ${MIN_SIZE} --max-size ${MAX_SIZE}")
echo "AWS command: ${AUTOSCALING_START}"

sleep 120

ECSSERVICE_START1=$(eval "${AWS_CMDPREFIX} ecs update-service --cluster ${ECS_CLUSTERNAME} --service ${ECS_SERVICENAME1} --desired-count ${DESIRED_COUNT}")
echo "AWS command: ${ECSSERVICE_START1}"

#ECSSERVICE_START2=$(eval "${AWS_CMDPREFIX} ecs update-service --cluster ${ECS_CLUSTERNAME} --service ${ECS_SERVICENAME2} --desired-count ${DESIRED_COUNT}")
#echo "AWS command: ${ECSSERVICE_START2}"

#ECSSERVICE_START3=$(eval "${AWS_CMDPREFIX} ecs update-service --cluster ${ECS_CLUSTERNAME} --service ${ECS_SERVICENAME3} --desired-count ${DESIRED_COUNT}")
#echo "AWS command: ${ECSSERVICE_START3}"
