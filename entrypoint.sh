#!/bin/bash
set -e
set -o pipefail

# Date function
get_date () {
    date --utc "+%FT%TZ"
}

echo "$(get_date) Postgres backup started"

DB_HOST=$(echo -n "${DB_HOST}" | cut -d ':' -f 1)

export MC_HOST_backup="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}@s3.${AWS_REGION}.amazonaws.com"
export PGPASSWORD="${DB_PASSWORD}"

dump_db(){
  DATABASE=$1
  # Ping databaase
  psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DATABASE}" -c ''

  echo "$(get_date) Dumping database: $DATABASE"

  dump_file=dump-$(get_date)

  pg_dump --format=custom --no-owner -h "${DB_HOST}" -U "${DB_USER}" -d "${DATABASE}" | mc pipe backup/${S3_BUCK}/${S3_NAME}/${dump_file} --insecure
  echo ${dump_file} | mc pipe backup/${S3_BUCK}/${S3_NAME}/LATEST --insecure
}

dump_db "$DB_NAME"

echo "$(get_date) Postgres backup completed successfully"
