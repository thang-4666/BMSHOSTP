SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0016" (
   PV_REFCURSOR      IN OUT   PKG_REPORT.REF_CURSOR,
   p_OPT             IN       VARCHAR2,
   p_BRID            IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   p_DATE            IN       VARCHAR2,
   p_CUSTODYCD       IN       VARCHAR2,
   P_ADDAMT          IN       VARCHAR2
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
    v_INDATE        DATE;
    V_CURRDATE      DATE;
BEGIN

-- Prepare Parameters

    l_OPT := p_OPT;

    IF (l_OPT = 'A') THEN
      l_BRID_FILTER := '%';
    ELSE if (l_OPT = 'B') then
            select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = p_BRID;
        else
            l_BRID_FILTER := p_BRID;
        end if;
    END IF;

    if upper(p_CUSTODYCD) = 'ALL' or p_CUSTODYCD is null then
        l_CUSTODYCD:= '%';
    else
        l_CUSTODYCD:= p_CUSTODYCD;
    end if;


    v_INDATE := to_date(p_DATE,'dd/mm/rrrr');
    select to_date(VARVALUE,'DD/MM/RRRR') into V_CURRDATE from sysvar where grname='SYSTEM' and varname='CURRDATE';

IF v_INDATE = V_CURRDATE THEN
    OPEN PV_REFCURSOR
    FOR
    SELECT v_INDATE indate, custodycd, acctno, fullname, sereal, mramt,
        addvnd, marginrate, brname
    FROM
    (
    select cf.custodycd, af.acctno, cf.fullname, v.sereal, nvl(ln.mramt,0) mramt,
        round(greatest(round((case when nvl(mr.marginrate,0) * af.mrmrate =0 then - mr.outstanding else
                     greatest( 0,- mr.outstanding - mr.navaccount *100/af.mrmrate) end),0),greatest(ci.ovamt/*+ci.depofeeamt*/ - ci.balance - nvl(mr.avladvance,0),0)),0
                     ) addvnd, mr.marginrate, br.brname
    from (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, p_BRID, TLGOUPS)=0) cf, afmast af, cimast ci, v_getsecmargininfo sec, vw_getsecmargindetail v, brgrp br,
        (select afacctno, sum(depoamt) AVLADVANCE
            from v_getaccountavladvance group by afacctno) adv,
        (select afacctno, nvl(sum(secureamt),0) SECUREDAMT
            from v_getbuyorderinfo group by afacctno) b,
        (select trfacctno,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
            from lnmast group by trfacctno) ln,
        v_getsecmarginratio mr
    where cf.custid = af.custid and af.acctno = ci.afacctno
    and af.brid = br.brid
    and af.acctno = mr.afacctno(+)
    and af.acctno = adv.afacctno(+)
    and af.acctno = b.afacctno(+)
    and af.acctno = ln.trfacctno(+)
    and af.acctno = v.afacctno(+)
    and af.acctno = sec.afacctno(+)
    and cf.custodycd like l_CUSTODYCD
    order by v.symbol
    )
    WHERE ((addvnd = 0 AND P_ADDAMT = 'NO') OR P_ADDAMT = 'ALL')
        OR ((addvnd <> 0 AND P_ADDAMT = 'YES') OR P_ADDAMT = 'ALL')
    ;
else
    OPEN PV_REFCURSOR
    FOR
    SELECT v_INDATE indate, custodycd, acctno, fullname, sereal, mramt, addvnd, marginrate,
        brname
    FROM
    (
    select cf.custodycd, af.acctno, cf.fullname, v.sereal, v.mramt, mr.addvnd, mr.marginrate,
        br.brname
    from tbl_mr3007_log v, vw_mr0003 mr, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, p_BRID, TLGOUPS)=0) cf, brgrp br, afmast af
    where af.acctno = mr.acctno(+) and v.custodycd = cf.custodycd and cf.custid = af.custid
        and af.brid = br.brid
        and v.txdate = v_INDATE
        and cf.custodycd like l_CUSTODYCD
        and (v.sereal <> 0 or v.mramt <> 0)
    order by v.txdate
    ) WHERE ((addvnd = 0 AND P_ADDAMT = 'NO') OR P_ADDAMT = 'ALL')
        OR ((addvnd <> 0 AND P_ADDAMT = 'YES') OR P_ADDAMT = 'ALL')
    ;
end if;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
