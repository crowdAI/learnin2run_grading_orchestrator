#!/usr/bin/env python
from __future__ import print_function

import argparse
import base64
from config import Config as config
import requests


def report(submission_id, message, state):
    print("Reporting state '{}' for submission_id {}".format(state, submission_id))
    headers = {'Authorization' : 'Token token='+config.CROWDAI_TOKEN, "Content-Type":"application/vnd.api+json"}
    _payload = {}
    _payload['grading_status'] = state
    _payload['challenge_client_name'] = config.CHALLENGE_ID
    _payload['grading_message'] = args.message
    r = requests.patch("{}/{}".format(config.CROWDAI_GRADER_URL, args.submission_id), params=_payload, headers=headers, verify=False)
    print(r.text)
    if r.status_code != 202:
        print(r.status_code)
        raise Exception("Unusual behaviour in crowdAI API")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Report to crowdAI')
    parser.add_argument('--submission_id', dest='submission_id', action='store', required=True)
    parser.add_argument('--message', dest='message', action='store', required=True)
    parser.add_argument('--state', dest='state', action='store', required=True)
    args = parser.parse_args()
    print(args)
    args.message = base64.b64decode(args.message)

    assert args.state in ['submitted', 'failed']
    report(args.submission_id, args.message, args.state)
