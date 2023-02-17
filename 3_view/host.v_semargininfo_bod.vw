SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SEMARGININFO_BOD
(CODEID, TRADE, RECEIVING)
BEQUEATH DEFINER
AS 
select se.codeid, sum(se.trade) trade, sum(nvl(se.receiving,0)) receiving
from semast se, afmast af, aftype aft, mrtype mrt, lntype lnt
where se.afacctno = af.acctno
and af.actype = aft.actype
and aft.mrtype = mrt.actype
and mrt.mrtype = 'T'
and aft.lntype = lnt.actype(+)
and (   nvl(lnt.chksysctrl,'N') = 'Y'
    or exists (select 1 from afidtype afi, lntype lnt1 where afi.objname = 'LN.LNTYPE' and afi.aftype = af.actype and afi.actype = lnt1.actype and lnt1.chksysctrl='Y'))
group by se.codeid
/
