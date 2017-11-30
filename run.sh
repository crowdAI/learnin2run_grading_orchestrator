#!/bin/bash

echo "Starting execution at `date`"
# """
# Initial Setup
# """
docker pull spmohanty/learning2run-grader-image:v1.0
docker network create grader_internet

SUBMISSIONID=$1
# Clean up in the beginning....Just in case :D
./cleanup_containers.sh $SUBMISSIONID

function report(){
  echo "========================================================================================================================"
  echo "========================================================================================================================"
  retval=$1
  error_message=`echo $2 | base64 -w 0`
  success_message=`echo $3 | base64 -w 0`
  if [ $retval -ne 0 ]; then
      echo "`echo $error_message | base64 --decode`"
      python grading_service/report.py --submission_id=$SUBMISSIONID --message=`echo $error_message` --state='failed'
      echo "Stopping execution at `date`"
      echo "Cleaning up..."
      # ./cleanup_containers.sh $SUBMISSIONID
      exit 1
  else
      echo "`echo $success_message | base64 --decode`"
      python grading_service/report.py --submission_id=$SUBMISSIONID --message=`echo $success_message` --state='submitted'
  fi
}

# """
#   Download container from S3
# """
report 0 "" "Attempting to download container image"
python download_image.py --submission_id=$SUBMISSIONID
retval=$?
err_message="Could not load docker container successfully"
success_message="Docker container downloaded successfully"
report $retval "$err_message" "$success_message"

# """
#   Correct tar manifest to have a custom name of the image
# """
./correct_tar_manifest.sh $SUBMISSIONID
retval=$?
err_message="Could not correct tar manifest. Possibly corrupt docker image ?"
success_message="Tar manifest corrected successfully"
report $retval "$err_message" "$success_message"

# """
#   Load docker image through `docker load`
# """
./load_docker_image.sh $SUBMISSIONID
retval=$?
err_message="Unable to load docker image. Ensure you can load the docker image by 'docker load --input <path_to_tar>'"
success_message="Successfully loaded docker image"
report $retval "$err_message" "$success_message"

#Now the submitted image should be available as "submission_image_$SUBMISSIONID:latest"

# """
#   Instantitate variables
# """
export NETWORK_NAME=submission-$SUBMISSIONID-network
export SUBMISSION_IMAGE_NAME=submission_image_$SUBMISSIONID
export SUBMISSION_CONTAINER_NAME=$SUBMISSIONID-submission-container
export GRADER_IMAGE_NAME="spmohanty/learning2run-grader-image:v1.0"
export GRADER_CONTAINER_NAME=$SUBMISSIONID-grader-container
export LOG_DIRECTORY="data/$SUBMISSIONID/logs"
mkdir -p $LOG_DIRECTORY
#
# """
#   Create containers and sub network from images
# """

docker network create --internal $NETWORK_NAME
docker run -id --memory=5g --name="$SUBMISSION_CONTAINER_NAME" --network=$NETWORK_NAME $SUBMISSION_IMAGE_NAME /bin/bash
docker run -id --memory=6g --name="$GRADER_CONTAINER_NAME" --link="$SUBMISSION_CONTAINER_NAME" --network="$NETWORK_NAME" spmohanty/learning2run-grader-image:v1.0  /bin/bash
docker network connect grader_internet $GRADER_CONTAINER_NAME
###TODO: Add the creation of grader_internet to the bootstrapping process, along with pulling the grader_image

retval=$?
err_message="Unable to create containers. Please contact admins."
success_message="Successfully created containers and subnet"
report $retval "$err_message" "$success_message"


# """
#   Start the submission execution
# """
report 0 "" "Starting execution of submitted container......"
docker exec -i $SUBMISSION_CONTAINER_NAME /etc/init.d/redis-server restart
docker exec -id $SUBMISSION_CONTAINER_NAME bash -c "/home/submit.sh &> /submission_container_logs.txt"

docker cp grading_service $GRADER_CONTAINER_NAME:/home/
docker exec -i $GRADER_CONTAINER_NAME chmod +x /home/grading_service/grade.sh

docker exec --env REMOTE_HOST=$SUBMISSION_CONTAINER_NAME --env REMOTE_PORT=6379 --env SUBMISSIONID=$SUBMISSIONID -i $GRADER_CONTAINER_NAME /home/grading_service/grade.sh &> $LOG_DIRECTORY/grader_container_logs.txt

# Copy over the images
mkdir -p $LOG_DIRECTORY/video_frames/
docker cp $GRADER_CONTAINER_NAME:/home/grading_service/$SUBMISSIONID $LOG_DIRECTORY/video_frames/
docker cp $SUBMISSION_CONTAINER_NAME:/submission_container_logs.txt $LOG_DIRECTORY/submission_container_logs.txt
docker cp $GRADER_CONTAINER_NAME:/home/grading_service/score.json $LOG_DIRECTORY/score.json

docker stop $SUBMISSION_CONTAINER_NAME
docker stop $GRADER_CONTAINER_NAME

echo "Stopping execution at `date`"

# """
#   Clean up
# """
# ./cleanup_containers.sh $SUBMISSIONID
