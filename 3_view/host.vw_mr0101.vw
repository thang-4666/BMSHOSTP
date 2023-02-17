SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0101
(ACTYPE, TYPENAME, CO_FINANCING, ISMARGINACC, CUSTODYCD, 
 ACCTNO, FULLNAME, MARGINAMT, T0AMT, MARGINOVDAMT, 
 T0OVDAMT, MARGINRATIO, ADDVND, MRIRATIO, MRMRATIO, 
 MRLRATIO, TOTALVND, ADVANCELINE, SEREAL, MRCRLIMIT, 
 MRCRLIMITMAX, DFODAMT, MRCRLIMITREMAIN, STATUS, CAREBY)
BEQUEATH DEFINER
AS 
select af.actype, aft.typename, DECODE(co_financing,'Y','YES','NO') co_financing, DECODE(ismarginacc,'Y','YES','NO') ismarginacc,
custodycd,af.acctno, cf.fullname, ROUND(nvl(ln.margin74amt,0)) marginamt, ROUND(nvl(ln.t0amt,0)) t0amt,
ROUND(nvl(ln.margin74ovdamt,0)) MARGINOVDAMT, ROUND(nvl(ln.t0ovdamt,0)) t0ovdamt, ROUND(nvl(sec.marginrate74,0)) marginratio,
ROUND(greatest((af.mrmratio/100 - sec.marginrate74/100) * (sec.sereal + GREATEST(balance + ROUND(nvl(avladvance,0)) - ROUND(nvl(ln.margin74amt,0)),0)),greatest(ROUND(nvl(ln.margin74ovdamt,0)) - balance - ROUND(avladvance),0))) addvnd,
af.mriratio, af.mrmratio, af.mrlratio, ROUND(balance + avladvance) totalvnd, nvl(t0.advanceline,0) advanceline,sec.sereal, af.mrcrlimit,
af.mrcrlimitmax, ci.dfodamt,af.mrcrlimitmax - ci.dfodamt mrcrlimitremain, af.status, af.careby

from cfmast cf, afmast af, cimast ci, aftype aft, v_getsecmarginratio_74 sec,
    (select acctno, 'Y' ismarginacc from afmast af
          where exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y'
                          union all
                          select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y')
          group by acctno) ismr,
    (select aftype, 'Y' co_financing from afidtype where objname = 'LN.LNTYPE' group by aftype) cof,
    (select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)+round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                 trunc(sum(decode(lnt.chksysctrl,'Y',1,0)*(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)+round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd))),0) margin74amt,
                 trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                 trunc(sum((round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) + round(nvl(ls.dueamt,0)) + round(feeintdue))),0) marginovdamt,
                 trunc(sum(decode(lnt.chksysctrl,'Y',1,0)*(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) + round(nvl(ls.dueamt,0)) + round(feeintdue))),0) margin74ovdamt,
                 trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt
        from lnmast ln, lntype lnt,
                (select acctno, sum(nml+intdue) dueamt  from lnschd
                        where reftype = 'P' and overduedate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by acctno) ls
        where ftype = 'AF' and ln.actype = lnt.actype
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln,
(select acctno, sum(acclimit) advanceline from useraflimit where typereceive = 'T0' group by acctno) t0
where cf.custid = af.custid
and cf.custatcom = 'Y'
and af.actype = aft.actype
and af.acctno = ci.acctno
and af.acctno = sec.afacctno
and af.acctno = ln.trfacctno(+)
and af.acctno = ismr.acctno(+)
and af.actype = cof.aftype(+)
and af.acctno = t0.acctno(+)
and nvl(ismarginacc,'N') = 'Y'
/
