SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_GETSECMARGINRATIO_74
(AFACCTNO, SECUREAMT, ADVAMT, OVERAMT, EXECBUYAMT, 
 SEAMT, SEASS, SEREAL, RECEIVINGAMT, AVLADVANCE, 
 PAIDAMT, ADVANCEAMOUNT, AAMT, NAVACCOUNT, MARGINRATE74, 
 AVLLIMIT, OUTSTANDING, CHKSYSCTRL, MRIRATIO, MRMRATIO, 
 MRLRATIO, MRCRLIMITMAX)
BEQUEATH DEFINER
AS 
select ci.acctno afacctno,
nvl(al.secureamt,0) secureamt,
nvl(al.advamt,0) advamt, nvl(al.overamt,0) overamt,nvl(al.execbuyamt,0) execbuyamt,
nvl(se.seamt,0) seamt,nvl(se.seass,0) seass, nvl(se.SEREAL,0) SEREAL, nvl(se.receivingamt,0) receivingamt,
nvl(adv.avladvance,0) avladvance, nvl(adv.paidamt,0) paidamt,nvl(adv.advanceamount,0) advanceamount, nvl(adv.aamt,0) aamt,
--least(nvl(se.SEASS,0), af.mrcrlimitmax - dfodamt) NAVACCOUNT,
nvl(se.SEASS,0) NAVACCOUNT,
/*round((case when ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(al.secureamt,0) - ci.trfbuyamt - ci.ramt>=0 then 100000
else least( nvl(se.SEASS,0), af.mrcrlimitmax - dfodamt)
    / abs(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(al.secureamt,0) - ci.trfbuyamt - ci.ramt) end),4) * 100 MARGINRATE74,
*/
/*round((case when least( nvl(se.SEASS,0), af.mrcrlimitmax - dfodamt) = 0 then 1
else (least( nvl(se.SEASS,0), af.mrcrlimitmax - dfodamt) - least(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(al.secureamt,0) - ci.trfbuyamt - ci.ramt,0) )
    / least( nvl(se.SEASS,0), af.mrcrlimitmax - dfodamt) end),4)* 100 MARGINRATE74,*/
round((case when nvl(se.SEASS,0) = 0 then 100
else (nvl(se.SEASS,0) + least(ci.balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt)+ nvl(adv.avladvance,0) - ci.odamt - nvl(al.secureamt,0) - ci.trfbuyamt - ci.ramt,0) )
    / nvl(se.SEASS,0) end),4)* 100 MARGINRATE74,

(nvl(adv.avladvance,0) +nvl(af.MRCRLIMIT,0)+ balance - nvl(al.secureamt,0) - ci.trfbuyamt - nvl (al.overamt, 0) - ci.odamt - ci.ramt - ci.dfdebtamt - ci.dfintdebtamt + af.advanceline
    + af.mrcrlimitmax - ci.dfodamt)  avllimit,
nvl(adv.avladvance,0) + balance +LEAST(nvl(af.MRCRLIMIT,0),nvl(al.secureamt,0) + ci.trfbuyamt) - nvl(al.secureamt,0) - ci.trfbuyamt - nvl (al.overamt, 0)- ci.odamt - ci.ramt - ci.dfdebtamt - ci.dfintdebtamt outstanding,
chksysctrl, MRIRATIO,MRMRATIO,MRLRATIO,af.mrcrlimitmax

from cimast ci, afmast af, aftype aft, lntype lnt,
v_getbuyorderinfo al,
v_getsecmargininfo_74 se,
(select sum(aamt) aamt,sum(depoamt) avladvance,sum(paidamt) paidamt, sum(advamt) advanceamount,afacctno from v_getAccountAvlAdvance group by afacctno) adv

where ci.acctno = af.acctno and af.actype = aft.actype and aft.lntype = lnt.actype(+)
        and ci.acctno = al.afacctno(+) and se.afacctno(+)=ci.acctno and adv.afacctno(+)=ci.acctno
/
