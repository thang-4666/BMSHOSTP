SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3379','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3379', 'Danh sách tiểu khoản chờ phân bổ quyền', 'View corporate actions to execute', 'SELECT * FROM V_CA3379 WHERE 0=0', 'CAMAST', '', '', '3379', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;