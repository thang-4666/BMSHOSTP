SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETSECMARGININFO_74
(AFACCTNO, SEAMT, SEASS, SEREAL, RECEIVINGAMT)
BEQUEATH DEFINER
AS 
select se.afacctno ,
                    --sum ((trade + receiving - execqtty + buyqtty) * nvl(rsk.mrratioloan,0)/100 * least(sb.MARGINREFPRICE,nvl(rsk.mrpriceloan,0)))
                    --    SEAMT, /*Tai San tinh suc mua*/
                    --sum ((trade + receiving - execqtty + buyqtty) * nvl(rsk.mrratiorate,0)/100 * least(sb.MARGINREFCALLPRICE,nvl(rsk.mrpricerate,0)))
                    --    SEASS,  /*Tai San tinh Rtt*/
                    sum (case when nvl(rsk.mrratioloan,0) * nvl(rsk.mrpriceloan,0) = 0 then 0 else  (trade + receiving - execqtty + buyqtty) * sb.basicprice end)
                        SEAMT, /*Tai San tinh suc mua*/
                    sum (case when nvl(rsk.mrratioloan,0) * nvl(rsk.mrpriceloan,0) = 0 then 0 else  (trade + receiving - execqtty + buyqtty) * sb.basicprice end)
                        SEASS,  /*Tai San tinh Rtt*/
                    sum ((trade + receiving - execqtty + buyqtty) * least(sb.MARGINPRICE,nvl(rsk.mrpricerate,0)))
                        SEREAL,
                    sum(se.MAMT) RECEIVINGAMT
                from
                (select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade , nvl(sts.receiving,0) receiving,nvl(BUYQTTY,0) BUYQTTY,nvl(od.EXECQTTY,0) EXECQTTY, nvl(STS.MAMT,0) mamt
                    from semast se inner join afmast af on se.afacctno =af.acctno
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
                                   --AND od.errod = 'N'
                                   and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                                   AND od.exectype IN ('NS', 'MS','NB','BC')
                                )
                     group by AFACCTNO, CODEID
                     ) OD
                    on OD.afacctno =se.afacctno and OD.codeid =se.codeid
                    left join
                    (SELECT STS.CODEID,STS.AFACCTNO,
                            SUM(CASE WHEN DUETYPE ='RM' THEN AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT-AMT*TYP.DEFFEERATE/100 ELSE 0 END) MAMT,
                            SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                        FROM STSCHD STS, ODMAST OD, ODTYPE TYP,
                        sysvar sy
                        WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                            and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                            AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                            GROUP BY STS.AFACCTNO,STS.CODEID
                     ) sts
                    on sts.afacctno =se.afacctno and sts.codeid=se.codeid
                ) se,
                afserisk74 rsk,
                securities_info sb
                where se.actype =rsk.actype(+) and se.codeid=rsk.codeid(+)
                and se.codeid=sb.codeid
                group by se.afacctno
/
