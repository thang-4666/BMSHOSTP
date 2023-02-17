SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('CA3340','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('CA3340', 'Xác nhận thực hiện quyền với trưng tâm lưu ký', 'Confirm CA action', 'select * from (select a.camastid,max(a.autoid) autoid, max(a.description) description , max(b.symbol) symbol, max(a.actiondate) actiondate, max(cd.cdcontent) catype,
max(chd.codeid) codeid,MAX(A.REPORTDATE) REPORTDATE,
sum((case when a.catype in (''014'',''023'')then nvl(chd.qtty,0) else nvl(chd.trade,0) end)) QTTYDIS,
nvl(max(a.tocodeid),max(a.codeid)) tocodeid, max(tosym.symbol) TOSYMBOL, a.isincode
from camast a, sbsecurities b, allcode cd, caschd chd, sbsecurities tosym
where a.codeid = b.codeid and ((chd.status IN(''V'',''M'') and a.catype in (''014'',''023''))
or(chd.status IN(''A'') and a.catype not in (''014'',''023'',''028'')) --KRX04: xu ly them SKQ CW 028
or(chd.status IN(''Z'') and a.catype = ''028'') --KRX04: xu ly them SKQ CW 028
) and a.deltd=''N''
and a.camastid= chd.camastid and chd.deltd <> ''Y''
and cd.cdname =''CATYPE'' and cd.cdtype =''CA'' and cd.cdval = a.catype
and a.catype not in (''019'')
and nvl(a.tocodeid,a.codeid)=tosym.codeid
and NOT EXISTS (select 1 from tllog tl where tl.tltxcd =''3340'' and tl.deltd <> ''Y'' and tl.txstatus =''4'' and tl.msgacct=a.camastid)
group by a.camastid, a.isincode ) where 0=0', 'CAMAST', '', 'AUTOID DESC', '3340', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', '');COMMIT;