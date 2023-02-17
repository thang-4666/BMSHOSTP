SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0040" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BBRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2, --CUSTODYCD
   PV_AFACCTNO         IN       VARCHAR2,
   PV_CAREBY         IN       VARCHAR2,
   PV_RRTYPE         IN       VARCHAR2,
   PLSENT         IN       VARCHAR2,
   TLID            IN       VARCHAR2
   )
IS
--Bang tong hop theo doi khe uoc vay theo tung khach hang
--created by CHaunh at 03/02/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (40);            -- USED WHEN V_NUMOPTION > 0
   V_INBRID     VARCHAR2 (5);
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_STRAFACCTNO               VARCHAR2(20);
   V_STRCAREBY               VARCHAR2(20);
   V_STRRRTYPE               VARCHAR2(20);
   V_STRPLSENT               VARCHAR2(50);
   v_FrDate                DATE;
   V_ToDate                 DATE;
   l_BRID_FILTER        VARCHAR2(50);
   V_run            number(2);
   v_currdate     date;
   V_STRTLID           VARCHAR2(6);

BEGIN
   V_STRTLID:= TLID;
   V_STROPTION := upper(OPT);
   V_INBRID := BBRID;

   if(V_STROPTION = 'A') then
        V_STRBRID := '%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := BBRID;
        end if;
    end if;

   v_FrDate := to_date(F_DATE,'DD/MM/RRRR');
   v_ToDate   := to_date(T_DATE,'DD/MM/RRRR');

   IF(PV_CUSTODYCD = 'ALL' or PV_CUSTODYCD is null )
   THEN
        V_STRCUSTODYCD := '%%';
   ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
   END IF;

   IF(PV_AFACCTNO = 'ALL' OR PV_AFACCTNO IS NULL)
    THEN
       V_STRAFACCTNO := '%';
   ELSE
       V_STRAFACCTNO := PV_AFACCTNO;
   END IF;

   IF(PLSENT = 'ALL' OR PLSENT IS NULL)
    THEN
       V_STRPLSENT := '%';
   ELSE
       V_STRPLSENT := PLSENT;
   END IF;

   IF(PV_RRTYPE = 'ALL' OR PV_RRTYPE IS NULL)
    THEN
       V_STRRRTYPE := '%';
   ELSE
       V_STRRRTYPE := PV_RRTYPE;
   END IF;


   IF(PV_CAREBY = 'ALL' OR PV_CAREBY IS NULL)
    THEN
       V_STRCAREBY := '%';
   ELSE
       V_STRCAREBY := PV_CAREBY;
   END IF;

   if(PLSENT = 'ALL' )
    then
        v_run := -1;
    else
        v_run := 0;
    end if;
    select to_Date(varvalue, 'DD/MM/RRRR') into v_currdate from sysvar where grname = 'SYSTEM' and varname = 'CURRDATE';



OPEN PV_REFCURSOR
FOR

