SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_AFTYPE_AFTER 
 AFTER
   UPDATE
 ON aftype
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
declare
    --v_afacctno varchar2(20);
    --v_errmsg varchar2(10000);
begin
    if fopks_api.fn_is_ho_active then
        IF :NEWVAL.MRCRLIMITMAX <> :OLDVAL.MRCRLIMITMAX  THEN
            INSERT into AFTYPE_log(txdate,actype,oldMRCRLIMITMAX,newMRCRLIMITMAX,status)
            values(getcurrdate,:OLDVAL.actype,:OLDVAL.MRCRLIMITMAX,:NEWVAL.MRCRLIMITMAX,'N');
        END IF;
        --End Log trigger for buffer
    end if;
end;
/
