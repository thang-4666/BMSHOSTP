SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "MR0019" (
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

   l_MRAMT_BG          number(20,0);
   l_MRAMT_END         number(20,0);

   l_INTpaidMRAMT_BG        number(20,0);
   l_INTpaidMRAMT_END        number(20,0);

   l_INTMRAMT_BG        number(20,0);
   l_INTMRAMT_END        number(20,0);

   l_DFAMT_BG          number(20,0);
   l_DFAMT_END         number(20,0);

   l_T3AMT_BG          number(20,0);
   l_T3AMT_END         number(20,0);

   l_ADAMT_BG          number(20,0);
   l_ADAMT_END         number(20,0);


   l_MRAMT_GH1_BG          number(20,0);
   l_MRAMT_GH1_END         number(20,0);

   l_MRAMT_GH3_BG          number(20,0);
   l_MRAMT_GH3_END         number(20,0);

   l_MRAMT_GH4_BG          number(20,0);
   l_MRAMT_GH4_END         number(20,0);

   l_MRAMT_OVD3_BG          number(20,0);
   l_MRAMT_OVD3_END         number(20,0);

   l_MRAMT_OVD4_BG          number(20,0);
   l_MRAMT_OVD4_END         number(20,0);

   l_MRAMT_XL_end           number(20,0);
   l_T3AMT_XL_END           number(20,0);


-- DECLARE PROGRAM VARIABLES AS SHOWN ABOVE

BEGIN

   V_STROPTION := upper(pv_OPT);
   V_INBRID := pv_BRID;

 -- END OF GETTING REPORT'S PARAMETERS

    V_FDATE := to_date(F_DATE,'DD/MM/RRRR');
    v_TDATE := to_date(T_DATE,'DD/MM/RRRR');
   select to_date(varvalue,'DD/MM/RRRR') into v_CurrDate from sysvar where varname = 'CURRDATE' and grname = 'SYSTEM';

    ----Tong du no MR
    select sum(lnprin+lnprovd) into l_MRAMT_BG
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
            where lg.txdate > V_FDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE <> 'DF'
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin' and af.actype <> '0000'
            and ls.rlsdate <= V_FDATE
    );
    select sum(lnprin+lnprovd) into l_MRAMT_END
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
            where lg.txdate > v_TDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE <> 'DF'
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin' and af.actype <> '0000'
            and ls.rlsdate <= v_TDATE
    );

    ----Tong du no DF
    select sum(lnprin+lnprovd) into l_DFAMT_BG
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
            where lg.txdate > V_FDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+) and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE = 'DF'
            and af.actype = aft.actype and af.actype <> '0000'
            and ls.rlsdate <= V_FDATE
    )
    ;
    select sum(lnprin+lnprovd) into l_DFAMT_END
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
            where lg.txdate > v_TDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+) and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE = 'DF'
            and af.actype = aft.actype and af.actype <> '0000'
            and ls.rlsdate <= v_TDATE
    )
    ;
   ----end Tong du no DF

    ----Tong du no T3
    select sum(lnprin+lnprovd) into l_T3AMT_BG
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
            where lg.txdate > V_FDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE <> 'DF'
            and af.actype = aft.actype
            and aft.mnemonic <> 'Margin' and af.actype <> '0000'
            and ls.rlsdate <= V_FDATE
    )
    ;
    select sum(lnprin+lnprovd) into l_T3AMT_END
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
            where lg.txdate > v_TDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+) AND LN.FTYPE <> 'DF'
            and af.actype = aft.actype
            and aft.mnemonic <> 'Margin' and af.actype <> '0000'
            and ls.rlsdate <= v_TDATE
    )
    ;
   ----end Tong du no T3
   ---Ton du no UT
   /*
      l_ADAMT_BG          number(20,0);
   l_ADAMT_END         number(20,0);
   */

    select  sum(amt) into l_ADAMT_BG
    from
    (
        select sum(amt) amt
        from ADSCHD ad
        where ad.txdate <= V_FDATE
            and ad.cleardt > V_FDATE
            and ad.deltd <> 'Y'
        union all
        select sum(amt) amt
        from adschdhist ad
        where ad.txdate <= V_FDATE
            and ad.cleardt > V_FDATE
            and ad.deltd <> 'Y'
    );
    select sum(amt) into l_ADAMT_END
    from
    (
        select sum(amt) amt
        from ADSCHD ad
        where ad.txdate <= v_TDATE
            and ad.cleardt > v_TDATE
            and ad.deltd <> 'Y'
        union all
        select sum(amt) amt
        from adschdhist ad
        where ad.txdate <= v_TDATE
            and ad.cleardt > v_TDATE
            and ad.deltd <> 'Y'
    );
   ---end Tong du no UT
   --- Gia tri gia han
   --gia han duoi 1 thang.
   l_MRAMT_GH1_BG := 0;
   /*select sum(lnprin+lnprovd) into l_MRAMT_GH1_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > V_FDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and (ls.overduedate-ls.rlsdate-90) > 0
            and (ls.overduedate-ls.rlsdate-90) <= 30
            and ls.rlsdate <= V_FDATE and af.actype <> '0000'
    );*/
        l_MRAMT_GH1_END := 0;
    /*
    select sum(lnprin+lnprovd) into l_MRAMT_GH1_END
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > v_TDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and (ls.overduedate-ls.rlsdate-90) > 0
            and (ls.overduedate-ls.rlsdate-90) <= 30
            and ls.rlsdate <= v_TDATE and af.actype <> '0000'
    );*/

    ---- gia han tren 1thang den 3 thang.
    select sum(lnprin+lnprovd) into l_MRAMT_GH3_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > V_FDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and (ROUND((ls.overduedate-ls.rlsdate)/90,0)-1) > 0
            and (ROUND((ls.overduedate-ls.rlsdate)/90,0)-1) <= 1
            and ls.rlsdate <= V_FDATE and af.actype <> '0000'
    );
    select sum(lnprin+lnprovd) into l_MRAMT_GH3_END
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > v_TDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and (ROUND((ls.overduedate-ls.rlsdate)/90,0)-1) > 0
            and (ROUND((ls.overduedate-ls.rlsdate)/90,0)-1) <= 1
            and ls.rlsdate <= v_TDATE and af.actype <> '0000'
    );
   --- gia han tren 3 thang.
   select sum(lnprin+lnprovd) into l_MRAMT_GH4_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > V_FDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and (ROUND((ls.overduedate-ls.rlsdate)/90,0)-1) > 1
            and ls.rlsdate <= V_FDATE and af.actype <> '0000'
    );
    select sum(lnprin+lnprovd) into l_MRAMT_GH4_END
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > v_TDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and (ROUND((ls.overduedate-ls.rlsdate)/90,0)-1) > 1
            and ls.rlsdate <= v_TDATE and af.actype <> '0000'
    );
   ---end gia tri gia han

   --- gia tri qua han
    select sum(lnprovd) into l_MRAMT_OVD3_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > V_FDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            --and aft.mnemonic = 'Margin'
            and (V_FDATE-ls.overduedate) >= 1
            and (V_FDATE-ls.overduedate) <= 90
            and ls.rlsdate <= V_FDATE and af.actype <> '0000'
    );
    select sum(lnprovd) into l_MRAMT_OVD3_END
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > v_TDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            ---and aft.mnemonic = 'Margin'
            and (v_TDATE-ls.overduedate) >= 1
            and (v_TDATE-ls.overduedate) <= 90
            and ls.rlsdate <= v_TDATE and af.actype <> '0000'
    );

    select sum(lnprovd) into l_MRAMT_OVD4_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > V_FDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            --and aft.mnemonic = 'Margin'
            and (V_FDATE-ls.overduedate) > 90
            and ls.rlsdate <= V_FDATE and af.actype <> '0000'
    );
    select sum(lnprovd) into l_MRAMT_OVD4_END
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin, ls.ovd - nvl(lg.ovd,0) lnprovd,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af, aftype aft,
            (
                select autoid, sum(nml) nml, sum(ovd) ovd
                from (select * from lnschdlog union all select * from lnschdloghist) lg
                where lg.txdate > v_TDATE
                group by autoid
            ) lg
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ls.autoid = lg.autoid(+)
            and af.actype = aft.actype
            --and aft.mnemonic = 'Margin'
            and (v_TDATE-ls.overduedate) > 90
            and ls.rlsdate <= v_TDATE and af.actype <> '0000'
    );
   ---end gia tri qua han

   select sum(intpaid+feepaid), sum(intamt+feeintamt)
    into l_INTpaidMRAMT_BG, l_INTMRAMT_BG
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin,
            ls.ovd - nvl(lg.ovd,0) lnprovd,
            ls.paid - nvl(lg.paid,0) lnprpaid,
            ls.intpaid-nvl(lg.intpaid,0) intpaid,
            ls.feepaid-nvl(lg.feepaid,0) feepaid,
            ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
            ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd,
                sum(intpaid) intpaid, sum(feepaid) feepaid
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > V_FDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and ls.rlsdate <= V_FDATE and af.actype <> '0000'
    )
    ;

    select sum(intpaid+feepaid), sum(intamt+feeintamt)
        into l_INTpaidMRAMT_END, l_INTMRAMT_END
    from
    (
        select cf.custodycd, af.acctno afacctno, ls.rlsdate, ls.overduedate,
            ls.nml - nvl(lg.nml,0) lnprin,
            ls.ovd - nvl(lg.ovd,0) lnprovd,
            ls.paid - nvl(lg.paid,0) lnprpaid,
            ls.intpaid-nvl(lg.intpaid,0) intpaid,
            ls.feepaid-nvl(lg.feepaid,0) feepaid,
            ls.intnmlacr + ls.intdue + ls.intovd + ls.intovdprin
            - nvl(lg.intnmlacr,0)- nvl(lg.intdue,0)- nvl(lg.intovd,0)- nvl(lg.intovdprin,0) intamt,
            ls.feeintnmlacr + ls.feeintdue + ls.feeintnmlovd + ls.feeintovdacr+ls.feeovd
            - nvl(lg.feeintnmlacr,0)- nvl(lg.feeintdue,0)- nvl(lg.feeintnmlovd,0)- nvl(lg.feeintovdacr,0) - nvl(lg.feeovd,0) feeintamt,
            cf.fullname, ln.acctno lnacctno, aft.mnemonic, cf.brid
        from vw_lnmast_all ln, vw_lnschd_all ls, cfmast cf, afmast af,aftype aft, cfmast cfb,
            (select autoid, sum(nml) nml, sum(ovd) ovd, sum(paid) paid,
                sum(intnmlacr) intnmlacr, sum(intdue) intdue, sum(intovd) intovd, sum(intovdprin) intovdprin,
                sum(feeintnmlacr) feeintnmlacr, sum(feeintdue) feeintdue, sum(feeintovd) feeintnmlovd, sum(feeintovdprin) feeintovdacr,sum(feeovd) feeovd,
                sum(intpaid) intpaid, sum(feepaid) feepaid
            from (select * from lnschdlog union all select * from lnschdloghist) lg
            where lg.txdate > v_TDATE
            group by autoid) lg,
            (select lnacctno, df.actype dftype, dft.isvsd  from dfgroup df, dftype dft where df.actype=dft.actype) df
        where ln.acctno = ls.acctno and instr(ls.reftype,'P') <> 0
            and ln.trfacctno = af.acctno and af.custid = cf.custid
            and ln.custbank = cfb.custid(+)
            and ls.autoid = lg.autoid(+)
            and ln.acctno = df.lnacctno(+)
            and af.actype = aft.actype
            and aft.mnemonic = 'Margin'
            and ls.rlsdate <= v_TDATE and af.actype <> '0000'
    )
    ;
  ---end DUNGNH

