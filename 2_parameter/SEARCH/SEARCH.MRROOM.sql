SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('MRROOM','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('MRROOM', 'Danh sách room margin hệ thống', 'System margin room list', '
select vm.codeid, vm.roomlimit prlimit, sb.symbol, nvl(vp.prinused,0) prinused
from vw_marginroomsystem vm, sbsecurities sb, securities_risk rsk,
(select codeid, sum(prinused) prinused from vw_afpralloc_all where restype = ''M'' group by codeid) vp
where vm.codeid = sb.codeid
and vm.codeid = vp.codeid(+)
and vm.codeid = rsk.codeid(+)
and rsk.ismarginallow = ''Y''
', 'MRROOM', 'CODEID', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;