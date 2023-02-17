SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0018" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2
)
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- LINHLNB   11-Apr-2012  CREATED

-- ---------   ------  -------------------------------------------
   l_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
   l_STRBRID          VARCHAR2 (4);

   V_FDATE           DATE; --ngay lam viec gan ngay fdate nhat
   v_TDATE           DATE; --ngay lam viec gan ngay tdate nhat
   v_CurrDate        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE


BEGIN



   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS

    V_FDATE := to_date(F_DATE,'DD/MM/RRRR');
    v_TDATE := to_date(T_DATE,'DD/MM/RRRR');
   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';


  -- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
select mst.custodycd, mst.fullname, mst.total_end, mst.total_MRamt_end, (mst.total_T3amt_end+nvl(ad_END.amt,0)) total_T3amt_end,
    mst.total_gh3_end, mst.total_gh4_end, mst.total_qh3_end, mst.total_qh4_end,
    nvl(ps.total_bg,0) total_bg, nvl(ps.total_MRamt_bg,0) total_MRamt_bg, nvl(ps.total_T3amt_bg,0)+nvl(ad_bg.amt,0) total_T3amt_bg,
    nvl(ps.total_gh3_bg,0) total_gh3_bg, nvl(ps.total_gh4_bg,0) total_gh4_bg, nvl(ps.total_qh3_bg,0) total_qh3_bg,
    nvl(ps.total_qh4_bg,0) total_qh4_bg, 0 odamt_ps
from
(
    SELECT * FROM
    (
    select * from
    (
        select custodycd, fullname, sum(lnprin+lnprovd) total_end,
            sum(case when mnemonic = 'Margin' and ftype = 'AF' then lnprin+lnprovd else 0 end) total_MRamt_end,
            sum(case when (mnemonic = 'Margin' and ftype = 'AF') then 0 else lnprin+lnprovd end) total_T3amt_end,
            sum(case when (ROUND((overduedate-rlsdate)/90,0)-1) > 0 and (ROUND((overduedate-rlsdate)/90,0)-1) <= 1 then
                lnprin+lnprovd else 0 end) total_gh3_end,
            sum(case when (ROUND((overduedate-rlsdate)/90,0)-1) > 1 then
                lnprin+lnprovd else 0 end) total_gh4_end,
            sum(case when (v_TDATE-overduedate) > 0 and (v_TDATE-overduedate) <= 30 then
                lnprin+lnprovd else 0 end) total_qh3_end,
            sum(case when (v_TDATE-overduedate) > 30 then
                lnprin+lnprovd else 0 end) total_qh4_end
        from
        (
            select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
                ls.nml - nvl(lg.nml,0) lnprin,
                ls.ovd - nvl(lg.ovd,0) lnprovd,
                ls.paid - nvl(lg.paid,0) lnprpaid,
                ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
                - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
                ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
                - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
                cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid, ln.ftype
            from vw_lnmast_all ln, vw_lnschd_all ls, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,aftype aft, cfmast cfb,
                (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                    sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                    sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > v_TDATE
                group by autoid) lg,
                (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
            where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
                and ln.trfacctno = af.acctno and af.custid = cf.custid
                and ln.custbank = cfb.custid(+)
                and ls.autoid = lg.autoid(+)
                and ln.acctno = df.lnacctno(+)
                and af.actype = aft.actype and af.actype <> '0000'
                and ls.rlsdate <= v_TDATE
        )
        group by custodycd, fullname
    )
    order by total_end desc
    )
    where rownum <= 20
) mst,
(
        select custodycd, fullname, sum(lnprin+lnprovd) total_bg,
            sum(case when mnemonic = 'Margin' and ftype = 'AF' then lnprin+lnprovd else 0 end) total_MRamt_bg,
            sum(case when (mnemonic = 'Margin' and ftype = 'AF') then 0 else lnprin+lnprovd end) total_T3amt_bg,
            sum(case when (ROUND((overduedate-rlsdate)/90,0)-1) > 0 and (ROUND((overduedate-rlsdate)/90,0)-1) <= 1 THEN
                lnprin+lnprovd else 0 end) total_gh3_bg,
            sum(case when (ROUND((overduedate-rlsdate)/90,0)-1) > 1 then
                lnprin+lnprovd else 0 end) total_gh4_bg,
            sum(case when (V_FDATE-overduedate) > 0 and (V_FDATE-overduedate) <= 30 then
                lnprin+lnprovd else 0 end) total_qh3_bg,
            sum(case when (V_FDATE-overduedate) > 30 then
                lnprin+lnprovd else 0 end) total_qh4_bg
        from
        (
            select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
                ls.nml - nvl(lg.nml,0) lnprin,
                ls.ovd - nvl(lg.ovd,0) lnprovd,
                ls.paid - nvl(lg.paid,0) lnprpaid,
                ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
                - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
                ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
                - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
                cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid, ln.ftype
            from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af,aftype aft, cfmast cfb,
                (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                    sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                    sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > V_FDATE
                group by autoid) lg,
                (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
            where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
                and ln.trfacctno = af.acctno and af.custid = cf.custid
                and ln.custbank = cfb.custid(+)
                and ls.autoid = lg.autoid(+)
                and ln.acctno = df.lnacctno(+)
                and af.actype = aft.actype and af.actype <> '0000'
                and ls.rlsdate <= V_FDATE
        )
        group by custodycd, fullname
) ps,
(
    select  sum(amt) amt, custodycd, fullname
    from
    (
        select sum(amt) amt, cf.custodycd, cf.fullname
        from ADSCHD ad, afmast af, cfmast cf
        where ad.txdate <= V_FDATE
            and ad.cleardt >= V_FDATE
            and ad.acctno = af.acctno and af.custid = cf.custid
        group by cf.custodycd, cf.fullname
        union all
        select sum(amt) amt, cf.custodycd, cf.fullname
        from adschdhist ad, afmast af, cfmast cf
        where ad.txdate <= V_FDATE
            and ad.cleardt >= V_FDATE
            and ad.acctno = af.acctno and af.custid = cf.custid
        group by cf.custodycd, cf.fullname
    )
    group by custodycd, fullname
) ad_bg,
(
    select sum(amt) amt, custodycd, fullname
    from
    (
        select sum(amt) amt, cf.custodycd, cf.fullname
        from ADSCHD ad, afmast af, cfmast cf
        where ad.txdate <= v_TDATE
            and ad.cleardt >= v_TDATE
            and ad.acctno = af.acctno and af.custid = cf.custid
        group by cf.custodycd, cf.fullname
        union all
        select sum(amt) amt, cf.custodycd, cf.fullname
        from adschdhist ad, afmast af, cfmast cf
        where ad.txdate <= v_TDATE
            and ad.cleardt >= v_TDATE
            and ad.acctno = af.acctno and af.custid = cf.custid
        group by cf.custodycd, cf.fullname
    )
    group by custodycd, fullname
) ad_END
where /*rownum <= 20
    and*/ mst.custodycd = ps.custodycd(+)
    and mst.custodycd = ad_bg.custodycd(+)
    and mst.custodycd = ad_END.custodycd(+)
;

 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
