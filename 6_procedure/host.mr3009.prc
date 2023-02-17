SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3009" (
   PV_REFCURSOR                 IN OUT   PKG_REPORT.REF_CURSOR,
   PV_OPT                       IN       VARCHAR2,
   PV_BRID                      IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE                       IN       VARCHAR2,
   p_ISASSREMAIN                IN       VARCHAR2,
   ISCALLED                     IN       VARCHAR2,
   PV_AFTYPE                    IN       VARCHAR2,
   SERVICETYPE                  IN       VARCHAR2,
   PV_CUSTODYCD                 IN       VARCHAR2,
   PV_AFACCTNO                  IN       VARCHAR2
      )
IS
-- MODIFICATION HISTORY
-- BAO CAO TONG HOP MARGIN CALL THEO NGAY
-- PERSON   DATE  COMMENTS
-- LINHLNB  13-04-2012  CREATED
-- ---------   ------  -------------------------------------------
l_NEXTDATE varchar2(10);
l_PREVDATE varchar2(10);
l_CURRDATE varchar2(10);
l_OPT varchar2(10);
l_BRID varchar2(1000);
l_BRID_FILTER varchar2(1000);
l_ISCALLED varchar2(10);
l_SERVICETYPE varchar2(10);
l_aftype varchar2(10);
l_CUSTODYCD  varchar2(10);
L_ACCTNO  VARCHAR2(10);
BEGIN

select varvalue into l_NEXTDATE from sysvar where varname = 'NEXTDATE';
select varvalue into l_PREVDATE from sysvar where varname = 'PREVDATE';
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

IF (PV_AFTYPE <> 'ALL')
 THEN
   l_AFTYPE := PV_AFTYPE;
 ELSE
   l_AFTYPE := '%%';
END IF;


IF (SERVICETYPE <> 'ALL')
 THEN
   l_SERVICETYPE := SERVICETYPE;
 ELSE
   l_SERVICETYPE := '%%';
END IF;


select '[' || brid || ']: ' || brname into l_BRID
from brgrp
where brid = PV_BRID;

IF(PV_CUSTODYCD <> 'ALL')
   THEN
        l_CUSTODYCD  := PV_CUSTODYCD;
   ELSE
        l_CUSTODYCD  := '%%';
   END IF;

   IF(PV_AFACCTNO <> 'ALL')
   THEN
        L_ACCTNO  := PV_AFACCTNO;
   ELSE
        L_ACCTNO := '%%';
   END IF;

l_ISCALLED:=ISCALLED;

if l_CURRDATE = I_DATE then --Lay du lieu trong ngay

    OPEN PV_REFCURSOR
    FOR
    select *
    from (
    select l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,'AF' FTYPE,cf.custodycd, af.acctno afacctno, '' dfgroupid, cf.fullname,
        sec.marginrate, af.mrlrate,
        greatest(-outstanding,0) odamt, sec.navaccount NAVACCOUNT,
        round(greatest(round((case when nvl(sec.marginrate,0) * af.mrmrate =0 then - outstanding else
                         greatest( 0,- outstanding - sec.navaccount*100/af.mrmrate) end),0),greatest(ci.ovamt/*+depofeeamt*/ - balance - nvl(avladvance,0),0)),0) rtnamtCL,
        0 rtnamtDF,
        nvl(lnt0.ovd,0) ovd,
        nvl(cl_ovdamt,0) MARGINOVD,
        re.refullname , TLG.grpname carebyname
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af, cimast ci, aftype aft, mrtype mrt, v_getsecmarginratio sec,
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
        GROUP BY AFACCTNO) re, tlgroups TLG
    where cf.custid = af.custid and af.acctno = sec.afacctno
    and af.actype = aft.actype and af.acctno = ci.acctno
    and cf.custatcom = 'Y'
    and aft.mrtype = mrt.actype --and mrt.mrtype = 'T'
    AND af.acctno LIKE L_ACCTNO
    AND cf.custodycd LIKE l_CUSTODYCD
    and af.acctno = lnt0.trfacctno(+)
    and af.acctno = re.afacctno(+) AND CF.careby = TLG.grpid
    and ((sec.marginrate<af.mrlrate and af.mrlrate <> 0)
          or ci.ovamt>1
          or (EXISTS (select 1 from mr3008_log lg
                      where afacctno= af.acctno and txdate = to_date(l_PREVDATE,'DD/MM/RRRR')
                      and log_action ='AF-END' and FTYPE ='AF'
                      and round(lg.marginrate) < lg.mrmrate
                      )
                and sec.marginrate >= af.mrlrate and round(sec.marginrate)<af.mrmrate and l_ISCALLED='Y' and af.mrlrate <>0 and af.mrmrate <> 0
             )
        )
    and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
    and case when p_ISASSREMAIN = 'ALL' then 1
             when sec.navaccount > 0 and p_ISASSREMAIN = 'Y' then 1
             when sec.navaccount <= 0 and p_ISASSREMAIN = 'N' then 1
        else 0 end <> 0
   AND 'AF'  LIKE L_SERVICETYPE
   and  aft.mnemonic like l_aftype
    union all

    SELECT l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE,'DF' FTYPE, custodycd,afacctno,groupid,
    fullname,rtt,lrate,DDF, TADF,0, ODSELLDF, ovd, nvl(df_ovdamt,0) MARGINOVD, refullname, carebyname
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
    A4.CDCONTENT RRTYPENAME, CF.MOBILESMS FAX1, CF.EMAIL, ODDF, nvl(avladvance,0) avladvance, balance, ovamt, depofeeamt,nvl(lnt0.ovd,0) ovd, odoverduedf, re.refullname,
    nvl(ln.prinovd+ln.intovdacr+ln.intnmlovd+ln.feeintovdacr+ln.feeintnmlovd,0) df_ovdamt, TLG.grpname carebyname
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
        GROUP BY AFACCTNO
    ) re, tlgroups TLG, aftype
    where df.lnacctno= ln.acctno and ln.acctno=lns.acctno and ln.actype=lnt.actype and lns.reftype='P' and df.afacctno= af.acctno and af.custid= cf.custid and df.actype=dftype.actype
    and A1.cdname = 'YESNO' and A1.cdtype ='SY' AND A1.CDVAL = LN.PREPAID
    and A2.cdname = 'INTPAIDMETHOD' and A2.cdtype ='LN' AND A2.CDVAL = LN.INTPAIDMETHOD
    and A3.cdname = 'AUTOAPPLY' and a3.cdtype ='LN' AND A3.CDVAL = LN.AUTOAPPLY
    and A4.cdname = 'RRTYPE' and A4.cdtype ='DF' AND A4.CDVAL = DF.RRTYPE
    and af.actype = aftype.actype
    and aftype.mnemonic like l_aftype
    AND af.acctno LIKE L_ACCTNO
    AND cf.custodycd LIKE l_CUSTODYCD
    and df.flagtrigger=al1.cdval and al1.cdname='FLAGTRIGGER' and df.groupid=v.groupid(+)
    and df.groupid=od.groupid(+) and df.afacctno=od.afacctno(+)
    and af.acctno = ci.acctno and af.acctno = adv.afacctno(+)
    and af.acctno = lnt0.trfacctno(+)
    and af.acctno = re.afacctno(+) AND CF.careby = TLG.grpid
    and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
    AND 'DF'  LIKE L_SERVICETYPE
    and case when p_ISASSREMAIN = 'ALL' then 1
             when TADF > 0 and p_ISASSREMAIN = 'Y' then 1
             when TADF <= 0 and p_ISASSREMAIN = 'N' then 1
        else 0 end <> 0
    ) MST WHERE ((ODDF>0 AND (RTT < LRATE or odoverduedf>0))
                or df_ovdamt > 0
                or (EXISTS (select 1 from mr3008_log lg
                            where afacctno= MST.afacctno and txdate = to_date(l_PREVDATE,'DD/MM/RRRR')
                            and log_action ='AF-END' and FTYPE ='DF'
                            and round(lg.marginrate) < lg.mrmrate
                            )
                and RTT >= LRATE and round(RTT) < MRATE and l_ISCALLED='Y' and LRATE <>0 and MRATE <> 0
                )
            )
    ) order by custodycd, dfgroupid;

