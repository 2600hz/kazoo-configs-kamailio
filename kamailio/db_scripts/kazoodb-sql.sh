#!/bin/sh -e

KAMAILIO_SHARE_DIR=${KAMAILIO_SHARE_DIR:-/usr/share/kamailio}
DB_ENGINE=${DB_ENGINE:-db_kazoo}
RESULTED_SQL=${RESULTED_SQL:-/tmp/kamailio_initdb.sql}

. $(dirname $0)/$DB_ENGINE-specific --source-only

sql_filelist() {
cat << EOF
acc-create.sql
lcr-create.sql
domain-create.sql
group-create.sql
permissions-create.sql
registrar-create.sql
usrloc-create.sql
msilo-create.sql
alias_db-create.sql
uri_db-create.sql
speeddial-create.sql
avpops-create.sql
auth_db-create.sql
pdt-create.sql
dialog-create.sql
dispatcher-create.sql
dialplan-create.sql
topos-create.sql
presence-create.sql
rls-create.sql
imc-create.sql
cpl-create.sql
siptrace-create.sql
domainpolicy-create.sql
carrierroute-create.sql
userblacklist-create.sql
htable-create.sql
purple-create.sql
uac-create.sql
pipelimit-create.sql
mtree-create.sql
sca-create.sql
mohqueue-create.sql
rtpproxy-create.sql
uid_auth_db-create.sql
uid_avp_db-create.sql
uid_domain-create.sql
uid_gflags-create.sql
uid_uri_db-create.sql
EOF
}

sql_all_header() {
cat << EOF
CREATE TABLE version (
    table_name VARCHAR(32) NOT NULL,
    table_version INTEGER DEFAULT 0 NOT NULL,
    CONSTRAINT version_table_name_idx UNIQUE (table_name)
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
