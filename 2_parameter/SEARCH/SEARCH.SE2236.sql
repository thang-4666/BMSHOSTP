SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2236','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2236', 'Trung tâm lưu ký từ chối hồ sơ cầm cố (2236)', 'View pending to cancel send mortage center (wait for 2236)', 'select se.autoid,tl.BUSDATE,se.txdate, af.acctno afacctno,se.acctno,cf.fullname CUSTNAME,cf.custodycd,sb.symbol,sb.parvalue,
se.sendqtty qtty  ,sb.codeid,cf.address , cf.idcode  LICENSE
from semortage se, afmast af ,cfmast cf,sbsecurities sb,VW_TLLOG_ALL TL
where substr(se.acctno,1,10)= af.acctno
and SE.TXNUM = TL.TXNUM AND SE.TXDATE = TL.TXDATE
and af.custid= cf.custid and se.status=''N'' AND SE.DELTD<>''Y''
and substr(se.acctno,11)= sb.codeid and tl.tltxcd = ''2232'' and se.sendqtty> 0', 'SEMAST', '', '', '2236', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;