SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GEN_SE_ACCTNO(PV_AFACCTNO IN VARCHAR2, PV_CODEID IN VARCHAR2)
    RETURN VARCHAR2 IS
-- Purpose: Lay so tai khoan CK
-- MODIFICATION HISTORY
-- Person      Date         Comments
-- ---------   ------       -------------------------------------------
-- THANHNM   31/01/2012     Created
    V_RESULT VARCHAR2 (50);
BEGIN
 V_RESULT:= REPLACE(PV_AFACCTNO,'.','') || pv_codeid;
 RETURN V_RESULT;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
