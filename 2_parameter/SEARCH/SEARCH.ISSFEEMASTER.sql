SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ISSFEEMASTER','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ISSFEEMASTER', 'Biểu phí', 'Transaction mapping', 'SELECT MST.AUTOID, MST.ISSUERID, MST.FEECD, MT.FEENAME FROM ISSFEEMASTER MST, FEEMASTER MT WHERE MST.FEECD = MT.FEECD AND  MST.ISSUERID=''<$KEYVAL>'' ORDER BY AUTOID', 'SA.ISSFEEMASTER', 'frmISSFEEMASTER', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;