SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_clearday_bond( pv_sectype IN VARCHAR2, pv_clearday in varchar2)
--T10/2015 TTBT T+2:
--Ham check Chu ky thanh toan tren man hinh SYSTEM co <= Chu ky TT tren sysvar k voi TH Trai phieu?
--Neu co tra ve True, neu ko tra ve False
    RETURN varchar2 IS
    v_Result  varchar2(5);
    v_codeid varchar2(10);
    v_sectype varchar2(5);
    v_clearday number;
    v_sysclearday number;
    v_sybol_sectype varchar2(5);
BEGIN
    --v_codeid := nvl(substr(pv_codeid,2,LENGTH(pv_codeid)-1),'--ALL--');
    v_codeid := '--ALL--';
    v_sectype := pv_sectype;
    v_clearday := to_number(pv_clearday);

    SELECT TO_NUMBER(NVL(MAX(VARVALUE),'0')) INTO V_SYSCLEARDAY FROM SYSVAR WHERE GRNAME LIKE 'SYSTEM' AND VARNAME='CLEARDAY' ;
    IF (v_clearday > v_sysclearday) THEN
        IF (v_codeid = '--ALL--') THEN
          if (v_sectype in ('444', '003', '006', '222','012')) THEN
            v_result := 'False';
          ELSE
            v_result := 'True' ;
          END IF;

         ELSE
            SELECT SECTYPE INTO V_SYBOL_SECTYPE FROM SBSECURITIES WHERE CODEID=V_CODEID AND ROWNUM<=1;
            IF (v_sectype in ('444', '003', '006', '222','012') and v_sybol_sectype in ('444', '003', '006', '222','012')) THEN
            v_result := 'False';
          ELSE
            v_result := 'True' ;
          END IF;

         END IF;
     ELSE
        v_result := 'True' ;
     END IF;
    plog.error('FN_CHECK_CLEARDAY_BOND: v_result=/'||v_result||'/');
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 'False';
END;
 
/
