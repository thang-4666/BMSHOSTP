SET DEFINE OFF;
CREATE OR REPLACE TRIGGER trg_emaillog_before
 BEFORE
  INSERT OR UPDATE
 ON emaillog
REFERENCING NEW AS NEWVAL OLD AS OLDVAL
 FOR EACH ROW
DECLARE
    diff NUMBER(20,8);
    v_ISTEST VARCHAR2(10);
    v_strEmail VARCHAR2(2000);
    v_strSMS VARCHAR2(2000);
    v_strSendType   varchar2(5);
begin
    IF :NEWVAL.EMAIL is null THEN
        :newval.status := 'R';
    END IF;
    
--:NEWVAL.last_change:= SYSTIMESTAMP;
    BEGIN
        SELECT VARVALUE INTO v_ISTEST FROM SYSVAR WHERE VARNAME LIKE 'ISTEST' AND GRNAME='SYSTEM';
    EXCEPTION WHEN OTHERS THEN
        v_ISTEST := 'N';
    END;
    
    -- Neu la moi truong test
    --> Email ngoai DS dang ky --> khong gui --> chuyen TT Reject luon.
    IF v_ISTEST ='Y' THEN
        BEGIN
            SELECT VARVALUE INTO v_strEmail FROM SYSVAR WHERE VARNAME LIKE 'EMAILTEST' AND GRNAME='SYSTEM';
            SELECT VARVALUE INTO v_strSMS FROM SYSVAR WHERE VARNAME LIKE 'SMSTEST' AND GRNAME='SYSTEM';
        EXCEPTION WHEN OTHERS THEN
            v_strEmail := '';
            v_strSMS := '';
        END;
        
        BEGIN
            SELECT t.type INTO v_strSendType FROM TEMPLATES t WHERE t.code = :NEWVAL.templateid;
            
        EXCEPTION WHEN OTHERS THEN
            v_strSendType := 'E';
        END;

        
        If instr(upper(v_strEmail), upper(trim(:NEWVAL.email))) = 0 and v_strSendType like 'E' then
            :NEWVAL.STATUS :='R';
        end if;
        
        If instr(upper(v_strSMS), upper(trim(:NEWVAL.email))) = 0 and v_strSendType like 'S' then
            :NEWVAL.STATUS :='R';
        end if;
    END IF;
END;
/
