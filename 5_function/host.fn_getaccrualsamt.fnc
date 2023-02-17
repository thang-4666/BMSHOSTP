SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getaccrualsamt(p_autoid IN number, p_int IN number)
  RETURN  number
  IS
 v_Result number ;
BEGIN

SELECT LEAST( sum(accrualsamt),p_int) INTO v_Result FROM lnschd WHERE autoid =  p_autoid;

    RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
/
