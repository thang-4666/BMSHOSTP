SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR1013" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   p_DATE         in       VARCHAR2,
   p_RESTYPE      in       VARCHAR2,
   p_CUSTODYCD   IN       VARCHAR2,
   p_AFACCTNO    IN       VARCHAR2,
   PV_AFTYPE      IN       VARCHAR2,
   p_FR_RLSDATE       in       VARCHAR2,
   p_TO_RLSDATE       in       VARCHAR2,
   p_FR_OVERDUEDATE       in       VARCHAR2,
   p_TO_OVERDUEDATE       in       VARCHAR2,
   p_ISVSD       in       VARCHAR2,
   p_RLSTYPE       in       VARCHAR2,
   p_PAIDSTATUS       in       VARCHAR2,
   p_PERIODSTATUS       in       VARCHAR2,
   p_USER       in       VARCHAR2,
   GRCAREBY       IN       VARCHAR2,
   P_GROUPID       IN       VARCHAR2,
   TLID            IN       VARCHAR2
   )
IS
--

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   12-APR-2012  CREATE
-- ---------   ------  -------------------------------------------

    l_OPT varchar2(10);
    l_BRID varchar2(1000);
    l_BRID_FILTER varchar2(1000);
    l_CUSTODYCD varchar2(10);
    l_AFACCTNO varchar2(10);
    v_strAFTYPE      VARCHAR2(20);
    l_ISVSD varchar2(10);
    V_STRTLID           VARCHAR2(6);
    l_companyshortname varchar2(10);

    V_CURRDATE          date;
    V_CAREBY    varchar2(10);
    v_GROUPID   varchar2(10);

BEGIN

