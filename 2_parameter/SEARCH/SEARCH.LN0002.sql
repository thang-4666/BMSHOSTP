SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('LN0002','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('LN0002', 'Tra cứu thông tin vay tài khoản (MR+BL)', 'View loan accounts (AF loan type)', 'select cf.custodycd,af.acctno afacctno,cf.fullname,lns.autoid,lns.rlsdate,
case when ln.rrtype = ''B'' then ln.custbank when ln.rrtype = ''C'' then sys_cmp.varvalue else null end rrtype,
ln.actype lntype,ln.acctno lnacctno, c1.cdcontent chksysctrl,
case when lns.reftype = ''P'' then ''Margin'' when lns.reftype = ''GP'' then ''Bao lanh'' else null end reftype,
ROUND(nml)+ROUND(ovd)+ROUND(paid) rlsamt,
ROUND(lns.paid) paid,ROUND(lns.nml)+ROUND(lns.ovd) prin,ROUND(lns.intnmlacr)+ROUND(lns.intdue)+ROUND(lns.intovd)+ROUND(lns.intovdprin) intprin,
ROUND(lns.ovd) ovd,ROUND(lns.intovd)+ROUND(lns.intovdprin) intovd,
lns.overduedate, greatest(to_number(to_date(sy_Date.varvalue,''DD/MM/RRRR'') - lns.overduedate),0) ovddays,   lns.overduedate - lns.rlsdate period,
greatest(to_number(lns.overduedate - to_date(sy_Date.varvalue,''DD/MM/RRRR'')),0) remaindays, cf.mobilesms, cf.email,
    aft.mnemonic LOAIHINH
from lnschd lns, lnmast ln, afmast af, cfmast cf, lntype lnt, sysvar sy_Date, allcode c1, sysvar sys_cmp ,
    aftype aft
where lns.acctno = ln.acctno
and ln.trfacctno = af.acctno
and af.actype = aft.actype
and af.custid = cf.custid
and ln.actype = lnt.actype
and lns.reftype in (''P'',''GP'')
and ln.ftype = ''AF''
and c1.cdname = ''YESNO'' and c1.cdtype = ''SY'' and c1.cdval = lnt.chksysctrl
and sy_Date.varname = ''CURRDATE'' and sy_Date.grname = ''SYSTEM''
and sys_cmp.varname = ''COMPANYSHORTNAME'' and sys_cmp.grname = ''SYSTEM''', 'LNMAST', '', 'PRIN ASC', '', NULL, 50, 'N', 30, 'NYNNYYYNNN', 'Y', 'T', '', 'N', '', 'CUSTODYCD');COMMIT;