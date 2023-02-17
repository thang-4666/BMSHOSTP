SET DEFINE OFF;
CREATE OR REPLACE procedure pr_updatepin(p_pin       varchar2,
                                         p_custodycd varchar2) is
begin
  update cfmast set pin = p_PIN where custodycd = p_CUSTODYCD;
  commit;
end PR_UPDATEPIN;

 
 
 
 
/
