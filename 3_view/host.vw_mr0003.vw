SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0003
(GROUPLEADER, ACTYPE, TYPENAME, CUSTODYCD, ACCTNO, 
 FULLNAME, MOBILESMS, EMAIL, MARGINRATE, RTNAMT, 
 ADDVND2, RTNREMAINAMT, MRIRATE, MRMRATE, MRLRATE, 
 TOTALVND, ADVANCELINE, SEASS, MRCRLIMIT, MRCRLIMITMAX, 
 DFODAMT, MRCRLIMITREMAIN, STATUS, OVDAMOUNT, T0OVDAMOUNT, 
 RMAMT, CALLDATE, CALLTIME, OUTSTANDING, RTNAMOUNTREF, 
 OVDAMOUNTREF, SELLLOSTASSREF, SELLAMOUNTREF, CALLDAY, TRIGGERDAY, 
 MONEYPAY, MNEMONIC, CALLTYPE, SELLTYPE, MRCRATE, 
 ADDVND, ADD_TO_MRCRATE, ADD_TO_MRIRATE, ADD_TO_SELL_ENOUGH, FIRST_CALLDATE)
BEQUEATH DEFINER
AS 
select af.groupleader, af.actype, aft.typename, --DECODE(co_financing,'Y','YES','NO') co_financing, DECODE(ismarginacc,'Y','YES','NO') ismarginacc,
cf.custodycd,af.acctno, cf.fullname, cf.mobilesms, cf.email,
nvl(sec.marginrate,0) marginrate,
round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),0),0) rtnamt,

/*--THeo yeu cau BSC thi khong call do giam ty le ma chi do den han qua han
round(greatest(ci.ovamt\*+ci.depofeeamt*\ - ci.balance - nvl(avladvance,0),0),0) addvnd,*/
round(greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance,0),0) addvnd2,
round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),greatest(round(ci.ovamt)/*+round(ci.depofeeamt)*/ - ci.balance - nvl(avladvance,0) - nvl(lostass,0),0))  - nvl(od.sellamount,0),0) rtnremainamt,

af.mrirate, af.mrmrate, af.mrlrate, ci.balance + nvl(avladvance,0) totalvnd, af.advanceline,--nvl(t0.advanceline,0) advanceline,
nvl(sec.seass,0) seass, af.mrcrlimit,
af.mrcrlimitmax, ci.dfodamt,af.mrcrlimitmax - ci.dfodamt mrcrlimitremain, af.status, nvl(ln.marginovdamt,0) ovdamount,round(nvl(ln.t0amt,0)) t0ovdamount,
round(nvl(od.sellamount,0),0) RMAMT,
CALLDATE, CALLTIME, nvl(sec.outstanding,0) outstanding,

round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),0),0) RTNAMOUNTREF,
round(greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0),0) OVDAMOUNTREF,
round(nvl(lostass,0),0) SELLLOSTASSREF,
round(nvl(od.sellamount,0),0) SELLAMOUNTREF,
af.callday,
--to_number(to_date(sy.varvalue,'DD/MM/RRRR')-nvl(af.triggerdate,to_date(sy.varvalue,'DD/MM/RRRR'))) triggerday,
nvl((select nvl(-numday,0) from sbcurrdate where sbdate = af.triggerdate and sbtype = 'B'),0) triggerday,
ltrim(to_char(round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0)),0),'9,999,999,999')) moneypay,
aft.mnemonic,
(CASE WHEN  CI.ovamt=0 THEN 'Tỉ lệ'
      WHEN CI.ovamt>0 AND
             ((sec.marginrate<af.mrlrate and af.mrlrate <> 0)
                           OR (sec.marginrate<AF.MRCRATE AND (AF.CALLDAY =AF.K1DAYS OR AF.CALLDAY =AF.K2DAYS ))
              ) THEN 'Tỉ lệ-Nợ quá hạn'
      ELSE 'Nợ quá hạn' END) CALLTYPE,
(CASE WHEN AF.Callday=AF.K2DAYS THEN 'Bán hết' ELSE 'Bán đủ' END) SELLTYPE,
AF.Mrcrate,
round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRCRATE) end),0),greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0)),0) addvnd,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0)
else
    0
end ADD_TO_MRCRATE,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRIRATE) end),0)
else
    0
end ADD_TO_MRIRATE,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/(AF.MRCRATE+AF.MREXRATE)) end),0)
else
    0
end ADD_TO_SELL_ENOUGH,
fn_get_prevdate(GETCURRDATE,AF.CALLDAY) FIRST_CALLDATE
from cfmast cf, afmast af, cimast ci, aftype aft,
    --v_getsecmarginratio sec,
    (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance from buf_ci_account ) sec,
    /*(select acctno, 'Y' ismarginacc from afmast af
          where exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y'
                          union all
                          select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y')
          group by acctno) ismr,
    (select aftype, 'Y' co_financing from afidtype where objname = 'LN.LNTYPE' group by aftype) cof,*/
    (select trfacctno, trunc(sum(round(prinnml)+round(prinovd)+round(intnmlacr)+round(intdue)+round(intovdacr)+round(intnmlovd)+round(feeintnmlacr)+round(feeintdue)+round(feeintovdacr)+round(feeintnmlovd)),0) marginamt,
                 trunc(sum(round(oprinnml)+round(oprinovd)+round(ointnmlacr)+round(ointdue)+round(ointovdacr)+round(ointnmlovd)),0) t0amt,
                 trunc(sum(round(prinovd)+round(intovdacr)+round(intnmlovd)+round(feeintovdacr)+round(feeintnmlovd)),0) marginovdamt,
                 trunc(sum(round(oprinovd)+round(ointovdacr)+round(ointnmlovd)),0) t0ovdamt
        from lnmast ln,
                (select acctno, round(sum(nml+intdue)) dueamt  from lnschd
                        where reftype = 'P' and overduedate = (select to_date(varvalue,'DD/MM/RRRR') from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM')
                        group by acctno) ls
        where ftype = 'AF'
                and ln.acctno = ls.acctno(+)
        group by ln.trfacctno) ln,
--(select acctno, sum(acclimit) advanceline from useraflimit where typereceive = 'T0' group by acctno) t0,
(select od.afacctno,
    round(greatest(
           -- least(sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(rsk.advrate,0)*getnonworkingday(3)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
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
    group by afacctno) od,
(
   select max(txdate) CALLDATE, max(txtime) CALLTIME, acctno from sendmsglog group by acctno
) SMS,
(select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy
where cf.custid = af.custid
and cf.custatcom = 'Y'
and af.actype = aft.actype
and af.acctno = ci.acctno
and af.acctno = sec.afacctno
and af.acctno = ln.trfacctno(+)
--and af.acctno = ismr.acctno(+)
--and af.actype = cof.aftype(+)
--and af.acctno = t0.acctno(+)
and af.acctno = sms.acctno(+)
and af.acctno = od.afacctno(+)
--and aft.istrfbuy <> 'Y'
and (
    (sec.marginrate<af.mrlrate and af.mrlrate <> 0)
    OR (sec.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS OR AF.CALLDAY >=AF.K2DAYS ))
    or ci.ovamt>1
    )
/
