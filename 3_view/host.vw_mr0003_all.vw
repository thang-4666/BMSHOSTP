SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0003_ALL
(GROUPLEADER, ACTYPE, TYPENAME, CUSTODYCD, ACCTNO, 
 FULLNAME, MOBILESMS, EMAIL, CAREBY, MARGINRATE, 
 RTNAMT, RTNREMAINAMT, MRIRATE, MRMRATE, MRLRATE, 
 TOTALVND, ADVANCELINE, SEASS, MRCRLIMIT, MRCRLIMITMAX, 
 DFODAMT, MRCRLIMITREMAIN, STATUS, OVDAMOUNT, T0OVDAMOUNT, 
 DUEAMOUNT, RMAMT, CALLDATE, CALLTIME, OUTSTANDING, 
 RTNAMOUNTREF, OVDAMOUNTREF, SELLLOSTASSREF, SELLAMOUNTREF, CALLDAY, 
 TRIGGERDAY, MONEYPAY, MNEMONIC, REFULLNAME, REGROUPNAME, 
 CALLTYPE, SELLTYPE, MRCRATE, FIRST_CALLDATE, ADDVND, 
 ADDVND2, ADD_TO_MRCRATE, ADD_TO_MRIRATE, ADD_TO_SELL_ENOUGH, MREXRATE)
BEQUEATH DEFINER
AS 
select af.groupleader, af.actype, aft.typename,
cf.custodycd,af.acctno, cf.fullname, cf.mobilesms, cf.email,CF.CAREBY,
nvl(sec.marginrate,0) marginrate,
case when aft.mnemonic <> 'T3' then
    round(greatest(round((case when /*nvl(sec.marginrate,0) **/ af.mrcrate =0 then - sec.outstanding else
                         greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRCRATE) end),0),0),0)
else 0 end rtnamt,

--round(greatest(ci.ovamt+ci.dueamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0),0) addvnd,
--round(greatest(ci.ovamt+ci.dueamt/*+ci.depofeeamt*/ - ci.balance ,0),0) addvnd2,
case when aft.mnemonic <> 'T3' then
    round(greatest(round((case when /*nvl(sec.marginrate,0) **/ af.mrcrate =0 then - sec.outstanding else
                         greatest( 0,- sec.outstanding - sec.navaccount *100/(af.MRCRATE))*(1+AF.Mrexrate/100) end),0),greatest((round(ci.ovamt/*+ci.dueamt*/)/*+round(ci.depofeeamt)*/ - ci.balance - nvl(avladvance,0)) *(1+AF.Mrexrate/100) - nvl(lostass,0),0))  - nvl(od.sellamount,0),0)
else --Ngoc.vu edit bo no den han dueamt VCBSDEPII-809
    round((greatest((round(ci.ovamt/*+ci.dueamt*/)/*+round(ci.depofeeamt)*/ - ci.balance - nvl(avladvance,0))*(1+AF.Mrexrate/100) - nvl(lostass,0),0))  - nvl(od.sellamount,0),0)
end rtnremainamt,
af.mrirate, af.mrmrate, af.mrlrate, ci.balance + nvl(avladvance,0) totalvnd, af.advanceline,--nvl(t0.advanceline,0) advanceline,
nvl(sec.seass,0) seass, af.mrcrlimit,
af.mrcrlimitmax, ci.dfodamt,af.mrcrlimitmax - ci.dfodamt mrcrlimitremain, af.status,
case when mrt.mrtype ='T' then ci.ovamt else 0 end ovdamount,
case when mrt.mrtype <>'T' then ci.ovamt else 0 end t0ovdamount,
ci.dueamt dueamount,
round(nvl(od.sellamount,0),0) RMAMT,
CALLDATE, CALLTIME, nvl(sec.outstanding,0) outstanding,
case when aft.mnemonic <> 'T3' then
    round(greatest(round((case when /*nvl(sec.marginrate,0) **/ af.mrcrate =0 then - sec.outstanding else
                         greatest( 0,- sec.outstanding - sec.navaccount *100/(AF.MRCRATE))*(1+AF.Mrexrate/100) end),0),0),0)
