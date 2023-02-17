SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CF3002','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CF3002', 'Quản lý số điện thoại mở trực tuyến', 'Management online register', 'SELECT reg.reqid, reg.txdate, reg.fullname, reg.mobile, br.brname, a1.cdcontent typeinvest, reg.carename, reg.carebyid
FROM (SELECT reqid, txdate, fullname, mobile, branch, typeinvest, carename, carebyid
      FROM (SELECT ex.*, ROW_NUMBER() OVER (PARTITION BY mobile ORDER BY REQID DESC) RN
          FROM ekyc_cfinfor ex ORDER BY REQID DESC) api
      WHERE RN = 1) reg, registeronline re, brgrp br, allcode a1
WHERE reg.reqid = re.reqid(+) and reg.branch = br.brid
  and reg.typeinvest = a1.cdval and a1.cdtype =''CF'' and a1.cdname =''TYPEINVESTOR''
  --and re.status <> ''A''
  and reg.carebyid IN (SELECT TLGRP.GRPID FROM TLGRPUSERS TLGRP WHERE TLID = ''<$TELLERID>'')', 'ONLINERES', '', 'REQID DESC', '', 0, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;