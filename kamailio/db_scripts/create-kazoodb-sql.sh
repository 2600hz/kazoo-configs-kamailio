#!/bin/sh -e

KAMAILIO_SHARE_DIR=${KAMAILIO_SHARE_DIR:-/usr/share/kamailio}
DB_ENGINE=${DB_ENGINE:-postgres}
RESULTED_SQL=${RESULTED_SQL:-/tmp/kamailio_initdb.sql}

. ./$DB_ENGINE-spectific --source-only

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

echo "Creating kamailio database init file in '$RESULTED_SQL'"

sql_db_pre_setup > $RESULTED_SQL
sql_header > $RESULTED_SQL
for i in $(sql_filelist); do
    cat $KAMAILIO_SHARE_DIR/$DB_ENGINE/$i >> $RESULTED_SQL
done
sql_extra_tables >> $RESULTED_SQL
sql_footer >> $RESULTED_SQL
exit 0
