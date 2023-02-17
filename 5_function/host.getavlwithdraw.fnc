SET DEFINE OFF;
CREATE OR REPLACE FUNCTION getavlwithdraw (p_afacctno IN VARCHAR2)
RETURN NUMBER
  IS
    l_AVLWITHDRAW NUMBER(20,2);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
BEGIN
     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_afacctno,'CIMAST','ACCTNO');
     l_AVLWITHDRAW := l_CIMASTcheck_arr(0).AVLWITHDRAW;
    RETURN l_AVLWITHDRAW;
EXCEPTION WHEN others THEN
    return 0;
END;

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
/
