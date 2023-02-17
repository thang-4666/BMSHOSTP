SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SEMARGININFO_OD
(CODEID, OD_QTTY)
BEQUEATH DEFINER
AS 
select od.codeid,
    sum(case when od.exectype = 'NB' then od.remainqtty + od.execqtty
            when od.exectype in ('NS','MS') then - (od.execqtty - nvl(dfexecqtty,0))
            else 0 end) od_qtty
from odmast od, afmast af, aftype aft, lntype lnt, mrtype mrt,
    (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
where od.afacctno = af.acctno
and od.orderid =dfex.orderid(+)
and af.actype = aft.actype
and aft.lntype = lnt.actype
and aft.mrtype = mrt.actype
and mrt.mrtype = 'T'
and (nvl(lnt.chksysctrl,'N') = 'Y'
    or exists (select 1 from afidtype afid, lntype lnt1
                where afid.actype = lnt1.actype and afid.aftype = aft.actype and afid.objname = 'LN.LNTYPE' and lnt1.chksysctrl = 'Y'))
group by od.codeid
/
