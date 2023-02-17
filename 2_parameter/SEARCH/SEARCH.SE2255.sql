SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2255','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2255', 'Gửi hồ sơ chuyển khoản chứng khoán ra ngoài(GD2255)', 'View sending account to outward transfer (wait for 2255)', 'SELECT SEO.*, CF.FULLNAME,CF.CUSTODYCD,AF.ACCTNO AFACCTNO,SEC.SYMBOL, SE.COSTPRICE, tlf.cvalue REFERENCEID
FROM SESENDOUT SEO, CFMAST CF, AFMAST AF, SBSECURITIES SEC,SEMAST SE,
(select * from vw_tllogfld_all where fldcd = ''77'') tlf
WHERE SUBSTR(SEO.ACCTNO,0,10)=AF.ACCTNO
AND AF.CUSTID=CF.CUSTID
AND SEC.CODEID=SEO.CODEID
AND SE.ACCTNO=SEO.ACCTNO
and seo.trade+seo.blocked+seo.caqtty>0
and seo.txnum = tlf.txnum(+) and seo.txdate = tlf.txdate(+)
and NOT EXISTS (select 1 from tllog tl where tl.tltxcd =''2244'' and tl.deltd <> ''Y'' and tl.txstatus =''4'' and txnum = SEO.txnum and txdate = SEO.txdate)
and deltd =''N''', 'SEMAST', 'frmSEMAST', '', '2255', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;