else --Lau du lieu trong qua khu
    if l_ISCALLED='Y' then
        OPEN PV_REFCURSOR
        FOR
        SELECT l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE, LG.FTYPE, LG.custodycd,  LG.afacctno,
            LG.dfgroupid, LG.fullname, LG.marginrate, LG.mrlrate,
            LG.odamt, LG.NAVACCOUNT, LG.rtnamtCL, LG.rtnamtDF, LG.ovd, LG.MARGINOVD,
            LG.refullname, TLG.grpname carebyname
        from mr3009_logall lg, tlgroups TLG, cfmast cf,afmast af, aftype aft
        where LG.txdate = to_date(I_DATE,'DD/MM/RRRR')
        and LG.log_action ='AF-END' and LG.custodycd = CF.custodycd AND CF.careby = TLG.grpid
        and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(LG.afacctno,1,4)) end  <> 0
        and case when p_ISASSREMAIN = 'ALL' then 1
                 when LG.NAVACCOUNT > 0 and p_ISASSREMAIN = 'Y' then 1
                 when LG.NAVACCOUNT <= 0 and p_ISASSREMAIN = 'N' then 1
            else 0 end <> 0
        and cf.custid = af.custid
        and lg.ftype like l_aftype
        and af.actype = aft.actype
        and aft.mnemonic like l_aftype
        AND af.acctno LIKE L_ACCTNO
         AND cf.custodycd LIKE l_CUSTODYCD
        order by LG.custodycd, LG.dfgroupid;
    else
        OPEN PV_REFCURSOR
        FOR
        SELECT l_OPT OPT,l_BRID BRID, l_NEXTDATE RPTDATE, LG.FTYPE, LG.custodycd,  LG.afacctno, LG.dfgroupid, LG.fullname,
            LG.marginrate, LG.mrlrate,
            LG.odamt, LG.NAVACCOUNT,
            LG.rtnamtCL,
            LG.rtnamtDF,
            LG.ovd,
            LG.MARGINOVD,
            LG.refullname, TLG.grpname carebyname
        from mr3009_logall lg, tlgroups TLG, cfmast cf, aftype aft,afmast af
        where LG.txdate = to_date(I_DATE,'DD/MM/RRRR')
        and LG.log_action ='AF-END' and LG.custodycd = CF.custodycd AND CF.careby = TLG.grpid
        and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(LG.afacctno,1,4)) end  <> 0
        and case when p_ISASSREMAIN = 'ALL' then 1
                 when LG.NAVACCOUNT > 0 and p_ISASSREMAIN = 'Y' then 1
                 when LG.NAVACCOUNT <= 0 and p_ISASSREMAIN = 'N' then 1
            else 0 end <> 0
        and ((LG.marginrate<LG.mrlrate and LG.mrlrate <> 0)
                or ovd>1 or LG.MARGINOVD>1)
        and cf.custid = af.custid
        and lg.ftype like l_aftype
        and af.actype = aft.actype
        and aft.mnemonic like l_aftype
        AND af.acctno LIKE L_ACCTNO
         AND cf.custodycd LIKE l_CUSTODYCD
        order by LG.custodycd, LG.dfgroupid;
    end if;
end if;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
