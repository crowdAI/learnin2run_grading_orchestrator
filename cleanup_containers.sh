#!/bin/bash

SUBMISSIONID=$1
export NETWORK_NAME=submission-$SUBMISSIONID-network
export SUBMISSION_IMAGE_NAME=submission_image_$SUBMISSIONID
export SUBMISSION_CONTAINER_NAME=$SUBMISSIONID-submission-container
export GRADER_IMAGE_NAME="spmohanty/learning2run-grader-image:v1.0"
export GRADER_CONTAINER_NAME=$SUBMISSIONID-grader-container
export LOG_DIRECTORY="data/$SUBMISSIONID/logs"
mkdir -p $LOG_DIRECTORY

docker stop $SUBMISSION_CONTAINER_NAME
docker rm -f $SUBMISSION_CONTAINER_NAME
docker stop $GRADER_CONTAINER_NAME
docker rm -f $GRADER_CONTAINER_NAME
docker network rm $NETWORK_NAME
docker rmi $SUBMISSION_IMAGE_NAME
