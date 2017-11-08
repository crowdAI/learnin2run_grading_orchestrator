#!/usr/bin/env python
from __future__ import print_function

import requests
import argparse
from config import Config as config
import json
import os
import boto3
import shutil

def download_submission(submission_id):
    print("Attempting to download the tar dump of submission_id : {}".format(args.submission_id))
    if not os.path.exists("{}/{}/submission.tar".format(config.DATA_DIRECTORY, args.submission_id)):
        #Get the filekey of submission_id
        headers = {'Authorization' : 'Token token='+config.CROWDAI_TOKEN, "Content-Type":"application/vnd.api+json"}
        response = requests.get("{}/{}/submission_info".format(config.CROWDAI_GRADER_URL,args.submission_id))
        if response.status_code==200:
            response = json.loads(response.text)
            submission_id = args.submission_id
            response_body = json.loads(response['body'])
            meta = json.loads(response_body['meta'])
            filekey = meta['file_key']
            print("File Key on S3 ", filekey)
            # Sync the file from S3 bucked to data directory
            os.mkdir("{}/{}".format(config.DATA_DIRECTORY, submission_id))
            s3 = boto3.client(  's3',
                                aws_access_key_id=config.AWS_ACCESS_KEY_ID,
                                aws_secret_access_key=config.AWS_SECRET_ACCESS_KEY
                                )
            filepath = "{}/{}/submission.tar.gz".format(config.DATA_DIRECTORY, submission_id)
            s3.download_file(config.AWS_S3_BUCKET, filekey, filepath)
            #Check if its a .tar.gz file and in that case unzip it
            print("Download complete")
            # If its a .gz file, `gunzip` it
            try:
                f = gzip.open(filepath)
                d = f.read(10)
                f.close()
                print("Found a gzipped file, unzipping....")
                os.system("gunzip {}".format(filepath))
            except:
                shutil.move(filepath, filepath.replace("submission.tar.gz", "submission.tar"))
        else:
            raise Exception("Submission ID not valid:"+str(response.text))
    else:
        print("tar dump already exists on the local disk. proceding with the same data...")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Download a particular submission to local disk')
    parser.add_argument('--submission_id', dest='submission_id', action='store', required=True)
    args = parser.parse_args()
    download_submission(args.submission_id)
