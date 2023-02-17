SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_check_restrction_allow (p_symbol      VARCHAR2,
                                                    p_afacctno      VARCHAR2,
                                                    p_side          VARCHAR2) RETURN VARCHAR2 IS
  l_trscope      sbsecurities.trscope%TYPE;
  l_count        NUMBER;
  l_accountType  VARCHAR2(10);
BEGIN
  SELECT trscope INTO l_trscope FROM sbsecurities WHERE symbol = p_symbol;
  IF l_trscope = 0 THEN
    RETURN 'Y';
  END IF;
  SELECT decode(substr(custodycd,4,1), 'P', '3', '1') INTO l_accountType
  FROM cfmast cf, afmast af
  WHERE cf.custid = af.custid AND af.acctno = p_afacctno;
  
  SELECT COUNT(1) INTO l_count FROM hotrscopemap 
  WHERE trscope = l_trscope AND side = p_side
  AND accounttype = l_accountType;
  IF l_count > 0 THEN
    RETURN 'N';
  END IF;
  
  RETURN 'Y';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END ;
/
