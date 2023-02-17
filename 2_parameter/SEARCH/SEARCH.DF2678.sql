SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('DF2678','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('DF2678', 'View giải ngân cho hợp đồng DF', 'View drawndown for deal', '
SELECT v.*, (v.orgamt - v.amt) DRAWNDOWNAMT,
''Giải ngân /'' || dft.typename || ''/'' || dft.actype || ''/'' || v.acctno || ''/'' || v.symbol DESCSEARCH
FROM v_getdealinfo v, dftype dft
WHERE v.actype = dft.actype and amt=0 and v.status =''P''
', 'DFMAST', '', 'ACCTNO DESC', '2678', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;