SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3345','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3345', 'Sự kiện chuyển đổi(Hủy TP cũ hoặc hủy CP cũ)', 'Sự kiện chuyển đổi(Hủy TP cũ hoặc hủy CP cũ)', 'select * from (select max(a.autoid) autoid,a.camastid, a.description, b.symbol, a.actiondate ,a.canceldate POSTINGDATE, sum(chd.qtty) qtty, max(cd.cdcontent) catype,
max(nvl(a.tocodeid,a.codeid)) codeid, max(b2.symbol) symbol_org, ''Y'' ISCANCEL, a.isincode
from camast a, sbsecurities b, caschd chd ,allcode cd, sbsecurities b2
where nvl(a.tocodeid,a.codeid) = b.codeid and a.status  in (''I'',''G'',''H'',''J'')
     and a.deltd<>''Y'' and a.camastid = chd.camastid and chd.deltd <> ''Y''
     ---and (select count(1) from caschd where camastid = a.camastid and status <> ''C'' and isSE =''N'' and qtty>0 and deltd=''N'') = 0
     and cd.cdname =''CATYPE'' and cd.cdtype =''CA'' and cd.cdval = a.catype
     and b2.codeid=a.codeid
     and a.catype in (''023'',''020'') and a.cancelstatus = ''N''
     group by a.isincode,a.camastid, a.description, b.symbol, a.actiondate, a.canceldate
     ----having sum(chd.qtty) <>0
) where 0=0', 'CAMAST', '', 'AUTOID DESC', '3341', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;