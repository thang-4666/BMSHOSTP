SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3008" (
   PV_REFCURSOR                 IN OUT   PKG_REPORT.REF_CURSOR,
   PV_OPT                       IN       VARCHAR2,
   PV_BRID                      IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE                       IN       VARCHAR2
   )
IS
-- MODIFICATION HISTORY
-- BAO CAO TONG HOP MARGIN CALL THEO NGAY
-- PERSON   DATE  COMMENTS
-- LINHLNB  13-04-2012  CREATED
-- ---------   ------  -------------------------------------------
l_NEXTDATE varchar2(10);
l_CURRDATE  varchar2(10);
l_OPT varchar2(10);
l_BRID varchar2(1000);
l_BRID_FILTER varchar2(1000);
BEGIN

select varvalue into l_NEXTDATE from sysvar where varname = 'NEXTDATE';
select varvalue into l_CURRDATE from sysvar where varname = 'CURRDATE';
l_OPT:=PV_OPT;

IF (l_OPT = 'A') THEN
  l_BRID_FILTER := '%';
ELSE if (l_OPT = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = PV_BRID;
    else
        l_BRID_FILTER := PV_BRID;
    end if;
END IF;

select '[' || brid || ']: ' || brname into l_BRID
from brgrp
where brid = PV_BRID;

if l_CURRDATE = I_DATE then --Lay du lieu trong ngay

    OPEN PV_REFCURSOR
    FOR
        select *
        from (
        select l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,'AF' FTYPE,cf.custodycd, af.acctno afacctno, '' dfgroupid, cf.fullname,
        round(sec.marginrate) marginrate, af.mrmrate,
            ci.odamt, sec.NAVACCOUNT,
            greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - outstanding else
                             greatest( 0,- outstanding - navaccount *100/af.mrmrate) end),0)) addvnd,
        re.refullname, TLG.grpname CAREBYNAME
        from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, cimast ci, aftype aft, mrtype mrt, v_getsecmarginratio sec,
        (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re, tlgroups TLG
        where cf.custid = af.custid and af.acctno = sec.afacctno
        and af.actype = aft.actype and af.acctno = ci.acctno
        and aft.mrtype = mrt.actype and mrt.mrtype = 'T'
        and af.acctno = re.afacctno(+) AND CF.careby = TLG.grpid
        and (af.mrlrate <= sec.marginrate AND round(sec.marginrate) < af.mrmrate)
        and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0

        union all

        SELECT l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,'DF' FTYPE,custodycd,afacctno, groupid dfgroupid,fullname, round(rtt) rtt, mrate, DDF, tadf, ODSELLDF,
            refullname, CAREBYNAME
        FROM ( select al1.cdcontent DEALFLAGTRIGGER,DF.GROUPID,CF.CUSTODYCD,CF.FULLNAME,AF.ACCTNO AFACCTNO,CF.ADDRESS,CF.IDCODE,DECODE(DF.LIMITCHK,'N',0,1) LIMITCHECK ,
        DF.ORGAMT -DF.RLSAMT AMT, DF.LNACCTNO , DF.STATUS DEALSTATUS ,DF.ACTYPE ,DF.RRTYPE, DF.DFTYPE, DF.CUSTBANK, DF.CIACCTNO,DF.FEEMIN,
        DF.TAX,DF.AMTMIN,DF.IRATE,DF.MRATE,DF.LRATE,DF.RLSAMT,DF.DESCRIPTION, lns.rlsdate, lns.overduedate,
        to_date (lns.overduedate,'DD/MM/RRRR') - to_date ((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') duenum,
        (case when df.ciacctno is not null then df.ciacctno when df.custbank is not null then   df.custbank else '' end )
        RRID , decode (df.RRTYPE,'O',1,0) CIDRAWNDOWN,decode (df.RRTYPE,'B',1,0) BANKDRAWNDOWN,
        decode (df.RRTYPE,'C',1,0) CMPDRAWNDOWN,dftype.AUTODRAWNDOWN,df.calltype,LN.RLSAMT AMTRLS,
        LN.RATE1,LN.RATE2,LN.RATE3,LN.CFRATE1,LN.CFRATE2,LN.CFRATE3,
        A1.CDCONTENT PREPAIDDIS,A2.CDCONTENT INTPAIDMETHODDIS,A3.CDCONTENT AUTOAPPLYDIS,TADF,DDF, RTTDF RTT, ODCALLDF, ODCALLSELLRCB,ODCALLSELLMRATE, ODCALLSELLIRATE - NVL(od.sellamount,0) ODSELLDF, ODCALLSELLRXL, ODCALLRTTDF, ODCALLRTTDF ODCALLRTTF,
        CURAMT, CURINT, CURFEE, LNS.PAID, DF.DFBLOCKAMT, vndselldf, vndwithdrawdf, tadf - ddf*(v.irate/100) vwithdrawdf,
        LEAST(ln.MInterm, TO_NUMBER( TO_DATE(lns.OVERDUEDATE,'DD/MM/RRRR') - TO_DATE(lns.RLSDATE,'DD/MM/RRRR')) )  MInterm, ln.intpaidmethod, lnt.WARNINGDAYS,
        A4.CDCONTENT RRTYPENAME, CF.MOBILESMS FAX1, CF.EMAIL, ODDF, re.refullname,
        nvl(ln.prinovd+ln.intovdacr+ln.intnmlovd+ln.feeintovdacr+ln.feeintnmlovd,0)  df_ovdamt,
        TLG.grpname CAREBYNAME
        from dfgroup df, dftype, lnmast ln, lntype lnt ,lnschd lns, afmast af , (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode al1,
           ALLCODE A1, ALLCODE A2, ALLCODE A3, v_getgrpdealformular v , allcode A4, v_getdealsellamt od,
        (select re.afacctno, MAX(cf.fullname) refullname
            from reaflnk re, sysvar sys, cfmast cf,RETYPE
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y'
            AND   substr(re.reacctno,11) = RETYPE.ACTYPE
            AND  rerole IN ( 'RM','BM')
            GROUP BY AFACCTNO
        ) re, tlgroups TLG
        where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and ln.actype=lnt.actype and lns.reftype='P' and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
        and A1.cdname = 'YESNO' and A1.cdtype ='SY' AND A1.CDVAL = LN.PREPAID
        and A2.cdname = 'INTPAIDMETHOD' and A2.cdtype ='LN' AND A2.CDVAL = LN.INTPAIDMETHOD
        and A3.cdname = 'AUTOAPPLY' and a3.cdtype ='LN' AND A3.CDVAL = LN.AUTOAPPLY
        and A4.cdname = 'RRTYPE' and A4.cdtype ='DF' AND A4.CDVAL = DF.RRTYPE
        and df.flagtrigger=al1.cdval and al1.cdname='FLAGTRIGGER' and df.groupid=v.groupid(+)
        and df.groupid=od.groupid(+) and df.afacctno=od.afacctno(+)
        and df.afacctno = re.afacctno(+) AND CF.careby = TLG.grpid
        and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
        ) WHERE ODDF>0 AND ( round(RTT) < MRATE AND RTT>= LRATE) and df_ovdamt <=0
        ) order by custodycd, dfgroupid;

else --Lau du lieu trong qua khu
    OPEN PV_REFCURSOR
    FOR
    SELECT l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE, lg.FTYPE, lg.custodycd, lg.afacctno, lg.dfgroupid,
        lg.fullname, round(lg.marginrate) marginrate, lg.mrmrate, lg.odamt, lg.NAVACCOUNT, lg.addvnd,
        lg.refullname, TLG.grpname CAREBYNAME
    from mr3008_log lg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, tlgroups TLG
    where txdate = to_date(I_DATE,'DD/MM/RRRR')
    and log_action ='AF-MID'
    and round(marginrate) < mrmrate AND LG.custodycd = CF.custodycd
    AND CF.careby = TLG.grpid
    and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(afacctno,1,4)) end  <> 0
    order by custodycd, dfgroupid;

end if;

EXCEPTION
   WHEN OTHERS
   THEN
 --   pr_error('MR3008','Error when others then:'||SQLERRM);
      RETURN;
END;

 
 
 
 
/
