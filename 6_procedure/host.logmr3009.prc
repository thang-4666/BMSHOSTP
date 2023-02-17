SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LOGMR3009" (PV_REFCURSOR IN OUT   PKG_REPORT.REF_CURSOR,V_OPT IN  VARCHAR2) IS
    l_NEXTDATE varchar2(10);
    l_PREVDATE varchar2(10);
BEGIN
select varvalue into l_NEXTDATE from sysvar where varname = 'CURRDATE';
select varvalue into l_PREVDATE from sysvar where varname = 'PREVDATE';
DELETE FROM mr3009_log;

insert into mr3009_log

select *
from (
select  TO_DATE(l_NEXTDATE,'DD/MM/RRRR') RPTDATE, 'AF' FTYPE,cf.custodycd, af.acctno afacctno, '' dfgroupid, cf.fullname,
    sec.marginrate, af.mrlrate,
    greatest(-outstanding,0) odamt, sec.navaccount NAVACCOUNT,
    round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - outstanding else
                     greatest( 0,- outstanding - sec.navaccount*100/af.mrmrate) end),0),greatest(ci.ovamt/*+depofeeamt*/ - balance - nvl(avladvance,0),0)),0) rtnamtCL,
    0 rtnamtDF,
    nvl(lnt0.ovd,0) ovd,
    nvl(cl_ovdamt,0) MARGINOVD,
    re.refullname, SYSTIMESTAMP txtime
from cfmast cf, afmast af, cimast ci, aftype aft, mrtype mrt, v_getsecmarginratio sec,
(select trfacctno,
        sum(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd) ovd,
        sum(prinovd+intovdacr+intnmlovd+feeintovdacr+feeintnmlovd) cl_ovdamt
    from lnmast
    where ftype = 'AF' group by trfacctno) lnt0,
    (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
    ) re
where cf.custid = af.custid and af.acctno = sec.afacctno
and af.actype = aft.actype and af.acctno = ci.acctno
and cf.custatcom = 'Y'
and aft.mrtype = mrt.actype --and mrt.mrtype = 'T'
and af.acctno = lnt0.trfacctno(+)
and af.acctno = re.afacctno(+)
and ((sec.marginrate<af.mrlrate and af.mrlrate <> 0)
          or ci.ovamt>1
          or (EXISTS (select 1 from mr3008_log where afacctno= af.acctno and txdate = to_date(l_PREVDATE,'DD/MM/RRRR') and log_action ='AF-END' and FTYPE ='AF')
                and sec.marginrate >= af.mrlrate and sec.marginrate<af.mrmrate and af.mrlrate <>0 and af.mrmrate <> 0
             )
        )

union all

