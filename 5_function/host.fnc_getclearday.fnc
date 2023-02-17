SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fnc_getclearday( FDATE IN VARCHAR2, TDATE IN VARCHAR2)
  RETURN number IS
    v_Result number(18,5);
BEGIN
SELECT COUNT(*)-1  INTO  v_Result  FROM sbcldr WHERE  SBDATE >=TO_DATE(FDATE,'DD/MM/YYYY') AND SBDATE <=TO_DATE(TDATE,'DD/MM/YYYY')  AND cldrtype='000' AND holiday ='N';
RETURN v_Result;
END;
 
 
 
 
 
 
 
 
 
 
 
 
 
/
