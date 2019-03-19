CREATE VIEW w_location_contact as
    select id, ruid, case when instr(contact,";") > 0
                          then substr(contact, 1, instr(contact,";")-1)
                          else contact
                          end as contact
    from location
