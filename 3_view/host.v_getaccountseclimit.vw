SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETACCOUNTSECLIMIT
(CODEID, AFACCTNO, SEQTTY, SEAMT)
BEQUEATH DEFINER
AS 
(
select se.codeid, se.afacctno,
       se.trade+nvl(sts.receiving,0)+nvl(od.BUYQTTY,0) - nvl(od.EXECQTTY,0) seqtty,
       (se.trade+nvl(sts.receiving,0)+nvl(od.BUYQTTY,0) - nvl(od.EXECQTTY,0)) * inf.basicprice seamt
from semast se, securities_info inf,
    (select sum(BUYQTTY) BUYQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
            from (
                SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                        (case when od.exectype IN ('NS','MS') and od.stsstatus <> 'C' then EXECQTTY - nvl(dfexecqtty,0) else 0 end) EXECQTTY,AFACCTNO, CODEID
                FROM odmast od, afmast af,
                    (select orderid, sum(execqtty) dfexecqtty from odmapext where type = 'D' group by orderid) dfex
                   where od.afacctno = af.acctno and od.orderid = dfex.orderid(+)
                   and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                   AND od.deltd <> 'Y'
                   and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                   AND od.exectype IN ('NS', 'MS','NB','BC')
                )
     group by AFACCTNO, CODEID
     ) OD,
    (SELECT STS.CODEID,STS.AFACCTNO,
           SUM(CASE WHEN STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
       FROM STSCHD STS, ODMAST OD, ODTYPE TYP, sysvar sy
       WHERE STS.DUETYPE = 'RS' AND STS.STATUS ='N'
           and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
           AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
           GROUP BY STS.AFACCTNO,STS.CODEID
    ) sts
where se.codeid = inf.codeid
    and sts.afacctno(+) =se.afacctno and sts.codeid(+)=se.codeid
    and OD.afacctno(+) =se.afacctno and OD.codeid(+) =se.codeid
)
/
