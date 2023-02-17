SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETMARGINROOMINFO
(CODEID, MRMAXQTTY, SEQTTY, AFMAXAMT, AFMAXAMTT3)
BEQUEATH DEFINER
AS 
select risk.codeid, least(risk.mrmaxqtty,sb.roomlimit) mrmaxqtty, nvl(se.seqtty,0) seqtty, risk.afmaxamt, risk.afmaxamtt3
from
(select se.codeid ,
                  /*  sum (case when nvl(rsk1.mrratioloan,0)/100 * least(sb.MARGINPRICE,nvl(rsk1.mrpriceloan,0)) > 0 then
                            (trade + receiving - execqtty + buyqtty)
                            else 0 end)*/
                   SUM(trade + receiving - execqtty + buyqtty)
                        SEQTTY
                from
                (select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade , nvl(sts.receiving,0) receiving,nvl(BUYQTTY,0) BUYQTTY,nvl(od.EXECQTTY,0) EXECQTTY
                    from semast se
                    inner join afmast af on se.afacctno =af.acctno
                    inner join aftype aft on af.actype =aft.actype
                    inner join lntype lnt on aft.lntype = lnt.actype
                    inner join mrtype mrt on aft.mrtype =mrt.actype
                    left join
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
                     ) OD
                    on OD.afacctno =se.afacctno and OD.codeid =se.codeid
                    left join
                    (SELECT STS.CODEID,STS.AFACCTNO,
                            SUM(CASE WHEN STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                        FROM STSCHD STS, ODMAST OD, ODTYPE TYP, sysvar sy
                        WHERE STS.DUETYPE = 'RS' AND STS.STATUS ='N'
                            and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                            AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                            GROUP BY STS.AFACCTNO,STS.CODEID
                     ) sts
                    on sts.afacctno =se.afacctno and sts.codeid=se.codeid
                    where se.roomchk ='Y' and  mrt.mrtype = 'T' and aft.istrfbuy <> 'Y' and lnt.chksysctrl ='Y' --Chi check voi tai khoan Margin tuan thu theo uy ban
                ) se,
                afserisk rsk1,
                securities_info sb
                where se.actype =rsk1.actype and se.codeid=rsk1.codeid
                and se.codeid=sb.codeid
                group by se.codeid
) se, securities_risk risk, securities_info sb
where se.codeid(+) = risk.codeid and risk.codeid = sb.codeid
/