else 0
end RTNAMOUNTREF,
round(greatest(ci.ovamt/*+ci.dueamt*//*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0),0)  OVDAMOUNTREF,
round(nvl(lostass,0),0) SELLLOSTASSREF,
round(nvl(od.sellamount,0),0) SELLAMOUNTREF,
af.callday,
--to_number(to_date(sy.varvalue,'DD/MM/RRRR')-nvl(af.triggerdate,to_date(sy.varvalue,'DD/MM/RRRR'))) triggerday,
nvl((select nvl(-numday,0) from sbcurrdate where sbdate = af.triggerdate and sbtype = 'B'),0) triggerday,
case when aft.mnemonic <> 'T3' then
    ltrim(to_char(round(greatest(round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - sec.outstanding else greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrcrate) end),0),greatest(ci.ovamt/*+ci.dueamt*//*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0)),0),'9,999,999,999'))
else
    ltrim(to_char(round(greatest(ci.ovamt/*+ci.dueamt+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0),0),'9,999,999,999'))
end moneypay,
aft.mnemonic,re.refullname, tlg.grpname REGROUPNAME,
(CASE WHEN  CI.ovamt=0 THEN 'Tỷ lệ'
      WHEN CI.ovamt>0 AND
             ((sec.marginrate<af.mrlrate and af.mrlrate <> 0)
                           OR (sec.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS OR AF.CALLDAY >=AF.K2DAYS ))
              ) THEN 'Tỷ lệ - nợ quá hạn'
      ELSE 'Nợ quá hạn' END) CALLTYPE,
(CASE WHEN AF.Callday>=AF.K2DAYS THEN 'Bán hết' ELSE 'Bán đủ' END) SELLTYPE,
AF.Mrcrate,fn_get_prevdate(GETCURRDATE,AF.CALLDAY) FIRST_CALLDATE,
CASE WHEN aft.mnemonic<>'T3' then
     round(greatest(round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRCRATE) end),0),greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0)),0)
ELSE 0
END ADDVND,
CASE WHEN aft.mnemonic<>'T3' then
     round(greatest(round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRCRATE) end),0),greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance ,0)),0)
ELSE 0
END ADDVND2,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRCRATE) end),0)
else
    0
end ADD_TO_MRCRATE,
case when aft.mnemonic<>'T3' then
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/AF.MRIRATE) end),0)
else
    0
end ADD_TO_MRIRATE,
(case when aft.mnemonic<>'T3' then
    greatest(
    round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - nvl(sec.outstanding,0) else greatest( 0,- nvl(sec.outstanding,0) - nvl(sec.navaccount,0) *100/(AF.MRCRATE)) end),0),
    greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0)
    )
else
    greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0)
end) * (1+AF.Mrexrate/100)  ADD_TO_SELL_ENOUGH,AF.Mrexrate
from cfmast cf, afmast af, cimast ci, aftype aft,mrtype mrt,
    (select afacctno, marginrate,se_outstanding outstanding,se_navaccount navaccount,seass, seamt,avladvance from buf_ci_account ) sec,
    (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re,
(select od.afacctno,
    round(greatest(
    --T2 NAMNT
            --least(sum(od.remainqtty*od.quoteprice*(1-od.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(od.advrate,0)*getnonworkingday(3)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
            least(sum(od.remainqtty*od.quoteprice*(1-od.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(od.advrate,0)*getnonworkingday(SYS1.advclearday)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
    --END T2 NAMNT
                    sum(od.remainqtty*od.quoteprice*(1-od.deffeerate/100-to_number(sy.varvalue)/100)-nvl(od.advminfee,0)/*Gia tri tien ve tinh theo phi UTTB toi thieu*/))
            - sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(od.mrirate,100) = 0 then 100 else nvl(od.mrirate,100) end) )
            ,0)
            ) sellamount,
    round(greatest(sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(od.mrirate,100) = 0 then 100 else nvl(od.mrirate,100) end) ),0)) lostass

    from
        (select od.*, aft.actype aftype , af.mrirate, nvl(adt.advrate,0)/100 advrate,nvl(adt.advminfee,0) advminfee, odt.deffeerate
        from odmast od, odtype odt,afmast af, aftype aft, adtype adt
        where od.exectype in ('NS','MS')  and od.remainqtty > 0
            and od.actype = odt.actype and od.afacctno = af.acctno
            and af.actype = aft.actype and aft.adtype = adt.actype) od,
        afserisk rsk,
        securities_info sec,
        sysvar sy,
        (select TO_NUMBER(varvalue) advclearday from sysvar where grname='SYSTEM' and varname='ADVCLEARDAY' and rownum<=1) SYS1
    where  od.aftype = rsk.actype(+) and od.codeid = rsk.codeid(+)
    and od.codeid = sec.codeid
    and sy.varname = 'ADVSELLDUTY'
    group by afacctno) od,
(
   select max(txdate) CALLDATE, max(txtime) CALLTIME, acctno from sendmsglog group by acctno
) SMS, tlgroups tlg,
(select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') sy
where cf.custid = af.custid
and cf.custatcom = 'Y' and cf.careby = tlg.grpid
and af.actype = aft.actype and aft.mrtype =mrt.actype and af.actype <> '0000'
and af.acctno = ci.acctno
and af.acctno = sec.afacctno
and af.acctno = sms.acctno(+)
and af.acctno = od.afacctno(+)
and cf.custid = re.afacctno(+)
and (
    (aft.mnemonic <>'T3' and
                  ((sec.marginrate<af.mrlrate and af.mrlrate <> 0)
                  OR (sec.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))
                  )

     )
     or (CI.OVAMT-GREATEST(0,CI.BALANCE+NVL(AVLADVANCE,0)- CI.BUYSECAMT))>1 )
/
