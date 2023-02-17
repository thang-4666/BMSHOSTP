SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0102','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0102', 'Danh sách quản lý liên kết tài khoản', 'Mapping account management', 'select CF.CUSTID, cf.custodycd, cf.custodycd custodycdtrf, cf.custodycd custodycdpay, d.domainname, d.domaincode, a0.cdcontent vsdstatus, cf.fullname,
       (case when c.vsdstatus = ''C'' then ''DELE'' else ''REGI'' end) ACCLINKTYPE
from cfdomain c, cfmast cf, domain d, allcode a0
where c.custid = cf.custid
      and c.vsdstatus = a0.cdval and a0.cdname = ''CFDOMAINSTS''
      and c.vsdstatus in (''P'',''C'',''F'')
      and cf.nsdstatus in (''C'',''W'')
      and c.domaincode = d.domaincode', 'CF0102', 'frm', 'CUSTODYCD', '0102', 0, 50, 'N', 30, 'NNNNYNYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;