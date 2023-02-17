SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('AFTYPE_LIST','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('AFTYPE_LIST', 'Loại hình tiểu khoản giao dịch', 'Sub-account product type management', 'SELECT ACTYPE, TYPENAME, A0.CDCONTENT AFSTATUS, A1.CDCONTENT AFTYPE, TYP.DESCRIPTION, A02.CDCONTENT STATUS,
A03.CDCONTENT APPRV_STS,
(CASE WHEN APPRV_STS IN (''D'') THEN ''N'' ELSE ''Y'' END) EDITALLOW, (CASE WHEN APPRV_STS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW,
(CASE WHEN APPRV_STS IN (''D'') THEN ''N'' ELSE ''Y'' END) AS DELALLOW
FROM AFTYPE TYP, ALLCODE A0, ALLCODE A1, ALLCODE A02, ALLCODE A03,
 (SELECT DISTINCT(aftype)
   FROM
        (SELECT GRPID FROM TLGRPUSERS WHERE BRID=''<$BRID>'' AND TLID=''<$TELLERID>'' UNION ALL select ''XXXX'' GRPID from dual) TLCAREBY,
         (SELECT * FROM tlgrpaftype WHERE grpid IN
                                    ( SELECT paravalue FROM brgrpparam WHERE  paratype=''TLGROUPS'' AND brid=''<$BRID>'')) grtyp  ,
         (SELECT * FROM tlgroups WHERE active=''Y'' AND grptype=''2'') tlgrp
 WHERE TLCAREBY.GRPID=grtyp.grpid and TLCAREBY.GRPID= TLGRP.GRPID ) grtyp
WHERE A0.CDTYPE = ''SY'' AND A0.CDNAME = ''TYPESTS'' AND A0.CDVAL=TYP.APPROVECD AND A1.CDTYPE = ''CF''
AND A02.CDVAL = TYP.STATUS AND A02.CDTYPE = ''SY'' AND A02.CDNAME = ''STATUS''
AND A03.CDVAL = TYP.APPRV_STS AND A03.CDTYPE = ''SY'' AND A03.CDNAME = ''APPRV_STS''
AND A1.CDNAME = ''AFTYPE'' AND A1.CDVAL=TYP.AFTYPE AND TYP.APPRV_STS =''A''
AND typ.actype=grtyp.aftype', 'AFTYPE', 'frmAFTYPE', '', '', 0, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;