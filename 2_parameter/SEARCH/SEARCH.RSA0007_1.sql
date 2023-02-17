SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('RSA0007_1','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('RSA0007_1', 'Danh sách chi nhánh/ Nhóm KH/ NSD', 'Branch/Groups/User list', 'SELECT * FROM
(SELECT ''Branch'' objtype, ''B'' || br.brid objid, br.brname objname
FROM brgrp br
UNION ALL
SELECT ''Group'' objtype, ''G'' || tlg.grpid objid, tlg.grpname objname
FROM tlgroups tlg WHERE TLG.GRPTYPE=''2''
UNION ALL
SELECT ''User'' objtype, ''U'' || tl.tlid objid, tl.tlname objname
FROM tlprofiles tl) A
WHERE 0 = 0 ', 'TLGROUPS', 'frmTLGROUPS', 'OBJTYPE, OBJID', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;