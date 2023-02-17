SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2256','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2256', 'Gửi hồ sơ giải tỏa cầm cố lên VSD (2256)', 'View pending to Send release mortage (wait for 2256)', 'select se.autoid,se.txDATE busdate,se.txdate, af.acctno afacctno,se.acctno,cf.fullname CUSTNAME,cf.custodycd,sb.symbol,
sb.parvalue,(se.qtty-se.sendqtty-se.released) qtty,sb.codeid,cf.address, cf.idcode LICENSE
from semortage se, afmast af ,cfmast cf,sbsecurities sb
where substr(se.acctno,1,10)= af.acctno
and af.custid= cf.custid AND SE.DELTD<>''Y''
and substr(se.acctno,11)= sb.codeid and se.status = ''N'' and se.tltxcd = ''2233''
and (se.qtty-se.sendqtty-se.released)>0 ', 'SEMAST', '', '', '2256', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;