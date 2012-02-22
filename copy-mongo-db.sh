#!/bin/sh

echo "Copy mongo DB from remote host into your local mongodb"
echo "Usage:  copy-mongo-db.sh [remote db host] [remote db name] [local db name]"

DEFAULT_REMOTE_SERVER="cc1.dev.prv"
DEFAULT_REMOTE_DB="assets_cc1"
DEFAULT_LOCAL_DB="assets_dev"

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

echo
echo "*** Remote DB ***"

readParam "host" "${DEFAULT_REMOTE_SERVER}" "${1}"
REMOTE_SERVER=${RETURN_VALUE}

readParam "DB name" "${DEFAULT_REMOTE_DB}" "${2}"
REMOTE_DB=${RETURN_VALUE}

echo
echo "*** Local DB ***"

readParam "DB name" "${DEFAULT_LOCAL_DB}" "${3}"
LOCAL_DB=${RETURN_VALUE}

echo
echo "Restore $REMOTE_DB @ $REMOTE_SERVER into local DB $LOCAL_DB"
mongo --eval "db.copyDatabase('$REMOTE_DB', '$LOCAL_DB', '$REMOTE_SERVER')"
