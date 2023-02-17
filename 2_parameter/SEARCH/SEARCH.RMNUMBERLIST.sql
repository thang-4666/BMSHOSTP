SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RMNUMBERLIST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RMNUMBERLIST', 'Danh sách số hiệu bản kê ', 'Bank information', 'SELECT MST.AUTOID, MST.VERSION,MST.VERSIONLOCAL, MST.TXDATE, MST.AFFECTDATE,
MST.REFBANK||'':''||A2.CDCONTENT REFBANK,MST.TRFCODE, MST.CREATETST, MST.SENDTST,
FN_CRB_GETVOUCHERNO(MST.TRFCODE, MST.TXDATE, MST.VERSION) VOUCHERNO,DTL.AMT,DTL.CRDATE,
A0.CDCONTENT DESC_STATUS, A1.CDCONTENT DESC_TRFCODE, ERR.ERRDESC,
DECODE(MST.STATUS,''P'',''Y'',''N'') APRALLOW, DECODE(MST.STATUS,''P'',''Y'',''N'') EDITALLOW
FROM CRBTRFLOG MST, ALLCODE A0, ALLCODE A1,DEFERROR ERR,CRBDEFACCT CRA,ALLCODE A2,
(
    SELECT DTL.BANKCODE,DTL.VERSION,DTL.TRFCODE,DTL.TXDATE,MAX(REQ.TXDATE) CRDATE,SUM(DTL.AMT) AMT
    FROM CRBTRFLOGDTL DTL,CRBTXREQ REQ
    WHERE DTL.REFREQID=REQ.REQID
    GROUP BY DTL.BANKCODE,DTL.VERSION,DTL.TRFCODE,DTL.TXDATE
) DTL
WHERE A0.CDTYPE=''RM'' AND A0.CDNAME=''TRFLOGSTS'' AND A0.CDVAL=MST.STATUS
AND A1.CDTYPE=''SY'' AND A1.CDNAME=''TRFCODE'' AND A1.CDVAL=MST.TRFCODE
AND MST.REFBANK=A2.CDVAL AND A2.CDNAME=''BANKNAME'' AND A2.CDTYPE=''CF''
AND MST.TRFCODE=CRA.TRFCODE
AND MST.REFBANK=CRA.REFBANK AND cspks_rmproc.is_number(CRA.MSGID)=1
AND MST.REFBANK=DTL.BANKCODE AND MST.TRFCODE=DTL.TRFCODE AND MST.TXDATE=DTL.TXDATE
AND MST.VERSION=DTL.VERSION AND MST.ERRCODE=ERR.ERRNUM(+)', 'BANKINFO', '', '', '', 0, 100, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;