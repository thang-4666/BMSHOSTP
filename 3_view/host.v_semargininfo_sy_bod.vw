SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SEMARGININFO_SY_BOD
(CODEID, TRADE, RECEIVING)
BEQUEATH DEFINER
AS 
select se.codeid, sum(se.trade) trade, sum(nvl(se.receiving,0)) receiving
from semast se, afmast af, aftype aft, mrtype mrt
where se.afacctno = af.acctno
and af.actype = aft.actype
and aft.mrtype = mrt.actype
and mrt.mrtype = 'T'
group by se.codeid
/
