SET DEFINE OFF;
CREATE OR REPLACE TRIGGER TRG_CMDAUTH_AFTER 
 AFTER
  INSERT
 ON cmdauth
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    pkgctx     plog.log_ctx;
    l_count NUMBER;
    l_autoid    NUMBER;
    l_oldvalue  varchar2(50);
    l_currdate  DATE;
    l_LastDeleted   varchar2(1);
BEGIN
    -- Chi log neu thong tin thay doi khac voi thong tin da log truoc do
    SELECT NVL(max(autoid),0)
    INTO l_autoid
    FROM rightassign_log rl
    WHERE rl.logtable = 'CMDAUTH' AND RL.authtype = :NEWVAL.AUTHTYPE AND RL.AUTHID = :NEWVAL.AUTHID
        AND RL.cmdcode = :NEWVAL.CMDCODE AND RL.cmdtype = :NEWVAL.CMDTYPE;
    SELECT getcurrdate INTO l_currdate FROM dual;

    -- Check xem thong tin log truoc co phai la xoa hay ko
    IF l_autoid >0 THEN
        SELECT decode(rl.newvalue,'D','Y','N')
        INTO l_LastDeleted
        FROM rightassign_log rl
        WHERE rl.autoid = l_autoid;
    END IF;

    IF L_AUTOID > 0 AND l_LastDeleted = 'N' THEN
        SELECT count(autoid)
        INTO l_count
        FROM rightassign_log rl
        WHERE rl.autoid = l_autoid AND rl.cmdallow || rl.strauth <> :NEWVAL.CMDALLOW || :NEWVAL.STRAUTH;

        
        -- THONG TIN PHAN QUYEN THAY DOI THI MOI LOG
        IF L_COUNT > 0 THEN
            -- LAY THONG TIN PHAN QUYEN CU
            SELECT rl.cmdallow || rl.strauth
            INTO l_oldvalue
            FROM rightassign_log rl
            WHERE rl.autoid = l_autoid;
            INSERT INTO rightassign_log(autoid,logtable,brid,grpid,authtype,AUTHID,cmdcode,cmdtype,cmdallow,
                strauth,tltype,tllimit,chgtlid,chgtime, OLDVALUE, NEWVALUE, busdate)
            VALUES (seq_rightassign_log.NEXTVAL, 'CMDAUTH', '', '', :NEWVAL.AUTHTYPE, :NEWVAL.AUTHID,:NEWVAL.CMDCODE,:NEWVAL.CMDTYPE,
                :NEWVAL.CMDALLOW,:NEWVAL.STRAUTH,'','',:NEWVAL.SAVETLID,SYSTIMESTAMP,l_oldvalue,:NEWVAL.CMDALLOW || :NEWVAL.STRAUTH,l_currdate);
        END IF;
     
    ELSE
            
        INSERT INTO rightassign_log(autoid,logtable,brid,grpid,authtype,AUTHID,cmdcode,cmdtype,cmdallow,
            strauth,tltype,tllimit,chgtlid,chgtime, OLDVALUE, NEWVALUE, busdate)
        VALUES (seq_rightassign_log.NEXTVAL, 'CMDAUTH', '', '', :NEWVAL.AUTHTYPE, :NEWVAL.AUTHID,:NEWVAL.CMDCODE,:NEWVAL.CMDTYPE,
            :NEWVAL.CMDALLOW,:NEWVAL.STRAUTH,'','',:NEWVAL.SAVETLID,SYSTIMESTAMP,'',:NEWVAL.CMDALLOW || :NEWVAL.STRAUTH,l_currdate);
 
    END IF;
exception
  when others then
    plog.error(pkgctx, SQLERRM);
    plog.setEndSection(pkgctx, 'trg_CMDAUTH_after');

END;
/
