SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0002
(CUSTODYCD, ACCTNO, GROUPLEADER, FULLNAME, MOBILESMS, 
 EMAIL, ACTYPE, TYPENAME, MNEMONIC, MARGINRATE, 
 CALLTYPE, RTNAMT, ADDVND, RTNREMAINAMT, ADD_TO_MRCRATE, 
 RTNAMOUNTREF, ADD_TO_MRIRATE, ADDVND2, MRIRATE, MRMRATE, 
 MRLRATE, MRCRATE, TOTALVND, ADVANCELINE, SEASS, 
 MRCRLIMIT, MRCRLIMITMAX, DFODAMT, MRCRLIMITREMAIN, STATUS, 
 DUEAMOUNT, OVDAMOUNT, CALLDATE, CALLTIME, CALLDAY, 
 MONEYPAY, ADDT3, ADVT3, DATEORDER, CAREBYNAME, 
 FIRST_CALLDATE, OVDAMOUNTREF, SELLLOSTASSREF, SELLAMOUNTREF, OUTSTANDING, 
 CAREBY)
BEQUEATH DEFINER
AS 
select
cf.custodycd,af.acctno,af.groupleader, cf.fullname, cf.mobilesms, cf.email,

af.actype, aft.typename,aft.mnemonic, --DECODE(co_financing,'Y','YES','NO') co_financing, DECODE(ismarginacc,'Y','YES','NO') ismarginacc,

nvl(sec.marginrate,0) marginrate,
(CASE WHEN  CI.DUEAMT=0 THEN 'Tỉ lệ'
      WHEN CI.DUEAMT>0 AND (aft.mnemonic<>'T3'
              AND (
                    (af.mrlrate <= sec.marginrate AND sec.marginrate < af.mrmrate)-- Rtt<Rcall
                  OR (AF.Mrlrate<=SEC.MARGINRATE AND SEC.MARGINRATE<AF.MRCRATE AND AF.Callday>0
                      AND NOT (AF.CALLDAY=AF.K1DAYS OR AF.CALLDAY=AF.K2days))-- Rtt<Rt.call va call k ngay lien tiep
                  )
              ) THEN 'Tỉ lệ-Nợ đến hạn'
      ELSE 'Nợ đến hạn' END) CALLTYPE,
ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else
                             greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0),0)) rtnamt,

