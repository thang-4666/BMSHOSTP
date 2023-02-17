SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SECURITIES_RATE','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SECURITIES_RATE', 'Tỷ lệ theo bước giá', 'Margin ticksize', 'SELECT TYP.AUTOID, TYP.CODEID, SB.SYMBOL, A0.CDCONTENT STATUS, TYP.FROMPRICE, TYP.TOPRICE, TYP.MRRATIORATE, TYP.MRRATIOLOAN FROM SECURITIES_RATE TYP, SBSECURITIES SB, ALLCODE A0 WHERE SB.CODEID=TYP.CODEID AND A0.CDTYPE=''SY'' AND A0.CDNAME=''YESNO'' AND TYP.STATUS=A0.CDVAL AND TYP.CODEID=''<$KEYVAL>'' ORDER BY SB.SYMBOL', 'SA.SECURITIES_RATE', 'frmSECURITIES_RATE', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;