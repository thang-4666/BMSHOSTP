SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFCLOSE_TX','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFCLOSE_TX', 'Thông tin tài khoản lưu ký', 'Customer custody code', 'select * from (SELECT cf.custodycd, cf.fullname, cf.custid, cf.idcode, cf.iddate, cf.idplace, cf.address
   FROM vw_tllog_all lg, afmast af, cfmast cf
   WHERE af.custid = cf.custid AND lg.msgacct = af.acctno
   AND lg.tltxcd = ''0088''
   group by cf.custodycd,cf.fullname, cf.custid,
   cf.idcode, cf.iddate, cf.idplace, cf.address) where 0=0 ', 'CFLINK', 'frmCFMAST', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;