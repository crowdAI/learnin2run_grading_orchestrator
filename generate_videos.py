#!/usr/bin/env python
from __future__ import print_function
from multiprocessing import Pool
import glob
import os

SUBMISSION_IDS = []
for _video_dir in glob.glob("data/*/logs/video_frames_newPov"):
    _sub_id = _video_dir.split("/")[-3]
    SUBMISSION_IDS.append(_sub_id)

print(SUBMISSION_IDS)
def process(sid):
    os.system("./generate_video.sh "+str(sid))

p = Pool(30)
p.map(process, SUBMISSION_IDS)
