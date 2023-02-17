SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_int(pv_intPaidMethod IN VARCHAR2 )
    RETURN number IS
    v_Result  number;
BEGIN
    IF TO_NUMBER(pv_intPaidMethod) =TO_NUMBER(pv_intPaidMethod) then
    v_Result:=1;
    END IF;


    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
 
 
 
 
 
 
 
 
 
 
/
