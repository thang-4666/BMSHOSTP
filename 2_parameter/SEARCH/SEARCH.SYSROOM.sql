SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SYSROOM','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SYSROOM', 'Tra cứu Room CK hệ thống', 'Pool/Room Master', '
select sb.codeid, sb.symbol, rm.syroomlimit prlimit, nvl(afpr.prinused,0) + sb.syroomused prinused,
sb.syroomlimit, sb.syroomused,
nvl(afpr.prinused,0) markedqtty,
rm.syroomlimit - sb.syroomused - nvl(afpr.prinused,0) PRAVLLIMIT, ''S'' roomtype
from vw_marginroomsystem rm, securities_info sb,
       (select codeid, sum(prinused) prinused from vw_afpralloc_all where restype = ''S'' group by codeid) afpr
where rm.codeid = afpr.codeid(+) and rm.codeid = sb.codeid', 'SYSROOM', '', '', '0104', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;