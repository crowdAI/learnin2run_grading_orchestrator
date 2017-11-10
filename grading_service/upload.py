#!/usr/bin/env python
from config import Config as config
import boto3
import requests

def upload(submission_id, mp4_path, mp4_thumb_path):
    bucket = config.AWS_MEDIA_BUCKET
    challenge_id = config.CHALLENGE_ID_NUM
    bucket_key_template = "challenge_{}/{}/{}"


    s3 = boto3.client(  's3',
                        aws_access_key_id=config.AWS_ACCESS_KEY_ID,
                        aws_secret_access_key=config.AWS_SECRET_ACCESS_KEY
                        )

    mp4_key = bucket_key_template.format(config.CHALLENGE_ID_NUM, submission_id, "movie.mp4")
    s3.upload_file(mp4_path,config.AWS_MEDIA_BUCKET, mp4_key)

    mp4_thumb_key = bucket_key_template.format(config.CHALLENGE_ID_NUM, submission_id, "movie_thumb.mp4")
    s3.upload_file(mp4_thumb_path,config.AWS_MEDIA_BUCKET, mp4_thumb_key)

    SUBMISSION_ENDPOINT = "{}/{}".format(config.CROWDAI_GRADER_URL, submission_id)
    headers = {
        'Accept': 'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json',
        'Authorization': 'Token token={}'.format(config.CROWDAI_TOKEN)
    }
    _payload = {
    	"media_large" : mp4_key,
    	"media_thumbnail" : mp4_thumb_key,
    	"media_content_type" : "video/mp4"
    }
    r = requests.patch(SUBMISSION_ENDPOINT, params=_payload, headers=headers,verify=False)
    if r.status_code in [200, 202]:
        print "Successfully Uploaded GIF to CrowdAI..."
    else:
        raise Exception("Unable to upload to crowdai...")
