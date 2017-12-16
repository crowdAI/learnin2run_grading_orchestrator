#!/bin/bash

submission_id=$1

current_dir=`pwd`
cd data/$submission_id
echo "Extracting Manifest...."

tar xvf submission.tar

echo "Modifying manifest to call image as : submission_image_$submission_id"
cat manifest.json | python -c "import sys, json;d=json.load(sys.stdin);d[0]['RepoTags']=['submission_image_$submission_id:latest'];print(json.dumps(d))" > manifest_updated.json
mv manifest_updated.json manifest.json

rm submission.tar
tar cvf submission.tar *
rm -rf `\ls -tr  | grep -v "submission.tar"`
cd $current_dir
