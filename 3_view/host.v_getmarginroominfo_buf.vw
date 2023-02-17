SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETMARGINROOMINFO_BUF
(CODEID, MRMAXQTTY, SEQTTY, AFMAXAMT, AFMAXAMTT3)
BEQUEATH DEFINER
AS 
select risk.codeid, least(risk.mrmaxqtty,sb.roomlimit) mrmaxqtty, nvl(sb.roomused,0) + nvl(SEQTTY,0) seqtty, risk.afmaxamt, risk.afmaxamtt3
from
(
select se.codeid ,
                   /* sum (case when nvl(rsk1.mrratioloan,0)/100 * least(sb.MARGINPRICE,nvl(rsk1.mrpriceloan,0)) > 0 then
                            (- execqtty + buyqtty)
                            else 0 end)*/
                          sum  (- execqtty + buyqtty)
                                                    SEQTTY
                from
(SELECT od.AFACCTNO,af.actype, od.CODEID,sum(case when od.exectype IN ('NB','BC')  and od.txdate > (select sbdate from sbcurrdate where sbtype ='B' and numday =-3) then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                    sum (case when od.exectype IN ('NS','MS') and od.txdate =getcurrdate and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY
   FROM odmast od, afmast af,aftype aft, lntype lnt, mrtype mrt,semast se,
       (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
      where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
      --and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
      AND od.deltd <> 'Y'
      and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
      AND od.exectype IN ('NS', 'MS','NB','BC')
      and af.actype =aft.actype
      and aft.lntype = lnt.actype
      and aft.mrtype =mrt.actype
      and se.acctno =od.seacctno
      and mrt.mrtype = 'T' and aft.istrfbuy <> 'Y' and lnt.chksysctrl ='Y' and se.roomchk ='Y'
     group by od.AFACCTNO, od.CODEID, af.actype
 ) se,afserisk rsk1,
    securities_info sb
    where se.actype =rsk1.actype and se.codeid=rsk1.codeid
    and se.codeid=sb.codeid
    group by se.codeid
 ) od
 , securities_risk risk, securities_info sb
where od.codeid(+) = risk.codeid and risk.codeid = sb.codeid
/
