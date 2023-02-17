SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_semast_avl_blocked_otc(pv_afacctno In VARCHAR2, pv_codeid IN VARCHAR2)
    RETURN number IS

    l_BLOCKED NUMBER(20,2);

BEGIN
     SELECT BLOCKED INTO  l_BLOCKED FROM semast WHERE acctno = pv_afacctno||pv_codeid;

    RETURN l_BLOCKED ;
exception when others then
    return 0;
END;

 
 
 
 
/
