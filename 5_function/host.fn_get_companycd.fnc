SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_COMPANYCD RETURN VARCHAR2
IS
   return_val VARCHAR2(3) := '001';
BEGIN
    SELECT VARVALUE INTO return_val FROM SYSVAR WHERE VARNAME='COMPANYCD' AND GRNAME='SYSTEM';
   RETURN return_val;
EXCEPTION
  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20001,SQLERRM);
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
