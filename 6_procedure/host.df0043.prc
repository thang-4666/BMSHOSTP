SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0043" (
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
--Danh sach chi tiet khe uoc vay
--created by CHaunh at 03/02/2012

-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_STRAFACCTNO               VARCHAR2(20);
   V_STRCAREBY               VARCHAR2(20);
   V_STRRRTYPE               VARCHAR2(20);
   V_STRPLSENT               VARCHAR2(50);
   v_FrDate                DATE;
   l_BRID_FILTER        VARCHAR2(50);
   V_ToDate                 DATE;
   V_run            number(2);
   V_STRTLID           VARCHAR2(6);
   --v_currdate     date;


BEGIN
   V_STROPTION := OPT;
   V_STRTLID:= TLID;

   v_FrDate := to_date(F_DATE,'DD/MM/RRRR');
   v_ToDate   := to_date(T_DATE,'DD/MM/RRRR');

IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(BBRID,1,2) || '__' ;
else
    V_STRBRID:=BBRID;
END IF;

   IF(PV_CUSTODYCD = 'ALL' or PV_CUSTODYCD is null )
   THEN
        V_STRCUSTODYCD := '%%';
   ELSE
        V_STRCUSTODYCD := PV_CUSTODYCD;
   END IF;


IF (V_STROPTION = 'A') THEN
  l_BRID_FILTER := '%';
ELSE if (V_STROPTION = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = BBRID;
    else
        l_BRID_FILTER := BBRID;
    end if;
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
    --select to_Date(varvalue, 'DD/MM/RRRR') into v_currdate from sysvar where grname = 'SYSTEM' and varname = 'CURRDATE';



OPEN PV_REFCURSOR
FOR
select main.txdate,main.grpname,main.overduedate, main.rrtype, main.actype, main.custodycd, main.afacctno, main.fullname, main.groupid,
       /*nvl(release_all.msgamt,0)*/ main.rlsamt goc_vay,
       main.prinpaid - nvl(prinpaid_mov.prinpaidamt,0) tien_tt,
       main.goc - nvl(prinpaid_mov.prinamt,0) no_goc_con_lai,
       GTTSDB.amt - (nvl(GTTSDB_mov.amt,0)+nvl( CACASHQTTY_mov.amt,0)) gtts_quy_doi,
       debts.int_now -  (nvl(int_mov.amt,0)+ nvl(INT_congdon.amt,0)) du_no_lai,
       debts.fee_now - (nvl(FEE_congdon.amt,0) + nvl(fee_mov.amt,0) ) du_no_phi

from
(select dg.txdate,lnschd.overduedate, tl.grpname, cfbank.fullname rrtype,
        dftype.actype, cf.custodycd,
        dg.afacctno, cf.fullname, dg.groupid, lnmast.rlsamt, lnmast.prinpaid, (lnmast.prinnml + lnmast.prinovd) goc
    from vw_dfmast_all df, (Select * from dfgroup union all select * from dfgrouphist) dg, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0) cf, afmast af,
        tlgroups tl, dftype,vw_lnmast_all lnmast,vw_lnschd_all lnschd, cfmast cfbank
    where  dg.groupid = df.groupid
    and cf.custid = af.custid and af.acctno = dg.afacctno and tl.grpid = cf.careby
    and dftype.actype = dg.actype
    and dg.txdate <= v_todate and dg.txdate >= v_frdate
    and df.lnacctno = lnmast.acctno and lnmast.acctno = lnschd.acctno and lnschd.reftype = 'P'
    AND cfbank.custid = lnmast.custbank
    and tl.grpid like V_STRCAREBY
    AND lnmast.custbank LIKE V_STRRRTYPE    --and df.rrtype like V_STRRRTYPE
    and cf.custodycd like V_STRCUSTODYCD
    and af.acctno like  V_STRAFACCTNO
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    group by  dg.txdate,lnschd.overduedate,tl.grpname, cfbank.fullname, dftype.actype, cf.custodycd, dg.afacctno, cf.fullname,
            dg.groupid, lnmast.rlsamt,lnmast.prinpaid, lnmast.prinnml , lnmast.prinovd
) main
---- cac lan giai ngan truoc todate
/*left join
(select  log.tltxcd ,log.msgamt, log.msgacct, fld.cvalue from vw_tllog_all log, vw_tllogfld_all fld
    where tltxcd = '2674' and fld.txnum = log.txnum and fld.txdate = log.txdate and fld.fldcd = '20'
    and log.txdate <= v_todate AND log.deltd <> 'Y'
    ) release_all
on release_all.cvalue = main.groupid*/
---no goc da tra truoc todate
left join
(select dg.groupid, sum(case when ap.txtype = 'D' AND ap.field = 'PRINPAID'then -tran.namt
                             WHEN ap.txtype = 'C' AND ap.field = 'PRINPAID' THEN tran.namt
                             ELSE 0 END ) prinpaidamt,
                    SUM(case when ap.txtype = 'D' AND ap.field IN  ('PRINNML','PRINOVD') then -tran.namt
                             WHEN ap.txtype = 'C' AND ap.field IN  ('PRINNML','PRINOVD') THEN tran.namt
                             ELSE 0 END ) prinamt
    from vw_lntran_all tran, (Select * from dfgroup union all select * from dfgrouphist) dg, apptx ap
    where ap.txcd = tran.txcd and tran.acctno = dg.lnacctno and tran.deltd <> 'Y'
    and ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.field in ('PRINPAID','PRINNML','PRINOVD') --thu xet tren 2 truong PRINNML va PRINOVD
    and tran.txdate > v_todate--tran.txdate <= v_todate
    group by dg.groupid) prinpaid_mov
