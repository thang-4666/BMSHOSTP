SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('V_CRBTRFACCTSRC','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('V_CRBTRFACCTSRC', 'Quản lý tài khoản nguồn ngân hàng', 'List of source bank account information', 'SELECT SRC.AUTOID,SRC.BANKCODE,CRB.BANKCODE || '':'' || CRB.BANKNAME BANKNAME,
SRC.BANKACCTNO,SRC.BANKACCTNAME
FROM CRBTRFACCTSRC SRC,CRBDEFBANK CRB
WHERE SRC.BANKCODE=CRB.BANKCODE', 'CRBTRFACCTSRC', 'CRBTRFACCTSRC', '', '', 0, 50, 'N', 0, 'NNNNNNNNNNN', 'Y', 'T', '', 'N', '', '');COMMIT;