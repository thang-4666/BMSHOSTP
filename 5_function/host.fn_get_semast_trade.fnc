SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_GET_SEMAST_TRADE(pv_afacctno In VARCHAR2, pv_codeid IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_Result  NUMBER;

BEGIN
              SELECT trade INTO v_Result FROM semast WHERE acctno=pv_afacctno||pv_codeid;
             v_Result:= NVL(v_Result,0);

    RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
