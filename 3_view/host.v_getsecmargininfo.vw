SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETSECMARGININFO
(AFACCTNO, SEAMT, SEASS, RECEIVINGAMT)
BEQUEATH DEFINER
AS 
select se.afacctno ,
                    --sum(least(trade + receiving - execqtty + buyqtty, nvl(lm.afmaxamt, case when se.istrfbuy='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)/(case when sb.basicprice<=0 then 1 else sb.basicprice end))) seqtty,
                    --Phan tai san toi da duoc phep tham gia vao suc mua (Lay min voi ham muc vay toi da / Gia tham chieu)
                    floor(sum (least((trade + receiving - execqtty + buyqtty) * nvl(rsk1.mrratioloan,0)/100 * least(sb.MARGINPRICE,nvl(rsk1.mrpriceloan,0))
                                    ,nvl(lm.afmaxamt, case when se.istrfbuy='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)
                                    )))
                        SEAMT, /*Tai San tinh suc mua*/
                    floor(sum (least((trade + receiving - execqtty + buyqtty) * nvl(rsk1.mrratiorate,0)/100 * least(sb.MARGINCALLPRICE,nvl(rsk1.mrpricerate,0))
                                    ,nvl(lm.afmaxamt, case when se.istrfbuy='N' then rsk.afmaxamt else rsk.afmaxamtt3 end)
                                    )))
                        SEASS,  /*Tai San tinh Rtt*/
                    sum(se.MAMT) RECEIVINGAMT
                from
                (select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade , 
                --nvl(sts.receiving,0) receiving,
                --nvl(BUYQTTY,0) BUYQTTY,nvl(od.EXECQTTY,0) EXECQTTY, 
                se.odreceiving receiving, se.execbuyqtty + nvl(od.BUYQTTY,0) BUYQTTY, --HSX04
                se.execsellqtty + se.execmsqtty EXECQTTY,--HSX04
                nvl(STS.MAMT,0) mamt,aft.istrfbuy
                    from semast se,afmast af ,aftype aft,
                    --HSX04
                    /*(select sum(BUYQTTY) BUYQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
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
                     ) OD,
                    (SELECT STS.CODEID,STS.AFACCTNO,
                            SUM(CASE WHEN DUETYPE ='RM' THEN AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT-AMT*TYP.DEFFEERATE/100 ELSE 0 END) MAMT,
                            SUM(CASE WHEN DUETYPE ='RS' AND STS.TXDATE <> TO_DATE(sy.VARVALUE,'DD/MM/RRRR') THEN QTTY-AQTTY ELSE 0 END) RECEIVING
                        FROM STSCHD STS, ODMAST OD, ODTYPE TYP,
                        sysvar sy
                        WHERE STS.DUETYPE IN ('RM','RS') AND STS.STATUS ='N'
                            and sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE'
                            AND STS.DELTD <>'Y' AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                            GROUP BY STS.AFACCTNO,STS.CODEID
                     ) sts*/
                     (select sum(BUYQTTY) BUYQTTY, sum(buyingqtty) buyingqtty,  AFACCTNO, CODEID
                            from (
                                SELECT AFACCTNO, CODEID, 
                                    (case when od.exectype IN ('NB','BC') then REMAINQTTY- DFQTTY else 0 end) BUYQTTY,
                                    (case when od.exectype IN ('NB','BC') then REMAINQTTY else 0 end) BUYINGQTTY
                                FROM odmast od, afmast af
                                   where od.afacctno = af.acctno
                                   and od.txdate =(select to_date(VARVALUE,'DD/MM/RRRR') from sysvar where grname='SYSTEM' and varname='CURRDATE')
                                   AND od.deltd <> 'Y'
                                   and(od.REMAINQTTY >0 or od.dfqtty >0 )
                                   and not(od.grporder='Y' and od.matchtype='P') --Lenh thoa thuan tong khong tinh vao
                                   AND od.exectype IN ('NB','BC')
                                )
                     group by AFACCTNO, CODEID
                     ) OD,
                    (SELECT STS.CODEID,STS.AFACCTNO,
                            SUM(CASE WHEN DUETYPE ='RM' THEN AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT-AMT*TYP.DEFFEERATE/100 ELSE 0 END) MAMT
                     FROM STSCHD STS, ODMAST OD, ODTYPE TYP
                        WHERE STS.DUETYPE IN ('RM') AND STS.STATUS ='N'
                            AND STS.DELTD <>'Y' 
                            AND STS.ORGORDERID=OD.ORDERID AND OD.ACTYPE =TYP.ACTYPE
                            GROUP BY STS.AFACCTNO,STS.CODEID
                     ) sts
                     --END HSX04
                    where   se.afacctno =af.acctno and af.actype = aft.actype
                            and OD.afacctno(+) =se.afacctno and OD.codeid(+) =se.codeid
                            and sts.afacctno(+) =se.afacctno and sts.codeid(+)=se.codeid
                ) se,
                afserisk rsk1,
                securities_info sb,
                securities_risk rsk, afselimit lm
                where se.actype =rsk1.actype(+) and se.codeid=rsk1.codeid(+)
                and se.codeid = rsk.codeid and se.afacctno = lm.afacctno(+) and se.codeid = lm.codeid(+)
                and se.codeid=sb.codeid
                group by se.afacctno
/
