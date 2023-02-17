SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_getstorename( p_afacctno IN VARCHAR2)
    RETURN varchar2 IS
    l_Storetname varchar2(100);
BEGIN
    select max(case when aft.istrfbuy = 'Y' and mrt.mrtype = 'T' then 'AF1012'
            when aft.istrfbuy <> 'Y' and mrt.mrtype = 'T' and cf.custtype = 'I'  then 'AF1010'
            when aft.istrfbuy <> 'Y' and mrt.mrtype = 'T' and cf.custtype = 'I'  then 'AF1016'
            else '' end)
           into l_Storetname
    from cfmast cf, afmast af, aftype aft, mrtype mrt
    where cf.custid = af.custid and af.actype = aft.actype and aft.mrtype = mrt.actype
    and af.acctno = p_afacctno;
    RETURN l_Storetname;
EXCEPTION
   WHEN OTHERS THEN
    RETURN '';
END;

 
 
 
 
 
 
 
 
 
 
 
/
