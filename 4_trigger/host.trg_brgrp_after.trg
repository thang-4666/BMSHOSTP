SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_BRGRP_AFTER 
 AFTER
  UPDATE
 ON brgrp
REFERENCING NEW AS NEW OLD AS OLD
declare
    V_count number(10);
begin
    select count(*) into V_count from brgrp where status = 'A';
    if V_count = 0 then
        pr_SMSMonitor('BRINACTIVE');
    end if;
end;
/
