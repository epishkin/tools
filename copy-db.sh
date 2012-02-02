#!/bin/bash

default() {
    if [ "${1}" = "" ] ; then
        echo "$2"
    else
        echo "${1}"
    fi
}
prompt() {
    read -p "$1"" (default="$2") [ENTER]: " value
    echo `default "$value" "$2"`
}

drop_create_db() {
psql -U $2 $1 -c "
drop schema public cascade;
CREATE SCHEMA public AUTHORIZATION postgres;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
"
}

echo "Usage:  copy-db.sh [remote db host] [remote db name] [remote db user] [local db name] [local db user]"

REMOTE_SERVER=`default "$1" "cc1.dev.prv"`
REMOTE_DB=`default "$2" "plat_cc1"`
REMOTE_USER=`default "$3" "$REMOTE_DB"`
LOCAL_DB=`default "$4" "$REMOTE_DB"`
LOCAL_USER=`default "$5" "sa"`

echo -e "\n*** Remote DB ***"
REMOTE_SERVER=`prompt "remote host" "$REMOTE_SERVER"`
REMOTE_DB=`prompt "remote DB name" "$REMOTE_DB"`
REMOTE_USER=`prompt "remote DB username" "$REMOTE_USER"`

echo -e "\n*** Local DB ***"
LOCAL_DB=`prompt "local DB name" "$LOCAL_DB"`
LOCAL_USER=`prompt "local DB username" "$LOCAL_USER"`

if [ ! -d "dumps" ]; then
    mkdir dumps
fi
DUMP_FILE=dumps/$REMOTE_DB.tar

echo -e "\n1. Delete old dump file $DUMP_FILE"
rm $DUMP_FILE

echo -e "\n2. Dump remote DB $REMOTE_DB @ $REMOTE_SERVER into file $DUMP_FILE"
pg_dump -f $DUMP_FILE --format=t $REMOTE_DB -h $REMOTE_SERVER -U $REMOTE_USER

echo -e "\n3. Wipe local DB $LOCAL_DB"
drop_create_db $LOCAL_DB $LOCAL_USER

echo -e "\n4. Restore dump file $DUMP_FILE into local DB $LOCAL_DB"
pg_restore -1 -e --no-owner --dbname=$LOCAL_DB -U $LOCAL_USER $DUMP_FILE