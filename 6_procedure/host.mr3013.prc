SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR3013" (
   PV_REFCURSOR           IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT                    IN       VARCHAR2,
   pv_BRID                   IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   p_DATE                       IN       VARCHAR2,
   TLID            IN       VARCHAR2
  )
IS

--
-- BAO CAO DANH MUC CHUNG KHOAN THUC HIEN GIAO DICH KI QUY
-- MODIFICATION HISTORY
-- PERSON       DATE                COMMENTS
-- ---------   ------  -------------------------------------------
--

   l_OPT varchar2(10);
   l_BRID varchar2(1000);
   l_BRID_FILTER varchar2(1000);
   l_CurrDate date;
    V_STRTLID           VARCHAR2(6);

BEGIN


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

    select to_date(varvalue,'DD/MM/RRRR') into l_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

if l_CurrDate = to_date(p_DATE,'DD/MM/RRRR') then

    OPEN PV_REFCURSOR FOR
    select cf.custodycd, sec74.afacctno, cf.fullname, af.mriratio mrirate, af.mrmratio mrmrate, af.mrlratio mrlrate, sec74.marginrate74 marginrate,
        nvl(sec74.sereal,0) navaccount,
        greatest(nvl(marginamt,0) - nvl(sec74.avladvance,0) - balance,0) outstanding,
        case when (sec74.sereal + GREATEST(balance + nvl(avladvance,0) - nvl(ln.marginamt,0),0)) = 0 then greatest(nvl(marginamt,0) - nvl(sec74.avladvance,0) - balance,0)
            else round(greatest((af.mrmratio/100 - sec74.marginrate74/100) * (sec74.sereal + GREATEST(balance + nvl(avladvance,0) - nvl(ln.marginamt,0),0)),0),0) end addvnd,
        nvl(refullname,'') refullname
    from v_getsecmarginratio_74 sec74, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, cimast ci,
        (select trfacctno, sum(prinnml+prinovd+intnmlacr+intnmlovd+intdue+intovdacr+fee+feeovd+feedue+feeintnmlacr+feeintnmlovd+feeintdue+feeintovdacr) marginamt
                from lnmast ln, lntype lnt
                where ln.actype = lnt.actype
                and ln.ftype = 'AF'
                and lnt.chksysctrl = 'Y'
                group by ln.trfacctno) ln,
        (select re.afacctno, cf.fullname refullname
            from reaflnk re, sysvar sys, cfmast cf
            where to_date(varvalue,'DD/MM/RRRR') between re.frdate and re.todate
            and substr(re.reacctno,0,10) = cf.custid
            and varname = 'CURRDATE' and grname = 'SYSTEM'
            and re.status <> 'C' and re.deltd <> 'Y') re
    where cf.custid = af.custid and af.acctno = sec74.afacctno
        and af.acctno = ln.trfacctno(+)
        and af.acctno = ci.acctno and af.acctno = re.afacctno(+)
        and sec74.marginrate74 <= af.mrlratio
        AND (substr(af.acctno,1,4) LIKE l_BRID_FILTER OR instr(l_BRID_FILTER,substr(af.acctno,1,4))<> 0)
        and greatest(nvl(marginamt,0) - nvl(sec74.avladvance,0) - balance,0) >0
        and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    order by cf.custodycd;

else

    OPEN PV_REFCURSOR FOR
/*    select log.*, cf.custodycd, cf.fullname, cfb.fullname refullname,
        greatest(round((case when nvl(log.marginrate,0) * log.mrmrate =0 then nvl(log.outstanding,0) else
                             greatest( 0, nvl(log.outstanding,0) - nvl(log.navaccount,0) *100/log.mrmrate) end),0),0) addvnd
    from report_rskmngt_log log, cfmast cf, afmast af, cfmast cfb
    where cf.custid = af.custid and af.acctno = log.afacctno
        and log.recustid = cfb.custid(+)
        and log.txdate = (select max(txdate) from report_rskmngt_log where txdate <= to_date(p_DATE,'DD/MM/RRRR'))
        and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
        and log.marginrate <= log.mrlrate
    order by cf.custodycd;*/
    select log.*, cf.custodycd, cf.fullname, cfb.fullname refullname,
        case when (nvl(log.navaccount,0) + GREATEST(-nvl(log.outstanding,0),0)) = 0 then log.outstanding
            else round(greatest((log.mrmrate/100 - log.marginrate/100) * (nvl(log.navaccount,0) + GREATEST(-nvl(log.outstanding,0),0)),0),0) end addvnd
    from report_rskmngt_log log, cfmast cf, afmast af, cfmast cfb
    where cf.custid = af.custid and af.acctno = log.afacctno
        and log.recustid = cfb.custid(+)
        and log.txdate = (select max(txdate) from report_rskmngt_log where txdate <= to_date(p_DATE,'DD/MM/RRRR'))
        --and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(af.acctno,1,4)) end  <> 0
        AND (substr(af.acctno,1,4) LIKE l_BRID_FILTER OR instr(l_BRID_FILTER,substr(af.acctno,1,4))<> 0)
        and log.marginrate <= log.mrlrate
        and log.outstanding > 0
        and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    order by cf.custodycd;

end if;


EXCEPTION
  WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
