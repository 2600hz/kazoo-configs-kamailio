#!/bin/sh

TEMP_DB_LOCATION=/tmp/db
TEMP_DB=${TEMP_DB_LOCATION}/kazoo.db

rm -rf ${TEMP_DB_LOCATION}
. $(dirname $0)/kazoodb-sql.sh --source-only

file=$(sql_db_prepare)
sql_setup $file ${TEMP_DB_LOCATION}

DB_VERSION=`KazooDB -db ${TEMP_DB} "select sum(table_version) from version;"`

DB_CURRENT_DB=${DB_LOCATION:-/etc/kazoo/kamailio}/kazoo.db
DB_CURRENT_VERSION=`KazooDB -db ${DB_CURRENT_DB} "select sum(table_version) from version;"`


if [[ $DB_CURRENT_VERSION -ne $DB_VERSION ]]; then
   echo "db required version is ${DB_VERSION}, existing version is ${DB_CURRENT_VERSION}, applying diff"
   KazooDB-diff --schema  ${DB_CURRENT_DB} ${TEMP_DB} | KazooDB -db ${DB_CURRENT_DB}
   KazooDB-diff --primarykey --table version ${DB_CURRENT_DB} ${TEMP_DB} | KazooDB -db ${DB_CURRENT_DB}
   KazooDB-diff --primarykey --table event_list ${DB_CURRENT_DB} ${TEMP_DB} | KazooDB -db ${DB_CURRENT_DB}
fi


for VIEW in `ls ${DB_SCRIPT_DIR}/vw_*.sql`; do
   filename=$(basename -- "$VIEW")
   filename="${filename%.*}"
   viewname=${filename#*_}
   v1=$(KazooDB -db ${DB_CURRENT_DB} "select sql from sqlite_master where type='view' and name='$viewname'" 2> /dev/null | tr -d ' ' | md5sum | cut -d ' ' -f1)
   v2=$(cat $VIEW | tr -d ' ' | md5sum | cut -d ' ' -f1)
   if [[ "$v1" != "$v2" ]]; then
      echo "rebuilding view $viewname"
      KazooDB -db ${DB_CURRENT_DB} "drop view if exists $viewname;"
      KazooDB -db ${DB_CURRENT_DB} < $VIEW
   fi
done

if [ -f ${DB_SCRIPT_DIR}/db_extra_check.sql ]; then
    . ${DB_SCRIPT_DIR}/db_extra_check.sql --source-only
    do_db_extra_check;    
fi

for INIT in `ls ${DB_SCRIPT_DIR}/db_init_*.sql`; do
    KazooDB -db ${DB_CURRENT_DB} < $INIT
done
