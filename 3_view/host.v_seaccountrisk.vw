SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_SEACCOUNTRISK
(FLOORPRICE, MRCRLIMIT, MRCRLIMITMAX, CODEID, AFACCTNO, 
 ACCTNO, TRADE, RECEIVING, MRPRICELOAN, MRRATIOLOAN, 
 MRPRICERATE, MRRATIORATE, BUYQTTY, EXECQTTY, MAMT)
BEQUEATH DEFINER
AS 
(
                select se.floorprice,se.MRCRLIMIT,se.MRCRLIMITMAX,se.codeid,se.afacctno,se.acctno, se.trade, se.receiving,se.mrpriceloan,se.mrratioloan,se.mrpricerate,se.mrratiorate,nvl(BUYQTTY,0) BUYQTTY,nvl(od.EXECQTTY,0) EXECQTTY, nvl(STS.MAMT,0) mamt
                from
                (select se.floorprice,se.MRCRLIMIT,se.MRCRLIMITMAX,se.aftype, se.codeid,se.afacctno,se.acctno, se.trade, se.receiving,nvl(rsk.mrpriceloan,0) mrpriceloan, nvl(rsk.mrratioloan,0) mrratioloan,nvl(rsk.mrpricerate,0) mrpricerate, nvl(rsk.mrratiorate,0) mrratiorate
                    from
                    (select sb.floorprice,af.MRCRLIMIT,af.MRCRLIMITMAX,af.actype aftype, se.codeid,se.afacctno,se.acctno, se.trade, se.receiving
                        from semast se, afmast af,securities_info sb
                    where se.afacctno = af.acctno and se.codeid=sb.codeid
                    ) SE
                    left join
                    afserisk rsk
                    on SE.aftype=rsk.actype and se.codeid= rsk.codeid
                 ) SE
                left join
                (select sum(BUYQTTY) BUYQTTY, sum(EXECQTTY) EXECQTTY , SEACCTNO
                        from (
                            SELECT (case when od.exectype IN ('NB','BC') then (REMAINQTTY + EXECQTTY) else 0 end) BUYQTTY,
                                (case when od.exectype IN ('NS','MS') then (EXECQTTY) else 0 end) EXECQTTY,SEACCTNO
                            FROM odmast od
                             WHERE od.txdate =(SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE')
                               AND od.deltd <> 'Y'
                               AND od.exectype IN ('NS', 'MS','NB','BC')
                            )
                 group by seacctno
                 ) OD
                on OD.seacctno =se.acctno
                left join
                (select codeid,AFACCTNO,SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) MAMT  from stschd sts
                        where DUETYPE='RM' and status ='N'
                        AND DELTD <>'Y'
                        GROUP BY AFACCTNO,codeid
                 ) sts
                on sts.afacctno =se.afacctno and sts.codeid=se.codeid
                )
/
