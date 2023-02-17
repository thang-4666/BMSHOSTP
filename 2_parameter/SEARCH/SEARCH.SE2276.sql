SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2276','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2276', 'Tra cứu từ chối hồ sơ nhận chuyển khoản chứng khoán ra ngoài', 'Look up and reject the application for securities transfer', '
SELECT re.autoid, re.recustodycd, re.custodycd, re.symbol,
       sb.codeid, re.trade, re.blocked, re.reseacctno,
       cf.fullname custname, SUBSTR(re.reseacctno, 1, 10) reafacctno
FROM sereceived re, sbsecurities sb, cfmast cf, (SELECT * FROM vsdtxreq WHERE objname = ''2275'') req
WHERE re.symbol = sb.symbol
  AND re.recustodycd = cf.custodycd
  AND re.autoid = req.refcode
  AND re.status = ''A''
', 'SEMAST', '', '', '2276', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;