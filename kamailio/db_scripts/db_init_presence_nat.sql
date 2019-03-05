CREATE TABLE if not exists presence_nat (
    id INTEGER PRIMARY KEY NOT NULL,
    contact VARCHAR(2048) NOT NULL COLLATE NOCASE,
    local_contact VARCHAR(32) NOT NULL COLLATE NOCASE,
    time_inserted timestamp DEFAULT CURRENT_TIMESTAMP,
    time_sent timestamp DEFAULT CURRENT_TIMESTAMP,
    slot INTEGER NOT NULL,
    selected INTEGER DEFAULT 0,
    CONSTRAINT presence_nat_idx UNIQUE (contact)
    );
