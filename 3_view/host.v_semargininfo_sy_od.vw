SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SEMARGININFO_SY_OD
(CODEID, OD_QTTY)
BEQUEATH DEFINER
AS 
select od.codeid,
    sum(case when od.exectype = 'NB' then od.remainqtty + od.execqtty
            when od.exectype in ('NS','MS') then - (od.execqtty - nvl(dfex.dfexecqtty,0))
            else 0 end) od_qtty
from odmast od, afmast af, aftype aft, mrtype mrt,
    (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
where od.afacctno = af.acctno
and od.orderid = dfex.orderid(+)
and af.actype = aft.actype
and aft.mrtype = mrt.actype
and mrt.mrtype = 'T'
group by od.codeid
/
