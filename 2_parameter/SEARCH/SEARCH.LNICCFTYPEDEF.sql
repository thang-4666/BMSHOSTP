SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LNICCFTYPEDEF','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LNICCFTYPEDEF', 'Xu ly tu dong', 'Batch events', 'SELECT TYP.AUTOID, TYP.EVENTCODE, TYP.ACTYPE, APPEVENTS.EVENTNAME FROM ICCFTYPEDEF TYP, APPEVENTS WHERE TYP.EVENTCODE=APPEVENTS.EVENTCODE AND TYP.MODCODE=APPEVENTS.MODCODE AND TYP.MODCODE=''<$MODCODE>'' AND TYP.ACTYPE=''<$KEYVAL>'' ORDER BY TYP.EVENTCODE', 'LN.ICCFTYPEDEF', 'frmICCFTYPEDEF', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;