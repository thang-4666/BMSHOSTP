SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0030
(ACTYPE, TYPENAME, CUSTODYCD, ACCTNO, FULLNAME, 
 MARGINAMT, T0AMT, MARGINOVDAMT, T0OVDAMT, MARGINRATE, 
 ADDVND, MRIRATE, MRMRATE, MRLRATE, TOTALVND, 
 ADVANCELINE, MRCRLIMIT, MRCRLIMITMAX, DFODAMT, MRCRLIMITREMAIN, 
 STATUS, CAREBY, SEAMT, CALLDAY, TRIGGERDAY, 
 LOAIHINH, MRRATE, REFULLNAME, GRPNAME, SEASS, 
 SEREAL, BRNAME)
BEQUEATH DEFINER
AS 
select af.actype, aft.typename,
cf.custodycd, af.acctno, cf.fullname, ROUND(ci.mrodamt) marginamt, ROUND(ci.t0odamt) t0amt,
ROUND(nvl(ln.marginovdamt,0)) marginovdamt, ROUND(nvl(ln.t0ovdamt,0)) t0ovdamt,
nvl(ci.marginrate,0) marginrate,
ROUND(greatest(round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - ci.outstanding else
greatest( 0,- ci.outstanding - ci.navaccount *100/af.mrmrate) end),0),greatest(mst.dueamt+mst.ovamt+ci.OVDCIDEPOFEE - ci.balance - nvl(avladvance,0),0))) addvnd,
af.mrirate, af.mrmrate, af.mrlrate, ROUND(ci.balance + nvl(avladvance,0)) totalvnd, af.advanceline,
af.mrcrlimit,
af.mrcrlimitmax, ci.dfodamt, af.mrcrlimitmax - ci.dfodamt mrcrlimitremain, af.status, af.careby, nvl(ci.seamt,0) seamt,
af.callday, to_number(nvl(af.triggerdate,to_date(sy.varvalue,'DD/MM/RRRR')) - to_date(sy.varvalue,'DD/MM/RRRR')) triggerday,
AFT.mnemonic LoaiHinh,
case when (nvl(sec.mrqttyamt,0)) + ci.balance + ci.bamt + ci.rcvamt + ci.mrcrlimit +
    (case when af.alternateacct = 'Y' or af.corebank ='Y' then ci.BANKAVLBAL else 0 end) -
    ((ci.dfodamt + ci.t0odamt + ci.mrodamt + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt +
            ci.rcvadvamt + ci.TDODAMT)-ci.dfodamt+ci.paidamt) < 0
    then 0 else (case when (nvl(sec.mrqttyamt,0))=0 then 100 else
    round(((nvl(sec.mrqttyamt,0)) +  least(ci.balance + ci.bamt + ci.rcvamt + ci.mrcrlimit +
    (case when af.alternateacct = 'Y' or af.corebank ='Y' then ci.BANKAVLBAL else 0 end) -
    ((ci.dfodamt + ci.t0odamt + ci.mrodamt + ci.ovdcidepofee + ci.execbuyamt + ci.trfbuyamt +
            ci.rcvadvamt + ci.TDODAMT)-ci.dfodamt+ci.paidamt),0))/
    (nvl(sec.mrqttyamt,0)),3)*100 end) end MRRATE,
    re.refullname, re.grpname,
    sec.MRQTTYAMT SEASS, sec.NONMRQTTYAMT SEREAL, brgrp.brname
from cfmast cf, afmast af, cimast mst, aftype aft,  mrtype mrt,
    (select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)
                                +round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                 trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                 trunc(sum(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) + round(nvl(ls.dueamt,0)) + round(feeintdue)),0) marginovdamt,
                 trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt
        from lnmast ln, lntype lnt,
                (select acctno, sum(nml+intdue) dueamt
                        from lnschd, (select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy
                        where reftype = 'P' and overduedate = to_date(varvalue,'DD/MM/RRRR')
                        group by acctno) ls
        where ftype = 'AF'
                and ln.actype = lnt.actype
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln,
    (select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy,
    buf_ci_account ci,
    (
        select afacctno,
            sum(case when mrratioloan>0 then  QTTY*BASICPRICE else 0 end) MRQTTYAMT,
            sum(case when mrratioloan>0 then  QTTY*currprice else 0 end) MRQTTYAMT_CURR,
            sum(case when mrratioloan>0 then  QTTY*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT,
            sum(case when mrratioloan>0 then  0 else QTTY*BASICPRICE end) NONMRQTTYAMT,
            sum(case when mrratioloan>0 then  0 else QTTY*currprice end) NONMRQTTYAMT_CURR,
            sum(DFQTTY * BASICPRICE) DFQTTYAMT,
            sum(DFQTTY * currprice) DFQTTYAMT_CURR,
            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE else 0 end) MRQTTYAMT_BUY,
            sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT_BUY,
            sum(case when mrratioloan>0 then  0 else buyingqtty*BASICPRICE end) NONMRQTTYAMT_BUY
        from (
            select afacctno,mrratioloan,basicprice,nvl(st.closeprice,basicprice) currprice,
                AVLMRQTTY qtty, AVLDFQTTY dfqtty,
                buyingqtty
            from buf_se_account se, sbsecurities sb ,stockinfor st
            where se.codeid= sb.codeid and sb.symbol = st.symbol(+)
            ) SE group by afacctno
    ) sec,
    (
        select re.afacctno, cf.fullname refullname, cf2.fullname grpname
        from reaflnk re, remast mst, retype ret, cfmast cf, regrplnk reg, regrp , cfmast cf2
        where re.deltd <> 'Y' and re.status = 'A' and re.clstxdate is null
            and re.reacctno = mst.acctno and mst.actype = ret.actype
            and ret.rerole = 'RM' and mst.custid = cf.custid
            and mst.acctno = reg.reacctno and reg.clstxdate is NULL
            and reg.status = 'A' and reg.deltd <> 'Y'
            and reg.refrecflnkid = regrp.autoid
            and regrp.custid = cf2.custid
    ) RE, brgrp
where cf.custid = af.custid and aft.mrtype = mrt.actype and mrt.mrtype in ('S', 'T')
and cf.custatcom = 'Y'
and af.actype = aft.actype
and af.acctno = ci.afacctno
and af.acctno = mst.afacctno
and af.acctno = ln.trfacctno(+)
and ci.afacctno = sec.afacctno(+)
and af.custid = RE.afacctno(+)
AND cf.status <> 'C' and cf.brid = brgrp.brid
/
