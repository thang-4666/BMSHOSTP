SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_STRADE_CA_RIGHTOFF
(ABC, AUTOID, CUSTODYCD, FULLNAME, PHONE, 
 AFACCTNO, CAMASTID, SYMBOL, CODEID, TRADE, 
 BALANCE, PBALANCE, QTTY, MAXQTTY, AVLQTTY, 
 SUQTTY, SUAAMT, AAMT, INBALANCE, OUTBALANCE, 
 OPTCODEID, OPTSYMBOL, ISCOREBANK, COREBANK, STATUS, 
 SEACCTNO, OPTSEACCTNO, PARVALUE, REPORTDATE, ACTIONDATE, 
 EXPRICE, EN_DESCRIPTION, DESCRIPTION, CATYPE, CUSTNAME, 
 IDCODE, IDPLACE, IDDATE, ADDRESS, ISSNAME, 
 DUEDATE, BEGINDATE, BALDEFOVD, BANKACCTNO, BANKNAME, 
 SYMBOL_ORG, ISINCODE, CAREBY, ISALLOC, CODEID_ORG)
BEQUEATH DEFINER
AS 
(
SELECT (RECEIVING + getbaldefovd(CI.AFACCTNO))ABC, ca.autoid  ,CF.CUSTODYCD, CF.FULLNAME,CF.MOBILESMS PHONE, CA.AFACCTNO,
SUBSTR(CAMAST.CAMASTID,1,4) || '.' || SUBSTR(CAMAST.CAMASTID,5,6) || '.' || SUBSTR(CAMAST.CAMASTID,11,6) CAMASTID,
SYM.SYMBOL, CAMAST.TOCODEID CODEID, CA.TRADE,CA.balance + CA.pbalance BALANCE, CA.PBALANCE PBALANCE, CA.PQTTY QTTY, CA.PQTTY + CA.QTTY MAXQTTY, CA.PQTTY AVLQTTY, CA.QTTY SUQTTY, CAMAST.EXPRICE*CA.QTTY SUAAMT, CA.PAAMT AAMT, CA.INBALANCE,CA.OUTBALANCE, CAMAST.OPTCODEID, OPTSYM.SYMBOL OPTSYMBOL,
(CASE WHEN CI.COREBANK ='Y' THEN 1 ELSE 0 END) ISCOREBANK, ( CASE WHEN CI.COREBANK ='Y' THEN 'Yes' ELSE 'No' END) COREBANK,
A1.CDCONTENT STATUS, CA.AFACCTNO ||(CASE WHEN CAMAST.ISWFT='Y' THEN (SELECT CODEID FROM SBSECURITIES WHERE REFCODEID =SYM.CODEID ) ELSE CAMAST.TOCODEID END) SEACCTNO, CA.AFACCTNO || CAMAST.OPTCODEID OPTSEACCTNO,
SYM.PARVALUE PARVALUE, CAMAST.REPORTDATE REPORTDATE,-- PhuongHT sua loi lay nham ngay reportdate thanh duedate
 CAMAST.ACTIONDATE, CAMAST.EXPRICE,
--DuongLH 08-07-2011 Bo sung due date vao description
CAMAST.description EN_DESCRIPTION,
camast.DESCRIPTION,
A2.CDCONTENT CATYPE, CF.FULLNAME CUSTNAME, (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
             CF.IDPLACE,  (case when cf.country = '234' then cf.iddate else cf.tradingcodedt end) IDDATE,
             CF.ADDRESS,iss.fullname issname
----KhanhND 25/05/2011: Lay them ngay dang ky quyen mua cuoi cung
,CAMAST.DUEDATE,CAMAST.BEGINDATE
--PhuongHT add 08/08/2011: lay them so du KH
--,greatest(getbaldefovd(CI.AFACCTNO),getbaldefovd(CI.AFACCTNO)) BALDEFOVD
,fn_getBalRightoff(CI.AFACCTNO) BALDEFOVD
--Chaunh 23/04/2012: lay corebank
,AF.BANKACCTNO, AF.BANKNAME, sym_org.symbol SYMBOL_ORG, camast.isincode, cf.careby, CAMAST.isalloc, sym_org.CODEID CODEID_ORG
FROM SBSECURITIES SYM, SBSECURITIES OPTSYM, ALLCODE A1, CAMAST, CASCHD CA, AFMAST AF, CFMAST CF, CIMAST CI, ALLCODE A2, issuers iss,
sbsecurities SYM_ORG
WHERE AF.ACCTNO = CI.ACCTNO AND CA.AFACCTNO = AF.ACCTNO AND AF.CUSTID = CF.CUSTID
AND nvl(CAMAST.TOCODEID,camast.codeid) = SYM.CODEID AND CAMAST.OPTCODEID = OPTSYM.CODEID AND CAMAST.camastid  = CA.camastid
AND CA.status IN( 'V','M') AND CA.status <>'Y' AND CA.DELTD <> 'Y' AND CAMAST.catype='014' AND CA.PBALANCE > 0 AND CA.PQTTY > 0
AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = CA.STATUS
AND CAMAST.CATYPE = A2.CDVAL AND A2.CDTYPE = 'CA' AND A2.CDNAME = 'CATYPE'
and iss.issuerid = sym.issuerid
AND to_date(camast.begindate,'DD/MM/YYYY') <= to_date(GETCURRDATE,'DD/MM/YYYY')
 --AND to_date(camast.duedate,'DD/MM/YYYY') >= to_date(GETCURRDATE,'DD/MM/YYYY')
 AND sym_org.codeid=camast.codeid)
/
