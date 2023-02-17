SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getholiday( pv_TXDATE IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(10);

BEGIN

    BEGIN
        SELECT MAX(holiday) INTO v_Result FROM sbcldr WHERE CLDRTYPE = '999' AND SBDATE = TO_DATE(pv_TXDATE,'DD/MM/RRRR');
    EXCEPTION WHEN OTHERS THEN
        v_Result := 'Y';
    END;
    v_Result := NVL(v_Result,'Y');
    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 'Y';
END;
 
 
 
 
/
