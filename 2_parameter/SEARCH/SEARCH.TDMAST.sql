SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('TDMAST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('TDMAST', 'Tài khoản tiết kiệm', 'Term deposit sub-account', 'SELECT MST.ACCTNO,MST.ACTYPE, MST.AFACCTNO, CF.CUSTODYCD, CF.FULLNAME, MST.BALANCE-MST.MORTGAGE AVLWITHDRAW,
MST.ORGAMT, MST.BALANCE, MST.BALANCE + MST.BLOCKAMT CURRBALANCE, MST.MORTGAGE,MST.BLOCKAMT, MST.PRINTPAID, MST.INTNMLACR, MST.INTPAID, MST.TAXRATE, MST.BONUSRATE, MST.INTRATE,
MST.TDTERM, MST.OPNDATE, MST.FRDATE, MST.TODATE, MST.STATUS,
A0.CDCONTENT DESC_TDSRC, A1.CDCONTENT DESC_AUTOPAID, A2.CDCONTENT DESC_BREAKCD, A3.CDCONTENT DESC_SCHDTYPE,
A4.CDCONTENT DESC_TERMCD, A5.CDCONTENT DESC_STATUS,
CF.ADDRESS, CF.IDCODE LICENSE, CF.IDDATE, CF.IDPLACE,A6.CDCONTENT BUYINGPOWER, MST.MAPID, MST.ODAMT,MST.ODINTACR,
FLOOR(MST.BALANCE * MST.ODMAXMORTGAGE/100)- MST.ODAMT AVLMORTGAGE,
MST.ODINTRATE, MST.ODMAXMORTGAGE, FN_GET_TDRATE(MST.ACCTNO) TDRATE
FROM TDMAST MST, AFMAST AF, CFMAST CF, TDTYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A2, ALLCODE A3, ALLCODE A4, ALLCODE A5,ALLCODE A6
WHERE MST.ACTYPE=TYP.ACTYPE AND MST.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND MST.DELTD<>''Y''
AND A0.CDTYPE=''TD'' AND A0.CDNAME=''TDSRC'' AND MST.TDSRC=A0.CDVAL
AND A1.CDTYPE=''SY'' AND A1.CDNAME=''YESNO'' AND MST.AUTOPAID=A1.CDVAL
AND A2.CDTYPE=''SY'' AND A2.CDNAME=''YESNO'' AND MST.BREAKCD=A2.CDVAL
AND A4.CDTYPE=''TD'' AND A4.CDNAME=''TERMCD'' AND MST.TERMCD=A4.CDVAL
AND A5.CDTYPE=''TD'' AND A5.CDNAME=''STATUS'' AND MST.STATUS=A5.CDVAL
AND A3.CDTYPE=''TD'' AND A3.CDNAME=''SCHDTYPE'' AND MST.SCHDTYPE=A3.CDVAL
AND A6.CDTYPE=''SY'' AND A6.CDNAME=''YESNO'' AND MST.BUYINGPOWER=A6.CDVAL', 'TDMAST', 'frmTDMAST', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;