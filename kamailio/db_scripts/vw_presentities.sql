CREATE VIEW presentities as
select id, cast(printf("sip:%s@%s",username,domain) as varchar(64)) presentity_uri ,
          username, domain, event, cast(substr(etag, instr(etag,"@")+1) as varchar(64)) callid, 
          datetime(received_time, 'unixepoch') as received,
          datetime(expires, 'unixepoch') as expire_date,
          expires, cast(sender as varchar(30)) sender,
          lower(cast( case when event = "dialog" 
                           then substr(body, instr(BODY,"<state>")+7, instr(body,"</state>") - instr(body,"<state>") - 7) 
                           when event = "presence" 
                           then case when instr(body,"<dm:note>") == 0 
                                    then replace(substr(body, instr(body,"<note>")+6, instr(body,"</note>") - instr(body,"<note>") - 6), " ", "") 
                                    else replace(substr(body, instr(body,"<dm:note>")+9, instr(body,"</dm:note>") - instr(body,"<dm:note>") - 9), " ", "")
                                end
                           when event = "message-summary" 
                           then case when instr(body,"Messages-Waiting: yes") = 0 
                                     then "Waiting" 
                                     else "Not-Waiting" 
                                end 
                      end  as varchar(12))) state 
    from presentity
