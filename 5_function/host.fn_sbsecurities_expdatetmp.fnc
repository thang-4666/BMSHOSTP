SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_sbsecurities_expdatetmp(PV_ISSUEDATE VARCHAR2,pv_TERM IN VARCHAR2,pv_TYPETERM VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(20);
    V_YEAR_TEMP NUMBER;
    V_MONTH_TEMP NUMBER;
    V_DAY_TEMP  NUMBER;
    v_maxdate   date;
BEGIN
    /*if(pv_TRADEPLACE <>'001') THEN
        v_Result:='AL';
    ELSE
        v_Result:=pv_ALLOWSESSION;
    END IF;
    W   W   Tu?n
    M   M   Th?
    Y   Y   Nam
    */
    IF(pv_TYPETERM = 'W') THEN
        V_DAY_TEMP := pv_TERM*7;
        v_Result := TO_CHAR(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR')+pv_TERM,'DD/MM/RRRR');
    END IF;
    IF(pv_TYPETERM = 'M') THEN
        v_Result := to_char(add_months(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR'), pv_TERM),'DD/MM/RRRR');
    END IF;
    IF(pv_TYPETERM = 'Y') THEN
        V_DAY_TEMP := pv_TERM*12;
        v_Result := to_char(add_months(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR'), pv_TERM*12),'DD/MM/RRRR');
    END IF;
    ---- v_Result := TO_CHAR(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR')+V_DAY_TEMP,'DD/MM/RRRR');
    --- SELECT max(SBDATE)  INTO v_maxdate FROM sbcldr;
    /*if TO_DATE(v_Result,'DD/MM/RRRR') < v_maxdate then
        SELECT TO_CHAR(MIN(SBDATE),'DD/MM/RRRR') INTO v_Result FROM sbcldr WHERE SBDATE >= TO_DATE(v_Result,'DD/MM/RRRR')
            AND holiday <> 'Y';
    end if;*/

    return v_Result;


EXCEPTION
   WHEN OTHERS THEN
    RETURN PV_ISSUEDATE;
END;

 
 
 
 
/
