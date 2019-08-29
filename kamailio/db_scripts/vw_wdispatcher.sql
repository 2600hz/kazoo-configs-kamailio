CREATE VIEW wdispatcher as
    select *, 
        cast(substr(attrs, instr(attrs, "zone=")+5, instr(attrs, ";profile")-instr(attrs, "zone=")-5) as varchar(20)) zone,
        cast(substr(attrs, instr(attrs, "duid=")+5, instr(attrs, ";node")-instr(attrs, "duid=")-5) as integer) idx,
        cast(substr(attrs, instr(attrs, "node=")+5) as varchar(50)) node 
    from dispatcher
