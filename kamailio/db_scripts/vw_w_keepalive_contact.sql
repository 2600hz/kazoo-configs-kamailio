CREATE VIEW w_keepalive_contact as
     select id, slot, selected, failed, case when instr(contact,";") > 0
                                        then substr(contact, 1, instr(contact,";")-1)
                                        else contact
                                        end as contact
     from keepalive
