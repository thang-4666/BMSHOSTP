SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE sp_jobs_check_pass_exp
IS
---p_err_code varchar2(100);
    l_strISRESET varchar2(1);
    l_strRESETTIME number(10);
BEGIN

FOR rec IN
(
    SELECT A.ID, A.USERNAME, A.OLDLOGINPWD, A.OLDTRADINGPWD, A.NEWLOGINPWD, A.NEWTRADINGPWD, A.TIMECHANGE, A.ISPROCESS
    FROM USERLOGIN_CHANGE A
    WHERE A.ISPROCESS = 'N'
)
LOOP
    begin
        select max(ISRESET) into l_strISRESET from userlogin where username = rec.USERNAME;
    EXCEPTION WHEN OTHERS  THEN
        l_strISRESET := 'N';
    end ;
    
    
     begin
       select to_number(varvalue)  into l_strRESETTIME
       from sysvar
       where varname like 'OTPASSEXPIRE';
    EXCEPTION WHEN OTHERS  THEN
        l_strRESETTIME := '60';
    end ;
    
    --so gio expire pass khi resset la tham so theo phut, khi expire se resset ve pass cu
    if (sysdate - rec.TIMECHANGE)*24*60 >= l_strRESETTIME then
        if l_strISRESET = 'Y' then
            update userlogin set loginpwd = rec.OLDLOGINPWD,tradingpwd = rec.OLDTRADINGPWD
            where USERNAME = rec.USERNAME and AUTHTYPE = '1';
        end if;
        update USERLOGIN_CHANGE set ISPROCESS = 'Y' where ID = rec.id;
    end if;
    commit;

END LOOP;

EXCEPTION
   WHEN OTHERS  THEN
   ROLLBACK;
   RETURN;
END;
 
/
