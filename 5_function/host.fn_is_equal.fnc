SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_IS_EQUAL(pv_temp1 In VARCHAR2, pv_temp2 IN VARCHAR2)
    RETURN number IS
    v_Result  number;
BEGIN
    IF (pv_temp1 = pv_temp2)
      THEN v_result := 1 ;
     ELSE
       v_result := 0;
       END IF;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
