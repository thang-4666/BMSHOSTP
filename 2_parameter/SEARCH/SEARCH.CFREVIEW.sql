SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CFREVIEW','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CFREVIEW', 'Thông tin kỳ review khách hàng', 'Customer type', 'Select c.autoid, c.frdate, c.todate, A0.cdcontent
status, c.description ,
(CASE WHEN STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW
from cfreview c, ALLCODE A0
where c.status=a0.cdval
 and A0.CDTYPE = ''SY'' AND A0.CDNAME = ''APPRV_STS''', 'CFREVIEW', 'frmTDTYPE', 'autoid', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;