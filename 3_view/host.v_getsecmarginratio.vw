SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETSECMARGINRATIO
(AFACCTNO, SECUREAMT, ADVAMT, OVERAMT, EXECBUYAMT, 
 SEAMT, SEASS, RECEIVINGAMT, AVLADVANCE, PAIDAMT, 
 ADVANCEAMOUNT, AAMT, NAVACCOUNT, MARGINRATE, AVLLIMIT, 
 OUTSTANDING, CHKSYSCTRL, MRIRATE, MRMRATE, MRLRATE, 
 MRCRATE, MRWRATE, MRCRLIMITMAX, DUEAMT, OVAMT, 
 RCVAMT, DCLAMTLIMIT, MRODAMT)
BEQUEATH DEFINER
AS 
select ci.acctno afacctno,
nvl(al.secureamt,0) secureamt,
nvl(al.advamt,0) advamt, nvl(al.overamt,0) overamt, nvl(al.execbuyamt,0) execbuyamt,
nvl(se.seamt,0) seamt,nvl(se.seass,0) seass, nvl(se.receivingamt,0) receivingamt,
nvl(adv.avladvance,0) avladvance, nvl(adv.paidamt,0) paidamt,nvl(adv.advanceamount,0) advanceamount, nvl(adv.aamt,0) aamt,
--least(nvl(se.SEASS,0), af.mrcrlimitmax - dfodamt) NAVACCOUNT,
nvl(se.SEASS,0) NAVACCOUNT,
round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(al.secureamt,0) - ci.trfbuyamt - ci.ramt
--han muc dam bao tu ngan hang
+GREATEST(LEAST(nvl(al.secureamt,0) -
                                 GREATEST( ci.balance + af.advanceline +  nvl(adv.avladvance,0)+  LEAST ( nvl(se.seamt,0), AF.MRCRLIMITMAX) - ci.odamt
                                           + LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)
                                         ,0)
      , af.clamtlimit)  ,0)

 >=0 then 100000
else  nvl(se.SEASS,0)
    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(al.secureamt,0) - ci.trfbuyamt - ci.ramt
    +GREATEST(LEAST(nvl(al.secureamt,0) -
                                 GREATEST( ci.balance + af.advanceline +  nvl(adv.avladvance,0)+  LEAST ( nvl(se.seamt,0), AF.MRCRLIMITMAX) - ci.odamt
                                           + LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)
                                         ,0)
      , af.clamtlimit)  ,0)
    /* - ci.depofeeamt*/) end),4) * 100 MARGINRATE,

(nvl(adv.avladvance,0) +nvl(af.MRCRLIMIT,0)+ balance - nvl(al.secureamt,0) - ci.trfbuyamt - nvl (al.overamt, 0) - ci.odamt - ci.ramt - ci.dfdebtamt - ci.dfintdebtamt + af.advanceline
    + af.mrcrlimitmax - ci.dfodamt- ci.depofeeamt +af.clamtlimit )  avllimit,
nvl(adv.avladvance,0) + balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt) - nvl(al.secureamt,0) - ci.trfbuyamt - nvl (al.overamt, 0)- ci.odamt - ci.ramt - ci.dfdebtamt - ci.dfintdebtamt outstanding,
chksysctrl, af.MRIRATE,af.MRMRATE,af.MRLRATE,AF.MRCRATE,AF.MRWRATE,AF.MRCRLIMITMAX, ci.dueamt, ci.ovamt,
nvl(adv.rcvamt,0) rcvamt,
GREATEST(LEAST(nvl(al.secureamt,0) -
                                 GREATEST( ci.balance + af.advanceline +  nvl(adv.avladvance,0)+  LEAST ( nvl(se.seamt,0), AF.MRCRLIMITMAX) - ci.odamt
                                           + LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)
                                         ,0)
      , af.clamtlimit)  ,0) Dclamtlimit, CI.ODAMT MRODAMT
from cimast ci, afmast af, aftype aft, lntype lnt,
v_getbuyorderinfo al,
v_getsecmargininfo se,
(select sum(aamt) aamt,sum(depoamt) avladvance,sum(paidamt) paidamt, sum(advamt) advanceamount,afacctno, sum(rcvamt) rcvamt from v_getAccountAvlAdvance group by afacctno) adv

where ci.acctno = af.acctno and af.actype = aft.actype and aft.lntype = lnt.actype(+)
        and ci.acctno = al.afacctno(+) and se.afacctno(+)=ci.acctno and adv.afacctno(+)=ci.acctno
/
