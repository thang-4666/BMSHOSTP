SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0088','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0088', 'Tra cứu đóng tiểu khoản', 'View sub-account for closing', '
select CF.CUSTODYCD, CF.FULLNAME, CF.IDCODE, CF.IDDATE, CF.idplace, cf.address, cf.mobilesms phone,
AF.ACCTNO AFACCTNO, aft.TYPENAME, A0.CDCONTENT STATUS, CI.BALANCE, CASE WHEN CF.STATUS =''G'' THEN ''G'' ELSE ''A'' END CLOSESTATUS
from cfmast cf, afmast af, cimast ci, aftype aft,ALLCODE A0
where cf.custid = af.custid and af.actype = aft.actype and af.acctno = ci.acctno
and A0.CDTYPE=''CF'' AND A0.CDNAME=''STATUS'' AND A0.CDVAL=AF.STATUS
and cf.status IN (''A'',''G'') and af.status IN (''A'',''G'')', 'CFLINK', '', '', '0088', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;