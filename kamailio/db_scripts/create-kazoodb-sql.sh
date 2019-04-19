#!/bin/sh -e

. $(dirname $0)/kazoodb-sql.sh --source-only

file=$(sql_db_prepare)
echo "setting up kazoo db from init script $file"
sql_setup $file

exit 0