select sum(case when mnemonic= 'T3' then ADDVND2 else 0 end) ,
    sum(case when mnemonic= 'Margin' then ADDVND2 else 0 end)
into l_T3AMT_XL_END, l_MRAMT_XL_end
from vw_mr0003_all;


-- GET REPORT'S DATA
OPEN PV_REFCURSOR FOR
    select nvl(l_MRAMT_BG,0) MRAMT_BG, nvl(l_MRAMT_END,0) MRAMT_END, nvl(l_DFAMT_BG,0) DFAMT_BG,
        nvl(l_DFAMT_END,0) DFAMT_END, nvl(l_T3AMT_BG,0)+nvl(l_ADAMT_BG,0) T3AMT_BG, nvl(l_T3AMT_END,0)+nvl(l_ADAMT_END,0) T3AMT_END,
        nvl(l_MRAMT_GH1_BG,0) MRAMT_GH1_BG, nvl(l_MRAMT_GH1_END,0) MRAMT_GH1_END, nvl(l_MRAMT_GH3_BG,0) MRAMT_GH3_BG,
        nvl(l_MRAMT_GH3_END,0) MRAMT_GH3_END, nvl(l_MRAMT_GH4_BG,0) MRAMT_GH4_BG, nvl(l_MRAMT_GH4_END,0) MRAMT_GH4_END,
        nvl(l_MRAMT_OVD3_BG,0) MRAMT_OVD3_BG, nvl(l_MRAMT_OVD3_END,0) MRAMT_OVD3_END, nvl(l_MRAMT_OVD4_BG,0) MRAMT_OVD4_BG,
        nvl(l_MRAMT_OVD4_END,0) MRAMT_OVD4_END,
        nvl(l_INTpaidMRAMT_BG,0) INTpaidMRAMT_BG, nvl(l_INTMRAMT_BG,0) INTMRAMT_BG,
        nvl(l_INTpaidMRAMT_END,0) INTpaidMRAMT_END, nvl(l_INTMRAMT_END,0) INTMRAMT_END,
        0 xl_gd_kq_bg, l_MRAMT_XL_end xl_gd_kq_end, 0 xl_gd_khac_bg, l_T3AMT_XL_END xl_gd_khac_end,
        0 pt_gd_kq_bg, 0 pt_gd_kq_end, 0 pt_gd_khac_bg, 0 pt_gd_khac_end
   from dual;
 EXCEPTION
   WHEN OTHERS
   THEN
        RETURN;
END;

 
 
 
 
/