select * from (
select  case when main.nguon_giai_ngan = 'B' then nvl(lm.amt,lm.lmamt)
             when main.nguon_giai_ngan = 'C' then main.mrcrlimitmax
             else 0 end tong_hm_kh,
       (case when main.nguon_giai_ngan = 'B' then nvl(lm.amt,lm.lmamt)
             when main.nguon_giai_ngan = 'C' then main.mrcrlimitmax
             else 0 end) - sum(goc.orgamt - goc.prinpaid) hm_conlai,
        main.afacctno, case when main.nguon_giai_ngan = 'B' then 'BIDV' when main.nguon_giai_ngan = 'C' then utf8nums.c_const_RPT_OD0040_noidetien_2 end  cdcontent, main.actype, main.custodycd, main.fullname , main.grpname,
        sum(goc.orgamt) tong_goc_vay,
        sum(goc.prinpaid - nvl(prinpaid_mov.amt,0)) tong_tien_da_tt,
        sum(goc.orgamt - goc.prinpaid + nvl(prinpaid_mov.amt,0)) no_goc_con_lai,
        sum(GTTSDB.amt - nvl( GTTSDB_mov.amt,0)- nvl(CACASHQTTY_mov.amt,0)) GTTSDB_today,
        sum(goc.ovd - nvl(PRINOVD_mov.amt,0)) no_goc_qua_han,
        sum(goc.fee_now - nvl(fee_mov.amt,0) - nvl(FEE_congdon.amt,0)) tong_phi,
        sum(goc.int_now - nvl(int_mov.amt,0) - nvl(INT_congdon.amt,0)) tong_lai,
        sum(BLOCK_now - nvl(BLOCK_mov.amt,0)) tien_phong_toa,
        sum(goc.MONEY_now - nvl(MONEY_mov.amt,0)) tong_today/*,
        goc.prinpaid, prinpaid_mov.amt,
       goc.ovd, goc.int_now, goc.fee_now, goc.MONEY_now,
       GTTSDB.amt, GTTSDB_mov.amt, CACASHQTTY_mov.amt , PRINOVD_mov.amt,
       int_mov.amt, BLOCK_now, fee_mov.amt, BLOCK_mov.amt, FEE_congdon.amt, INT_congdon.amt, MONEY_mov.amt*/
from
( -- khach hang thoa man dieu kien

select tl.grpname, --cfbank.fullname rrtype,
        dg.rrtype nguon_giai_ngan,
        dftype.actype, cf.custodycd, dg.afacctno, cf.fullname, dg.groupid, dg.custbank, af.mrcrlimitmax,  sum(nvl(dg.dfblockamt,0)) BLOCK_now
from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0)  cf, afmast af,
    (Select * from dfmast union all select * from dfmasthist) df, tlgroups tl, dftype, lnmast--cfmast cfbank,  -- allcode a1,
where cf.custid = af.custid and dg.afacctno = af.acctno
and df.groupid = dg.groupid
and df.txdate <= v_ToDate
and dg.txdate <= v_ToDate
and tl.grpid = cf.careby --and a1.cdtype = 'DF' and a1.cdname = 'RRTYPE' and a1.cdval = dg.rrtype
AND lnmast.acctno = df.lnacctno
--AND cfbank.custid = lnmast.custbank
and dftype.actype = dg.actype
and tl.grpid like V_STRCAREBY
and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
--AND lnmast.custbank LIKE V_STRRRTYPE --and df.rrtype like V_STRRRTYPE
and cf.custodycd like V_STRCUSTODYCD
and af.acctno like  V_STRAFACCTNO
group by  tl.grpname, --cfbank.fullname,
    dftype.actype, cf.custodycd, dg.afacctno, cf.fullname, dg.groupid, dg.custbank,dg.rrtype,  af.mrcrlimitmax

) main
left join
(select cflimit.*, cflimitext.lmamt amt from cflimit, cflimitext where cflimit.bankid = cflimitext.bankid(+) AND cflimit.lmsubtype = 'DFMR') lm
on lm.bankid = main.custbank
---------tong goc vay, goc da tra, no goc qua han, no phi hien tai, no lai hien tai, tong tien tren loan ht
left join
(select a.groupid, a.afacctno,
    sum(a.prinpaid) prinpaid, sum(a.orgamt) orgamt, sum(ovd) ovd, sum(int_now) int_now, sum(fee_now) fee_now, sum(all_now) MONEY_now
    --sum(case when V_todate = v_currdate then a.prinpaid + nvl(b.vndselldf,0) else a.prinpaid end) prinpaid
    from
        (select  dg.groupid,dg.afacctno, sum(orgamt) orgamt,sum(ln.prinpaid) prinpaid,
                 sum(prinovd) ovd, sum(intnmlacr+ intovdacr+ intdue+ intnmlovd) int_now, --+ intpaid
                 sum( feeintnmlacr + feeintovdacr + feeintnmlovd + feeintdue ) fee_now, --+ feeintpaid
                 sum(prinnml+prinovd+intnmlacr+intovdacr+intnmlovd+intdue+feeintnmlacr+feeintovdacr+feeintnmlovd+feeintdue+intfloatamt+feefloatamt) all_now
            from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, vw_lnmast_all ln
            where dg.lnacctno = ln.acctno
            --and dg.txdate <=  v_ToDate
            group by    dg.groupid, dg.afacctno ) a,
        v_getgrpdealformular b
    where a.afacctno = b.afacctno(+) and a.groupid = b.groupid(+)
    group by a.groupid, a.afacctno
) goc
on  goc.groupid = main.groupid and goc.afacctno = main.afacctno
--tong goc vay phat sinh tu today
left join
 (select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'D' then -tran.namt else tran.namt end) amt
    from vw_lntran_all tran, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, apptx ap
    where ap.txcd = tran.txcd and tran.acctno = dg.lnacctno and tran.deltd <> 'Y'
    and ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.field in ('PRINPAID') --thu xet tren 2 truong PRINNML va PRINOVD
    and dg.txdate <=  v_ToDate
    and tran.txdate >  v_ToDate
    group by dg.groupid, dg.afacctno) prinpaid_mov
 on prinpaid_mov.groupid = main.groupid and prinpaid_mov.afacctno = main.afacctno
