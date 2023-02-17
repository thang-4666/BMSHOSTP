SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_TLAUTH_AFTER 
 AFTER 
 INSERT
 ON TLAUTH
 REFERENCING OLD AS OLDVAL NEW AS NEWVAL
 FOR EACH ROW
DECLARE
    pkgctx     plog.log_ctx;
    l_count NUMBER;
    l_autoid    NUMBER;
    l_oldvalue  varchar2(50);
    l_currdate  DATE;
BEGIN
    -- Chi log neu thong tin thay doi khac voi thong tin da log truoc do
    SELECT NVL(max(autoid),0)
    INTO l_autoid
    FROM rightassign_log rl
    WHERE rl.logtable = 'TLAUTH' AND RL.authtype = :NEWVAL.AUTHTYPE AND RL.AUTHID = :NEWVAL.AUTHID
        AND RL.cmdcode = :NEWVAL.TLTXCD AND RL.tltype = :NEWVAL.TLTYPE;
    SELECT getcurrdate INTO l_currdate FROM dual;
    IF L_AUTOID > 0 THEN
        SELECT count(autoid)
        INTO l_count
        FROM rightassign_log rl
        WHERE rl.autoid = l_autoid AND rl.tltype || TO_CHAR(rl.tllimit) <> :NEWVAL.TLTYPE || TO_CHAR(:NEWVAL.TLLIMIT);
       -- THONG TIN PHAN QUYEN THAY DOI THI MOI LOG
        IF L_COUNT > 0 THEN
            -- LAY THONG TIN PHAN QUYEN CU
            SELECT TO_CHAR(rl.tllimit)
            INTO l_oldvalue
            FROM rightassign_log rl
            WHERE rl.autoid = l_autoid;
            -- LOG THONG TIN
            INSERT INTO rightassign_log(autoid,logtable,brid,grpid,authtype,AUTHID,cmdcode,cmdtype,
                cmdallow, strauth,tltype,tllimit,chgtlid,chgtime, OLDVALUE, NEWVALUE, busdate)
            VALUES (seq_rightassign_log.NEXTVAL, 'TLAUTH', '', '', :NEWVAL.AUTHTYPE, :NEWVAL.AUTHID,:NEWVAL.TLTXCD, 'T',
                '', '',:NEWVAL.TLTYPE, :NEWVAL.TLLIMIT,:NEWVAL.SAVETLID,SYSTIMESTAMP,l_oldvalue,TO_CHAR(:NEWVAL.TLLIMIT),l_currdate);
        END IF;
    ELSE
        -- CHUA CO DONG NAO TRONG LOG THI LOG VAO
        INSERT INTO rightassign_log(autoid,logtable,brid,grpid,authtype,AUTHID,cmdcode,cmdtype,
            cmdallow, strauth,tltype,tllimit,chgtlid,chgtime, OLDVALUE, NEWVALUE, busdate)
        VALUES (seq_rightassign_log.NEXTVAL, 'TLAUTH', '', '', :NEWVAL.AUTHTYPE, :NEWVAL.AUTHID,:NEWVAL.TLTXCD, 'T',
            '', '',:NEWVAL.TLTYPE, :NEWVAL.TLLIMIT,:NEWVAL.SAVETLID,SYSTIMESTAMP,'',TO_CHAR(:NEWVAL.TLLIMIT),l_currdate);
    END IF;

exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'trg_TLAUTH_after');

END;
/
