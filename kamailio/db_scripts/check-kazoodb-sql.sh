#!/bin/bash

TEMP_DB_LOCATION=/tmp/db
TEMP_DB=${TEMP_DB_LOCATION}/kazoo.db

DB_CURRENT_DB=${DB_LOCATION:-/etc/kazoo/kamailio}/kazoo.db

rm -rf ${TEMP_DB_LOCATION}
. $(dirname $0)/kazoodb-sql.sh --source-only

file=$(sql_db_prepare)
sql_setup $file ${TEMP_DB_LOCATION}

DB_VERSION=`KazooDB -db ${TEMP_DB} "select sum(table_version) from version;"`

DB_CURRENT_VERSION=`KazooDB -db ${DB_CURRENT_DB} "select sum(table_version) from version;"`

if [[ "$DB_CURRENT_VERSION" -ne "$DB_VERSION" ]]; then
   echo "db required version is ${DB_VERSION}, existing version is ${DB_CURRENT_VERSION}, applying diff"
   KazooDB-diff --schema  ${DB_CURRENT_DB} ${TEMP_DB} | KazooDB -db ${DB_CURRENT_DB}

   ## this shuold be an iterator over a configured list of tables
   KazooDB-diff --primarykey --table version ${DB_CURRENT_DB} ${TEMP_DB} | KazooDB -db ${DB_CURRENT_DB}
   KazooDB-diff --primarykey --table event_list ${DB_CURRENT_DB} ${TEMP_DB} | KazooDB -db ${DB_CURRENT_DB}
fi

# verify views
echo "" > /tmp/.view_diff.sql
current_views=$(KazooDB -db ${DB_CURRENT_DB} "select name from sqlite_master where type='view'")
schema_views=$(KazooDB -db ${TEMP_DB} "select name from sqlite_master where type='view'")
for view in $current_views ; do
    if grep -q "$view" <<< "$schema_views"; then
        # echo "verifying existing view $view"
        v1=$(KazooDB -db ${DB_CURRENT_DB} "select sql from sqlite_master where type='view' and name='$view'" 2> /dev/null | tr -d ' ' | md5sum | cut -d ' ' -f1)
        v2=$(KazooDB -db ${TEMP_DB} "select sql from sqlite_master where type='view' and name='$view'" 2> /dev/null | tr -d ' ' | md5sum | cut -d ' ' -f1)
        # echo "verify result of existing view $view is '${v1}' => '${v2}'"
        if [ "$v1" != "$v2" ]; then
            echo "" >> /tmp/.view_diff.sql
            echo "DROP VIEW $view;" >> /tmp/.view_diff.sql
            KazooDB -db ${TEMP_DB} "select sql || ';' from sqlite_master where type='view' and name='$view'" 2> /dev/null >> /tmp/.view_diff.sql
            echo "" >> /tmp/.view_diff.sql
        fi
    else
        echo "DROP VIEW $view;" >> /tmp/.view_diff.sql
    fi
done
for view in $schema_views ; do
    if ! grep -q "$view" <<< "$current_views"; then
        KazooDB -db ${TEMP_DB} "select sql || ';' from sqlite_master where type='view' and name='$view'" 2> /dev/null >> /tmp/.view_diff.sql
    fi
done
KazooDB -db ${DB_CURRENT_DB} < /tmp/.view_diff.sql
rm /tmp/.view_diff.sql


for VIEW in `ls ${DB_SCRIPT_DIR}/vw_*.sql`; do
    filename=$(basename -- "$VIEW")
    filename="${filename%.*}"
    viewname=${filename#*_}
    if ! grep -q "$view" <<< "$schema_views"; then
        v1=$(KazooDB -db ${DB_CURRENT_DB} "select sql from sqlite_master where type='view' and name='$viewname'" 2> /dev/null | tr -d ' ' | md5sum | cut -d ' ' -f1)
        v2=$(cat $VIEW | tr -d ' ' | md5sum | cut -d ' ' -f1)
        if [[ "$v1" != "$v2" ]]; then
            echo "rebuilding view $viewname"
            KazooDB -db ${DB_CURRENT_DB} "drop view if exists $viewname;"
            KazooDB -db ${DB_CURRENT_DB} < $VIEW
        fi
    fi
done

if [ -f ${DB_SCRIPT_DIR}/db_extra_check.sql ]; then
    . ${DB_SCRIPT_DIR}/db_extra_check.sql --source-only
    do_db_extra_check;    
fi


## init - things we want to change every time (restart)
for INIT in `ls ${DB_SCRIPT_DIR}/db_init_*.sql`; do
    KazooDB -db ${DB_CURRENT_DB} < $INIT
done

if [ -d ${DB_SCRIPT_DIR}/init.d ]; then
if ls ${DB_SCRIPT_DIR}/init.d/*.sql 1> /dev/null 2>&1; then
for INIT in `ls ${DB_SCRIPT_DIR}/init.d/*.sql`; do
    KazooDB -db ${DB_CURRENT_DB} < $INIT
done
fi
fi

## sql.d - other scripts we want to run
if [ -d ${DB_SCRIPT_DIR}/sql.d ]; then
if ls ${DB_SCRIPT_DIR}/sql.d/*.sql 1> /dev/null 2>&1; then
for INIT in `ls ${DB_SCRIPT_DIR}/sql.d/*.sql`; do
    KazooDB -db ${DB_CURRENT_DB} < $INIT
done
fi
fi

## sql.d - other scripts from custom location we want to run
if [[ ! -z "${DB_EXTRA_SCRIPT_DIR}" ]]; then
if [ -d ${DB_EXTRA_SCRIPT_DIR} ]; then
if ls ${DB_EXTRA_SCRIPT_DIR}/*.sql 1> /dev/null 2>&1; then
for INIT in `ls ${DB_EXTRA_SCRIPT_DIR}/*.sql`; do
    KazooDB -db ${DB_CURRENT_DB} < $INIT
done
fi
fi
fi

## sql.d - other scripts from custom location we want to run
if [[ ! -z "${DB_SCRIPT_TEMPLATE_DIR}" ]]; then
if [ -d ${DB_SCRIPT_TEMPLATE_DIR} ]; then
if ls ${DB_SCRIPT_TEMPLATE_DIR}/*.sql 1> /dev/null 2>&1; then
for INIT in `ls ${DB_SCRIPT_TEMPLATE_DIR}/*.sql`; do
    KazooDB -db ${DB_CURRENT_DB} < $INIT
done
fi
fi
fi
