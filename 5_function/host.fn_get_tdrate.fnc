SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_tdrate (pv_ACCTNO IN VARCHAR2)
RETURN NUMBER
iS
    v_result    NUMBER(20,4);
    V_ACTYPE    VARCHAR2(5);
    V_balance   NUMBER(20);
    V_schdtype  VARCHAR2(1);
    V_termcd    VARCHAR2(1);
    V_intrate   NUMBER(20,4);
    v_dblDDRAMT NUMBER(20);
    V_frdate    DATE;
    V_CURRDATE  DATE;
    v_dblTDTERM number(20,6);

BEGIN
    SELECT TO_DATE(varvalue,'DD/MM/RRRR') INTO V_CURRDATE FROM SYSVAR WHERE VARNAME LIKE 'CURRDATE' AND GRNAME = 'SYSTEM';
    BEGIN
        SELECT ACTYPE, BALANCE+BLOCKAMT, schdtype, termcd, intrate, frdate, DDRAMT, TDTERM
        INTO V_ACTYPE, V_balance, V_schdtype, V_termcd, V_intrate, V_frdate, v_dblDDRAMT, v_dblTDTERM
        FROM TDMAST WHERE ACCTNO = pv_ACCTNO;
    EXCEPTION WHEN OTHERS THEN
        V_intrate := 0;
        V_schdtype := 'F';
    END;
    IF (V_schdtype = 'F') THEN
        RETURN V_intrate;
    END IF;
    BEGIN
        SELECT INTRATE into V_intrate FROM TDMSTSCHM
        WHERE ACCTNO = pv_ACCTNO AND FRAMT <= (V_balance+v_dblDDRAMT) AND TOAMT > (V_balance+v_dblDDRAMT)
        AND FRTERM < v_dblTDTERM AND TOTERM >= v_dblTDTERM;
    EXCEPTION WHEN OTHERS THEN
        V_intrate := 0;
    END;
    RETURN V_intrate;

EXCEPTION WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
/
