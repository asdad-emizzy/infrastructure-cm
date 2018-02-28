#!/bin/bash

set -x

cd testhtml/

echo Listing directory contents

ls -ltrh

echo Syncing S3 bucket with updated contents

aws s3 sync . s3://dfs-web-dev.asurion.com/ --delete --profile dev --region ap-northeast-1
