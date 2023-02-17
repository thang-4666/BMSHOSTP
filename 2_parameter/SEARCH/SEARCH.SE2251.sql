SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2251','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2251', 'Xác nhận cầm cố chứng khoán(2251)', 'View pending to send mortage center (wait for 2251)', 'select se.autoid,tl.BUSDATE,se.txdate, af.acctno afacctno,se.acctno,cf.fullname CUSTNAME,cf.custodycd,sb.symbol,sb.parvalue,se.qtty,sb.codeid,cf.address , cf.idcode  LICENSE,
FEEAMT
from semortage se, afmast af ,cfmast cf,sbsecurities sb,VW_TLLOG_ALL TL
where substr(se.acctno,1,10)= af.acctno
and SE.TXNUM = TL.TXNUM AND SE.TXDATE = TL.TXDATE
and af.custid= cf.custid and se.status=''N'' AND SE.DELTD<>''Y''
and substr(se.acctno,11)= sb.codeid and tl.tltxcd = ''2232'' and se.sendqtty> 0', 'SEMAST', '', '', '2251', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;