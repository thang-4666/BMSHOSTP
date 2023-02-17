SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_BD_PENDING_SETTLEMENT
(AFACCTNO, DUETYPE, CURRDATE, TXDATE, CLEARCD, 
 CLEARDAY, SYMBOL, TDAY, RDAY, NDAY, 
 ST_QTTY, ST_AQTTY, ST_AMT, ST_AAMT, ST_FAMT, 
 EN_DUETYPE_DESC, DUETYPE_DESC, CODEID, FEEACR, TRFDAY, 
 EXECAMTINDAY, ST_PAIDAMT, ST_PAIDFEEAMT, TAXSELLAMT)
BEQUEATH DEFINER
AS 
SELECT ST.AFACCTNO, ST.DUETYPE, TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR') CURRDATE, ST.TXDATE, ST.CLEARCD, ST.CLEARDAY, SB.SYMBOL,
    --PhuNh: TDAY la ngay mua , khong phai ngay ve
    SP_BD_GETCLEARDAY(ST.CLEARCD, MAX(SB.TRADEPLACE), ST.TXDATE, TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR')) TDAY,
    --PhuongHT: RDAY: ngay CK ve
    SP_BD_GETCLEARDAY(ST.CLEARCD, MAX(SB.TRADEPLACE), TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR'),Max(ST.CLEARDATE) ) RDAY,
    --ST.CLEARDAY-SP_BD_GETCLEARDAY(ST.CLEARCD, MAX(SB.TRADEPLACE), ST.TXDATE, TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR')) TDAY,
    MAX(st.cleardate)-TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR') NDAY,
    SUM(ST.QTTY) ST_QTTY, SUM(ST.AQTTY) ST_AQTTY, SUM(ST.AMT) ST_AMT, SUM(ST.AAMT) ST_AAMT, SUM(ST.FAMT) ST_FAMT,
    MAX(CD1.CDCONTENT) EN_DUETYPE_DESC, MAX(CD1.CDCONTENT) DUETYPE_DESC, MAX(ST.CODEID) CODEID,
    SUM(CASE WHEN OD.FEEACR >0 THEN OD.FEEACR ELSE OD.EXECAMT * (OD.BRATIO -100)/100 END) FEEACR,
    SP_BD_GETCLEARDAY(ST.CLEARCD, MAX(SB.TRADEPLACE), TO_DATE(MAX(SYSVAR.VARVALUE),'DD/MM/RRRR'),max(ST.cleardate)) TRFDAY,
    SUM(CASE WHEN ST.TXDATE = TO_DATE(SYSVAR.VARVALUE,'DD/MM/RRRR') THEN ST.AMT ELSE 0 END) EXECAMTINDAY,
    SUM(ST.paidamt) ST_PAIDAMT, SUM(ST.paidfeeamt) ST_PAIDFEEAMT,
    SUM(CASE WHEN OD.TAXSELLAMT >0 THEN OD.TAXSELLAMT
            WHEN INSTR(OD.EXECTYPE,'S') >0 AND OD.EXECAMT >0 THEN OD.EXECAMT* (DECODE (CF.VAT,'Y',TO_NUMBER(SYS1.VARVALUE),'N',0 )+DECODE (CF.WHTAX,'Y',TO_NUMBER(SYS2.VARVALUE),'N',0 ) ) /100 ELSE 0 END) TAXSELLAMT
FROM STSCHD ST, SYSVAR, SBSECURITIES SB, ALLCODE CD1, CFMAST CF, AFMAST AF, ODMAST OD, SYSVAR SYS1 , SYSVAR SYS2
WHERE SYSVAR.VARNAME='CURRDATE' AND ST.CODEID=SB.CODEID
    AND CF.CUSTID=AF.CUSTID AND AF.ACCTNO=ST.AFACCTNO
    AND OD.ORDERID = ST.ORGORDERID
    and cf.custatcom='Y' AND ST.status = 'N' AND st.deltd = 'N'
    AND CD1.CDTYPE='OD' AND CD1.CDNAME='DUETYPE' AND ST.DUETYPE=CD1.CDVAL
    and sys1.varname = 'ADVSELLDUTY' and sys1.grname = 'SYSTEM'
    and SYS2.varname = 'WHTAX' and SYS2.grname = 'SYSTEM'
    --AND OD.errod = 'N'
GROUP BY ST.AFACCTNO, ST.DUETYPE, ST.TXDATE, ST.CLEARCD, ST.CLEARDAY, SB.SYMBOL
/
