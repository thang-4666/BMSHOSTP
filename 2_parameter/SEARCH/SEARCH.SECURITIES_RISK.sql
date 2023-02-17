SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('SECURITIES_RISK','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('SECURITIES_RISK', 'Tham số hệ thống chứng khoán ký quỹ tài khoản', 'Securities system parameter for credit line', '
select sb.symbol, sb.codeid, rm.mrmaxqtty,sb.roomlimit roomlimit74, risk.mrpricerate, risk.mrpriceloan,
    rm.mrmaxqtty - rm.seqtty avlmrqtty, rm.seqtty,  c1.cdcontent ismarginallow , sb.listingqtty, rm.afmaxamt, rm.afmaxamtt3,
    (CASE WHEN RISK.STATUS IN (''D'') THEN ''N'' ELSE ''Y'' END) EDITALLOW,
    (CASE WHEN RISK.STATUS IN (''P'') THEN ''Y'' ELSE ''N'' END) APRALLOW,
    (CASE WHEN RISK.STATUS IN (''D'') THEN ''N'' ELSE ''Y'' END) DELALLOW,
    A2.CDCONTENT APPRV_STSD
from securities_info sb, v_getmarginroominfo rm, securities_risk risk, allcode c1,ALLCODE a2
where sb.codeid = risk.codeid and sb.codeid = rm.codeid
and c1.cdtype = ''SY'' and c1.cdname = ''YESNO'' and c1.cdval = risk.ismarginallow and
A2.CDNAME=''APPRV_STS'' AND A2.CDTYPE=''SY'' AND A2.CDVAL=NVL(risk.STATUS,''A'')
and 0=0', 'SECURITIES_RISK', 'frmSECURITIES_RISK', '', '', NULL, 50, 'N', 30, '', 'Y', 'T', '', 'N', '', '');COMMIT;