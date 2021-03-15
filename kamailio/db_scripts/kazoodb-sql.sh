#!/bin/sh -e
####################################################################
#                                                                  #
# To use other database than default sqlite, change "DB_ENGINE="   #
# Example "DB_ENGINE=${DB_ENGINE:-mysql}".                         #
#                                                                  #
####################################################################

KAMAILIO_SHARE_DIR=${KAMAILIO_SHARE_DIR:-/usr/share/kamailio}
DB_ENGINE=${DB_ENGINE:-db_kazoo}
RESULTED_SQL=${RESULTED_SQL:-/tmp/kamailio_initdb.sql}

. $(dirname $0)/$DB_ENGINE-specific --source-only

sql_filelist() {
  echo `ls -A1 ${KAMAILIO_SHARE_DIR}/${DB_ENGINE}/*.sql | grep -v standard | tr '\n' '\0' | xargs -0 -n 1 basename | grep -v -E 'ims_dialog-create.sql|ims_usrloc_scscf-create.sql|ims_usrloc_pcscf-create.sql' | sort`
}

sql_all_header() {
cat << EOF
CREATE TABLE version (
    table_name VARCHAR(32) NOT NULL,
    table_version INTEGER DEFAULT 0 NOT NULL,
    PRIMARY KEY(table_name)
);
INSERT INTO version VALUES('version',1);

EOF
}

sql_all_extra_tables() {
cat << EOF

CREATE TABLE event_list ( event varchar(25) PRIMARY KEY NOT NULL);
INSERT INTO event_list VALUES('dialog');
INSERT INTO event_list VALUES('presence');
INSERT INTO event_list VALUES('message-summary');
INSERT INTO version VALUES('event_list',1);

EOF
}

sql_all_footer() {
cat << EOF
COMMIT;
EOF
}

sql_db_prepare() {
    sql_db_pre_setup > $RESULTED_SQL
    sql_all_header >> $RESULTED_SQL
    sql_header >> $RESULTED_SQL
    for i in $(sql_filelist); do
        cat $KAMAILIO_SHARE_DIR/$DB_ENGINE/$i >> $RESULTED_SQL
    done
    sql_all_extra_tables >> $RESULTED_SQL
    sql_extra_tables >> $RESULTED_SQL
    sql_footer >> $RESULTED_SQL
    sql_all_footer >> $RESULTED_SQL

    echo "$RESULTED_SQL"
}
