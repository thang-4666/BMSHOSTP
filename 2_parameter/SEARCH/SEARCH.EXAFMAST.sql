SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('EXAFMAST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('EXAFMAST', 'Customize schedule management', 'Customize management', 'SELECT EX.*, AV.EVENTNAME
FROM ( SELECT * FROM EXAFMAST UNION ALL SELECT * FROM EXAFMASTHIST  )EX, APPEVENTS AV WHERE EX.EVENTCODE=AV.EVENTCODE AND EX.MODCODE = AV.MODCODE AND EX.AFACCTNO=''<@KEYVALUE>''', 'EXAFMAST', 'frmEXAFMAST', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;