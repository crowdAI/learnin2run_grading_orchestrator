#!/usr/bin/env python
import redis
from config import Config as config
POOL = redis.ConnectionPool(host=config.REDIS_HOST, port=config.REDIS_PORT, db=config.REDIS_DB, password=config.REDIS_PASSWORD)
import subprocess
import os

while True:
    print "="*80
    print "*"*80
    print "Waiting to process a New submission at :: ", config.REDIS_Q
    redis_conn = redis.Redis(connection_pool=POOL)
    channel, submission_id = redis_conn.brpop(config.REDIS_Q)
    print channel, submission_id
    """
        Create necessary directory structure if not exists already
    """
    try:
        os.mkdir("data/{}".format(submission_id))
    except:
        pass
    try:
        os.mkdir("data/{}/logs".format(submission_id))
    except:
        pass


    overall_log_path = "data/{}/logs/overall_logs.txt".format(submission_id)
    cmd = ['./run.sh', str(submission_id)]
    with open(overall_log_path, "w") as out:
        return_code = subprocess.call(cmd, stdout=out)
