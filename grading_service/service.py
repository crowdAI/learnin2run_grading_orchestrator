#!/usr/bin/env python
from osim.redis.service import OsimRlRedisService
from osim.redis import messages as OsimMessages
from config import Config as config
import report

import argparse
parser = argparse.ArgumentParser(description='Submit the result to crowdAI')
parser.add_argument('--host', dest='host', action='store', required=True)
parser.add_argument('--port', dest='port', action='store', required=True)
parser.add_argument('--submission_id', dest='submission_id', action='store', required=True)
args = parser.parse_args()

seed_map = ",".join([str(x) for x in config.SEEDS])
try:
    grader = OsimRlRedisService(remote_host= args.host, remote_port=int(args.port), seed_map=seed_map, max_steps=1000, visualize=True, verbose=True)
    result = grader.run()
    if result['type'] == OsimMessages.OSIM_RL.ENV_SUBMIT_RESPONSE:
        reward = result['payload']
        _payload = {}
        _payload = {}
        _payload['grading_status'] = 'graded'
        _payload['challenge_client_name'] = config.CHALLENGE_ID
        _payload['score'] = reward
        report.report(args.submission_id, _payload=_payload)
    else:
        raise Exception("Unknown response from grading service")
except Exception as e:
    print "Exception ::",str(e)
    report.report(args.submission_id, message="Error grading submission: "+str(e), state='failed')
