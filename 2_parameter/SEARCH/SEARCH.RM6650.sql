SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM6650','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM6650', 'Thông báo đăng ký mã chứng khoán mới', 'Notice of new stock code registration', 'SELECT nt.trfcode , vsd.description , nt.vsdmsgdate,CASE WHEN nt.trade = 0 THEN ''Đăng ký mã mới'' ELSE ''Đăng ký TH quyền'' END typemt,
nt.symbol, nt.isincode, a.cdcontent tradeplace, nt.trade
FROM newstockregister nt, vsdtrfcode vsd ,(SELECT * FROM allcode WHERE cdname =''TRADEPLACE'' AND cdtype =''SE'' )a
WHERE nt.deltd <> ''Y''
AND nt.trfcode = vsd.trfcode
AND nt.tradeplace = a.cdval (+)', 'CAMAST', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;