SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2237','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2237', 'Gửi hồ sơ giải tỏa cầm cố lên VSD (2237)', 'View pending to Send release mortage (wait for 2237)', 'select se.autoid,tl.BUSDATE,se.txdate, af.acctno afacctno,se.acctno,cf.fullname 
CUSTNAME,cf.custodycd,sb.symbol,sb.parvalue,
    se.qtty,sb.codeid,cf.address,cf.idcode LICENSE
from semortage se, afmast af ,cfmast cf,sbsecurities sb,VW_TLLOG_ALL TL
where substr(se.acctno,1,10)= af.acctno
and SE.TXNUM = TL.TXNUM AND SE.TXDATE = TL.TXDATE
and af.custid= cf.custid AND SE.DELTD<>''Y'' and se.sstatus = ''N''
and substr(se.acctno,11)= sb.codeid and se.status = ''N'' and se.tltxcd = ''2233''', 'SEMAST', '', '', '2237', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;