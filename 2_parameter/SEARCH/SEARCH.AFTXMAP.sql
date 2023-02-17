SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('AFTXMAP','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('AFTXMAP', 'Danh sach các giao dịch bị chặn theo loại hình', 'List of transactions blocked by the product', 'select af.autoid,af.tltxcd, tx.txdesc, effdate, expdate, tlname tlid, af.actype, typ.typename,
''Y'' EDITALLOW, (CASE WHEN AF.STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW,
''Y'' AS DELALLOW
from aftxmap af, tltx tx, tlprofiles tl, aftype typ, ALLCODE A03
where af.tltxcd= tx.tltxcd and af.deltd=''N'' AND TRIM(UPPER(AF.AFACCTNO))=''ALL''
      and af.tlid= tl.tlid AND A03.CDVAL = TYP.STATUS AND A03.CDTYPE = ''SY''
      and af.actype like ''<$KEYVAL>''
      AND A03.CDNAME = ''STATUS'' AND af.actype = typ.actype', 'CF.AFTXMAP', '', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;