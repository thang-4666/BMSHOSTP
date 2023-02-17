SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getavlsetrade (p_afacctno in VARCHAR2, p_codeid IN VARCHAR2)
  RETURN number IS
    l_AVLSETRADE NUMBER(20,2);
    l_SEMASTcheck_arr txpks_check.semastcheck_arrtype;
    l_SEBACKDATE    number(20,2);
BEGIN
    l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(p_afacctno||p_codeid,'SEMAST','ACCTNO');
    l_AVLSETRADE := l_SEMASTcheck_arr(0).TRADE;

    -- Lay so luong CK dat lenh backdate
    SELECT nvl(sum(od.execqtty),0)
    INTO l_SEBACKDATE
    FROM odmast od
    WHERE od.expdate = getcurrdate AND od.expdate > od.txdate
        AND od.seacctno = p_afacctno||p_codeid AND od.orstatus = '4';

    IF l_AVLSETRADE - l_SEBACKDATE > 0 THEN
        RETURN l_AVLSETRADE - l_SEBACKDATE;
    ELSE
        RETURN 0;
    END IF;
exception when others then
    return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
/
