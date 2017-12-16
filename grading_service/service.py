#!/usr/bin/env python
from osim.redis.service import OsimRlRedisService
from osim.redis import messages as OsimMessages
from config import Config as config
import report
import json
import timeout_decorator
import time

import argparse
parser = argparse.ArgumentParser(description='Submit the result to crowdAI')
parser.add_argument('--host', dest='host', action='store', required=True)
parser.add_argument('--port', dest='port', action='store', required=True)
parser.add_argument('--submission_id', dest='submission_id', action='store', required=True)
args = parser.parse_args()

seed_map = ",".join([str(x) for x in config.SEEDS])
try:
    begin = time.time()
    grader = OsimRlRedisService(remote_host= args.host, remote_port=int(args.port), seed_map=seed_map, max_steps=1000, difficulty=2, max_obstacles=0, visualize=True, verbose=True)
    @timeout_decorator.timeout(12*60*60, use_signals=False) # 12*60*60 seconds (12 hours)
    def run_grader(grader):
        return grader.run()
    try:
        result = run_grader(grader)
    except timeout_decorator.timeout_decorator.TimeoutError:
        raise Exception("Grader timeout after {} seconds ".format(int(time.time()-begin)))

    if result['type'] == OsimMessages.OSIM_RL.ENV_SUBMIT_RESPONSE:
        reward = result['payload']['mean_reward']
        _payload = {}
        _payload['grading_status'] = 'graded'
        _payload['challenge_client_name'] = config.CHALLENGE_ID
        _payload['score'] = reward
        report.report(args.submission_id, state='graded', _payload=_payload)
        f = open("/home/grading_service/score.json","w")
        f.write(json.dumps(result['payload']))
    elif result['type'] == OsimMessages.OSIM_RL.ERROR:
        raise Exception(str(result['payload']))
    else:
        raise Exception("Unknown response from grading service")
except Exception as e:
    print "Exception ::",str(e)
    report.report(args.submission_id, message="Error grading submission: "+str(e), state='failed')
    exit(1)
