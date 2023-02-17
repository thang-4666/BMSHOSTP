SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CRBTRFLOG_UPDATE_AFTER 
 AFTER UPDATE
 ON crbtrflog
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
begin
  --Xu ly trang thai cua crbtrflog (duyet, tu choi, huy bang ke)
  IF :newval.status='R' or :newval.status='D' THEN
  --Tu choi phe duyet hoac bi huy
  BEGIN
    UPDATE CRBTXREQ SET STATUS='P' WHERE REQID IN (SELECT REFREQID FROM CRBTRFLOGDTL WHERE VERSION=:newval.autoid);
    UPDATE CRBTRFLOGDTL SET STATUS=:newval.status WHERE VERSION=:newval.autoid;
  END;
  ELSIF :newval.status='S' THEN
    --Gui bang ke
  UPDATE CRBTRFLOGDTL SET STATUS='A' WHERE VERSION=:newval.autoid;
  END IF;
end;
/
