SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_GetTRADEPLACE (pv_codeid IN VARCHAR2)
RETURN varchar2
iS
    v_result VARCHAR2(003);
BEGIN
       SELECT TRADEPLACE
                INTO v_result
        FROM SBsecurities se WHERE codeid = pv_codeid;
    RETURN v_result;
EXCEPTION WHEN OTHERS THEN
    RETURN '000';
END;

 
 
 
 
/