-- Prepare Parameters
   V_STRTLID:= TLID;
    l_OPT:=p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = pv_BRID;
        else
            l_BRID_FILTER := pv_BRID;
        end if;
    END IF;

    if p_CUSTODYCD = 'A' or p_CUSTODYCD = 'ALL' then
        l_CUSTODYCD:= '%%';
    else
        l_CUSTODYCD:= p_CUSTODYCD;
    end if;

    if p_AFACCTNO = 'A' or p_AFACCTNO = 'ALL' then
        l_AFACCTNO:= '%%';
    else
        l_AFACCTNO:= p_AFACCTNO;
    end if;

    if PV_AFTYPE = 'ALL' then
        v_strAFTYPE := '%%';
    elsIF TRIM(PV_AFTYPE) = '001' then
        v_strAFTYPE := 'Margin';
    elsIF TRIM(PV_AFTYPE) = '002' then
        v_strAFTYPE := 'T3';
    ELSE
        v_strAFTYPE := 'Thu?ng';
    end if ;

    IF p_ISVSD = 'ALL' then
        l_ISVSD := '%%';
    elsIF TRIM(p_ISVSD) = '001' THEN
        l_ISVSD := 'N';
    else
        l_ISVSD := 'Y';
    end if;

    IF (GRCAREBY is null or upper(GRCAREBY) = 'ALL')
    THEN
        V_CAREBY := '%';
    ELSE
        V_CAREBY := GRCAREBY;
    END IF;

    IF (P_GROUPID is null or upper(P_GROUPID) = 'ALL')
    THEN
        v_GROUPID := '%';
    ELSE
        v_GROUPID := P_GROUPID;
    END IF;

    l_companyshortname:=cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME');

    select to_date(varvalue,'DD/MM/RRRR') into V_CURRDATE
    from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';---V_CURRDATE

    OPEN PV_REFCURSOR
    FOR
    SELECT restype, rlstype, custodycd, afacctno, rlsdate, overduedate, lnschdid, rlsprin, paid, lnprin, intamt, feeintamt ,fullname, mnemonic,GRPNAME,MRCRLIMITMAX,intpaid
    FROM (
        select  NVL(DF.ISVSD,'N') ISVSD, nvl(cfb.shortname,l_companyshortname) restype,
            decode (NVL(DF.ISVSD,'N'),'Y', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','')||'-VSD', decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','') ) rlstype,
            cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate, ls.autoid lnschdid,
            ls.nml + ls.ovd +ls.paid rlsprin, ls.intpaid - nvl(lg.intpaid,0) intpaid,
            ls.paid - nvl(lg.paid,0) paid, ls.nml + ls.ovd - nvl(lg.nml,0) - nvl(lg.ovd,0) lnprin,
            ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
            ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic,RE.GRPNAME,AF.MRCRLIMITMAX
        from vw_lnmast_all ln, vw_lnschd_all ls, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid, sum(intpaid) intpaid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > to_date(p_DATE,'DD/MM/RRRR')
            group by autoid) lg,
            (
            SELECT  MAX( REGRP.AUTOID) AUTOID , MAX( SUBSTR(re.reacctno,1,10)) RECUSTID , re.afacctno , MAX(REGRP.FULLNAME) GRPNAME
                FROM reaflnk re, regrplnk REGl,retype,regrp
                WHERE re.reacctno = REGl.reacctno(+)
                AND  SUBSTR(RE.reacctno,11)=RETYPE.actype
                AND retype.rerole ='RM'
                AND REGl.refrecflnkid = regrp.autoid(+)
                AND to_date(p_DATE,'DD/MM/RRRR') BETWEEN re.frdate AND  nvl(re.clstxdate-1, re.todate)
                AND to_date(p_DATE,'DD/MM/RRRR') BETWEEN REGl.frdate AND  nvl(REGl.clstxdate-1, REGl.todate)
                GROUP BY re.afacctno
                ) re,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and af.custid = re.afacctno(+)
            and case when p_RESTYPE = 'ALL' then 1
                    when ln.rrtype = 'C' and p_RESTYPE = l_companyshortname then 1
                    when ln.rrtype = 'B' and p_RESTYPE = nvl(cfb.shortname,l_companyshortname) then 1
                    else 0 end <> 0
            and cf.custodycd like l_CUSTODYCD
            and af.acctno like l_AFACCTNO
            and af.actype = aft.actype
            and aft.mnemonic like v_strAFTYPE
            and ls.rlsdate <= to_date(p_DATE,'DD/MM/RRRR')
            and ls.rlsdate between to_date(p_FR_RLSDATE,'DD/MM/RRRR') and to_date(p_TO_RLSDATE,'DD/MM/RRRR')
            and to_date(ls.overduedate) between to_date(p_FR_OVERDUEDATE,'DD/MM/RRRR') and to_date(p_TO_OVERDUEDATE,'DD/MM/RRRR')
            and case when p_RLSTYPE = 'ALL' then p_RLSTYPE else decode(ln.ftype||ls.reftype,'AFGP','BL','AFP','CL','DFP','DF','') end = p_RLSTYPE
            and case when p_PAIDSTATUS = 'ALL' then 1
                    when p_PAIDSTATUS = '001'
                                        and
                                        abs(ls.nml + ls.ovd) +
                                            abs( ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0)) +
                                             abs(ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0)) <1 THEN 1

                    when p_PAIDSTATUS = '002' and
                                        abs(ls.nml + ls.ovd) +
                                            abs( ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0)) +
                                             abs(ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0)) >=1 THEN 1
                    else 0 end <> 0
            and case when p_PERIODSTATUS = 'ALL' then 1
                when to_date(p_DATE,'DD/MM/RRRR') between ls.rlsdate and ls.overduedate - 1 and p_PERIODSTATUS = '001' then 1
                when to_date(p_DATE,'DD/MM/RRRR') = ls.overduedate and p_PERIODSTATUS = '002' then 1
                when to_date(p_DATE,'DD/MM/RRRR') > ls.overduedate and p_PERIODSTATUS = '003' then 1
                else 0 end <> 0
            and case when p_USER = 'ALL' then 1 when nvl(re.recustid,'') = p_USER then 1 else 0 end <> 0

            AND AF.CAREBY LIKE V_CAREBY
            and case when P_GROUPID = 'ALL' then 1 when nvl(re.AUTOID,'') = P_GROUPID then 1 else 0 end <> 0
    ) A WHERE isvsd like l_ISVSD
    order by custodycd, afacctno, lnacctno, rlsdate, lnschdid;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;-- PROCEDURE

 
 
 
 
/
