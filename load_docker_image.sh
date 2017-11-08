#!/bin/bash

submission_id=$1
echo "Loading docker container as an image..."
docker load --input data/$submission_id/submission.tar
retval=$?
if [ $retval -ne 0 ]; then
    echo "Could not load docker container successfully"
    exit 1
else
    echo "Docker container loaded successfully"
fi
