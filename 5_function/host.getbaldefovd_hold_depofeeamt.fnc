SET DEFINE OFF;
CREATE OR REPLACE FUNCTION GETBALDEFOVD_HOLD_DEPOFEEAMT (
        p_afacctno IN VARCHAR2)
RETURN NUMBER
  IS
    l_BALDEFOVD NUMBER(20,2);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
BEGIN
     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_afacctno,'CIMAST','ACCTNO');
     l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD_HOLD_DEPOFEEAMT;
RETURN l_BALDEFOVD;
EXCEPTION WHEN others THEN
    --plog.error(dbms_utility.format_error_backtrace);
    return 0;
END;

 
 
 
 
/
