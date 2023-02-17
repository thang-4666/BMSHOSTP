SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD9996','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD9996', 'Hiển thị các lệnh thỏa thuận tổng', 'Hiển thị các lệnh thỏa thuận tổng', '
SELECT OD.ORDERID,OD.CODEID, SB.SYMBOL, OD.AFACCTNO,OD.SEACCTNO, OD.TXDATE,
 OD.ORDERQTTY, OD.REMAINQTTY, OD.EXECQTTY, OD.CONTRAFIRM,
OD.TRADERID, OD.CLIENTID FROM ODMAST OD, SBSECURITIES SB WHERE GRPORDER=''Y'' AND DELTD<>''Y''
AND OD.CODEID=SB.CODEID AND OD.REMAINQTTY+OD.EXECQTTY>0
AND OD.ORDERID NOT IN (SELECT VOUCHER FROM ODMAST WHERE MATCHTYPE=''P'' AND DELTD<>''Y'' AND LENGTH(VOUCHER)>=10)
', 'ODMAST', '', '', 'EXEC', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;