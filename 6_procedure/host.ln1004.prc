SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "LN1004" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT            IN       VARCHAR2,
   p_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   p_I_DATE         IN       VARCHAR2,
   p_BANKNAME       IN       VARCHAR2,
   p_LOANTYPE       IN       VARCHAR2,
   p_SIGNTYPE       IN       VARCHAR2
       )
IS

-- RP NAME : Giai Ngan Tien Vay
-- PERSON : LinhLNB
-- DATE : 04/04/2012
-- COMMENTS : Create New
-- ---------   ------  -------------------------------------------
l_LOANTYPE varchar2(100);
l_BANKNAME varchar2(100);
l_OPT varchar2(10);
l_BRID varchar2(1000);
l_BRID_FILTER varchar2(1000);
l_INITRLSDATE date;
l_companyshortname varchar2(10);
BEGIN
    -- GET REPORT'S PARAMETERS
    l_BANKNAME:=p_BANKNAME; -- ALL, BVSC, CF.SHORTNAME

    l_LOANTYPE:=p_LOANTYPE; -- ALL, BL, CL, DF

    l_OPT:=p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = p_BRID;
        else
            l_BRID_FILTER := p_BRID;
        end if;
    END IF;
    l_companyshortname:=cspks_system.fn_get_sysvar('SYSTEM','COMPANYSHORTNAME');
    select nvl(min(rlsdate),to_date(p_I_DATE,'DD/MM/RRRR')+1) into l_INITRLSDATE from rlsrptlog_eod;

    -- GET REPORT'S DATA
    OPEN PV_REFCURSOR
     FOR
    select cf.custodycd, cf.idcode, to_char(cf.iddate,'DD/MM/RRRR') iddate, cf.idplace, l.afacctno,
           cf.fullname, l.mrcrlimitmax, l.mrcrlimitremain, l.rlsamt lnamt, l.totalprinamt lnprin,
           rate rate2, to_char(l.overduedate,'DD/MM/RRRR') overduedate, marginratio krate,
           ln.ftype || ls.reftype reftype,
           decode(ln.ftype || ls.reftype,'AFGP',utf8nums.c_const_reftype_AFGP,'AFP',utf8nums.c_const_reftype_AFP,'DFP',utf8nums.c_const_reftype_DFP,'')
                reftype_desc,
           ln.rrtype || case when ln.rrtype = 'B' then cfb.shortname when ln.rrtype = 'C' then l_companyshortname else null end rsctype,
           case when ln.rrtype = 'C' then l_companyshortname
            when ln.rrtype = 'B' then cfb.fullname
            else '' end rsctype_desc,
           ln.ftype, ls.reftype reftypecd, cfb.shortname bankname,
           p_SIGNTYPE SIGNTYPE
    from rlsrptlog_eod l, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, p_BRID, TLGOUPS)=0) cf, cfmast cfb, vw_lnmast_all ln, vw_lnschd_all ls
    where l.custid = cf.custid
        and l.custbank = cfb.custid(+)
        and ln.acctno = ls.acctno
        and ls.autoid = l.lnschdid
        and l.rlsdate = to_date(p_I_DATE,'DD/MM/RRRR')
        and case when l_OPT = 'A' then 1 else instr(l_BRID_FILTER,substr(afacctno,1,4)) end  <> 0
        and case --when l_BANKNAME = 'ALL' then 1
                when l_BANKNAME = l_companyshortname and l.rrtype = 'C' then 1
                --when cfb.shortname = l_BANKNAME and l.rrtype = 'B' then 1
            else 0 end = 1
        and case when l_LOANTYPE = 'ALL' then 1
                --when l_LOANTYPE = 'BL' and l.rrtype = 'C' and ftype = 'AF' and reftype = 'GP' then 1
                when l_LOANTYPE = 'CL' and ftype = 'AF' and reftype = 'P' then 1
                --when l_LOANTYPE = 'DF' and ftype = 'DF' and reftype = 'P' then 1
            else 0 end = 1
    order by custodycd, afacctno;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
