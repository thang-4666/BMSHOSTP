SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('OD8830','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('OD8830', 'Chuyển chứng khoán chơ về từ thường sang magin', 'Chuyển chứng khoán chơ về từ thường sang magin', 'SELECT  cf.custodycd,cf.custid, af.acctno afacctno,cf.fullname, cf.idcode,sts.amt MATCHAMT, sts.qtty MATCHQTTY, sts.txdate,sts1.cleardate,
sb.symbol ,od.orderid,sts.codeid,od.ORDERQTTY,od.QUOTEPRICE,STS1.ACCTNO SEACCTNO
FROM stschd sts, stschd sts1,afmast af, cfmast cf,sbsecurities sb,
     odmast od , aftype aft,mrtype mr
where sts.orgorderid = sts1.orgorderid
and sts.afacctno = af.acctno
and af.custid = cf.custid
and sts.codeid = sb.codeid
and af.actype = aft.actype
and aft.mrtype = mr.actype
AND sts.duetype=''SM'' AND sts.deltd<>''Y'' AND STS.STATUS =''C''
AND sts1.duetype=''RS'' AND sts1.deltd<>''Y'' AND STS1.STATUS =''N''
and mr.mrtype = ''N''
and od.orderid = sts.orgorderid', 'ODMAST', '', 'TXDATE DESC, CUSTODYCD, SYMBOL, ORDERID', '8830', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTID');COMMIT;