SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ICCFTIER','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ICCFTIER', 'Tham số bậc thang', 'Tier definition', 'SELECT DTL.AUTOID, DTL.MODCODE, DTL.EVENTCODE, DTL.ACTYPE, DTL.FRAMT, DTL.TOAMT, DTL.DELTA, APPEVENTS.EVENTNAME FROM ICCFTYPEDEF TYP, ICCFTIER DTL, APPEVENTS WHERE TYP.EVENTCODE=DTL.EVENTCODE AND TYP.MODCODE=DTL.MODCODE AND TYP.ACTYPE=DTL.ACTYPE AND APPEVENTS.MODCODE=TYP.MODCODE AND APPEVENTS.EVENTCODE=TYP.EVENTCODE AND TYP.AUTOID=''<$KEYVAL>'' ORDER BY DTL.MODCODE, DTL.EVENTCODE', 'SA.ICCFTIER', 'frmICCFTIER', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;