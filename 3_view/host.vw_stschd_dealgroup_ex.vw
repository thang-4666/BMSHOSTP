SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STSCHD_DEALGROUP_EX
(AUTOID, AFACCTNO, SEACCTNO, TXDATE, CLEARDAY, 
 CLEARDATE, CODEID, DUETYPE, AMT, AAMT, 
 QTTY, AQTTY, FAMT, PAIDAMT, PAIDFEEAMT, 
 MATCHPRICE)
BEQUEATH DEFINER
AS 
SELECT (to_char(txdate,'DD/MM/YYYY') || afacctno || codeid || to_char(clearday)) autoid, afacctno, acctno seacctno, txdate, clearday,cleardate,codeid, duetype,
sum(amt) amt, sum(aamt) aamt, sum(qtty) qtty, sum(aqtty) aqtty, sum(famt) famt,sum(paidamt) paidamt, sum(paidfeeamt) paidfeeamt , case WHEN SUM(qtty) > 0 THEN round(SUM(amt)/SUM(qtty),0) ELSE 0 END  matchprice
FROM stschd
WHERE status <> 'C' AND deltd <> 'Y' AND duetype = 'RS'  
GROUP BY afacctno, acctno , txdate, clearday,cleardate,codeid, duetype
/
