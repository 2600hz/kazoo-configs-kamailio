CREATE TRIGGER if not exists active_watchers_watcher_uri_insert
AFTER INSERT ON active_watchers
FOR EACH ROW
BEGIN
   UPDATE active_watchers SET watcher_uri = "sip:" || NEW.watcher_username || "@" || NEW.watcher_domain where id = NEW.id;
END;

CREATE TRIGGER if not exists active_watchers_watcher_uri_update
AFTER UPDATE ON active_watchers
FOR EACH ROW
WHEN OLD.watcher_username <> NEW.watcher_username OR OLD.watcher_domain <> NEW.watcher_domain
BEGIN
   UPDATE active_watchers SET watcher_uri = "sip:" || NEW.watcher_username || "@" || NEW.watcher_domain where id = NEW.id;
END;
