SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_3320_get_amt( pv_codeid varchar2,pv_custodycd varchar2)
    RETURN NUMBER IS
    v_Result  NUMBER;
    v_wftcodeid   varchar2(6);
    v_custodycd   varchar2(20);
BEGIN
    begin
    select refcodeid into v_wftcodeid from sbsecurities where nvl(refcodeid,'a')=pv_codeid;
    exception
    when others then
    v_wftcodeid:=pv_codeid;
    end;

    if pv_custodycd = 'ALL' or pv_custodycd is null then
        v_custodycd:='%%';
    else
        v_custodycd:=pv_custodycd;
    end if;
   select nvl(sum( trade+margin+wtrade+mortage+BLOCKED+secured+repo+netting+dtoclose+withdraw),0)
   into v_Result from semast, cfmast cf, afmast af
   where (codeid=pv_codeid or codeid=v_wftcodeid)
   and cf.custid = af.custid
   and af.acctno = semast.afacctno
   and cf.custodycd like v_custodycd
   ;
   RETURN v_Result;

EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END;
 
/
