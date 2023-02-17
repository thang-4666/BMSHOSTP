SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_TRADER_POLICY_GETALL_BK
(SYMBOL, FRDATE, TODATE, TRADER, LEADER, 
 TRADERID, LEADERID, ADMINID, CODEID, TOTALQTTY, 
 AVLQTTY, MAXNAV, MAXALLBUY, MAXALLSELL, MAXAVLBAL, 
 MINAVLBAL, MAXBPRICE, MINSPRICE, DELTABPRC, DELTASPRC, 
 BUYAMT, SELLAMT, AVLBUYAMT, AVLSELLAMT)
BEQUEATH DEFINER
AS 
SELECT mst.SYMBOL, mst.FRDATE, mst.TODATE, mst.TRADER, mst.LEADER, mst.TRADERID, mst.LEADERID, mst.ADMINID,
                          mst.CODEID, mst.TOTALQTTY, mst.AVLQTTY,
                          mst.MAXNAV, mst.MAXALLBUY, mst.MAXALLSELL, mst.MAXAVLBAL, mst.MINAVLBAL, mst.MAXBPRICE, mst.MINSPRICE,
                          mst.DELTABPRC, mst.DELTASPRC , sum(nvl(od.BUYAMT,0))  BUYAMT, sum(nvl(od.SELLAMT,0))  SELLAMT,
                          mst.MAXALLBUY - sum(nvl(od.BUYAMT,0))  AVLBUYAMT, mst.MAXALLSELL - sum(nvl(od.SELLAMT,0))  AVLSELLAMT
          FROM VW_DEALER_POLICY MST
          LEFT JOIN
                          (
                                            SELECT SUM(BUYAMT) BUYAMT, SUM(SELLAMT) SELLAMT,
                                                                          ODWK.TXDATE, ODWK.codeid
                                            FROM (
                                            SELECT DECODE(OD.EXECTYPE,'NB',OD.EXECAMT,0) BUYAMT, DECODE(OD.EXECTYPE,'NS',OD.EXECAMT,0) SELLAMT,
                                                                          OD.TXDATE, OD.codeid
                                            FROM ODMAST OD, CFAFTRDLNK AF
                                            WHERE OD.AFACCTNO=AF.AFACCTNO ---AND AF.TRADERID = :TELLERID OR AF.LEADERID = :LEADERID OR AF.ADMINID = :ADMINID
                                                AND OD.EXECQTTY>0
                                            UNION ALL
                                            SELECT DECODE(OD.EXECTYPE,'NB',OD.EXECAMT,0) BUYAMT, DECODE(OD.EXECTYPE,'NS',OD.EXECAMT,0) SELLAMT,
                                                                          OD.TXDATE, OD.codeid
                                            FROM ODMASTHIST OD, CFAFTRDLNK AF, SYSVAR
                                            WHERE OD.AFACCTNO=AF.AFACCTNO ---AND AF.TRADERID = :TELLERID OR AF.LEADERID = :LEADERID OR AF.ADMINID = :ADMINID
                                                          AND OD.EXECQTTY>0
                                            AND SYSVAR.VARNAME='CURRDATE'
                                            ) ODWK
                                            GROUP BY ODWK.TXDATE, ODWK.codeid
                          ) OD
          ON OD.TXDATE > MST.frdate AND OD.TXDATE <= MST.todate
                          AND MST.codeid = OD.codeid
----          WHERE TRADERID = :TELLERID OR LEADERID = :LEADERID OR ADMINID = :ADMINID
          group by mst.SYMBOL, mst.FRDATE, mst.TODATE, mst.TRADER, mst.LEADER, mst.TRADERID, mst.LEADERID, mst.ADMINID,
                          mst.CODEID, mst.TOTALQTTY, mst.AVLQTTY,
                          mst.MAXNAV, mst.MAXALLBUY, mst.MAXALLSELL, mst.MAXAVLBAL, mst.MINAVLBAL, mst.MAXBPRICE, mst.MINSPRICE,
                          mst.DELTABPRC, mst.DELTASPRC
/
