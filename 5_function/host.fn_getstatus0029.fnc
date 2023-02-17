SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getstatus0029( pv_STATUS IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  VARCHAR2(2);

BEGIN
    IF  UPPER(pv_STATUS) = 'Y' THEN
        v_Result := 'B';
    ELSE
        v_Result := 'A';
    END IF;
    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 'A';
END;

 
 
 
 
/
