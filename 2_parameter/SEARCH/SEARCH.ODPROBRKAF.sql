SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ODPROBRKAF','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ODPROBRKAF', 'Danh sách tiểu khoản', 'List of sub-account', 'SELECT RF.AUTOID, RF.REFAUTOID, RF.AFACCTNO, CF.FULLNAME, CF.CUSTODYCD, TYP.TYPENAME, RF.VALDATE, RF.EXPDATE, A1.CDCONTENT STATUS,
   MST.FULLNAME ODPRONAME, MST.AUTOID ODPROID,
   ''N'' EDITALLOW, (CASE WHEN RF.STATUS = ''A'' THEN ''N'' ELSE  ''Y'' END) APRALLOW,
   (CASE WHEN RF.STATUS = ''N'' THEN ''N'' ELSE ''Y'' END) DELALLOW
FROM ODPROBRKAF RF, CFMAST CF, AFMAST AF, AFTYPE TYP, ALLCODE A1, ODPROBRKMST MST
WHERE RF.AFACCTNO=AF.ACCTNO AND AF.CUSTID=CF.CUSTID AND AF.ACTYPE=TYP.ACTYPE
AND A1.CDTYPE = ''SA'' AND A1.CDNAME = ''STATUS'' AND RF.STATUS = A1.CDVAL
AND RF.REFAUTOID = MST.AUTOID
ORDER BY CF.CUSTODYCD, RF.AFACCTNO', 'ODPROBRKAF', 'frmODPROBRKAF', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;