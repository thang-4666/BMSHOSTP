SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0001" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   BANKNAME       IN       VARCHAR2
   )
IS
--

-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- THANHNM   12-APR-2012  CREATE
-- ---------   ------  -------------------------------------------

   V_STROPTION      VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID        VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0

   V_STRCUSTODYCD   VARCHAR2 (20);
   V_STRBANKNAME    VARCHAR2 (10);
   V_IDATE          DATE;

    BEGIN
    V_STROPTION := OPT;

   IF V_STROPTION = 'A' THEN     -- TOAN HE THONG
      V_STRBRID := '%';
   ELSIF V_STROPTION = 'B' THEN
      V_STRBRID := SUBSTR(pv_BRID,1,2) || '__' ;
   ELSE
      V_STRBRID := pv_BRID;
   END IF;

   V_IDATE := to_date (I_DATE,'DD/MM/RRRR');

   if(upper(PV_CUSTODYCD) = 'ALL' or PV_CUSTODYCD is null) then
        V_STRCUSTODYCD := '%';
   else
        V_STRCUSTODYCD := PV_CUSTODYCD;
   end if;

   if(upper(BANKNAME) = 'ALL' or BANKNAME is null) then
        V_STRBANKNAME := '%';
   else
        V_STRBANKNAME := BANKNAME;
   end if;


    OPEN PV_REFCURSOR
    FOR
select I_DATE indate,goc.custodycd, goc.fullname, goc.actype, goc.opndate, goc.expdate, goc.rate,
    goc.mnemonic, goc.nguon_giai_ngan,
    sum(goc.orgamt+goc.ovd - goc.prinpaid + nvl(prinpaid_mov.amt,0) - nvl(PRINOVD_mov.amt,0)) no_goc,
    sum(goc.fee_now - nvl(fee_mov.amt,0) - nvl(FEE_congdon.amt,0)) tong_phi,
    sum(goc.int_now - nvl(int_mov.amt,0) - nvl(INT_congdon.amt,0)) tong_lai
from
---------tong goc vay, goc da tra, no goc qua han, no phi hien tai, no lai hien tai, tong tien tren loan ht
(
    select a.groupid, a.afacctno, a.nguon_giai_ngan, a.expdate, a.opndate,
        a.fullname, a.actype, a.custodycd, a.rate, a.mnemonic,
        sum(a.prinpaid) prinpaid, sum(a.orgamt) orgamt, sum(ovd) ovd, sum(int_now) int_now, sum(fee_now) fee_now, sum(all_now) MONEY_now
    from
        (
            select al.cdcontent nguon_giai_ngan, dg.groupid, dg.afacctno, lns.overduedate expdate, ln.opndate,
                cf.fullname, af.actype, cf.custodycd, ln.rate2 rate, aft.mnemonic,
                sum(dg.orgamt) orgamt,sum(ln.prinpaid) prinpaid,
                sum(ln.prinovd) ovd, sum(ln.intnmlacr+ ln.intovdacr+ ln.intdue+ ln.intnmlovd) int_now, --+ intpaid
                sum( ln.feeintnmlacr + ln.feeintovdacr + ln.feeintnmlovd + ln.feeintdue ) fee_now, --+ feeintpaid
                sum(ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intovdacr+ln.intnmlovd+ln.intdue+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd+ln.feeintdue+ln.intfloatamt+ln.feefloatamt) all_now
            from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, vw_lnmast_all ln,  vw_lnschd_all lns,
                (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, PV_BRID, TLGOUPS)=0) cf, afmast af, aftype aft, allcode al
            where dg.lnacctno = ln.acctno and cf.custid = af.custid
                and dg.afacctno = af.acctno and af.actype = aft.actype
                and al.cdtype = 'DF' and al.cdname = 'RRTYPE' and dg.rrtype = al.cdval
                and ln.acctno = lns.acctno
                and dg.rrtype like V_STRBANKNAME
                and ln.opndate = V_IDATE
                and cf.custodycd like V_STRCUSTODYCD
            group by al.cdcontent, dg.groupid, dg.afacctno, lns.overduedate, ln.opndate, cf.fullname, af.actype, cf.custodycd, ln.rate2, aft.mnemonic
        ) a, v_getgrpdealformular b
    where a.afacctno = b.afacctno(+) and a.groupid = b.groupid(+)
    group by a.groupid, a.afacctno, a.nguon_giai_ngan, a.expdate, a.opndate, a.fullname, a.actype, a.custodycd, a.rate, a.mnemonic
) goc
-- tong goc vay phat sinh tu today
left join
(
    select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'D' then -tran.namt else tran.namt end) amt
    from vw_lntran_all tran, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, apptx ap
    where ap.txcd = tran.txcd and tran.acctno = dg.lnacctno and tran.deltd <> 'Y'
        and ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.field in ('PRINPAID') --thu xet tren 2 truong PRINNML va PRINOVD
        and dg.txdate <=  V_IDATE
        and tran.txdate > V_IDATE
    group by dg.groupid, dg.afacctno
) prinpaid_mov
 on prinpaid_mov.groupid = goc.groupid and prinpaid_mov.afacctno = goc.afacctno
