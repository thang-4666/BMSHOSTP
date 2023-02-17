SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('ODTYPE','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('ODTYPE', 'Quản lý loại hình lệnh giao dịch', 'Order product type management', 'SELECT ACTYPE, TYPENAME, A8.CDCONTENT SECTYPE,
A03.CDCONTENT APPRV_STS,
A7.CDCONTENT TRADEPLACE, GLGRP, BRATIO,FEERATE,
CLEARDAY,TRADELIMIT,A1.CDCONTENT TIMETYPE,
A2.CDCONTENT NORK, A3.CDCONTENT VIA, A4.CDCONTENT STATUS,
A5.CDCONTENT EXECTYPE,A6.CDCONTENT PRICETYPE, DESCRIPTION,
(CASE WHEN APPRV_STS IN (''D'') THEN ''N'' ELSE ''Y'' END) EDITALLOW, (CASE WHEN APPRV_STS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW,
(CASE WHEN APPRV_STS IN (''D'') THEN ''N'' ELSE ''Y'' END) AS DELALLOW
FROM ODTYPE OD,ALLCODE A1,ALLCODE A2,ALLCODE A3, ALLCODE A4, ALLCODE A03,
ALLCODE A5, ALLCODE A6, ALLCODE A7, ALLCODE A8
WHERE A1.CDTYPE = ''SA'' AND A1.CDNAME = ''TIMETYPE'' AND A1.CDVAL=OD.TIMETYPE
AND A2.CDTYPE = ''SA'' AND A2.CDNAME = ''NORK'' AND A2.CDVAL=OD.NORK
AND A3.CDTYPE = ''OD'' AND A3.CDNAME = ''VIA'' AND A3.CDVAL=VIA
AND A4.CDTYPE = ''SY'' AND A4.CDNAME = ''STATUS'' AND A4.CDVAL=OD.STATUS
AND A5.CDTYPE = ''SA'' AND A5.CDNAME = ''EXECTYPE'' AND A5.CDVAL=OD.EXECTYPE
AND A5.CDTYPE = ''SA'' AND A8.CDNAME = ''SECTYPE'' AND A8.CDVAL=OD.SECTYPE
AND A6.CDTYPE = ''SA'' AND A6.CDNAME = ''PRICETYPE'' AND TRIM(A6.CDVAL)=TRIM(OD.PRICETYPE)
AND A7.CDTYPE = ''OD'' AND A7.CDNAME = ''TRADEPLACE'' AND A7.CDVAL=OD.TRADEPLACE AND 0 = 0
AND A03.CDVAL = OD.APPRV_STS AND A03.CDTYPE = ''SY'' AND A03.CDNAME = ''APPRV_STS''', 'ODTYPE', 'frmODTYPE', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;