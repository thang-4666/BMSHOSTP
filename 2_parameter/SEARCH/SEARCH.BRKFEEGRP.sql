SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('BRKFEEGRP','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('BRKFEEGRP', 'Quản lý nhóm chung phí môi giới', 'Group broker fee management', 'SELECT MST.AUTOID, MST.GRPNAME, A1.CDCONTENT STATUS, NOTE
FROM BRKFEEGRP MST, ALLCODE A1
WHERE A1.CDTYPE=''SY'' AND A1.CDNAME=''APPRV_STS'' AND A1.CDVAL=MST.STATUS ', 'BRKFEEGRP', 'frmBRKFEEGRP', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;