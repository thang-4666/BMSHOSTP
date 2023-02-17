SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_MR0005
(GROUPLEADER, ACTYPE, TYPENAME, CUSTODYCD, ACCTNO, 
 FULLNAME, MOBILESMS, EMAIL, MARGINRATE, RTNAMT, 
 RTNREMAINAMT, MRIRATE, MRMRATE, MRLRATE, MRCRATE, 
 TOTALVND, ADVANCELINE, SEASS, MRCRLIMIT, MRCRLIMITMAX, 
 DFODAMT, MRCRLIMITREMAIN, STATUS, OVDAMOUNT, T0OVDAMOUNT, 
 DUEAMOUNT, RMAMT, CALLDATE, CALLTIME, OUTSTANDING, 
 RTNAMOUNTREF, OVDAMOUNTREF, SELLLOSTASSREF, SELLAMOUNTREF, CALLDAY, 
 TRIGGERDAY, MONEYPAY, MNEMONIC, REFULLNAME, REGROUPNAME, 
 ADDVND, ADDVND2, ADD_TO_MRCRATE, ADD_TO_MRIRATE, ADVDUEAMOUNT, 
 CAREBY)
BEQUEATH DEFINER
AS 
select af.groupleader, af.actype, aft.typename,
cf.custodycd,af.acctno, cf.fullname, cf.mobilesms, cf.email,
nvl(sec.marginrate,0) marginrate,
case when aft.mnemonic <> 'T3' then
    round(greatest(round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - sec.outstanding else
                         greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRWRATE) end),0),0),0)
else 0 end rtnamt,
case when aft.mnemonic <> 'T3' then
    GREATEST(ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrcrate =0 then - sec.outstanding else
                         greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRWRATE) end),0),0),0),
             greatest(nvl(LN.ADVDUEAMOUNT,0)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0))
else  greatest(nvl(LN.ADVDUEAMOUNT,0)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0) end rtnremainamt,
af.mrirate, af.mrmrate, af.mrlrate, af.MRCRATE,ci.balance + nvl(avladvance,0) totalvnd, af.advanceline,--nvl(t0.advanceline,0) advanceline,
nvl(sec.seass,0) seass, af.mrcrlimit,
af.mrcrlimitmax, ci.dfodamt,af.mrcrlimitmax - ci.dfodamt mrcrlimitremain, af.status,
case when mrt.mrtype ='T' then ci.ovamt else 0 end ovdamount,
case when mrt.mrtype <>'T' then ci.ovamt else 0 end t0ovdamount,
ci.dueamt dueamount,
0 RMAMT,
CALLDATE, CALLTIME, nvl(sec.outstanding,0) outstanding,
case when aft.mnemonic <> 'T3' then
    GREATEST(ROUND(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                         greatest( 0,- sec.outstanding - sec.navaccount *100/(AF.MRWRATE)) end),0),0),0),
               greatest(nvl(LN.ADVDUEAMOUNT,0)/*+ROUND(ci.depofeeamt)*/ - ci.balance - avladvance,0) )
else  0
end RTNAMOUNTREF,
round(greatest(nvl(LN.ADVDUEAMOUNT,0)/*+ci.depofeeamt*/ - ci.balance - nvl(avladvance,0),0),0) OVDAMOUNTREF,
0 SELLLOSTASSREF,
0 SELLAMOUNTREF,
af.callday,
--to_number(to_date(sy.varvalue,'DD/MM/RRRR')-nvl(af.triggerdate,to_date(sy.varvalue,'DD/MM/RRRR'))) triggerday,
nvl((select nvl(-numday,0) from sbcurrdate where sbdate = af.triggerdate and sbtype = 'B'),0) triggerday,
case when aft.mnemonic <> 'T3' then
    ltrim(to_char(round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else greatest( 0,- sec.outstanding - sec.navaccount *100/af.mrmrate) end),0),greatest(nvl(LN.ADVDUEAMOUNT,0)- ci.balance - nvl(avladvance,0),0)),0),'9,999,999,999'))
else
    ltrim(to_char(round(greatest(nvl(LN.ADVDUEAMOUNT,0)+ci.depofeeamt - ci.balance - nvl(avladvance,0),0),0),'9,999,999,999'))
end moneypay,
aft.mnemonic,re.refullname, tlg.grpname REGROUPNAME,
CASE WHEN aft.mnemonic<>'T3' then
     round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRWRATE) end),0),greatest(nvl(LN.ADVDUEAMOUNT,0) - ci.balance - nvl(avladvance,0),0)),0)
ELSE 0
END ADDVND,
CASE WHEN aft.mnemonic<>'T3' then
     round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - sec.outstanding else
                     greatest( 0,- sec.outstanding - sec.navaccount *100/AF.MRWRATE) end),0),greatest(nvl(LN.ADVDUEAMOUNT,0) - ci.balance ,0)),0)
ELSE 0
END ADDVND2,
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
nvl(LN.ADVDUEAMOUNT,0) ADVDUEAMOUNT, CF.CAREBY
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
        ) re,(
   select max(txdate) CALLDATE, max(txtime) CALLTIME, acctno from sendmsglog group by acctno
) SMS, tlgroups tlg,
(select * from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM') SY,
(SELECT MST.TRFACCTNO AFACCTNO,
        SUM(SCHD.NML+SCHD.INTNMLACR+SCHD.FEEINTNMLACR+SCHD.INTDUE+SCHD.FEEINTDUE) ADVDUEAMOUNT
 FROM LNSCHD SCHD,LNMAST MST,LNTYPE TYP
 WHERE SCHD.ACCTNO=MST.ACCTNO AND MST.ACTYPE=TYP.ACTYPE
 AND fn_get_prevdate(SCHD.OVERDUEDATE,TYP.Warningdays)<=GETCURRDATE
 AND SCHD.OVERDUEDATE >GETCURRDATE
 GROUP BY MST.TRFACCTNO) LN
where cf.custid = af.custid
and cf.custatcom = 'Y' and cf.careby = tlg.grpid
and af.actype = aft.actype and aft.mrtype =mrt.actype and af.actype <> '0000'
and af.acctno = ci.acctno
and af.acctno = sec.afacctno
and af.acctno = sms.acctno(+)
and cf.custid = re.afacctno(+)
AND AF.Acctno=LN.AFACCTNO(+)
and (CI.OVAMT+CI.DUEAMT=0)
AND (
    (AFT.MNEMONIC <>'T3') and
                  ((sec.marginrate<AF.MRwRATE and sec.marginrate>=AF.MRCRATE)-- chi pham ti le canh bao
                  OR (SEC.MARGINRATE<AF.MRCRATE AND SEC.MARGINRATE>=AF.MRMRATE AND AF.Callday=0)-- vi pham R thoat Call nhung callday=0
                  OR (EXISTS (SELECT * FROM LNSCHD SCHD,LNMAST MST,LNTYPE TYPE --den ngay canh bao
                            WHERE MST.ACCTNO=SCHD.ACCTNO AND MST.TRFACCTNO=AF.ACCTNO AND MST.ACTYPE=TYPE.ACTYPE
                            AND fn_get_prevdate(SCHD.OVERDUEDATE,TYPE.Warningdays)<=GETCURRDATE  AND SCHD.OVERDUEDATE >GETCURRDATE)
                         and af.callday = 0 and sec.marginrate > af.mrcrate
                     )
                  )

     )
/
