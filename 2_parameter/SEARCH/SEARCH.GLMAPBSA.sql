SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('GLMAPBSA','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('GLMAPBSA', 'Map kế toán ngoại bảng', 'Securities basket', 'select e.autoid,
       e.notes,
       e.brdebitacct,
       e.brcreditacct,
       a1.cdcontent typefield,
       a2.cdcontent  GLTYPESUBCD,
       a.cdcontent status,
       (CASE
         WHEN e.STATUS IN (''P'' ) THEN
          ''Y''
         ELSE
          ''N''
       END) APRALLOW,
       ''Y'' DELALLOW
  from GLMAPBSA  e,allcode a,  allcode a1,allcode a2
 where NVL(e.status,''P'') = a.cdval
   and a.CDTYPE = ''SA''
   AND a.CDNAME = ''STATUS''
   and a1.cdval = e.typefield
   and a1.cdname = ''SEFIELDS''
   and a1.cdtype = ''SE''
   and a2.cdval = e.GLTYPESUBCD
   and a2.cdname = ''GLTYPESUBCD'' ', 'GLMAPBSA', 'frmBASKET', ' AUTOID', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;