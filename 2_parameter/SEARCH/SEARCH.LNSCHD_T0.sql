SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LNSCHD_T0','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LNSCHD_T0', 'Giải ngân trong ngày', 'Customer loan account management', '
select cf.custodycd, tr.txnum rlstxnum, to_char(tr.txdate,''DD/MM/RRRR'') rlstxdate, tr.lnacctno, tr.ciacctno acctno, tr.rlsamt, ls.lnschdid, ls.lntype
from
cfmast cf, afmast af,
(
select t.txnum, t.txdate,
    max(decode(f.fldcd,''03'', cvalue, null)) lnacctno,
    max(decode(f.fldcd,''05'', cvalue, null)) ciacctno,
    max(case when decode(f.fldcd,''10'', nvalue, 0)> 0 then ''P''
            when decode(f.fldcd,''11'', nvalue, 0)> 0 then ''GP''
            else null end) reftype,
    sum(decode(f.fldcd,''10'', nvalue, 0) + decode(f.fldcd,''11'', nvalue, 0)) rlsamt
from tllog t, tllogfld f
where tltxcd = ''5566'' and deltd <> ''Y''
    and t.txnum = f.txnum
    and t.txdate = f.txdate
group by t.txnum, t.txdate
) tr,
(
select ls.acctno, ls.nml, ls.ovd, ls.reftype, ln.trfacctno, ls.autoid lnschdid, lnt.actype || '': '' || lnt.typename lntype
from lnmast ln, lnschd ls, lntype lnt
where ln.acctno = ls.acctno AND ln.actype = lnt.actype
and ls.reftype = ''P''
and ls.rlsdate = (select to_date(varvalue,''DD/MM/RRRR'') from sysvar where varname = ''CURRDATE'')
) ls
where cf.custid = af.custid
and af.acctno = ls.trfacctno
and tr.lnacctno = ls.acctno
and tr.reftype = ls.reftype
and tr.rlsamt = ls.nml+ls.ovd
and af.acctno = tr.ciacctno
', 'LNSCHD_T0', 'frmLNMAST', '', '', NULL, 50, 'N', 0, '', 'Y', 'T', '', 'N', '', '');COMMIT;