SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_TDTYPE_AUTOPAID(pv_AUTOPAID IN VARCHAR2,pv_INPUT VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(10);

BEGIN
    if(pv_AUTOPAID ='N') THEN
        v_Result:='N';
    ELSE
        v_Result:=pv_INPUT;
    END IF;

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 'N';
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
