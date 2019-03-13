CREATE VIEW w_keepalive_contact as
SELECT id, slot, failed, case when instr(contact,";") > 0 
                              then substr(contact, 1, instr(contact,";")-1)
                              else contact 
                         end as contact
from keepalive;
                
CREATE VIEW w_location_contact as
SELECT id, case when instr(contact,";") > 0
                then substr(contact, 1, instr(contact,";")-1)
                else contact
           end as contact
from location;
                
CREATE VIEW w_watchers_contact as
select id, case when instr(contact,";") > 0
                then substr(contact, 1, instr(contact,";")-1)
                else contact
           end as contact
from active_watchers;
