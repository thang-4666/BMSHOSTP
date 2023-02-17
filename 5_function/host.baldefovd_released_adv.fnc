SET DEFINE OFF;
CREATE OR REPLACE FUNCTION baldefovd_released_adv (
        p_afacctno IN VARCHAR2)
RETURN NUMBER
  IS
    l_baldefovd_released_adv NUMBER(20,2);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
BEGIN
     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_afacctno,'CIMAST','ACCTNO');
     l_baldefovd_released_adv := l_CIMASTcheck_arr(0).baldefovd_released_adv;
RETURN l_baldefovd_released_adv;
EXCEPTION WHEN others THEN
    --plog.error(dbms_utility.format_error_backtrace);
    return 0;
END;

 
 
 
 
/