--no goc qua han pat sinh tu today den ht
left join
(select dg.groupid,dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd and ap.field = 'PRINOVD'
    and tran.deltd <> 'Y' and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and tran.txdate > V_IDATE
    group by dg.groupid,dg.afacctno
) PRINOVD_mov
on PRINOVD_mov.groupid = goc.groupid and PRINOVD_mov.afacctno = goc.afacctno
 -------- tong lai phat sinh
left join
(select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('INTNMLACR','INTOVDACR','INTDUE','INTNMLOVD')--,'INTPAID'
    and tran.txdate > V_IDATE
    group by dg.groupid, dg.afacctno
) Int_mov
on Int_mov.groupid = goc.groupid and Int_mov.afacctno = goc.afacctno
--------- tong phi phat sinh
left join
(select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('FEEINTNMLACR','FEEINTOVDACR','FEEINTNMLOVD','FEEINTDUE') --,'FEEINTPAID'
    and tran.txdate > V_IDATE
    group by  dg.groupid, dg.afacctno
) FEE_mov
on FEE_mov.groupid = goc.groupid and FEE_mov.afacctno = goc.afacctno
--------phi cong don tu today den hien tai
left join
(select dg.groupid, dg.afacctno,
        sum(case when lni.frdate < V_IDATE then round(feeintamt/(lni.todate-lni.frdate)*(lni.todate - V_IDATE ))
                when lni.frdate >= V_IDATE then feeintamt end ) amt
from (SELECT * FROM lninttrana UNION ALL SELECT * FROM lninttran) lni, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
where lni.todate > V_IDATE
and dg.lnacctno = lni.acctno
group by dg.groupid, dg.afacctno
) FEE_congdon
on FEE_congdon.groupid = goc.groupid and FEE_congdon.afacctno = goc.afacctno
--------- phat sinh lai cong don tu today den ht
left join
(
select dg.groupid, dg.afacctno,
        sum(case when lni.frdate < V_IDATE then round(intamt/(lni.todate-lni.frdate)*(lni.todate - V_IDATE))
                when lni.frdate >= V_IDATE then intamt end ) amt
from (SELECT * FROM lninttrana UNION ALL SELECT * FROM lninttran) lni,
    (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
where lni.todate > V_IDATE
and dg.lnacctno = lni.acctno
group by dg.groupid, dg.afacctno
) INT_congdon
on INT_congdon.groupid = goc.groupid and INT_congdon.afacctno = goc.afacctno
group by goc.custodycd, goc.fullname, goc.actype, goc.opndate, goc.expdate, goc.rate, goc.mnemonic, goc.nguon_giai_ngan
;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
