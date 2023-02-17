SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_IS_FLOAT_INT(pv_isLastPaid In NUMBER, pv_intPaidMethod IN VARCHAR2)
    RETURN number IS
    v_Result  number;
BEGIN
    IF (pv_isLastPaid = 1)
      THEN v_result := 0 ;
     ELSE
       IF pv_intPaidMethod ='P'
         THEN
       v_result := 1;
       ELSE
          v_result := 0;
       END IF;
END IF;
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
