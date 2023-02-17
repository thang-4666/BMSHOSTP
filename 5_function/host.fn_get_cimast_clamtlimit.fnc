SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_get_cimast_clamtlimit(pv_afacctno In VARCHAR2)
    RETURN number IS

    l_clamtlimit NUMBER(20,2);
BEGIN

SELECT AF.CLAMTLIMIT-MT.DCLAMTLIMIT INTO l_clamtlimit FROM afmast AF, V_GETSECMARGINRATIO MT WHERE AF.ACCTNO = MT.AFACCTNO AND AF.acctno = pv_afacctno;

    RETURN l_clamtlimit;
exception when others then
    return 0;
END;

 
 
 
 
/
