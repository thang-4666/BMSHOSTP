SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0017" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   pv_OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2
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

   V_INDATE           DATE; --ngay lam viec gan ngay fdate nhat

   v_CurrDate        DATE;
   V_INBRID         VARCHAR2(4);
   V_STRBRID        VARCHAR2 (50);
   V_STROPTION      VARCHAR2(10);

   l_SEREALASS_MR              NUMBER(20,0);
   l_SEREALASS_T3              NUMBER(20,0);

   l_totalMRAMT_MR         number(20,0);
   l_totalMRAMT_T3        number(20,0);



-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE


BEGIN



   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

 -- END OF GETTING REPORT'S PARAMETERS

   SELECT max(sbdate) INTO V_INDATE FROM sbcurrdate WHERE sbtype ='B' AND sbdate <= to_date(I_DATE,'DD/MM/RRRR');

   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

   if V_INDATE = v_CurrDate then
        SELECT SUM(seass) into l_SEREALASS_MR
        FROM vw_getsecmargindetail LG, AFMAST AF, AFTYPE AFT
        WHERE LG.afacctno = AF.acctno AND AF.actype = AFT.actype
            AND AFT.mnemonic = 'Margin';

        SELECT SUM(seass) into l_SEREALASS_T3
        FROM vw_getsecmargindetail LG, AFMAST AF, AFTYPE AFT
        WHERE LG.afacctno = AF.acctno AND AF.actype = AFT.actype
            AND AFT.mnemonic <> 'Margin';
    else
        SELECT SUM(seass) into l_SEREALASS_MR
        FROM tbl_mr3007_log LG, AFMAST AF, AFTYPE AFT
        WHERE LG.afacctno = AF.acctno AND AF.actype = AFT.actype
            AND AFT.mnemonic = 'Margin'
            AND LG.txdate = V_INDATE;
        SELECT SUM(seass) into l_SEREALASS_T3
        FROM tbl_mr3007_log LG, AFMAST AF, AFTYPE AFT
        WHERE LG.afacctno = AF.acctno AND AF.actype = AFT.actype
            AND AFT.mnemonic <> 'Margin'
            AND LG.txdate = V_INDATE;
    end if;

    select sum(lnprin+lnprovd) into l_totalMRAMT_MR
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
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > V_INDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE <> 'DF'
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin' and af.actype <> '0000'
            and ls.rlsdate <= V_INDATE
    );

    select sum(lnprin+lnprovd) into l_totalMRAMT_T3
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
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > V_INDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and af.actype = aft.actype
            and aft.mnemonic <> 'Margin' and af.actype <> '0000'
            and ls.rlsdate <= V_INDATE
    )
    ;

if V_INDATE = v_CurrDate then
    -- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
    select V_INDATE indate, lg.symbol, sum(trade + receiving - execqtty + buyqtty ) total_qtty,
        sum(case when aft.mnemonic = 'Margin' then (trade + receiving - execqtty + buyqtty ) else 0 end) mr_qtty,
        sum(case when aft.mnemonic = 'Margin' then 0 else (trade + receiving - execqtty + buyqtty ) end) t3_qtty,
        round(sum(trade + receiving - execqtty + buyqtty)*100/max(sec.listingqtty),7) ty_le,
        sum(lg.sereal) se_amt,
        sum(case when aft.mnemonic = 'Margin' then round(seass*l_totalMRAMT_MR/l_SEREALASS_MR,0) else 0 end) mr_amt,
        sum(case when aft.mnemonic = 'Margin' then 0 else round(seass*l_totalMRAMT_T3/l_SEREALASS_T3,0) end) t3_amt
    from vw_getsecmargindetail lg, afmast af, aftype aft, securities_info sec
    where lg.seass <> 0 and lg.afacctno = af.acctno and af.actype = aft.actype
        and lg.codeid = sec.codeid(+) and af.actype <> '0000'
    group by lg.symbol
    ;
else
-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
    select V_INDATE indate, lg.symbol, sum(trade + receiving - execqtty + buyqtty ) total_qtty,
        sum(case when aft.mnemonic = 'Margin' then (trade + receiving - execqtty + buyqtty ) else 0 end) mr_qtty,
        sum(case when aft.mnemonic = 'Margin' then 0 else (trade + receiving - execqtty + buyqtty ) end) t3_qtty,
        round(sum(trade + receiving - execqtty + buyqtty)*100/max(sec.listingqtty),7) ty_le,
        sum(lg.sereal) se_amt,
        sum(case when aft.mnemonic = 'Margin' then round(seass*l_totalMRAMT_MR/l_SEREALASS_MR,0) else 0 end) mr_amt,
        sum(case when aft.mnemonic = 'Margin' then 0 else round(seass*l_totalMRAMT_T3/l_SEREALASS_T3,0) end) t3_amt
    from tbl_mr3007_log lg, afmast af, aftype aft, securities_info_hist sec
    where lg.seass <> 0 and lg.afacctno = af.acctno and af.actype = aft.actype
        and lg.codeid = sec.codeid(+) and lg.txdate = V_INDATE and af.actype <> '0000'
        and lg.txdate = sec.histdate(+)
    group by lg.symbol
    ;
end if;

 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
