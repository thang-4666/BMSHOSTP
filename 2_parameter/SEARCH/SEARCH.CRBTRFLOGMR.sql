SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CRBTRFLOGMR','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CRBTRFLOGMR', 'Quản lý bảng kê GD ký quỹ', 'List of voucher management', 'SELECT MST.AUTOID, MST.VERSION, MST.TXDATE, MST.AFFECTDATE, MST.REFBANK, MST.CREATETST, MST.SENDTST,
FN_CRB_GETVOUCHERNO(MST.TRFCODE, MST.TXDATE, MST.VERSION) VOUCHERNO,
A0.CDCONTENT DESC_STATUS, A1.CDCONTENT DESC_TRFCODE, ERR.ERRDESC,
DECODE(MST.STATUS,''P'',''Y'',''N'') APRALLOW, DECODE(MST.STATUS,''P'',''Y'',''N'') EDITALLOW
FROM CRBTRFLOG MST, ALLCODE A0, ALLCODE A1,DEFERROR ERR
WHERE A0.CDTYPE=''RM'' AND A0.CDNAME=''TRFLOGSTS'' AND A0.CDVAL=MST.STATUS
AND A1.CDTYPE=''SY'' AND A1.CDNAME=''TRFCODE'' AND A1.CDVAL=MST.TRFCODE
AND MST.TRFCODE IN (''LOANDRAWNDOWN'',''LOANPAYMENT'')
AND MST.ERRCODE=ERR.ERRNUM(+)', 'CRBTRFLOG', 'frmPRINT', '', '', NULL, 50, 'N', 0, 'NYYNYYNNNNY', 'Y', 'T', '', 'N', '', '');COMMIT;