SET DEFINE OFF;
CREATE OR REPLACE FUNCTION FN_IS_CAWAIT(PV_AFACCTNO IN VARCHAR2)
    RETURN CHAR IS
    V_RESULT char(1);
    l_count NUMBER;

BEGIN
  V_result:='N';
  SELECT COUNT(*) INTO l_count
  FROM caschd
  WHERE deltd='N' AND isexec='Y'
  AND ((isse='N' AND qtty>0)or(isci='N' AND amt>0))
  AND afacctno= PV_AFACCTNO;
  if(L_Count> 0) THEN
  V_result:='Y';
  END IF;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 'N';
END;
 
 
 
 
 
 
 
 
 
 
 
/
