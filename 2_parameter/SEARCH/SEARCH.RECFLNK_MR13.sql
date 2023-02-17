SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RECFLNK_MR13','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RECFLNK_MR13', 'Quản lý đại lý/môi giới', 'Broker/Remiser management', 'SELECT RF.AUTOID, CF.FULLNAME,
RF.MINDREVAMT+RF.MINIREVAMT MINREVENUE, A0.CDCONTENT DESC_STATUS, RF.CUSTID, RF.AFACCTNO, RF.EFFDATE, RF.EXPDATE
FROM RECFLNK RF, CFMAST CF, ALLCODE A0
WHERE A0.CDTYPE=''RE'' AND A0.CDNAME=''STATUS'' AND A0.CDVAL=RF.STATUS AND RF.CUSTID=CF.CUSTID
AND RF.CUSTID=CF.CUSTID', 'RECFLNK', 'frmRECFLNK', 'FULLNAME', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;