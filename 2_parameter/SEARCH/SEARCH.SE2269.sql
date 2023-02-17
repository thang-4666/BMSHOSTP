SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2269','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2269', 'Chuyển chứng khoán giao dịch thành chờ giao dịch (Giao dịch 2269)', 'View account transfer to other account(wait for 2269)', 'select sb.parvalue, SE.COSTPRICE PRICE , CF.CUSTODYCD,CF.CUSTID, af.acctno AFACCTNO,SB.CODEID,
 cf.fullname custname,cf.idcode LICENSE,cf.address,sb.symbol,se.STATUS,AF.ACCTNO||sbwft.CODEID SEACCTNOCR,AF.ACCTNO||sb.CODEID SEACCTNODR,
se.TRADE TRADE , se.TRADE TRADE2,
  se.MORTAGE+ se.STANDING MORTAGE,se.MARGIN ,se.NETTING,
 se.STANDING,se.WITHDRAW,se.DEPOSIT,se.LOAN,se.WITHDRAW WITHDRAW2,
 se.BLOCKED, se.BLOCKED BLOCKED2,se.emkqtty , se.emkqtty emkqtty2,
 se.blockwithdraw,  se.blockwithdraw blockwithdraw2,
 se.blockdtoclose, se.blockdtoclose blockdtoclose2,
 se.RECEIVING,se.TRANSFER,se.SENDDEPOSIT,
 se.SENDPENDING,se.DTOCLOSE,se.SDTOCLOSE
 from semast se , afmast af , cfmast cf, sbsecurities sb ,sbsecurities sbwft, SECURITIES_INFO SEINFO
where se.afacctno = af.acctno and af.custid = cf.custid and sb.codeid = seinfo.codeid
and se.codeid = sb.codeid and sb.codeid=sbwft.refcodeid
and sbwft.tradeplace=''006''
', 'SEMAST', 'frmSEMAST', '', '2269', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;