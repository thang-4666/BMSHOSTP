SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETPORTFOLIO"
   (
     PV_REFCURSOR   IN OUT PKG_REPORT.REF_CURSOR,
     pv_CONDVALUE    IN varchar2
   )
   IS
   v_txDate DATE;
BEGIN -- Proc
select to_date(varvalue,'dd/MM/yyyy') into v_txDate from sysvar where upper(varname) = 'CURRDATE' AND GRNAME='SYSTEM';

OPEN PV_REFCURSOR FOR
SELECT   custid, afacctno, symtype, symbol, avlbal, mortage, costprice,
         NVL (avllimit, 0) avllimit, NVL (avlwithdraw, 0) avlwithdraw,CURRPRICE, receiving
    FROM (SELECT mst.custid, dtl.afacctno, 'CI' symtype,
                 instrument.shortcd symbol,
                 dtl.balance - NVL (secureamt, 0) avlbal, 0 mortage,
                 1 costprice,
                   mst.advanceline
                 - nvl(al.overamt,0)
                 - dtl.odamt
                 + dtl.balance
                 - NVL (secureamt, 0) avllimit,
                   dtl.balance
                 - dtl.odamt
                 - NVL (al.advamt, 0)
                 - NVL (secureamt, 0) avlwithdraw,
                 0 CurrPrice,
                 nvl(sts.mamt,0) receiving
            FROM afmast mst,
                 cimast dtl,
                 sbcurrency instrument,
                 (select * from v_getbuyorderinfo where afacctno = pv_CONDVALUE) al,
                 (SELECT STS.AFACCTNO ACCTNO,SUM(AMT-AAMT-FAMT+PAIDAMT+PAIDFEEAMT) MAMT
					FROM STSCHD STS
					WHERE STS.DUETYPE ='RM' AND STS.STATUS ='N' AND STS.DELTD <>'Y'
					GROUP BY STS.AFACCTNO) STS
           WHERE mst.acctno = al.afacctno(+)
             AND mst.acctno = dtl.afacctno
             AND dtl.ccycd = instrument.ccycd
             and mst.acctno = sts.acctno (+)
             AND mst.acctno = pv_CONDVALUE

          UNION ALL
          SELECT mst.custid, dtl.afacctno, 'SE' symtype,
                 instrument.symbol symbol,
                 dtl.trade - NVL (secureamt, 0)+NVL(d.sereceiving,0) avlbal,
                 dtl.mortage - NVL (securemtg, 0) mortage, dtl.costprice,
                 0 avllimit, dtl.trade - NVL (secureamt, 0) avlwithdraw,
                 instrument.CURRPRICE/1000 CURRPRICE,
                 nvl(sts.samt,0) receiving
            FROM afmast mst,
                 semast dtl,
                 securities_info instrument,
                 (SELECT SEACCTNO, SUM(SECUREAMT) SECUREAMT, SUM(SECUREMTG) SECUREMTG, SUM(RECEIVING) SERECEIVING
                FROM (SELECT OD.SEACCTNO,
                        CASE WHEN OD.EXECTYPE IN ('NS', 'SS') AND OD.TXDATE =v_txDate THEN REMAINQTTY + EXECQTTY ELSE 0 END SECUREAMT,
                        CASE WHEN OD.EXECTYPE = 'MS'  AND OD.TXDATE =v_txDate THEN REMAINQTTY + EXECQTTY ELSE 0 END SECUREMTG,
                        CASE WHEN OD.EXECTYPE = 'NB' THEN ST.QTTY ELSE 0 END RECEIVING
                    FROM ODMAST OD, STSCHD ST, ODTYPE TYP
                    WHERE OD.DELTD <> 'Y'  AND OD.EXECTYPE IN ('NS', 'SS','MS', 'NB')
                        AND OD.ORDERID = ST.ORGORDERID(+) AND ST.DUETYPE(+) = 'RS'
                        And OD.ACTYPE = TYP.ACTYPE
                        AND ((TYP.TRANDAY <= (SELECT SUM(CASE WHEN CLDR.HOLIDAY = 'Y' THEN 0 ELSE 1 END)-1
                                            FROM SBCLDR CLDR
                                            WHERE CLDR.CLDRTYPE = '000' AND CLDR.SBDATE >= ST.TXDATE AND CLDR.SBDATE <= v_txDate) AND OD.EXECTYPE = 'NB')
                            OR OD.EXECTYPE IN ('NS','SS','MS'))
                        AND OD.afacctno = pv_CONDVALUE
                        AND OD.txdate = v_txDate)
                    GROUP BY SEACCTNO )d,
                  (SELECT STS.ACCTNO,SUM(QTTY) SAMT
					FROM STSCHD STS
					WHERE STS.DUETYPE ='RS' AND STS.STATUS ='N' AND STS.DELTD <>'Y'
					GROUP BY STS.ACCTNO) sts
           WHERE mst.acctno = dtl.afacctno
             AND dtl.acctno = d.seacctno(+)
             AND dtl.codeid = instrument.codeid
             AND mst.acctno = pv_CONDVALUE
             AND dtl.trade + dtl.mortage <> 0
			 and dtl.acctno = sts.acctno (+) )
ORDER BY custid, afacctno, symtype, symbol;
EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
