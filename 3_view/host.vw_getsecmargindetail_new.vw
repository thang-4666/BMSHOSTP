SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GETSECMARGINDETAIL_NEW
(CUSTODYCD, AFACCTNO, ACCTNO, CODEID, SYMBOL, 
 TRADE, RECEIVING, EXECQTTY, BUYQTTY, BUYINGQTTY, 
 MORTAGE, RATECL, PRICECL, CALLRATECL, CALLPRICECL, 
 CALLRATE74, CALLPRICE74, SEAMT, SEASS, SEREAL, 
 MRMAXQTTY, SEQTTY, BASICPRICE, COSTPRICE, CARECEIVING, 
 MORTAGE_NAV, DTOCLOSE, WITHDRAW)
BEQUEATH DEFINER
AS 
select cf.custodycd, af.acctno afacctno, se.acctno, se.codeid, sb.symbol,
    trade, receiving, execqtty, buyqtty,buyingqtty, mortage,
    nvl(rsk.mrratioloan,0) ratecl, nvl(least(sb.MARGINPRICE,nvl(rsk.mrpriceloan,0)),0) pricecl,
    nvl(rsk.mrratiorate,0) callratecl, nvl(least(sb.MARGINCALLPRICE,nvl(rsk.mrpricerate,0)),0) callpricecl,
    nvl(rsk74.mrratiorate,0) callrate74, nvl(least(sb.MARGINREFCALLPRICE,nvl(rsk74.mrpricerate,0)),0) callprice74,
   (trade + receiving - execqtty + buyqtty) * nvl(rsk.mrratioloan,0)/100 * least(sb.MARGINPRICE,nvl(rsk.mrpriceloan,0))
       SEAMT,
   (trade + receiving - execqtty + buyqtty) * nvl(rsk.mrratiorate,0)/100 * least(sb.MARGINCALLPRICE,nvl(rsk.mrpricerate,0))
       SEASS,
   (trade + receiving - execqtty + buyqtty) * nvl(sb.BASICPRICE,0)
       SEREAL,
   nvl(ro.mrmaxqtty,0) mrmaxqtty, nvl(seqtty,0) seqtty,
   nvl(sb.BASICPRICE,0) BASICPRICE, se.COSTPRICE,se.careceiving,se.mortage_nav,se.DTOCLOSE,se.WITHDRAW
                from
                (select se.codeid, af.actype, af.mriratio, se.afacctno,se.acctno, se.trade, se.mortage ,se.COSTPRICE,
                 se.mortage+se.STANDING mortage_nav, se.DTOCLOSE,se.WITHDRAW,
                (se.RECEIVING-(nvl(sts.receiving,0) +nvl(BUYQTTY,0)- nvl(BUYINGQTTY,0))) careceiving, --do cuoi ngay da cong vao receiving lenh mua trong ngay
                nvl(sts.receiving,0) receiving,nvl(BUYQTTY,0) BUYQTTY,nvl(BUYINGQTTY,0) BUYINGQTTY,nvl(od.EXECQTTY,0) EXECQTTY
                    from semast se inner join afmast af on se.afacctno =af.acctno
                    left join
                    (select sum(BUYQTTY) BUYQTTY, sum(BUYINGQTTY) BUYINGQTTY, sum(EXECQTTY) EXECQTTY , AFACCTNO, CODEID
                            from (
                                SELECT (case when od.exectype IN ('NB','BC') then REMAINQTTY + EXECQTTY - DFQTTY else 0 end) BUYQTTY,
                                       (case when od.exectype IN ('NB','BC') then REMAINQTTY else 0 end) BUYINGQTTY,
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
                afserisk rsk,
                afserisk74 rsk74,
                securities_info sb,
                V_GETMARGINROOMINFO ro,
                cfmast cf, afmast af
                where cf.custid = af.custid and af.acctno = se.afacctno
                and se.actype =rsk.actype(+) and se.codeid=rsk.codeid(+)
                and se.actype =rsk74.actype(+) and se.codeid=rsk74.codeid(+)
                and se.codeid=sb.codeid and se.codeid = ro.codeid(+)
                and trade + receiving - execqtty + buyqtty + mortage + careceiving+mortage_nav+DTOCLOSE+WITHDRAW> 0 --ngoc.vu edit them + careceiving+BLOCKED
/
