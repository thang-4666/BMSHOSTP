SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CI1181','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CI1181', 'Tra cứu tài khoản tiền của khách hàng', 'View money of customer', 'Select Cf.custodycd ,cf.fullname,cf.idcode ,
ci.afacctno,af.corebank,ci.balance,ci.receiving,
ci.netting , holdbalance   from cimast ci, cfmast cf  ,
afmast af
where ci.custid= cf.custid
and ci.afacctno = af.acctno', 'BANKINFO', 'CI1180', 'CUSTODYCD, AFACCTNO', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;