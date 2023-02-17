SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RM0001','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RM0001', 'Tra cứu các giao dịch CoreBank', 'View corebank Message', '
SELECT A.TXNUM, A.TXDATE,B.TXDESC,C.CDCONTENT BANKNAME ,D.CDCONTENT RMTYPE ,ACCTNO, BANACCTNO,DESACCTNO,TRFTYPE,AMOUNT,E.CDCONTENT STATUS,ERRORCODE,ERRORDESC
FROM AITRANLOG A, TLLOG B, ALLCODE C, ALLCODE D , ALLCODE E
WHERE A.TXNUM=B.TXNUM AND A.TXDATE=B.TXDATE
AND C.CDVAL=A.BANKCODE AND C.CDTYPE=''CF'' AND C.CDNAME=''BANKCODE''
AND D.CDVAL=A.TXCODE AND D.CDTYPE=''SA'' AND D.CDNAME=''RMTXTYPE''
AND E.CDVAL=A.STATUS AND E.CDTYPE=''SA'' AND E.CDNAME=''RMSTATUS''', 'GENERAL', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;