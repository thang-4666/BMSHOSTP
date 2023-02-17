SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_LN5541
(CUSTODYCD, ADDRESS, LICENSE, AFACCTNO, FULLNAME, 
 MARGINRATIO, MARGINRATE, RTNAMT, MRIRATIO, MRMRATIO, 
 MRLRATIO, SETOTALCALLASS, MRCRLIMIT, MRCRLIMITMAX, LNTYPE)
BEQUEATH DEFINER
AS 
select cf.custodycd,cf.address, cf.idcode license, af.acctno afacctno, cf.fullname, nvl(sec74.marginrate74,0) marginratio, nvl(sec.marginrate,0) marginrate,
ROUND(greatest((af.mriratio/100 - sec74.marginrate74/100) * (sec.seass + GREATEST(balance + ROUND(nvl(sec.avladvance,0)) - ROUND(nvl(ln.marginamt,0),0))),ROUND(nvl(marginovdamt,0))-balance-ROUND(nvl(sec.avladvance,0)))) rtnamt,
af.mriratio, af.mrmratio, af.mrlratio, sec.seass setotalcallass, af.mrcrlimit, af.mrcrlimitmax, aft.lntype

from cfmast cf, afmast af, cimast ci, aftype aft,
    v_getsecmarginratio sec,
    v_getsecmarginratio_74 sec74,
    (select acctno, 'Y' ismarginacc from afmast af
          where exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y'
                          union all
                          select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y')
          group by acctno) ismr,
    (select trfacctno, sum(prinnml+prinovd+intnmlacr+intdue+intovdacr+intnmlovd+feeintnmlacr+feeintdue+feeintovdacr+feeintnmlovd) marginamt,
                 sum(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd) t0amt,
                 sum(prinovd+intovdacr+intnmlovd+feeintovdacr+feeintnmlovd + nvl(ls.dueamt,0) + feeintdue) marginovdamt,
                 sum(oprinovd+ointovdacr+ointnmlovd) t0ovdamt
        from lnmast ln, lntype lnt,
                (select acctno, sum(nml+intdue) dueamt  from lnschd
                        where reftype = 'P' and overduedate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE')
                        group by acctno) ls
        where ftype = 'AF' and ln.actype = lnt.actype and lnt.chksysctrl = 'Y'
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln,
(select acctno, sum(acclimit) advanceline from useraflimit where typereceive = 'T0' group by acctno) t0,
(select afacctno, sum(remainqtty*quoteprice) sellamount from odmast where exectype in ('NS','MS') group by afacctno) od
where cf.custid = af.custid
and af.actype = aft.actype
and af.acctno = ci.acctno
and af.acctno = sec.afacctno(+)
and af.acctno = sec74.afacctno(+)
and af.acctno = ln.trfacctno(+)
and af.acctno = ismr.acctno(+)
and af.acctno = t0.acctno(+)
and af.acctno = od.afacctno(+)
and sec74.marginrate74<=af.mriratio
and nvl(ismr.ismarginacc,'N') = 'Y'
/
