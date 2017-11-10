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
export LD_LIBRARY_PATH=/opt/conda/envs/opensim-rl/lib/:$LD_LIBRARY_PATH
xvfb-run -a -s "-screen 0 1400x900x24" python service.py --host=$REMOTE_HOST --port=$REMOTE_PORT --submission_id=$SUBMISSIONID
