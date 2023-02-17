SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STRADE_AVL_ADV_PAYMENT
(AFACCTNO, CUSTODYCD, CURRDATE, DUEDATE, TDAY, 
 ST_AVL_AMT)
BEQUEATH DEFINER
AS 
SELECT ST.AFACCTNO, CF.CUSTODYCD, TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR') CURRDATE, ST.TXDATE DUEDATE,
ST.CLEARDAY-SP_STRADE_GETCLEARDAY(ST.CLEARCD, MAX(SB.TRADEPLACE), ST.TXDATE, TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR')) TDAY,
SUM(ST.AMT-ST.AAMT) ST_AVL_AMT
FROM STSCHD ST, SYSVAR, SBSECURITIES SB, AFMAST AF, CFMAST CF
WHERE SYSVAR.VARNAME='CURRDATE' AND ST.CODEID=SB.CODEID AND ST.STATUS='N' AND ST.DUETYPE='RM' AND ST.AMT-ST.AAMT>0
AND CF.CUSTID = AF.CUSTID AND AF.ACCTNO = ST.AFACCTNO
GROUP BY ST.AFACCTNO, CF.CUSTODYCD, ST.DUETYPE, ST.TXDATE, ST.CLEARCD, ST.CLEARDAY
HAVING ST.CLEARDAY-SP_STRADE_GETCLEARDAY(ST.CLEARCD, MAX(SB.TRADEPLACE), ST.TXDATE, TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR'))>0
/
