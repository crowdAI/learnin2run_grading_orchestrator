#!/usr/bin/env python


import argparse
import base64
from config import Config as config
import requests


def report_error(submission_id, error_message):
    print("Reporting Error for submission_id", submission_id)
    headers = {'Authorization' : 'Token token='+config.CROWDAI_TOKEN, "Content-Type":"application/vnd.api+json"}
    _payload = {}
    _payload['grading_status'] = 'failed'
    _payload['challenge_client_name'] = config.CHALLENGE_ID
    _payload['grading_message'] = args.error_message
    r = requests.patch("{}/{}".format(config.CROWDAI_GRADER_URL, args.submission_id), params=_payload, headers=headers, verify=False)
    print r.text
    if r.status_code != 202:
        raise Exception("Unusual behaviour in crowdAI API")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Submit the result to crowdAI')
    parser.add_argument('--submission_id', dest='submission_id', action='store', required=True)
    parser.add_argument('--error_message', dest='error_message', action='store', required=True)
    args = parser.parse_args()

    args.error_message = base64.b64decode(args.error_message)
    report_error(args.submission_id, args.error_message)
