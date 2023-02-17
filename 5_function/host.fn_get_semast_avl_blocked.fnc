SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_semast_avl_BLOCKED(pv_afacctno In VARCHAR2, pv_codeid IN VARCHAR2)
    RETURN number IS

    l_BLOCKED NUMBER(20,2);
    l_semastcheck_arr txpks_check.semastcheck_arrtype;
BEGIN 
     
     l_semastcheck_arr := txpks_check.fn_semastcheck(pv_afacctno || pv_codeid ,'SEMAST','ACCTNO');
     l_BLOCKED:=l_semastcheck_arr(0).BLOCKED;

    RETURN l_BLOCKED ;
exception when others then
    return 0;
END;
 
 
 
 
 
 
 
 
 
 
 
/