case when aft.mnemonic<>'T3' then
    ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0),greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)+/*ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0)))
else
    greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0)
end addvnd,

case when aft.mnemonic<>'T3' then
    ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0),greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)+/*ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0)))
else
    greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0)
end RTNREMAINAMT,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0)
else
    0
end ADD_TO_MRCRATE,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0)
else
    0
end RTNAMOUNTREF,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRIRATE) end),0)
else
    0
end ADD_TO_MRIRATE,
case when aft.mnemonic<>'T3' then
    ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0),greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance,0)))
else
    greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance,0)
end addvnd2,
af.mrirate, af.mrmrate, af.mrlrate,AF.MRCRATE,
ROUND(ci.balance + avladvance) totalvnd, af.advanceline, --nvl(t0.advanceline,0) advanceline,
sec.seass seass, af.mrcrlimit,
af.mrcrlimitmax, ROUND(ci.dfodamt) dfodamt,af.mrcrlimitmax - ROUND(ci.dfodamt) mrcrlimitremain, af.status, ROUND(ci.dueamt) dueamount, ROUND(ci.ovamt) ovdamount,
CALLDATE, CALLTIME, af.callday ,
case when aft.mnemonic<>'T3' then
    ltrim(to_char(ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/af.mrmrate) end),0),greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0))),'9,999,999,999'))
else
    ltrim(to_char(ROUND(greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0)),'9,999,999,999'))
end moneypay,
to_char(greatest(ROUND(ci.dueamt)+ROUND(ci.ovamt)/*+ROUND(ci.depofeeamt) */- ci.balance ,0) ,'9,999,999,999')  ADDT3,
to_char(avladvance ,'9,999,999,999')  ADVT3,
to_char( get_t_date(getcurrdate,3),'DD/MM/YYYY') dateorder, tlg.grpname carebyname,
fn_get_prevdate(GETCURRDATE,AF.CALLDAY) FIRST_CALLDATE,
round(greatest(ci.ovamt+ci.dueamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0),0) OVDAMOUNTREF,
round(nvl(OD.LOSTASS,0),0) SELLLOSTASSREF,
round(nvl(od.sellamount,0),0) SELLAMOUNTREF,SEC.OUTSTANDING,CF.CAREBY
from cfmast cf, afmast af, cimast ci, aftype aft,mrtype mrt,
     --v_getsecmarginratio sec,
     (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance from buf_ci_account ) sec,
      (select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)
                                    +round(intnmlovd)+round(feeintnmlacr)+round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                 trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                 trunc(sum(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd) + round(nvl(ls.dueamt,0)) + round(feeintdue)),0) marginovdamt,
                 trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt
        from lnmast ln,
                (select acctno, sum(nml+intdue) dueamt  from lnschd
                        where reftype = 'P' and overduedate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by acctno) ls
        where ftype = 'AF'
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln,
--(select acctno, sum(acclimit) advanceline from useraflimit where typereceive = 'T0' group by acctno) t0,
(
   select max(txdate) CALLDATE, max(txtime) CALLTIME, acctno from sendmsglog group by acctno
) SMS, tlgroups tlg,
(select od.afacctno,
    round(greatest(
            --least(sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(rsk.advrate,0)*getnonworkingday(3)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
            --T2-NAMNT
            least(sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(rsk.advrate,0)*getnonworkingday(SYS1.advclearday)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
            --END T2-NAMNT
                    sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)-nvl(rsk.advminfee,0)/*Gia tri tien ve tinh theo phi UTTB toi thieu*/))
            - sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(rsk.mrirate,100) = 0 then 100 else nvl(rsk.mrirate,100) end) )
            ,0)
            ) sellamount,
    round(greatest(sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(rsk.mrirate,100) = 0 then 100 else nvl(rsk.mrirate,100) end) ),0)) lostass
    from odmast od, odtype odt,
        (select af.acctno, af.mrirate, nvl(adt.advrate,0)/100 advrate,nvl(adt.advminfee,0) advminfee, rsk.*
            from afmast af, afserisk rsk, aftype aft, adtype adt
            where af.actype = rsk.actype(+)
            and af.actype = aft.actype and aft.adtype = adt.actype
            ) rsk,
        securities_info sec,
        sysvar sy,
       (select TO_NUMBER(varvalue) advclearday from sysvar where grname='SYSTEM' and varname='ADVCLEARDAY' and rownum<=1) SYS1
    where od.exectype in ('NS','MS') --and isdisposal = 'Y'
    and od.afacctno = rsk.acctno(+) and od.codeid = rsk.codeid(+)
    and od.codeid = sec.codeid
    and od.actype = odt.actype
    and sy.varname = 'ADVSELLDUTY'
    and od.remainqtty > 0
    group by afacctno) OD
where cf.custid = af.custid
and cf.custatcom = 'Y'
and af.actype = aft.actype and aft.mrtype = mrt.actype and mrt.mrtype ='T'
and af.acctno = ci.acctno
and af.acctno = sec.afacctno
and af.acctno = ln.trfacctno(+)
--and af.acctno = ismr.acctno(+)
--and af.actype = cof.aftype(+)
--and af.acctno = t0.acctno(+)
and af.acctno = sms.acctno(+)
and af.acctno = od.afacctno(+)
and aft.istrfbuy <> 'Y' and cf.careby = tlg.grpid
and ((AFT.MNEMONIC <>'T3'
      AND (
            (af.mrlrate <= sec.marginrate AND sec.marginrate < AF.MRMRATE )-- Rtt<Rcall
          OR (AF.Mrlrate<=SEC.MARGINRATE AND SEC.MARGINRATE<AF.MRCRATE AND AF.Callday>0
              -- Rtt<Rt.call va call k ngay lien tiep
          )
        )
      AND (AF.CALLDAY<AF.K1DAYS ))
      or ((ci.dueamt-GREATEST(0,CI.BALANCE+NVL(AVLADVANCE,0)- CI.BUYSECAMT))>1))
AND CI.OVAMT =0
AND (AF.CALLDAY<AF.K1DAYS or AF.CALLDAY =0)
AND af.mrlrate <= sec.marginrate
/
