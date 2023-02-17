SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI1195','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI1195', 'Đồng bộ giao dịch báo có từ ngân hàng - import excel', 'Sync credit file', '
SELECT autoid, c.custodycd, acctno,cf.fullname,b.glaccount, c.amt, c.description, c.refnum, c.txdate, c.status, c.errordesc,
b.bankacctno, c.fileid,cf.idcode, cf.idplace, cf.iddate, cf.address, c.deltd,b.glaccount glmast, c.bankid
FROM tblcashdeposit c, cfmast cf, banknostro b
WHERE c.custodycd = cf.custodycd(+) AND c.bankid = b.shortname(+) AND c.tltxcd = ''1195''
', 'CIMAST', '', '', '1195', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;