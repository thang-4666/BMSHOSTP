SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_semast_avl_trade_otc(pv_afacctno In VARCHAR2, pv_codeid IN VARCHAR2)
    RETURN number IS

    l_TRADE NUMBER(20,2);

BEGIN
     SELECT TRADE INTO  l_TRADE FROM semast WHERE acctno = pv_afacctno||pv_codeid;

    RETURN l_TRADE ;
exception when others then
    return 0;
END;

 
 
 
 
/