--------GT TSDB hien tai
left join
(select dg.groupid, dg.afacctno, sum(df.amt) amt from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg,
        (select df.acctno, df.groupid, nvl((dfqtty + rcvqtty + blockqtty + carcvqtty + caqtty )* df.dfrate/100 * seif.dfrefprice + df.cacashqtty*seif.dfrefprice,0) amt
            from (Select * from dfmast union all select * from dfmasthist) df , securities_info seif
            where  seif.codeid = df.codeid) df
    where dg.groupid = df.groupid
    group by dg.groupid, dg.afacctno) GTTSDB
on GTTSDB.groupid = main.groupid and GTTSDB.afacctno = main.afacctno
--so du GTTSDB tu today den ht, hien tai van lay gia chung khoan qua khu va ti le df hien tai
left join
(select dg.groupid, dg.afacctno, sum(tran.amt) amt from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg,
    (select df.acctno, df.groupid, sum(case when ap.txtype = 'D' then -namt else namt end )*df.dfrate/100* seif.dfrefprice amt
            from vw_dftran_all tran, apptx ap, (Select * from dfmast union all select * from dfmasthist) df, securities_info seif
            where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
            and ap.field in ('DFQTTY', 'RCVQTTY', 'BLOCKQTTY' , 'CARCVQTTY' ,'CAQTTY' ) and ap.txtype in ('C','D')
            and df.acctno = tran.acctno
            and seif.codeid = df.codeid
            and tran.txdate > v_ToDate
            group by df.acctno, df.groupid,df.dfrate,seif.dfrefprice ) tran
    where tran.groupid = dg.groupid
group by dg.groupid, dg.afacctno) GTTSDB_mov
on GTTSDB_mov.groupid = main.groupid and GTTSDB_mov.afacctno = main.afacctno
-------- phat sinh CACASHQTTY cua dfmast
left join
(select dg.groupid, dg.afacctno, sum(tran.amt) amt from (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg,
    (select df.acctno,df.groupid, sum(case when ap.txtype = 'D' then -namt else namt end )* seif.dfrefprice amt
        from vw_dftran_all tran, apptx ap, (Select * from dfmast union all select * from dfmasthist) df, securities_info seif
            where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
            and ap.field = 'CACASHQTTY'  and ap.txtype in ('C','D')
            and df.acctno = tran.acctno
            and seif.codeid = df.codeid
            and tran.txdate > v_ToDate
        group by df.acctno,df.groupid,  seif.dfrefprice) tran
    where tran.groupid = dg.groupid
group by  dg.groupid, dg.afacctno) CACASHQTTY_mov
on CACASHQTTY_mov.groupid = main.groupid and CACASHQTTY_mov.afacctno = main.afacctno
--no goc qua han pat sinh tu today den ht
left join
(select dg.groupid,dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd and ap.field = 'PRINOVD'
    and tran.deltd <> 'Y' and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and tran.txdate > v_ToDate
    group by dg.groupid,dg.afacctno) PRINOVD_mov
on PRINOVD_mov.groupid = main.groupid and PRINOVD_mov.afacctno = main.afacctno
 -------- tong lai phat sinh
left join
(select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('INTNMLACR','INTOVDACR','INTDUE','INTNMLOVD')--,'INTPAID'
    and tran.txdate > v_ToDate
    group by dg.groupid, dg.afacctno) Int_mov
on Int_mov.groupid = main.groupid and Int_mov.afacctno = main.afacctno
-------so tien phong toa phat sinh
left join
 (select df.groupid, df.afacctno, sum(case when ap.txtype = 'D' then -tran.namt else namt end) amt
    from vw_dftran_all tran, apptx ap, (Select * from dfmast union all select * from dfmasthist) df
    where ap.txcd = tran.txcd and ap.apptype = 'DF' and ap.txtype in ('D','C') and tran.deltd <> 'Y'
    and tran.tltxcd in ('2635','2648')
    and ap.field = 'DFBLOCKAMT'
    and tran.txdate > v_ToDate
    and df.acctno = tran.acctno
    group by df.groupid, df.afacctno) BLOCK_mov
on BLOCK_mov.groupid = main.groupid and BLOCK_mov.afacctno = main.afacctno
--------- tong phi phat sinh
left join
(select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('FEEINTNMLACR','FEEINTOVDACR','FEEINTNMLOVD','FEEINTDUE') --,'FEEINTPAID'
    and tran.txdate > v_ToDate
    group by  dg.groupid, dg.afacctno) FEE_mov
on FEE_mov.groupid = main.groupid and FEE_mov.afacctno = main.afacctno
--------phi cong don tu today den hien tai
left join
(select dg.groupid, dg.afacctno,
        sum(case when lni.frdate < v_ToDate then round(feeintamt/(lni.todate-lni.frdate)*(lni.todate - v_ToDate ))
                when lni.frdate >= v_ToDate then feeintamt end ) amt
from (SELECT * FROM lninttrana UNION ALL SELECT * FROM lninttran) lni, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
where lni.todate > v_ToDate
and dg.lnacctno = lni.acctno
group by dg.groupid, dg.afacctno) FEE_congdon
on FEE_congdon.groupid = main.groupid and FEE_congdon.afacctno = main.afacctno
--------- phat sinh lai cong don tu today den ht
left join
(select dg.groupid, dg.afacctno,
        sum(case when lni.frdate < v_ToDate then round(intamt/(lni.todate-lni.frdate)*(lni.todate - v_ToDate ))
                when lni.frdate >= v_ToDate then intamt end ) amt
from (SELECT * FROM lninttrana UNION ALL SELECT * FROM lninttran) lni, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
where lni.todate > v_ToDate
and dg.lnacctno = lni.acctno
group by dg.groupid, dg.afacctno) INT_congdon
on INT_congdon.groupid = main.groupid and INT_congdon.afacctno = main.afacctno
-------- cong tat ca loan phat sinh tu today den hien tai
left join
 (select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and dg.lnacctno = tran.acctno and tran.deltd <> 'Y' and ap.apptype ='LN' and ap.txtype in ('D','C')
    and ap.field in ('PRINNML','PRINOVD','INTNMLACR','INTOVDACR','INTNMLOVD','INTDUE','FEEINTNMLACR','FEEINTOVDACR','FEEINTNMLOVD','FEEINTDUE','INTFLOATAMT','FEEFLOATAMT')
    and tran.txdate > v_ToDate
    group by  dg.groupid, dg.afacctno) MONEY_mov
 on MONEY_mov.groupid = main.groupid and MONEY_mov.afacctno = main.afacctno
--order by custodycd, afacctno, cdcontent, rrtype, actype, fullname
group by  main.afacctno, --main.rrtype,
    main.actype, main.custodycd, main.fullname,main.nguon_giai_ngan, main.grpname, nvl(lm.amt,lm.lmamt), main.mrcrlimitmax
having sum(goc.MONEY_now - nvl(MONEY_mov.amt,0)) <> v_run )
WHERE  (substr(afacctno,1,4) LIKE V_STRBRID OR instr(V_STRBRID,substr(afacctno,1,4))<> 0)
--where case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(afACCTNO,1,4)) end  <> 0
/*select main.*,
        tong_goc_vay.orgamt tong_goc_vay,
        tong_goc_vay.prinpaid - nvl(no_goc_ps.namt,0) tong_tien_da_tt,
        (tong_goc_vay.orgamt - tong_goc_vay.prinpaid - nvl(NO_GOC_PS.NAMT,0)) no_goc_con_lai,
       (GTTSDB_ht.amt - nvl(GTTSDB_ps.amt,0)- nvl(GTTSDB_CASHQTTY.amt,0)) GTTSDB_today,
       lmamt tong_hm_kh,lmamt - (tong_goc_vay.orgamt - tong_goc_vay.prinpaid) hm_conlai,
       no_goc_qh_ht.ovd - nvl(ng_qh_ps.amt,0) no_goc_qua_han,
       (no_goc_qh_ht.sum_fee_now - nvl(mov_fee.amt,0) - nvl(ps_phi_cong_don.feeintamt,0)) tong_phi,
      ( no_goc_qh_ht.sum_int_now - nvl(mov_int.amt,0) - nvl(ps_lai_cong_don.intamt,0)) tong_lai,
       no_goc_qh_ht.sum_all_now - nvl(mov_all.amt,0) tong_today,
       amt_block_ht.namt - nvl(amt_block_ps.namt,0) tien_phong_toa
from
(select tl.grpname, case when df.rrtype = 'B' then 'Bank'
                         when df.rrtype = 'C' then 'Company' end cdcontent, df.rrtype,
        dftype.actype,cf.custodycd,df.afacctno, cf.fullname,
        case when df.rrtype = 'B' then nvl(lm.amt,lm.lmamt)
             when df.rrtype = 'C' then af.mrcrlimitmax end lmamt
    from dftype, (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) dg, (Select * from dfmast union all select * from dfmasthist) df, cfmast cf, afmast af, tlgroups tl, allcode a1,
        (select cflimit.*, cflimitext.lmamt amt from cflimit, cflimitext where cflimit.bankid = cflimitext.bankid(+)) lm--, lnschd ln, lnmast lm, securities_info secif, cflimit
    where df.afacctno like V_STRAFACCTNO and df.afacctno = af.acctno and  cf.custid = af.custid and tl.grpid = cf.careby
    and dftype.actype = dg.actype and df.groupid = dg.groupid
    and a1.cdname = 'RRTYPE' and a1.cdval = df.rrtype and a1.cdtype = 'DF'
    and lm.bankid = dftype.custbank
    and tl.grpid like V_STRCAREBY
    and df.rrtype like V_STRRRTYPE
    and cf.custodycd like V_STRCUSTODYCD
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    group by tl.grpname, df.rrtype,dftype.actype,af.mrcrlimitmax,cf.custodycd,df.afacctno, cf.fullname, lm.lmamt, lm.amt
    ) main
left join --tong goc vay, goc da tra
(select a.actype, a.rrtype, a.afacctno,
    sum(a.prinpaid) prinpaid, sum(a.orgamt) orgamt
    --sum(case when V_todate = v_currdate then a.prinpaid + nvl(b.vndselldf,0) else a.prinpaid end) prinpaid
    from
        (select  dg.actype, dg.rrtype, dg.groupid, dg.afacctno, sum(orgamt) orgamt, sum(ln.prinpaid) prinpaid
            from dfgroup dg, vw_lnmast_all ln
            where afacctno like V_STRAFACCTNO and dg.lnacctno = ln.acctno
            and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
            group by   dg.actype, dg.rrtype, dg.groupid, dg.afacctno ) a,
        v_getgrpdealformular b
    where a.afacctno = b.afacctno(+) and a.groupid = b.groupid(+)
    group by a.actype, a.rrtype, a.afacctno
) tong_goc_vay
on main.afacctno = tong_goc_vay.afacctno and main.actype = tong_goc_vay.actype and main.rrtype = tong_goc_vay.rrtype
left join --tong goc vay phat sinh tu today
 (select dg.actype, dg. rrtype, dg.afacctno, sum(case when ap.txtype = 'D' then -tran.namt else tran.namt end) namt
    from vw_lntran_all tran, dfgroup dg, apptx ap
    where ap.txcd = tran.txcd and tran.acctno = dg.lnacctno and tran.deltd <> 'Y'
    and ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.field in ('PRINPAID') --thu xet tren 2 truong PRINNML va PRINOVD
    and dg.afacctno like V_STRAFACCTNO
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    and tran.txdate > v_ToDate
    group by dg.actype, dg. rrtype,afacctno) no_goc_ps
 on main.afacctno = no_goc_ps.afacctno and main.actype = no_goc_ps.actype and main.rrtype = no_goc_ps.rrtype

left join --so du GTTSDB hien tai
(select df.actype, df.rrtype, df.afacctno, nvl(sum((dfqtty + rcvqtty + blockqtty + carcvqtty + caqtty )* df.dfrate/100 * seif.dfrefprice + df.cacashqtty*seif.dfrefprice),0) amt
    from (Select * from dfmast union all select * from dfmasthist) df , securities_info seif
    where df.afacctno like  V_STRAFACCTNO and seif.codeid = df.codeid
    and df.txdate >= v_FrDate and df.txdate <= V_ToDate
    group by  df.actype, df.rrtype,df.afacctno) GTTSDB_ht
on  GTTSDB_ht.afacctno = main.afacctno and main.actype = GTTSDB_ht.actype and main.rrtype = GTTSDB_ht.rrtype

left join --so du GTTSDB tu today den ht, hien tai van lay gia chung khoan qua khu va ti le df hien tai
(select actype, rrtype,afacctno, sum(amt ) amt from
    (select df.actype, df.rrtype, df.acctno,df.groupid, df.afacctno, sum(case when ap.txtype = 'D' then -namt else namt end )*df.dfrate/100* seif.dfrefprice amt
            from vw_dftran_all tran, apptx ap, (Select * from dfmast union all select * from dfmasthist) df, securities_info seif
            where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
            and ap.field in ('DFQTTY', 'RCVQTTY', 'BLOCKQTTY' , 'CARCVQTTY' ,'CAQTTY' ) and ap.txtype in ('C','D')
            and df.acctno = tran.acctno
            and seif.codeid = df.codeid
            and df.afacctno like V_STRAFACCTNO
            and df.txdate >= v_FrDate and df.txdate <= V_ToDate
            and tran.txdate > V_ToDate

            group by df.actype, df.rrtype, df.acctno, df.groupid,df.afacctno,df.dfrate, seif.dfrefprice)
group by actype, rrtype,afacctno) GTTSDB_ps
on GTTSDB_ps.afacctno = main.afacctno and main.actype = GTTSDB_ps.actype and main.rrtype = GTTSDB_ps.rrtype
left join -- phat sinh tren truong CACASHQTTY cua dfmast
(select actype, rrtype, afacctno, sum(amt ) amt from
    (select df.actype, df.rrtype,df.acctno,df.groupid, df.afacctno, sum(case when ap.txtype = 'D' then -namt else namt end )* seif.dfrefprice amt
            from vw_dftran_all tran, apptx ap, (Select * from dfmast union all select * from dfmasthist) df, securities_info seif
            where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
            and ap.field = 'CACASHQTTY'  and ap.txtype in ('C','D')
            and df.acctno = tran.acctno
            and seif.codeid = df.codeid
            and df.afacctno like V_STRAFACCTNO
            and df.txdate >= v_FrDate and df.txdate <= V_ToDate
            and tran.txdate > V_ToDate

            group by df.actype, df.rrtype,df.acctno, df.groupid,df.afacctno, seif.dfrefprice)
group by actype, rrtype, afacctno)  GTTSDB_CASHQTTY
on GTTSDB_CASHQTTY.afacctno = main.afacctno and main.actype = GTTSDB_CASHQTTY.actype and main.rrtype = GTTSDB_CASHQTTY.rrtype

left join --no goc qua han ht, tong lai hien tai, tong_phi_ht
(select dg.actype, dg.rrtype, dg.afacctno, sum(prinovd) ovd, sum(intnmlacr+ intovdacr+ intdue+ intnmlovd+ intpaid) sum_int_now,
            sum( feeintnmlacr + feeintovdacr + feeintnmlovd + feeintdue + feeintpaid) sum_fee_now,
            sum(prinnml+prinovd+intnmlacr+intovdacr+intnmlovd+intdue+feeintnmlacr+feeintovdacr+feeintnmlovd+feeintdue+intfloatamt+feefloatamt) sum_all_now
    from vw_lnmast_all ln, dfgroup dg
    where dg.lnacctno = ln.acctno and dg.afacctno like V_STRAFACCTNO
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    group by  dg.actype, dg.rrtype,dg.afacctno) no_goc_qh_ht
on no_goc_qh_ht.afacctno = main.afacctno and main.actype = no_goc_qh_ht.actype and main.rrtype = no_goc_qh_ht.rrtype

left join --no goc qua han pat sinh
(select dg.actype, dg.rrtype,dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, dfgroup dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd and ap.field = 'PRINOVD'
    and tran.deltd <> 'Y' and ap.txtype in ('D','C')
    and dg.afacctno like V_STRAFACCTNO
    and dg.lnacctno = tran.acctno
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    and tran.txdate > V_ToDate
    group by dg.actype, dg.rrtype,dg.afacctno) ng_qh_ps
on ng_qh_ps.afacctno = main.afacctno and main.actype = ng_qh_ps.actype and main.rrtype = ng_qh_ps.rrtype

left join -- tong lai phat sinh
(select dg.actype, dg.rrtype, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, dfgroup dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    and ap.field in ('INTNMLACR','INTOVDACR','INTDUE','INTNMLOVD','INTPAID')
    and dg.afacctno like V_STRAFACCTNO
    and tran.txdate > V_ToDate
    group by dg.actype, dg.rrtype,dg.afacctno) mov_int
 on mov_int.afacctno = main.afacctno and main.actype = mov_int.actype and main.rrtype = mov_int.rrtype

 left join
 (select dg.actype, dg.rrtype, dg.afacctno, sum(dg.dfblockamt) namt  from dfgroup dg
    where dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    and dg.afacctno like V_STRAFACCTNO
    group by dg.actype, dg.rrtype, dg.afacctno) amt_block_ht
 on amt_block_ht.afacctno = main.afacctno and main.actype = amt_block_ht.actype and main.rrtype = amt_block_ht.rrtype
 left join
 (select df.actype, df.rrtype, df.afacctno, sum(case when ap.txtype = 'D' then -tran.namt else namt end) namt
    from vw_dftran_all tran, apptx ap, dfmast df
    where ap.txcd = tran.txcd and ap.apptype = 'DF' and ap.txtype in ('D','C') and tran.deltd <> 'Y'
    and df.afacctno like V_STRAFACCTNO
    and df.txdate >= v_FrDate and df.txdate <= V_ToDate
    and ap.field = 'DFBLOCKAMT'
    and tran.txdate > V_ToDate
    and df.acctno = tran.acctno
    group by df.actype, df.rrtype, df.afacctno) amt_block_ps
 on amt_block_ps.afacctno = main.afacctno and main.actype = amt_block_ps.actype and main.rrtype = amt_block_ps.rrtype

left join -- tong phi phat sinh
(select dg.actype, dg.rrtype, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, dfgroup dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('FEEINTNMLACR','FEEINTOVDACR','FEEINTNMLOVD','FEEINTDUE','FEEINTPAID')
    and dg.afacctno like V_STRAFACCTNO
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    and tran.txdate > V_ToDate
    group by  dg.actype, dg.rrtype, dg.afacctno) mov_fee
 on mov_int.afacctno = main.afacctno and main.actype = mov_fee.actype and main.rrtype = mov_fee.rrtype
 -------phat sinh phi cong don
left join
(select dg.actype, dg.rrtype, dg.afacctno,
        sum(case when lni.frdate = V_ToDate then round(feeintamt/(lni.todate-lni.frdate))
                when lni.frdate < V_ToDate then round(feeintamt/(lni.todate-lni.frdate)*(lni.todate - v_todate ))
                when lni.frdate > V_ToDate then feeintamt end ) feeintamt
from lninttran lni, dfgroup dg
where lni.todate > V_ToDate
and dg.afacctno like  V_STRAFACCTNO
and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
and dg.lnacctno = lni.acctno
group by dg.actype, dg.rrtype, dg.afacctno) ps_phi_cong_don
on ps_phi_cong_don.afacctno = main.afacctno and main.actype = ps_phi_cong_don.actype and main.rrtype = ps_phi_cong_don.rrtype
---------------
left join -- phat sinh lai cong don
(select dg.actype, dg.rrtype, dg.afacctno,
        sum(case when lni.frdate = V_ToDate then round(intamt/(lni.todate-lni.frdate))
                when lni.frdate < V_ToDate then round(intamt/(lni.todate-lni.frdate)*(lni.todate - V_ToDate))
                when lni.frdate > V_ToDate then intamt end ) intamt
from lninttran lni, dfgroup dg
where lni.todate > V_ToDate
and dg.afacctno like  V_STRAFACCTNO
and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
and dg.lnacctno = lni.acctno
group by dg.actype, dg.rrtype, dg.afacctno) ps_lai_cong_don
on ps_lai_cong_don.afacctno = main.afacctno and main.actype = ps_lai_cong_don.actype and main.rrtype = ps_lai_cong_don.rrtype
--------------
 left join
 (select dg.actype, dg.rrtype, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, dfgroup dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and dg.lnacctno = tran.acctno and tran.deltd <> 'Y' and ap.apptype ='LN' and ap.txtype in ('D','C')
    and ap.field in ('PRINNML','PRINOVD','INTNMLACR','INTOVDACR','INTNMLOVD','INTDUE','FEEINTNMLACR','FEEINTOVDACR','FEEINTNMLOVD','FEEINTDUE','INTFLOATAMT','FEEFLOATAMT')
    and dg.afacctno like V_STRAFACCTNO
    and dg.txdate >= v_FrDate and dg.txdate <= V_ToDate
    and tran.txdate > V_ToDate
    group by dg.actype, dg.rrtype,dg.afacctno) mov_all
 on mov_all.afacctno = main.afacctno and main.actype = mov_all.actype and main.rrtype = mov_all.rrtype
where no_goc_qh_ht.sum_all_now - nvl(mov_all.amt,0) <> v_run
order by main.cdcontent, main.actype, main.custodycd, main.afacctno*/
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
