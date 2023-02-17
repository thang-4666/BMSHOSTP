SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SE2291','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SE2291', 'Quản lý tài khoản chờ đóng (2291)', 'Pending to close contract management(2291)', 'Select a.*, nvl(LIMITMAX,0)LIMITMAX ,nvl(USERHAVE,0)USERHAVE from
(SELECT CF.CUSTODYCD, CF.FULLNAME, AF.ACCTNO, AF.STATUS, CF.IDCODE, CI.ACCTNO CIACCTNO
FROM CFMAST CF,  AFMAST  AF, CIMAST CI
WHERE CF.CUSTID = AF.CUSTID
      AND AF.ACCTNO = CI.AFACCTNO
      AND AF.STATUS = ''N''
      AND (SUBSTR(CF.CUSTID,1,4) = DECODE(''<$BRID>'', ''<$HO_BRID>'', SUBSTR(CF.CUSTID,1,4), ''<$BRID>'')
      OR CF.CAREBY IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = ''<$TELLERID>'')))a
LEFT JOIN
(Select NVL(US.ACCTLIMIT,0) LIMITMAX,NVL(US.ALLOCATELIMMIT-US.USEDLIMMIT,0) USERHAVE
from userlimit US where US.tliduser=''<$TELLERID>'') us on 0=0  ', 'SEMAST', '', '', '2291', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;