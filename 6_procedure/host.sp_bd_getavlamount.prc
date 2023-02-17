SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "SP_BD_GETAVLAMOUNT" (PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,pv_ACCTNO varchar2, pv_EXECTYPE varchar2)
is
    l_cimastcheck_arr txpks_check.cimastcheck_arrtype;
    l_semastcheck_arr txpks_check.semastcheck_arrtype;

begin
    if pv_EXECTYPE in ('NB') then
        l_CIMASTcheck_arr := txpks_check.fn_CIMASTcheck(pv_ACCTNO,'CIMAST','ACCTNO');
        open PV_REFCURSOR for select l_CIMASTcheck_arr(0).PP AVLAMOUNT from dual;
    elsif pv_EXECTYPE in ('NS') then
        l_SEMASTcheck_arr := txpks_check.fn_SEMASTcheck(pv_ACCTNO,'SEMAST','ACCTNO');
        open PV_REFCURSOR for select l_SEMASTcheck_arr(0).TRADE AVLAMOUNT from dual;
    else
        open PV_REFCURSOR for select 10000000000000000 AVLAMOUNT from dual;
    end if;
end;

 
 
 
 
/