SELECT TO_DATE(l_NEXTDATE,'DD/MM/RRRR') RPTDATE,'DF' FTYPE, custodycd,afacctno,groupid,
fullname,rtt,lrate,DDF, TADF,0, ODSELLDF, ovd, nvl(df_ovdamt,0) MARGINOVD, refullname, SYSTIMESTAMP txtime
FROM ( select al1.cdcontent DEALFLAGTRIGGER,DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,DECODE(DF.LIMITCHK,'N',0,1) LIMITCHECK ,
DF.ORGAMT -DF.RLSAMT AMT, DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
DF.TAX,DF.AMTMIN,DF.IRATE,DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION, lns.rlsdate, lns.overduedate,
to_date (lns.overduedate,'DD/MM/RRRR') - to_date ((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') duenum,
(case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '' end )
RRID , decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN,
decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,LN.RLSAMT AMTRLS,
LN.RATE1,LN.RATE2,LN.RATE3,LN.CFRATE1,LN.CFRATE2,LN.CFRATE3,
A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS,TADF,DDF, RTTDF RTT, ODCALLDF, ODCALLSELLIRATE - NVL(od.sellamount,0) ODSELLDF, ODCALLRTTDF, ODCALLMRATE ODCALLRTTF,
ODCALLSELLRCB, ODCALLSELLMRATE, ODCALLSELLMRATE - NVL(od.sellamount,0) ODCALLSELLMR, ODCALLSELLRXL,
CURAMT, CURINT, CURFEE, LNS.PAID, DF.DFBLOCKAMT, vndselldf, vndwithdrawdf, tadf - ddf*(v.irate/100) vwithdrawdf,
LEAST(ln.MInterm, TO_NUMBER( TO_DATE(lns.OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(lns.RLSDATE,'DD/MM/RRRR')) )  MInterm, ln.intpaidmethod, lnt.WARNINGDAYS,
A4.CDCONTENT RRTYPENAME,CF.EMAIL, ODDF, nvl(avladvance,0) avladvance, balance, ovamt, depofeeamt,nvl(lnt0.ovd,0) ovd, odoverduedf, re.refullname,
nvl(ln.prinovd+ln.intovdacr+ln.intnmlovd+ln.feeintovdacr+ln.feeintnmlovd,0) df_ovdamt
from dfgroup df, dftype, lnmast ln, lntype lnt ,lnschd lns, afmast af, cimast ci , cfmast cf, allcode al1,
   ALLCODE A1, ALLCODE A2, ALLCODE A3, v_getgrpdealformular v , allcode A4, v_getdealsellamt od,
   (select sum(aamt) aamt,sum(depoamt) avladvance,sum(paidamt) paidamt, sum(advamt) advanceamount,afacctno from v_getAccountAvlAdvance_all group by afacctno) adv,
(select trfacctno,
        sum(decode(ftype,'AF',1,0)*(oprinnml+oprinovd+ointnmlacr+ointdue+ointovdacr+ointnmlovd)) ovd
    from lnmast
    group by trfacctno) lnt0,
(select re.afacctno, MAX(cf.fullname) refullname
        from reaflnk re, sysvar sys, cfmast cf,RETYPE
        where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
        and substr(re.reacctno,0,10) = cf.custid
        and varname = 'CURRDATE' and grname = 'SYSTEM'
        and re.status <> 'C' and re.deltd <> 'Y'
        AND   substr(re.reacctno,11) = RETYPE.ACTYPE
        AND  rerole IN ( 'RM','BM')
        GROUP BY AFACCTNO) re
where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and ln.actype=lnt.actype and lns.reftype='P' and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
and A1.cdname = 'YESNO' and A1.cdtype ='SY' AND A1.CDVAL = LN.PREPAID
and A2.cdname = 'INTPAIDMETHOD' and A2.cdtype ='LN' AND A2.CDVAL = LN.INTPAIDMETHOD
and A3.cdname = 'AUTOAPPLY' and a3.cdtype ='LN' AND A3.CDVAL = LN.AUTOAPPLY
and A4.cdname = 'RRTYPE' and A4.cdtype ='DF' AND A4.CDVAL = DF.RRTYPE
and df.flagtrigger=al1.cdval and al1.cdname='FLAGTRIGGER' and df.groupid=v.groupid(+)
and df.groupid=od.groupid(+) and df.afacctno=od.afacctno(+)
and af.acctno = ci.acctno and af.acctno = adv.afacctno(+)
and af.acctno = lnt0.trfacctno(+)
and af.acctno = re.afacctno(+)
) MST WHERE ((ODDF>0 AND (RTT < LRATE or odoverduedf>0))
                or df_ovdamt > 0
                or (EXISTS (select 1 from mr3008_log where afacctno= MST.afacctno and txdate = to_date(l_PREVDATE,'DD/MM/RRRR') and log_action ='AF-END' and FTYPE ='DF')
                and RTT >= LRATE and RTT < MRATE  and LRATE <>0 and MRATE <> 0
                )
            )
) order by custodycd, dfgroupid;



COMMIT;
OPEN PV_REFCURSOR
    FOR SELECT rptdate, ftype, custodycd, afacctno, dfgroupid, fullname, marginrate, mrlrate, odamt, navaccount, rtnamtcl, rtnamtdf, ovd, refullname, TO_CHAR(txtime,'HH24:MM:SS') TXTIME
          FROM mr3009_log ;

  EXCEPTION WHEN OTHERS THEN
  dbms_output.put_line('ERROR:'||SQLERRM||'.AY:'||dbms_utility.FORMAT_ERROR_BACKTRACE);
     RETURN;
END;

 
 
 
 
/
