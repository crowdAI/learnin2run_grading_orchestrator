#!/bin/bash

source activate opensim-rl
pip install -U git+https://github.com/stanfordnmbl/osim-rl.git
pip install boto3 timeout_decorator
export CROWDAI_SUBMISSION_ID=/home/grading_service/$SUBMISSIONID
# """
#   Note the `CROWDAI_SUBMISSION_ID` env variable is used by `simbody-visualizer` to dump the frames
#   The name as used here, is misleading.
#   This should be refactored after modifying the `simbody` fork at : https://github.com/spMohanty/simbody
# """
cd /home/grading_service
export LD_LIBRARY_PATH=/opt/conda/envs/opensim-rl/lib/:$LD_LIBRARY_PATH
xvfb-run -a -s "-screen 0 1400x900x24" python service.py --host=$REMOTE_HOST --port=$REMOTE_PORT --submission_id=$SUBMISSIONID
retval=$?
if [ $retval -ne 0 ]; then
    # """
    # # Exit if the grading service fails
    # """
    echo "Error in Grading service....."
    exit 1;
else
    echo "Grading Service exited successfully...."
fi
#Post process images
echo "Generating GIF from frames...."
convert -delay 5 -loop 1 $CROWDAI_SUBMISSION_ID/*.png $CROWDAI_SUBMISSION_ID/movie.gif
rm -rf $CROWDAI_SUBMISSION_ID/*.png

echo "Converting gif to mp4..."
avconv -y -an -i $CROWDAI_SUBMISSION_ID/movie.gif -vcodec libx264 -pix_fmt yuv420p -profile:v baseline -level 3 $CROWDAI_SUBMISSION_ID/movie.mp4

echo "Scaling down mp4 for thumbnail"
avconv -y -i $CROWDAI_SUBMISSION_ID/movie.mp4 -vf scale=268:200 -c:a copy $CROWDAI_SUBMISSION_ID/movie_thumb.mp4

echo "Uploading video...."
python -c "import upload; upload.upload('`echo $SUBMISSIONID`', '`echo $CROWDAI_SUBMISSION_ID/movie.mp4`', '`echo $CROWDAI_SUBMISSION_ID/movie_thumb.mp4`')"
