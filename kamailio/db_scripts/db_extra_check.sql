
do_db_extra_check() {

# location
if [[ $RESET_NON_UDP_ENABLED == "true" ]]; then
    KazooDB -db ${DB_CURRENT_DB} "delete from location where socket not like 'udp:%';"
fi

##KazooDB -db ${DB_CURRENT_DB} "delete from location where expires > 0 and datetime(expires) < datetime('now', '-30 seconds');"
KazooDB -db ${DB_CURRENT_DB} "delete from location_attrs where not exists(select id from location where ruid = location_attrs.ruid);"

## presence
if [[ $RESET_NON_UDP_ENABLED == "true" ]]; then
    KazooDB -db ${DB_CURRENT_DB} "delete from active_watchers where socket_info not like 'udp:%';"
fi
KazooDB -db ${DB_CURRENT_DB} "delete from active_watchers where expires > 0 and datetime(expires, 'unixepoch') < datetime('now', '-10 seconds');"
KazooDB -db ${DB_CURRENT_DB} "delete from presentity where expires > 0 AND datetime(expires, 'unixepoch') < datetime('now', '-10 seconds');"
KazooDB -db ${DB_CURRENT_DB} "delete from presentity where id in(select id from presentities where state in('terminated','available'));"
KazooDB -db ${DB_CURRENT_DB} "delete from active_watchers_log where id in(select id from active_watchers_log a where not exists(select callid from active_watchers b where b.callid = a.callid and b.watcher_username = a.watcher_username and b.watcher_domain = a.watcher_domain));"
KazooDB -db ${DB_CURRENT_DB} "delete from presentity where id in(select id from presentities a where not exists(select * from active_watchers where presentity_uri = a.presentity_uri));"

## notify watchers of pending calls
## 'create temp table as' because it will be dropped as soon as we ended the session
KazooDB -db ${DB_CURRENT_DB} "drop table if exists tmp_probe;"
KazooDB -db ${DB_CURRENT_DB} "create table tmp_probe as select distinct a.event, a.presentity_uri, cast(2 as integer) action from presentities a inner join active_watchers b on a.presentity_uri = b.presentity_uri and a.event = b.event where state in('early', 'confirmed', 'onthephone', 'busy');"
KazooDB -db ${DB_CURRENT_DB} "delete from presentity where id in(select id from presentities where state in('early', 'confirmed', 'onthephone', 'busy'));"

## keepalive
if [[ $RESET_NON_UDP_ENABLED == "true" ]]; then
    KazooDB -db ${DB_CURRENT_DB} "delete from keepalive where sockinfo NOT LIKE 'udp%';"
fi
KazooDB -db ${DB_CURRENT_DB} "update keepalive set selected = 0, time_sent = datetime('now') where selected < 3;"

}
