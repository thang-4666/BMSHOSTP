SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_DFMAST_AFTER 
 AFTER 
 UPDATE
 ON DFMAST
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
begin
    if fopks_api.fn_is_ho_active then
        --Log trigger for buffer if modify
            jbpks_auto.pr_trg_account_log(:newval.afacctno || :newval.codeid,'SE');
        --End Log trigger for buffer
    end if;
end;
/
