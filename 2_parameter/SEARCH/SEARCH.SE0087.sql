SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE0087','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE0087', 'Thông tin số dư tài khoản lưu ký chứng khóan (đối chiếu)', 'Coporate action detail', ' ', 'SEMAST', 'frmSEMAST', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNY', 'Y', 'T', '', 'N', '', '');COMMIT;