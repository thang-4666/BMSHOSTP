SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RECMFEE','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RECMFEE', 'Phí giảm trừ', 'Phí giảm trừ', 'SELECT RER.RERFID,RER.RERFTYPE,A1.CDCONTENT FEETYPE,RER.CALTYPE,
A2.CDCONTENT FEECALTYPE,RER.RERFRATE,RER. AFFECTDATE
FROM RERFEE RER,ALLCODE A1,ALLCODE A2
WHERE
RER.RERFTYPE=A1.CDVAL AND A1.CDTYPE=''RE'' AND A1.CDNAME=''RERFTYPE'' AND
RER.CALTYPE=A2.CDVAL AND A2.CDTYPE=''RE'' AND A2.CDNAME=''CALTYPE'' AND
RER.RERFOBJTYPE=''RE.RECFDEF''--La phi giam tru cho loai hinh
AND RER.REFOBJID=''<$KEYVAL>''', 'RE.RERFEE', 'frmRERFEE', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;