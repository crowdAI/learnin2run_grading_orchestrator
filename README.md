# learnin2run_grading_orchestrator

## Preprocessing

-- Sync file from S3
-- Check if gzipped, and if so, un-gzip
-- extract manifest.json in place
-- update manifest.json `RepoTags` to appropriate name
-- update tar file with the new manifest.json

## Overall structure
```
export SUBMISSION_ID=3351
export NETWORK_NAME="submission_$SUBMISSION_ID_network"
export SUBMISSION_IMAGE_NAME="submission_$SUBMISSION_ID_image"
export SUBMISSION_CONTAINER_NAME="submission_$SUBMISSION_ID_container"
export GRADER_IMAGE_NAME="spmohanty/learning2run-grader-image:v1.0"
export GRADER_CONTAINER_NAME="grader_$SUBMISSION_ID"
export LOG_DIRECTORY="data/$SUBMISSION_ID/logs"
mkdir -p $LOG_DIRECTORY

docker create network --internal $NETWORK_NAME
docker run -itd --memory=5g --name="$SUBMISSION_CONTAINER_NAME" --network=$NETWORK_NAME $SUBMISSION_IMAGE_NAME /bin/bash
docker run -itd --memory=5g --name="$GRADER_CONTAINER_NAME" --link="$SUBMISSION_CONTAINER_NAME" --network="$NETWORK_NAME" spmohanty/learning2run-grader-image:v1.0  /bin/bash
# Copy grader service code to /home/grader_service
docker cp grading_service $GRADER_CONTAINER_NAME:/home/
docker exec -it $GRADER_CONTAINER_NAME chmod +x /home/grading_service/grade.sh

# Start the submission execution
docker exec -itd --name="$SUBMISSION_CONTAINER_NAME" "/etc/init.d/redis-server restart"
docker exec -itd --name="$SUBMISSION_CONTAINER_NAME" /home/submit.sh &> $LOG_DIRECTORY/submission_container_logs.txt

# Execute grading service by passing the required params

docker exec --env REMOTE_HOST=$SUBMISSION_CONTAINER_NAME --env REMOTE_PORT=6379 --env SUBMISSIONID=$SUBMISSIONID -it $GRADER_CONTAINER_NAME /home/grading_service/grade.sh | tee $LOG_DIRECTORY/grader_container_logs.txt

#docker exec -it --name="$GRADER_CONTAINER_NAME" /home/grading_service/postprocess.sh | tee $LOG_DIRECTORY/grader_post_processing_logs.txt

#Clean up
docker stop $SUBMISSION_CONTAINER_NAME
docker rm -f $SUBMISSION_CONTAINER_NAME
docker stop $GRADER_CONTAINER_NAME
docker rm -f $GRADER_CONTAINER_NAME
docker network rm $NETWORK_NAME
docker rmi $SUBMISSION_IMAGE_NAME
```

# Author
S.P. Mohanty
