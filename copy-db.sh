#!/bin/sh
# version 1.0

echo "Copy postgres DB from remote host into your local posgres"
echo "Usage:  copy-db.sh [remote db host] [remote db name] [remote db user] [local db name] [local db user]"

DEFAULT_REMOTE_SERVER="cc1.dev.prv"
DEFAULT_REMOTE_DB="plat_cc1"
DEFAULT_LOCAL_DB="ops_dev"
DEFAULT_LOCAL_USER="sa"

default() {
  if [ "${1}" = "" ] ; then
    echo "${2}"
  else
    echo "${1}"
  fi
}

RETURN_VALUE=""
readParam() {
  if [ "${3}" = "" ] ; then
    read -p "${1}"": ["${2}"] " value
    RETURN_VALUE=`default "${value}" "${2}"`
  else
    echo "${1}: ${3}"
    RETURN_VALUE="${3}"
  fi
}

drop_create_db() {
  psql -U $2 $1 -c "
drop schema public cascade;
CREATE SCHEMA public AUTHORIZATION postgres;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
"
}

echo
echo "*** Remote DB ***"

readParam "host" "${DEFAULT_REMOTE_SERVER}" "${1}"
REMOTE_SERVER=${RETURN_VALUE}

readParam "DB name" "${DEFAULT_REMOTE_DB}" "${2}"
REMOTE_DB=${RETURN_VALUE}

readParam "DB username" "$REMOTE_DB" "${3}"
REMOTE_USER=${RETURN_VALUE}

echo
echo "*** Local DB ***"

readParam "DB name" "${DEFAULT_LOCAL_DB}" "${4}"
LOCAL_DB=${RETURN_VALUE}

readParam "DB username, should be superuser" "${DEFAULT_LOCAL_USER}" "${5}"
LOCAL_USER=${RETURN_VALUE}

if [ ! -d "dumps" ]; then
    mkdir dumps
fi
DUMP_FILE=dumps/$REMOTE_DB.tar

echo
echo "1. Delete old dump file $DUMP_FILE"
rm $DUMP_FILE

echo
echo "2. Dump remote DB $REMOTE_DB @ $REMOTE_SERVER into file $DUMP_FILE"
pg_dump -f $DUMP_FILE --format=t $REMOTE_DB -h $REMOTE_SERVER -U $REMOTE_USER

echo
echo "3. Wipe local DB $LOCAL_DB"
drop_create_db $LOCAL_DB $LOCAL_USER

echo
echo "4. Restore dump file $DUMP_FILE into local DB $LOCAL_DB"
pg_restore -1 -e --no-owner --dbname=$LOCAL_DB -U $LOCAL_USER $DUMP_FILE