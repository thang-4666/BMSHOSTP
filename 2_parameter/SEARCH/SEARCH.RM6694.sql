SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM6694','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM6694', 'Sửa danh sách tài khoản (6694)', 'Sửa danh sách tài khoản (6694)', 'SELECT AUTOID,TRFCODE,REFDORC,REFUNHOLD,REFBANK,REFACCTNO,REFACCTNAME,MSGID FROM CRBDEFACCT', 'CRBTRFLOG', '', '', '6694', 0, 250, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;