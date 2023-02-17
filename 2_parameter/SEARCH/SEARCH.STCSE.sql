SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('STCSE','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('STCSE', 'Quản lý thông tin chứng khoán', 'Securities information management', 'SELECT AUTOID,PRICETYPE,TRADELOT,QTTYMIN,TRADEUNIT,QTTYMAX,STCNAME,PARVALUE,FOREIGNRATE,CLEARDAY,FROMTIME,TOTIME,A0.CDCONTENT TRADEPLACE,
A1.CDCONTENT SECTYPE,A2.CDCONTENT NORP,A3.CDCONTENT CLEARCD,A4.CDCONTENT STATUS,A5.CDCONTENT EXECTYPE FROM STCSE,ALLCODE A0,ALLCODE A1,ALLCODE A2,ALLCODE A3,ALLCODE A4,ALLCODE A5
WHERE A0.CDTYPE =''SA'' AND A0.CDNAME = ''TRADEPLACE'' AND A0.cdval = TRADEPLACE
AND A1.CDTYPE =''SA'' AND A1.CDNAME = ''SECTYPE'' AND A1.cdval = SECTYPE
AND A2.CDTYPE =''OD'' AND A2.CDNAME = ''NORP'' AND A2.cdval = NORP
AND A4.CDTYPE =''SY'' AND A4.CDNAME = ''YESNO'' AND A4.cdval = STATUS
AND A5.CDTYPE =''OD'' AND A5.CDNAME = ''EXECTYPE'' AND A5.cdval = EXECTYPE
AND A3.CDTYPE =''OD'' AND A3.CDNAME = ''CLEARCD'' AND A3.cdval = CLEARCD', 'STCSE', 'frmSTCSE', 'STCNAME', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;