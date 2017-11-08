# learnin2run_grading_orchestrator

## Preprocessing

-- Sync file from S3
-- Check if gzipped, and if so, un-gzip
-- extract manifest.json in place
-- update manifest.json `RepoTags` to appropriate name
-- update tar file with the new manifest.json

## Overall structure
```
export NETWORK_NAME="submission_1_network"
export SUBMISSION_IMAGE_NAME="submission_mohanty"
export SUBMISSION_CONTAINER_NAME="submission1"
export GRADER_IMAGE_NAME="spmohanty/learning2run-grader-image:v1.0"
export GRADER_CONTAINER_NAME="grader1"
export LOG_DIRECTORY="Logs/submission1"
mkdir -p $LOG_DIRECTORY

docker create network --internal $NETWORK_NAME
docker run -itd --memory=5g --name="$SUBMISSION_CONTAINER_NAME" --network=$NETWORK_NAME $SUBMISSION_IMAGE_NAME /bin/bash
docker run -itd --memory=5g --name="$GRADER_CONTAINER_NAME" --link="$SUBMISSION_CONTAINER_NAME" --network="$NETWORK_NAME" spmohanty/learning2run-grader-image:v1.0  /bin/bash
# Copy grader service code to /home/grader_service
docker cp grading_service $GRADER_CONTAINER_NAME:/home/
# Start the submission execution
docker exec -itd --name="$SUBMISSION_CONTAINER_NAME" /home/submit.sh &> $LOG_DIRECTORY/submission_container_logs.txt

# Execute grading service by passing the required params
docker exec -it --env="CROWDAI_SUBMISSION_ID=/home/SUBMISSION" --name="$GRADER_CONTAINER_NAME" /home/grading_service/run.sh | tee $LOG_DIRECTORY/grader_container_logs.txt
# Note the `CROWDAI_SUBMISSION_ID` env variable is used by `simbody-visualizer` to dump the frames
docker exec -it --name="$GRADER_CONTAINER_NAME" /home/grading_service/postprocess.sh | tee $LOG_DIRECTORY/grader_post_processing_logs.txt

#Clean up
docker rm $SUBMISSION_CONTAINER_NAME
docker rm $GRADER_CONTAINER_NAME
docker network rm $NETWORK_NAME
#docker rmi $SUBMISSION_IMAGE_NAME
```

# Author
S.P. Mohanty