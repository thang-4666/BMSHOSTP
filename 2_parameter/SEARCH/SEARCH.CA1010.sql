SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA1010','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA1010', 'Đối chiếu cổ phiếu đăng ký nhận do chuyển đổi TP-nhận CP, hoặc tiền', 'Đối chiếu cổ phiếu đăng ký nhận do chuyển đổi TP-nhận CP, hoặc tiền', 'SELECT * FROM (SELECT CF.CUSTODYCD,MAX(CAS.AUTOID) AUTOID,CAS.CAMASTID,
   MAX(CAS.AFACCTNO) AFACCTNO,MAX(A0.CDCONTENT) CATYPE, MAX(CAS.CODEID) CODEID,
   MAX(A0.CDVAL) CATYPEVALUE, CF.FULLNAME,
    DECODE(SUBSTR(CF.CUSTODYCD,4,1),''F'',MAX(CF.TRADINGCODE),CF.IDCODE) IDCODE ,
   DECODE(SUBSTR(CF.CUSTODYCD,4,1),''F'',MAX(CF.TRADINGCODEDT),CF.IDDATE) IDDATE, MAX(CF.IDPLACE) IDPLACE, MAX(CF.ADDRESS) ADDRESS,
   SUM(CAS.TRADE) TRADE,SUM(CAS.PQTTY) PQTTY, SUM(CAS.AMT) AMT, SUM(CAS.AQTTY) AQTTY,
   MAX(CA.REPORTDATE) REPORTDATE,MAX(CA.ACTIONDATE) ACTIONDATE,
   SUM(CAS.AAMT) AAMT, MAX(SYM.SYMBOL) SYMBOL, MAX(A1.CDCONTENT) STATUS, max(ca.isincode) isincode
FROM CASCHD CAS, SBSECURITIES SYM, ALLCODE A0, ALLCODE A1, CAMAST CA, AFMAST AF, CFMAST CF
WHERE A0.CDTYPE = ''CA'' AND A0.CDNAME = ''CATYPE'' AND A0.CDVAL = CA.CATYPE
AND A1.CDTYPE = ''CA'' AND A1.CDNAME = ''CASTATUS'' AND A1.CDVAL = CAS.STATUS
AND CAS.CAMASTID = CA.CAMASTID AND CA.CODEID = SYM.CODEID AND CA.CATYPE IN (''023'')
AND CAS.DELTD =''N'' AND CA.DELTD=''N'' AND CAS.AFACCTNO= AF.ACCTNO
AND AF.CUSTID = CF.CUSTID  GROUP BY CF.CUSTODYCD,CAS.CAMASTID,CF.FULLNAME,CF.IDCODE,CF.IDDATE) WHERE 0=0', 'CASCHD', 'frmCASCHD', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNY', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;