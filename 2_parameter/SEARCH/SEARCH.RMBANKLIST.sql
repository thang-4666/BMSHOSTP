SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RMBANKLIST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RMBANKLIST', 'Danh sách ngân hàng liên thông', 'Bank information', 'SELECT BANKCODE,BANKNAME,STATUS,DECODE
(STATUS,''A'',''Active'',''I'',''Inactive'',''O'',''Offline'') STTEXT
FROM crbdefbank WHERE 0=0', 'BANKINFO', '', '', '', 0, 100, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;