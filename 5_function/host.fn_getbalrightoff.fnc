SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getbalrightoff (
        p_afacctno IN VARCHAR2)
RETURN NUMBER
  IS
    l_BALDEFOVD NUMBER(20,2);
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_ISSTOPADV  varchar2(1);

BEGIN
      select varvalue INTO l_ISSTOPADV  from sysvar where varname like 'ISSTOPADV' AND grname ='SYSTEM';
     l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(p_afacctno,'CIMAST','ACCTNO');

IF l_ISSTOPADV ='Y' THEN
  l_BALDEFOVD := least(greatest(l_CIMASTcheck_arr(0).pp,l_CIMASTcheck_arr(0).balance+  l_CIMASTcheck_arr(0).avladvance),l_CIMASTcheck_arr(0).balance + l_CIMASTcheck_arr(0).bamt+ l_CIMASTcheck_arr(0).avladvance);
 ELSE
  l_BALDEFOVD := least(greatest(l_CIMASTcheck_arr(0).pp,l_CIMASTcheck_arr(0).balance ),l_CIMASTcheck_arr(0).balance + l_CIMASTcheck_arr(0).bamt);
 END IF;
     --l_BALDEFOVD := l_CIMASTcheck_arr(0).BALDEFOVD;
RETURN l_BALDEFOVD;
EXCEPTION WHEN others THEN
    --plog.error(dbms_utility.format_error_backtrace);
    return 0;
END;
 
 
 
 
/
