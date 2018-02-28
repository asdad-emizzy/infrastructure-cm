#!/bin/bash

AWS_REGION=ap-northeast-1
AWS_PROFILE=dev
AWS_CMDPREFIX="aws --region ${AWS_REGION} --profile ${AWS_PROFILE} "

BASE_DIR=~

#AGE_LIMIT of file in seconds (# of seconds in 1 week)
AGE_LIMIT=604800

AMIQUERY_FILE=${BASE_DIR}/amiquery.out

AWS_CMDLINE="${AWS_CMDPREFIX} ec2 describe-images --owners amazon --filters \"Name=architecture,Values=x86_64\" \"Name=virtualization-type,Values=hvm\""

echo "Querying AWS for list of available images..."
echo ${AWS_CMDLINE}
#eval ${AWS_CMDLINE} > ${AMIQUERY_FILE}

#aws --region us-east-1 ec2 describe-images --owners amazon --filters "Name=architecture,Values=x86_64" "Name=virtualization-type,Values=hvm" > ${AMIQUERY_FILE}

if [ ! -f ${AMIQUERY_FILE} ]
then
   echo "${AMIQUERY_FILE} not generated. Exiting..."
   exit 1
fi

AMI_FILTER="ecs"

AWS_ECS_CLUSTER=mobility-dfs-cluster-dev

CONTAINER_INSTANCE_UUID=$(aws --region ap-northeast-1 --profile dev ecs list-container-instances --cluster mobility-dfs-cluster-dev | grep "arn:aws:ecs" | awk -F "\/" '{print $2}' 2>/dev/null | sed 's/"//')

INSTANCE_ID=${AWS_CMDPREFIX} ecs describe-container-instances --cluster ${AWS_ECS_CLUSTER} --container-instances ${CONTAINER_INSTANCEID} | grep ec2InstanceId

#AWS_CMDLINE="${AWS_CMDPREFIX} elasticbeanstalk describe-instances-health --environment-name ${AWS_ENVNAME} |grep InstanceId ${AWS_FILTER}"

echo "Querying AWS for InstanceId for environment ${AWS_ENVNAME}"
echo ${AWS_CMDLINE}
INSTANCE_ID=$(eval ${AWS_CMDLINE}|tail -1)

AWS_CMDLINE="${AWS_CMDPREFIX} ec2 describe-instances --instance-ids ${INSTANCE_ID} |grep ImageId ${AWS_FILTER}"

echo "Querying AWS for ImageId for instance ${INSTANCE_ID}"
echo ${AWS_CMDLINE}
IMAGE_ID=$(eval ${AWS_CMDLINE})

AWS_CMDLINE="${AWS_CMDPREFIX} ec2 describe-images --image-ids ${IMAGE_ID} |grep '\"Name\"' ${AWS_FILTER}"

echo "Querying AWS for AMI Name for image ${IMAGE_ID}"
echo ${AWS_CMDLINE}
AMI_NAME=$(eval ${AWS_CMDLINE})

#echo ${AMI_NAME}

echo "Current AMI : ${AMI_NAME}."
LATEST_AMI_NAME=$(grep ${AMI_FILTER} ${AMIQUERY_FILE}|grep Name|awk -F: '{print $2}'|sed 's/[",]//g'|sed "s/^ //"|sort -u|tail -1|sed "s/ *$//")

echo ${LATEST_IMAGE_ID}

echo " Latest AMI : ${LATEST_AMI_NAME}."

FILTER_CMD="grep -A 10 '${LATEST_AMI_NAME}' ${AMIQUERY_FILE}|grep ImageId ${AWS_FILTER}"

echo ${FILTER_CMD}

#LATEST_IMAGE_ID=$(grep -A 10 ${LATEST_AMI_NAME} ${AMIQUERY_FILE}|grep ImageId ${AWS_FILTER})
LATEST_IMAGE_ID=$(eval ${FILTER_CMD})

echo "Latest ImageId : ${LATEST_IMAGE_ID}"

if [[ ${AMI_NAME} == ${LATEST_AMI_NAME} ]]
then
   echo "Current AMI for ${APP_NAME} is up to date."
   exit 0
fi

echo "Current AMI for ${APP_NAME} : ${AMI_NAME} is outdated. Latest AMI is ${LATEST_AMI_NAME}"

TESTENV_PATH=${BASE_DIR}/eb_dev/${AWS_ENVNAME}

echo "Saving current configuration for ${AWS_ENVNAME}"

cd ${TESTENV_PATH}

EB_CMD="eb config save ${AWS_ENVNAME} --cfg ${AWS_ENVNAME}-$$"

echo "${EB_CMD}"
eval "${EB_CMD}"

CFG_FILE=$(find ${TESTENV_PATH} -name "*${AWS_ENVNAME}-$$.cfg.yml")

sed -i "/InstanceType/a \    ImageId: \"${LATEST_IMAGE_ID}\"" ${CFG_FILE}

echo "ImageId ${IMAGE_ID} inserted into ${CFG_FILE}"

AWS_CMDLINE="${AWS_CMDPREFIX} elasticbeanstalk terminate-environment --environment-name ${AWS_ENVNAME}"

echo "Terminating ${AWS_ENVNAME}"
echo ${AWS_CMDLINE}
eval ${AWS_CMDLINE}

SLEEP_TIME=30
LOOP_LIMIT=40

COUNT=0

#AWS_CMDLINE="${AWS_CMDPREFIX} elasticbeanstalk describe-environments --application-name ${AWS_APPNAME} --environment-name ${AWS_ENVNAME} ${AWS_FILTER}|grep -A 1 ${AWS_ENVNAME}|grep Status"
AWS_CMDLINE="${AWS_CMDPREFIX} elasticbeanstalk describe-environments --application-name ${AWS_APPNAME} --environment-name ${AWS_ENVNAME}|grep -A 1 ${AWS_ENVNAME}|grep Status|head -1 ${AWS_FILTER}"

while [ ${COUNT} -lt ${LOOP_LIMIT} ]
do
  echo "Pausing for 30 seconds."
  sleep ${SLEEP_TIME}
  echo "Checking termination status of ${AWS_ENVNAME}..."
  echo ${AWS_CMDLINE}
  RESULT=$(eval ${AWS_CMDLINE})

  if [[ ${RESULT} == "Terminated" ]]
  then
     echo "Environment status is now : ${RESULT}"
     break
  fi

  echo "Termination status is : ${RESULT}"
  COUNT=$(( ${COUNT} + 1 ))
done

if [ ${COUNT} -eq ${LOOP_LIMIT} ]
then
   echo "Environment ${AWS_ENVNAME} has not terminated properly. Please perform a manual check. Exiting..."
   exit 1
fi

#AWS_CMDLINE="${AWS_CMDPREFIX} elasticbeanstalk create-environment --application-name ${AWS_APPNAME} --environment-name ${AWS_ENVNAME} --cname-prefix ${AWS_ENVNAME} --template-name ${AWS_ENVNAME}-$$"

EB_CMD="eb create ${AWS_ENVNAME} --cfg ${AWS_ENVNAME}-$$ --cname ${AWS_ENVNAME}"

echo "Recreating ${AWS_ENVNAME} using ImageId ${LATEST_IMAGE_ID} with Name ${LATEST_AMI_NAME}."
echo "${EB_CMD}"
eval "${EB_CMD}"

#echo ${AWS_CMDLINE}
#eval ${AWS_CMDLINE}

#[ -f ${AMIQUERY_FILE} ] && rm ${AMIQUERY_FILE}

exit 0
