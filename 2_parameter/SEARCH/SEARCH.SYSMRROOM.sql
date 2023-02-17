SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SYSMRROOM','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SYSMRROOM', 'Tra cứu Room CK margin (theo UBCK)', 'Pool/Room Master', 'select sb.codeid, sb.symbol, rm.roomlimit prlimit, nvl(afpr.prinused,0) prinused,
rm.roomlimit - nvl(afpr.prinused,0) pravllimit, sb.roomlimit, sb.roomlimitmax, sb.listingqtty,
nvl(afpr.prinused,0) markedqtty, c1.cdcontent ismarginallow, ''M'' roomtype
from vw_marginroomsystem rm, securities_info sb,
       (select codeid, sum(prinused) prinused from vw_afpralloc_all where restype = ''M'' group by codeid) afpr,
             securities_risk prallow,
             allcode c1
where rm.codeid = afpr.codeid(+) and rm.codeid = sb.codeid and rm.codeid = prallow.codeid(+) and nvl(prallow.ismarginallow,''N'') = ''Y''
and c1.cdname = ''YESNO'' and c1.cdtype = ''SY'' and c1.cdval = nvl(prallow.ismarginallow,''N'')', 'SYSMRROOM', '', '', '0104', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;