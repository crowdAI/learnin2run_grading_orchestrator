#!/bin/bash

SUBMISSION_ID=$1
CURRENT_DIR=`pwd`
#cd data/$SUBMISSION_ID/logs/video_frames/$SUBMISSION_ID
cd data/$SUBMISSION_ID/logs/video_frames_newPov/$SUBMISSION_ID
echo "Converting PNGs to GIF..."
convert -delay 5 -loop 1 -verbose *.png video.gif
echo "Converting GIF to MP4..."
ffmpeg -y -an -i video.gif -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -level 3 $SUBMISSION_ID.mp4
echo "Creating MP4 Thumb..."
ffmpeg -y -i $SUBMISSION_ID.mp4 -vf scale=268:200 -c:a copy $SUBMISSION_ID.thumb.mp4
cd $CURRENT_DIR
