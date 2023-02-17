SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_BRGRPPARAM_AFTER 
 AFTER
  INSERT OR UPDATE
 ON brgrpparam
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
BEGIN
    -- THONG TIN PHAN QUYEN THAY DOI THI MOI LOG
    IF :NEWVAL.PARATYPE = 'TLGROUPS' THEN
        INSERT INTO rightassign_log(autoid,logtable,brid,grpid,authtype,AUTHID,cmdcode,cmdtype,
            cmdallow, strauth,tltype,tllimit,chgtlid,chgtime)
        VALUES (seq_rightassign_log.nextval, 'BRGRPPARAM', :NEWVAL.BRID, :NEWVAL.PARAVALUE, '', '','', '',
            '', '','', 0,:NEWVAL.SAVETLID,SYSTIMESTAMP);
    END IF;
END;
/
