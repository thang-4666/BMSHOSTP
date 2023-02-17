SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_gen_tradelot(pv_symbol IN VARCHAR2)
    RETURN NUMBER IS
    v_Result  NUMBER;
BEGIN
  SELECT tradelot INTO v_Result FROM securities_info WHERE symbol=pv_symbol;
RETURN v_Result;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 100;
END;
 
/
