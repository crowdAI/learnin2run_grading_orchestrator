#!/bin/bash


submission_id=$1

function report(){
  echo "========================================================================================================================"
  echo "========================================================================================================================"
  retval=$1
  error_message=`echo $2 | base64 -w 0`
  success_message=`echo $3 | base64 -w 0`
  if [ $retval -ne 0 ]; then
      echo "`echo $error_message | base64 --decode`"
      python grading_service/report.py --submission_id=$submission_id --message=`echo $error_message` --state='failed'
      exit 1
  else
      echo "`echo $success_message | base64 --decode`"
      python grading_service/report.py --submission_id=$submission_id --message=`echo $success_message` --state='submitted'
  fi
}

# """
#   Download container from S3
# """
report 0 "" "Attempting to download container image"
python download_image.py --submission_id=$submission_id
retval=$?
err_message="Could not load docker container successfully"
success_message="Docker container downloaded success"
report $retval "$err_message" "$success_message"

# """
#   Correct tar manifest to have a custom name of the image
# """
./correct_tar_manifest.sh $submission_id
retval=$?
err_message="Could not correct tar manifest. Possibly corrupt docker image ?"
success_message="Tar manifest corrected successfully"
report $retval "$err_message" "$success_message"

# """
#   Load docker image through `docker load`
# """
./load_docker_image.sh $submission_id
retval=$?
err_message="Unable to load docker image. Ensure you can load the docker image by 'docker load --input <path_to_tar>'"
success_message="Successfully loaded docker image"
report $retval "$err_message" "$success_message"

#Now the submitted image should be available as "submission_image_$submission_id:latest"

"""
  Create containers and subnet from image
"""
