SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETMARGINQUANTITY" (
		PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR
		)
IS
BEGIN
    open PV_REFCURSOR for
	select se.symbol,se.seqtty + nvl(od.seqtty,0) seqtty from
    (select sb.symbol,sum (trade+receiving) seqtty
    from semast se, afmast af, aftype aft, mrtype mrt,sbsecurities sb
	where se.afacctno =af.acctno and af.actype =aft.actype
    and aft.mrtype =mrt.actype and mrt.mrtype in ('S','T')
    and se.codeid=sb.codeid
    group by sb.symbol) se
    left join
   	(select sb.symbol,sum(case when od.exectype in ('NS','MS') then -execqtty when od.exectype in ('NB','BC') then remainqtty + execqtty else 0 end) seqtty
     from odmast od, afmast af, aftype aft, mrtype mrt,sbsecurities sb
	where od.afacctno =af.acctno and af.actype =aft.actype
	AND od.txdate = (select to_date(VARVALUE,'DD/MM/YYYY') from sysvar where grname='SYSTEM' and varname='CURRDATE')
    and aft.mrtype =mrt.actype and mrt.mrtype in ('S','T') and od.deltd <> 'Y'
    and od.codeid=sb.codeid
    group by sb.symbol) od
    on se.symbol= od.symbol;

EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
