#!/bin/bash
set -e
set -o pipefail

# Date function
get_date () {
    date +[%Y-%m-%d\ %H:%M:%S]
}

# Script
: ${GPG_KEYSERVER:='keyserver.ubuntu.com'}
: ${GPG_KEYID:=''}
START_DATE=$(date --utc "+%FT%TZ")
DUMP=dump-${START_DATE}

if [ -z "$GPG_KEYID" ]
then
    echo "$(get_date) !WARNING! It's strongly recommended to encrypt your backups."
else
    echo "$(get_date) Preparing keys: importing from keyserver"
    gpg --keyserver ${GPG_KEYSERVER} --recv-keys ${GPG_KEYID}
fi

echo "$(get_date) Postgres backup started"

DB_HOST=$(echo -n "${DB_HOST}" | cut -d ':' -f 1)

export MC_HOST_backup="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}@s3.${AWS_REGION}.amazonaws.com"
export PGPASSWORD="${DB_PASSWORD}"

mc mb backup/${S3_BUCK} --insecure || true

dump_db(){
  DATABASE=$1
  # Ping databaase
  psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DATABASE}" -c ''

  echo "$(get_date) Dumping database: $DATABASE"

  if [ -z "$GPG_KEYID" ]
  then
    pg_dump --format=custom -h "${DB_HOST}" -U "${DB_USER}" -d "${DATABASE}" | mc pipe backup/${S3_BUCK}/${S3_NAME}/${DUMP} --insecure
  else
    pg_dump --format=custom -h "${DB_HOST}" -U "${DB_USER}" -d "${DATABASE}" \
    | gpg --encrypt -z 0 --recipient ${GPG_KEYID} --trust-model always \
    | mc pipe backup/${S3_BUCK}/${S3_NAME}/${DUMP}.pgp --insecure
  fi
}

dump_db "$DB_NAME"

echo "$(get_date) Postgres backup completed successfully"
