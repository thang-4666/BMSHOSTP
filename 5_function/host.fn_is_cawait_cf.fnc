SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_is_cawait_CF(PV_CUSTODYCD IN VARCHAR2)
    RETURN CHAR IS
    V_RESULT char(1);
    l_count NUMBER;

BEGIN
  V_result:='N';
  SELECT COUNT(*) INTO l_count
  FROM caschd ca, cfmast cf, afmast af
  WHERE ca.deltd='N' AND ca.isexec='Y'
  AND ((ca.isse='N' AND ca.qtty>0)or(ca.isci='N' AND ca.amt>0))
  and ca.afacctno = af.acctno
  and cf.custid = af.custid
  AND cf.custodycd = PV_CUSTODYCD;
  if(L_Count> 0) THEN
  V_result:='Y';
  END IF;

RETURN V_RESULT;
EXCEPTION
   WHEN OTHERS THEN
    RETURN 'N';
END;
 
 
 
 
 
 
 
 
 
 
 
/
