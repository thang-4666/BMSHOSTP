SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LNPRMINMAST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LNPRMINMAST', 'Quản lý chính sách ưu đãi phí magin', 'Quản lý chính sách ưu đãi phí magin', '
select autoid, fullname, a1.cdcontent typeln,''Tính theo phần trăm'' typefee, rate1, rate2, rate3, a2.cdcontent datetype,valday,valdate,expdate, opendate, closedate, a3.cdcontent status,
	(CASE WHEN ln.STATUS IN (''B'',''C'',''N'') THEN ''N'' ELSE ''Y'' END) EDITALLOW,
    (CASE WHEN ln.STATUS = ''P'' THEN ''Y'' ELSE ''N'' END) APRALLOW,
    ''Y'' AS DELALLOW
from LNPRMINMAST ln , allcode a1, allcode a2, allcode a3
where ln.typeln = a1.cdval
and a1.cdname =''LOANTYPE''
and ln.datetype = a2.cdval
and a2.cdname =''DATETYPE''
and a3.cdval = ln.status
and a3.cdname =''APPRV_STS''
and a3.cdtype =''SY'' ', 'LNPRMINMAST', 'frmLNPRMINMAST', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;