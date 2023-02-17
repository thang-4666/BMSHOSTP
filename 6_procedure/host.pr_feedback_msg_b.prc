SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_feedback_msg_b (p_status IN varchar2)
   IS
--
-- To modify this template, edit file PROC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: G?i l?i msg B confirm cho s?
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- SONLT    04-01-2015 Created
-- ---------   ------  -------------------------------------------
   -- Declare program variables as shown above
   v_status varchar2(10);
BEGIN
    v_status := p_status;
   insert into ha_b (urgency, headline, linesoftext, text,
       msgtype, status, ptype, datetime, autoid)
       select urgency, headline, linesoftext, v_status,
       msgtype, 'N', 'O', sysdate, seq_ha_b.nextval
       from ha_b WHERE TRUNC(autoid) IN (SELECT MAX(autoid) FROM ha_b where ptype = 'I'  ) ;
EXCEPTION
    WHEN OTHERS THEN
        return;
END; -- Procedure

 
 
 
 
/
