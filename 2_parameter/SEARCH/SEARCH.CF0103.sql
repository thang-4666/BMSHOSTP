SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF0103','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF0103', 'Danh sách các liên kết tài khoản cần xác nhận', 'List of mapping request', 'select cf.custodycd, cf.custodycd custodycdtrf, cf.custodycd custodycdpay, d.domainname, d.domaincode, a0.cdcontent vsdstatus, cf.fullname,
       (case when c.vsdstatus = ''A'' then ''REGI'' else ''DELE'' end) ACCLINKTYPE
from cfdomain c, cfmast cf, domain d, allcode a0
where c.custid = cf.custid
      and c.vsdstatus = a0.cdval and a0.cdname = ''CFDOMAINSTS''
      and c.vsdstatus in (''A'',''U'')
      and c.domaincode = d.domaincode', 'CF0103', 'frm', 'CUSTODYCD', '0103', 0, 50, 'N', 30, 'NNNNYNYNNN', 'Y', 'T', 'CUSTODYCD', 'N', '', '');COMMIT;