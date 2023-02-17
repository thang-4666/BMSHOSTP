SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_DEALER_POLICY
(SYMBOL, FRDATE, TODATE, TRADER, LEADER, 
 TRADERID, LEADERID, ADMINID, CODEID, GROUPID, 
 MAXNAV, MAXALLBUY, MAXALLSELL, MAXAVLBAL, MINAVLBAL, 
 MAXBPRICE, MINSPRICE, DELTABPRC, DELTASPRC, TOTALQTTY, 
 AVLQTTY, SECOSTPRICE, RFPRICE)
BEQUEATH DEFINER
AS 
select mst.symbol, mst.frdate, mst.todate, mst.trader, mst.leader, mst.traderid, mst.leaderid, mst.adminid,
    mst.codeid, max(mst.groupid) groupid,
    max(mst.maxnav) maxnav, max(mst.maxallbuy) maxallbuy, max(mst.maxallsell) maxallsell,
    max(mst.maxavlbal) maxavlbal, max(mst.minavlbal) minavlbal,
    max(mst.maxbprice) maxbprice, max(mst.minsprice) minsprice,
    max(mst.deltabprc) deltabprc, max(mst.deltasprc) deltasprc,
    max(mst.maxqtty) totalqtty, sum(nvl(dtl.AVLQTTY,0)) avlqtty, max(NVL(DTL.costprice,0)) SEcostprice,  max(mst.basicprice) rfprice
from
(
select sb.symbol, sb.basicprice, sb.ceilingprice, sb.floorprice,
    mst.frdate, mst.todate, trd.tlname trader, ld.tlname leader, lnk.traderid, lnk.leaderid, lnk.adminid, lnk.groupid,
    mst.maxnav, mst.maxallbuy, mst.maxallsell, mst.maxavlbal, mst.minavlbal,
    mst.maxbprice, mst.minsprice, mst.deltabprc, mst.deltasprc,
    lnk.afacctno, mst.maxavlbal maxqtty, lnk.afacctno || sb.codeid seacctno, sb.codeid
from cfaftrdlnk lnk, cftrdpolicy mst, securities_info sb, tlprofiles trd, tlprofiles ld
where not mst.refid is null and mst.levelcd='I' and mst.status='A'
    and mst.refid=sb.codeid and mst.traderid=lnk.traderid
    and lnk.traderid=trd.tlid and lnk.leaderid=ld.tlid
) mst
left join
(
SELECT MST.AFACCTNO, MST.costprice,
    (CASE WHEN INSTR(SYMBOL,'_WFT') > 1 THEN SUBSTR(SYMBOL,1,INSTR(SYMBOL,'_WFT')-1) ELSE SYMBOL END) SYMBOL,
sum((MST.TRADE+mst.receiving+NVL(DF.DEALQTTY,0)+MST.DEPOSIT+MST.SENDDEPOSIT+mst.BLOCKED+nvl(od.EXECQTTY,0))-
(NVL(B.SECUREAMT,0)+MST.WITHDRAW+mst.blockwithdraw)) AVLQTTY
              FROM semast MST, v_getsellorderinfo B, sbsecurities sb, cfaftrdlnk cf,
                   (
                        SELECT DF.CODEID, DF.AFACCTNO,  SUM(DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) DEALQTTY, sum(df.dftrading) dftrading, sum(secured_match) dfsecured_match
                        FROM v_getdealinfo DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO
                    ) DF,
                    (
                        SELECT afacctno || codeid seacctno, SUM (EXECQTTY) EXECQTTY
                        FROM odmast
                        WHERE exectype IN ('NB', 'BC')
                               AND txdate = getcurrdate
                               AND deltd <> 'Y' AND EXECQTTY <> 0
                        GROUP BY afacctno, codeid
                    ) od
              WHERE mst.codeid = sb.codeid
               and mst.afacctno = cf.afacctno
               AND MST.ACCTNO = B.SEACCTNO(+)
               AND sb.SECTYPE<>'004'
               AND MST.AFACCTNO=DF.AFACCTNO (+) AND MST.CODEID=DF.CODEID (+)
               AND mst.acctno = od.seacctno (+)
group by MST.AFACCTNO, MST.costprice,
    (CASE WHEN INSTR(SYMBOL,'_WFT') > 1 THEN SUBSTR(SYMBOL,1,INSTR(SYMBOL,'_WFT')-1) ELSE SYMBOL END)
) dtl
on mst.afacctno=dtl.AFACCTNO and mst.symbol=dtl.symbol
group by mst.symbol, mst.frdate, mst.todate, mst.trader, mst.leader, mst.traderid,
    mst.leaderid, mst.adminid, mst.codeid
/
