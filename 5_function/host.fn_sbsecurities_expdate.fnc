SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_sbsecurities_expdate(pv_EXPDATE varchar2,pv_EXPDATEtmp varchar2,PV_ISSUEDATE VARCHAR2,pv_TERM IN VARCHAR2,pv_TYPETERM VARCHAR2,PV_SBTODATE Varchar2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(20);
    V_YEAR_TEMP NUMBER;
    V_MONTH_TEMP NUMBER;
    V_DAY_TEMP  NUMBER;
    v_maxdate   date;
    V_EXPDATETMP DATE;
BEGIN
    IF(pv_TYPETERM = 'W') THEN
        v_Result := TO_CHAR(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR')+pv_TERM*7,'DD/MM/RRRR');
    END IF;
    IF(pv_TYPETERM = 'M') THEN
        v_Result := to_char(add_months(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR'), pv_TERM),'DD/MM/RRRR');
    END IF;
    IF(pv_TYPETERM = 'Y') THEN
        v_Result := to_char(add_months(TO_DATE(PV_ISSUEDATE,'DD/MM/RRRR'), pv_TERM*12),'DD/MM/RRRR');
    END IF;

    IF(pv_TYPETERM = 'D') THEN
        v_Result := PV_SBTODATE;
            RETURN v_Result;
    END IF;

    V_EXPDATETMP := TO_DATE(NVL(pv_EXPDATEtmp,PV_ISSUEDATE),'DD/MM/RRRR');
    v_maxdate := TO_DATE(NVL(pv_EXPDATE,PV_ISSUEDATE),'DD/MM/RRRR');

    IF (V_EXPDATETMP = v_Result) THEN
        v_Result := v_maxdate;
    END IF;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN PV_ISSUEDATE;
END;

 
 
 
 
/
