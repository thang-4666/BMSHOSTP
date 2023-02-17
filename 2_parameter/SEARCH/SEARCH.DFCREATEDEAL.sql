SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DFCREATEDEAL','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DFCREATEDEAL', 'Danh sách chứng khoán có thể tạo deal', 'List securities to create deal', '
select * from v_getCreateDeal where  afacctno like nvl(''<$AFACCTNO>'',''%'')
and symbol in (select symbol from dfbasket bk, dftype dft where bk.basketid = dft.basketid and dft.actype like nvl(''<@KEYVALUE>'',''%''))
and DTYPE in <$CUSTID>
', 'DFMAST', '', '', '', NULL, 50, 'N', 0, '', 'Y', 'T', '', 'N', '', '');COMMIT;