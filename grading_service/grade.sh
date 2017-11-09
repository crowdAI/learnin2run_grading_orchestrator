#!/bin/bash

source activate opensim-rl
pip install -U git+https://github.com/stanfordnmbl/osim-rl.git
export CROWDAI_SUBMISSION_ID=/home/grading_service/$SUBMISSIONID
# """
#   Note the `CROWDAI_SUBMISSION_ID` env variable is used by `simbody-visualizer` to dump the frames
#   The name as used here, is misleading.
#   This should be refactored after modifying the `simbody` fork at : https://github.com/spMohanty/simbody
# """
cd /home/grading_service
python service.py --host=$REMOTE_HOST --port=$REMOTE_PORT --submission_id=$SUBMISSIONID
