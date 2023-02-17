SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('FEEMASTER','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('FEEMASTER', 'Quản lý phí giao dịch', 'Trading fee management', '
SELECT MST.FEECD, MST.FEENAME, A0.CDCONTENT FORP, A1.CDCONTENT STATUS, MST.FEEAMT, MST.FEERATE, MST.MINVAL, MST.MAXVAL, MST.VATRATE,
(CASE WHEN MST.STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW
FROM FEEMASTER MST, ALLCODE A0, ALLCODE A1
WHERE A0.CDTYPE=''SA'' AND A0.CDNAME=''FORP'' AND A0.CDVAL=MST.FORP AND A1.CDTYPE=''SY'' AND A1.CDNAME=''APPRV_STS''
AND A1.CDVAL=MST.STATUS ', 'FEEMASTER', 'frmFEEMASTER', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;