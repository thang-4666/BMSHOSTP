SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0001
(ACTYPE, TYPENAME, CUSTODYCD, ACCTNO, FULLNAME, 
 MARGINAMT, T0AMT, MARGINOVDAMT, MARGININAMT, T0OVDAMT, 
 MARGINRATE, ADDVND, MRIRATE, MRMRATE, MRLRATE, 
 MRWRATE, MRCRATE, TOTALVND, ADVANCELINE, MRCRLIMIT, 
 MRCRLIMITMAX, DFODAMT, MRCRLIMITREMAIN, STATUS, CAREBY, 
 SEAMT, SEASS, CALLDAY, TRIGGERDAY, LOAIHINH, 
 AVLLIMIT_MG, AVLLIMIT)
BEQUEATH DEFINER
AS 
select af.actype, aft.typename, --DECODE(co_financing,'Y','YES','NO') co_financing, DECODE(ismarginacc,'Y','YES','NO') ismarginacc,
cf.custodycd,af.acctno, cf.fullname, ROUND(nvl(ln.marginamt,0)) marginamt, ROUND(nvl(ln.t0amt,0)) t0amt,
ROUND(nvl(ln.marginovdamt,0)) marginovdamt,ROUND(nvl(ln.margininamt,0)) margininamt , ROUND(nvl(ln.t0ovdamt,0)) t0ovdamt,
nvl(sec.marginrate,0) marginrate,
ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - sec.outstanding else
greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrcrate) end),0),greatest(ci.dueamt+ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0))) addvnd,
af.mrirate, af.mrmrate, af.mrlrate,af.mrwrate, af.mrcrate,
ROUND(ci.balance + nvl(avladvance,0)) totalvnd, af.advanceline,--nvl(t0.advanceline,0) advanceline,
AF.MRCRLIMIT, --HAN MUC BAN DAU
af.mrcrlimitmax, ci.dfodamt, af.mrcrlimitmax - ci.dfodamt mrcrlimitremain, af.status, af.careby, nvl(sec.seamt,0) seamt,nvl(sec.seass,0) seass,
af.callday,
--to_number(-nvl(af.triggerdate,to_date(sy.varvalue,'DD/MM/RRRR')) + to_date(sy.varvalue,'DD/MM/RRRR')) triggerday,
nvl((select nvl(-numday,0) from sbcurrdate where sbdate = af.triggerdate and sbtype = 'B'),0) triggerday,
AFT.mnemonic LoaiHinh,
NVL(AF.MRCRLIMITMAX - NVL(CI.DFODAMT,0) - NVL(LN.NML,0) -fn_get_margin_execbuyamt_sec( AF.ACCTNO),0) AVLLIMIT_MG,--HAN MUC CON LAI THEO 111108
SEC.AVLLIMIT --HAN MUC CON LAI TRONG BUF_CI
from cfmast cf, afmast af, cimast ci, aftype aft,  mrtype mrt,
    --v_getsecmarginratio sec,
     (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance, AVLLIMIT from buf_ci_account ) sec,
    --(select aftype, 'Y' co_financing from afidtype where objname = 'LN.LNTYPE' group by aftype) cof,
    /*(select acctno, 'Y' ismarginacc from afmast af
          where exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y'
                          union all
                          select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y')
          group by acctno) ismr,*/
    (select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)
                                +round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                 trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                 trunc(sum(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) ),0) marginovdamt,
                 trunc(sum(round(nvl(ls.dueamt,0))),0) margininamt,
                 trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt, ROUND(SUM(LN.PRINNML+LN.PRINOVD)) NML
        from lnmast ln, lntype lnt,
                (select acctno, sum(nml+intdue+feeintdue) dueamt
                        from lnschd, (select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy
                        where reftype = 'P' and overduedate = to_date(varvalue,'DD/MM/RRRR')
                        group by acctno) ls
        where ftype = 'AF'
                and ln.actype = lnt.actype
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln,
--(select acctno, sum(acclimit) advanceline from useraflimit where typereceive = 'T0' group by acctno) t0,
(select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy
where cf.custid = af.custid and aft.mrtype = mrt.actype and mrt.mrtype in ('S', 'T')
and cf.custatcom = 'Y'
and af.actype = aft.actype
and af.acctno = ci.acctno
and af.acctno = sec.afacctno
and af.acctno = ln.trfacctno(+)
--and af.actype = cof.aftype(+)
--and af.acctno = t0.acctno(+)
--and af.acctno = ismr.acctno(+)
AND cf.status <> 'C'
/