on prinpaid_mov.groupid = main.groupid
--gt tsdb > todate
left join
(select dg.groupid, sum(tran.amt) amt from (Select * from dfgroup union all select * from dfgrouphist) dg,
    (select  df.acctno, df.groupid, sum(case when ap.txtype = 'D' then -namt else namt end )*df.dfrate/100* seif.dfrefprice amt
            from vw_dftran_all tran, apptx ap, vw_dfmast_all df, securities_info seif
            where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
            and ap.field in ('DFQTTY', 'RCVQTTY', 'BLOCKQTTY' , 'CARCVQTTY' ,'CAQTTY' ) and ap.txtype in ('C','D')
            and df.acctno = tran.acctno
            and tran.txdate > v_todate
            and seif.codeid = df.codeid
            group by df.acctno, df.groupid,df.dfrate,seif.dfrefprice ) tran
    where tran.groupid = dg.groupid
group by dg.groupid) GTTSDB_mov
on GTTSDB_mov.groupid = main.groupid

--gt cacaschqtty > todate
left join
(select dg.groupid, sum(tran.amt) amt from (Select * from dfgroup union all select * from dfgrouphist) dg,
    (select df.acctno,df.groupid, sum(case when ap.txtype = 'D' then -namt else namt end )* seif.dfrefprice amt
        from vw_dftran_all tran, apptx ap, vw_dfmast_all df, securities_info seif
            where tran.txcd = ap.txcd and ap.apptype = 'DF'  and tran.deltd <> 'Y'
            and ap.field = 'CACASHQTTY'  and ap.txtype in ('C','D')
            and df.acctno = tran.acctno
            and seif.codeid = df.codeid
            and tran.txdate > v_ToDate
        group by  df.acctno,df.groupid,  seif.dfrefprice) tran
    where tran.groupid = dg.groupid
group by  dg.groupid) CACASHQTTY_mov
on CACASHQTTY_mov.groupid = main.groupid

--gttsdb hien tai
left join
(select dg.groupid, dg.afacctno, sum(df.amt) amt from (Select * from dfgroup union all select * from dfgrouphist) dg,
        (select df.acctno, df.groupid, nvl((dfqtty + rcvqtty + blockqtty + carcvqtty + caqtty )* df.dfrate/100 * seif.dfrefprice + df.cacashqtty*seif.dfrefprice,0) amt
            from vw_dfmast_all df , securities_info seif
            where  seif.codeid = df.codeid) df
    where dg.groupid = df.groupid
    group by  dg.groupid, dg.afacctno) GTTSDB
on GTTSDB.groupid = main.groupid and GTTSDB.afacctno = main.afacctno
-- tong no phi, no lai hien tai
left join
(select  dg.groupid,sum(intnmlacr+ intovdacr+ intdue+ intnmlovd) int_now,
        sum( feeintnmlacr + feeintovdacr + feeintnmlovd + feeintdue ) fee_now
from (Select * from dfgroup union all select * from dfgrouphist) dg, vw_lnmast_all ln
     where dg.lnacctno = ln.acctno
     group by    dg.groupid) debts
on debts.groupid = main.groupid
--no lai phat sinh tu today den ht
left join
(select dg.groupid, dg.afacctno, sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (Select * from dfgroup union all select * from dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('INTNMLACR','INTOVDACR','INTDUE','INTNMLOVD')
    and tran.txdate > v_ToDate
    group by dg.groupid, dg.afacctno) Int_mov
on Int_mov.groupid = main.groupid
--------- phat sinh lai cong don
left join
(select dg.groupid, dg.afacctno,
        sum(case when lni.frdate < V_ToDate then round(intamt/(lni.todate-lni.frdate)*(lni.todate - to_date(V_ToDate,'DD/MM/RRRR')))
                when lni.frdate >= V_ToDate then intamt end ) amt
from lninttran lni, (Select * from dfgroup union all select * from dfgrouphist) dg
where lni.todate > V_ToDate
and dg.lnacctno = lni.acctno
group by dg.groupid, dg.afacctno) INT_congdon
on INT_congdon.groupid = main.groupid
------------phi phat sinh
left join
(select dg.groupid,  sum(case when ap.txtype = 'C' then tran.namt else -tran.namt end) amt
    from vw_lntran_all tran, apptx ap, (Select * from dfgroup union all select * from dfgrouphist) dg
    where ap.apptype = 'LN' and ap.txcd = tran.txcd
    and tran.deltd <> 'Y'  and ap.txtype in ('D','C')
    and dg.lnacctno = tran.acctno
    and ap.field in ('FEEINTNMLACR','FEEINTOVDACR','FEEINTNMLOVD','FEEINTDUE') --,'FEEINTPAID'
    and tran.txdate > v_ToDate
    group by  dg.groupid) FEE_mov
on FEE_mov.groupid = main.groupid
-----------------phi cong don
left join
(select dg.groupid,
        sum(case when lni.frdate < V_ToDate then round(feeintamt/(lni.todate-lni.frdate)*(lni.todate - to_date(V_ToDate,'DD/MM/RRRR') ))
                when lni.frdate >= V_ToDate then feeintamt end ) amt
from lninttran lni, (Select * from dfgroup union all select * from dfgrouphist) dg
where lni.todate > V_ToDate
and dg.lnacctno = lni.acctno
group by dg.groupid) FEE_congdon
on FEE_congdon.groupid = main.groupid

where   main.goc - nvl(prinpaid_mov.prinamt,0) <> V_run AND
case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(main.AFacctno,1,4)) end  <> 0
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
