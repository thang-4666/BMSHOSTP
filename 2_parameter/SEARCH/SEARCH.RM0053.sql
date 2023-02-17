SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM0053','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM0053', 'Danh sách bảng kê hoàn trả tiền cho vay UTTB CK', 'Create request transfer money of advanced payment to bank', '
SELECT LG.TXDATE, MST.OBJKEY, LG.AUTOID, A0.CDCONTENT DESC_STATUS, TLP.TLNAME TLID,  FN_CRB_GETVOUCHERNO(LG.TRFCODE, LG.TXDATE, LG.VERSION) VOUCHERNO,
MST.AFACCTNO, MST.BANKCODE, MST.BANKACCT, MST.TXAMT, CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE LICENSE, RF.*
FROM CFMAST CF, AFMAST AF, CRBTXREQ MST, CRBTRFLOG LG, CRBTRFLOGDTL LGDTL, ALLCODE A0, TLPROFILES TLP,
(SELECT *
FROM   (SELECT DTL.REQID, DTL.FLDNAME, NVL(DTL.CVAL,DTL.NVAL) REFVAL
        FROM   CRBTXREQ MST, CRBTXREQDTL DTL WHERE  MST.REQID=DTL.REQID AND MST.TRFCODE=''TRFADV2BANK'')
PIVOT  (MAX(REFVAL) AS R FOR (FLDNAME) IN  (''ORDATE'' as ORDATE, ''DAYS'' as DAYS))
ORDER BY REQID) RF
WHERE CF.CUSTID=AF.CUSTID AND AF.ACCTNO=MST.AFACCTNO AND MST.REQID=RF.REQID
AND LG.AUTOID = LGDTL.VERSION
AND LGDTL.REFREQID = MST.REQID
AND LG.TRFCODE = ''TRFADV2BANK''
AND A0.CDTYPE=''RM'' AND A0.CDNAME=''TRFLOGSTS'' AND A0.CDVAL=LG.STATUS
AND LG.TLID = TLP.TLID', 'AAAA', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;