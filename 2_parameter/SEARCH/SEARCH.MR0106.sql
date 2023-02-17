SET DEFINE OFF;DELETE FROM SEARCH WHERE 1 = 1 AND NVL(SEARCHCODE,'NULL') = NVL('MR0106','NULL');Insert into SEARCH   (SEARCHCODE, SEARCHTITLE, EN_SEARCHTITLE, SEARCHCMDSQL, OBJNAME, FRMNAME, ORDERBYCMDSQL, TLTXCD, CNTRECORD, ROWPERPAGE, AUTOSEARCH, INTERVAL, AUTHCODE, ROWLIMIT, CMDTYPE, CONDDEFFLD, BANKINQ, BANKACCT, CHKSCOPECMDSQL) Values   ('MR0106', 'Danh sách món vay cảnh báo trước hạn', 'View call margin account before liquidation (System)', 'select cf.CUSTODYCD, cf.FULLNAME, aft.MNEMONIC,mst.AFACCTNO ACCTNO, cf.mobilesms PHONE, mst.MARGINRATE,
ROUND(greatest(round((case when nvl(mst.marginrate,0) * af.mrirate =0 then - round(outstanding) else
                     greatest( 0,- outstanding - navaccount *100/af.mrmrate) end),0),
                     greatest(round(ci.dueamt)+round(ci.ovamt)+round(depofeeamt) - balance - round(avladvance),0))) addvnd,
ci.BALANCE, af.MRMRATE,
ls.overduedate - to_date(sy.varvalue,''DD/MM/RRRR'') warningdays,
round(ls.nml+ls.ovd) warningprin,
ROUND(ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin
    +ls.fee + Ls.feedue + ls.feeovd + ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd
    +ls.feeintdue + ls.nmlfeeint + ls.ovdfeeint + ls.feeintnml + ls.feeintovd) warningint,
ROUND(ls.nml+ls.ovd+ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin
    +ls.fee + Ls.feedue + ls.feeovd + ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd
    +ls.feeintdue + ls.nmlfeeint + ls.ovdfeeint + ls.feeintnml + ls.feeintovd) warningamt,
 ls.rlsdate, ls.overduedate , lnt.warningdays daysnum, to_date(sy.varvalue,''DD/MM/RRRR'') CURRDATE,
ln.FTYPE || ls.REFTYPE SCHDTYPE , ltrim(to_char(round(ls.nml+ls.ovd),''9,999,999,999,999'')) GOCVAY,
ltrim(to_char(ROUND(ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin
    +ls.fee + Ls.feedue + ls.feeovd + ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd
    +ls.feeintdue + ls.nmlfeeint + ls.ovdfeeint + ls.feeintnml + ls.feeintovd),''9,999,999,999,999'')) LAIVAY ,
ltrim(to_char(ROUND(ls.nml+ls.ovd+ls.intnmlacr+ls.intdue+ls.intovd+ls.intovdprin
    +ls.fee + Ls.feedue + ls.feeovd + ls.feeintnmlacr + ls.feeintovdacr + ls.feeintnmlovd
    +ls.feeintdue + ls.nmlfeeint + ls.ovdfeeint + ls.feeintnml + ls.feeintovd),''9,999,999,999,999'')) TONGVAY
from cfmast cf, afmast af, cimast ci, lnmast ln, lnschd ls, lntype lnt, v_getsecmarginratio mst, sysvar sy, aftype aft
where cf.custid = af.custid and af.actype = aft.actype
and af.acctno = ci.afacctno
and af.acctno = mst.afacctno
and af.acctno = ln.trfacctno
and ln.acctno = ls.acctno and ls.reftype = ''P''
and ln.actype = lnt.actype
and sy.grname = ''SYSTEM'' and sy.varname = ''CURRDATE''
and ((lnt.lncldr = ''N''
    and ls.overduedate > to_date(sy.varvalue,''DD/MM/RRRR'')
    and to_number(ls.overduedate - to_date(sy.varvalue,''DD/MM/RRRR'')) <= lnt.warningdays)
        or
    (lnt.lncldr = ''B''
    and ls.overduedate > to_date(sy.varvalue,''DD/MM/RRRR'')
    and to_date(sy.varvalue,''DD/MM/RRRR'') >= fn_get_prevdate( ls.overduedate , lnt.warningdays))
        )', 'MRTYPE', '', '', '', NULL, 50, 'N', 30, 'NYNNYYYYYN', 'Y', 'T', '', 'N', '', '');COMMIT;