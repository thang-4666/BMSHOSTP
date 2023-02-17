SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2275','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2275', 'Tra cứu gửi hồ sơ nhận chuyển khoản chứng khoán ra ngoài', 'Look up and send documents to transfer securities', '
SELECT re.autoid, re.trftxnum, re.vsdmsgid, re.recustodycd, re.custodycd, re.symbol,
       re.trade, re.blocked, re.vsdmsgdate, re.frbiccode, sb.codeid,
       cf.fullname custname, cf.address, de.fullname frfullname,re.selldaas, re.sellpcod
FROM sereceived re, sbsecurities sb, cfmast cf, deposit_member de
WHERE re.symbol = sb.symbol
  AND re.recustodycd = cf.custodycd
  AND re.frbiccode = de.biccode
  AND re.status = ''P''
', 'SEMAST', '', '', '2275', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;