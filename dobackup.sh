#!/bin/sh

set -exo pipefail

# default storage class to standard if not provided
S3_STORAGE_CLASS=${S3_STORAGE_CLASS:-STANDARD}

# generate file name for tar
FILE_NAME=/tmp/${BACKUP_NAME:-bitwarden}-`date "+%Y-%m-%d_%H-%M-%S"`.tar.gz

DESTINATION=/tmp/bitwarden

mkdir -p $DESTINATION

# Check if TARGET variable is set
if [[ -z ${TARGET} ]];
then
    echo $(date -u) "TARGET env var is not set so we use the default value (/data)"
    TARGET=/data
else
    echo $(date -u) "TARGET env var is set to ${TARGET}"
fi

sqlite3 $TARGET/db.sqlite3 ".backup '$DESTINATION/db.sqlite3'"

if [[ -d $TARGET/attachments ]]; then
    cp -r $TARGET/attachments $DESTINATION
fi

if [[ -d $TARGET/sends ]]; then
    cp -r $TARGET/sends $DESTINATION
fi

cp $TARGET/rsa_key* $DESTINATION

echo $(date -u) "creating archive"
tar -zcvf $FILE_NAME $DESTINATION
echo $(date -u) "uploading archive to S3 [$FILE_NAME, storage class - $S3_STORAGE_CLASS]"
aws s3 cp --storage-class $S3_STORAGE_CLASS $FILE_NAME $S3_BUCKET_URL
echo $(date -u) "removing local archive"
rm $FILE_NAME
rm -rf $DESTINATION
echo $(date -u) "done"
