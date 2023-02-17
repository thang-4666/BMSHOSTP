SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "DF0042" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   BBRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE         IN       VARCHAR2,
   T_DATE         IN       VARCHAR2,
   PV_CUSTODYCD       IN       VARCHAR2, --CUSTODYCD
   PV_AFACCTNO         IN       VARCHAR2,
   PV_RRTYPE         IN       VARCHAR2,
   PV_GROUPID         IN       VARCHAR2,
   PV_TXTYPE           in       varchar2,
   PV_TLTXCD    in          varchar2,
   PV_SYMBOL        in      varchar2,
   TLID            IN       VARCHAR2

   )
IS
--Sao ke giao dich khe uoc vay
--created by CHaunh at 08/03/2012
--Chaunh 30/03/2012 sua lai toan bo cac bang co dfmasthist, dfgrouphist, lnschdhist
--Chaunh 30/03/2012 them cac giao dich 2648,2646,2636,2665 tra no T0, chi cong vao cac truong PRINPAID, INTPAID, FEEINTPAID ma khong ghi giam cac truong goc, lai, phi
--Chaunh 06/04/2012 them vw_tllogfld_all de xu ly giao dich 2688 trong truong hop nguoi nhan bi sinh ra them 1 giao dich 2673
-- ---------   ------  -------------------------------------------

   V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
   V_STRBRID      VARCHAR2 (4);            -- USED WHEN V_NUMOPTION > 0
   V_STRCUSTODYCD  VARCHAR2 (20);
   V_STRAFACCTNO               VARCHAR2(20);
   V_GROUPID               VARCHAR2(20);
   V_STRRRTYPE               VARCHAR2(50);
   v_FrDate                DATE;
   V_ToDate                 DATE;
   V_TXTYPE                 varchar2(20);
   l_BRID_FILTER        VARCHAR2(50);
   V_TLTXCD            varchar2(20);
   V_SYMBOL              varchar2(20);
   V_STRTLID           VARCHAR2(6);


BEGIN
   V_STRTLID:= TLID;
   V_STROPTION := OPT;

   v_FrDate := to_date(F_DATE,'DD/MM/RRRR');
   v_ToDate   := to_date(T_DATE,'DD/MM/RRRR');

IF V_STROPTION = 'A' then
    V_STRBRID := '%';
ELSIF V_STROPTION = 'B' then
    V_STRBRID := substr(BBRID,1,2) || '__' ;
else
    V_STRBRID:=BBRID;
END IF;

IF (V_STROPTION = 'A') THEN
  l_BRID_FILTER := '%';
ELSE if (V_STROPTION = 'B') then
        select brgrp.mapid into l_BRID_FILTER from brgrp where brgrp.brid = BBRID;
    else
        l_BRID_FILTER := BBRID;
    end if;
END IF;


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

   IF(PV_RRTYPE = 'ALL' OR PV_RRTYPE IS NULL)
    THEN
       V_STRRRTYPE := '%';
   ELSE
       V_STRRRTYPE := PV_RRTYPE;
   END IF;


   IF(PV_GROUPID = 'ALL' OR PV_GROUPID IS NULL)
    THEN
       V_GROUPID := '%';
   ELSE
       V_GROUPID := PV_GROUPID;
   END IF;

   IF (PV_TXTYPE = 'ALL')
    THEN
        V_TXTYPE := '%';
    ELSE
        V_TXTYPE := PV_TXTYPE;
   END IF;

   if (PV_TLTXCD = 'ALL')
    then
        V_TLTXCD := '%';
    else
        V_TLTXCD := PV_TLTXCD;
   end if;

   if PV_SYMBOL = 'ALL'
    then
        V_SYMBOL:= '%';
    else
        V_SYMBOL := upper(replace(PV_SYMBOL,' ','_'));
   end if;


OPEN PV_REFCURSOR
FOR
SELECT * FROM (
select orderid, txdate, txnum, expdate, tltxcd, custodycd, afacctno,
        groupid, fullname, rrtype, txdesc, symbol,
        debit_namt, credit_namt
from (
    select '01' orderid, tran.txdate, tran.txnum, lnschd.overduedate expdate, tran.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype, tl.txdesc, sb.symbol,
        sum(case when ap.txtype = 'D' then tran.namt else 0 end) debit_namt,
        sum(case when ap.txtype = 'C' then tran.namt else 0 end) credit_namt
    from vw_dftran_all tran,
        (Select * from dfmast union all select * from dfmasthist) df,
        apptx ap, vw_lnmast_all ln, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, BBRID, TLGOUPS)=0)  cf, afmast af, vw_tllog_all tl, sbsecurities sb, vw_lnschd_all lnschd
    where ap.apptype = 'DF' and ap.txtype in  ('D','C') and ap.txcd = tran.txcd and tran.deltd <> 'Y'
    and ap.field in ('DFQTTY','RCVQTTY','CACASHQTTY','CARCVQTTY','BLOCKQTTY')
    and ln.acctno = df.lnacctno and cf.custid = af.custid and af.acctno = df.afacctno
    and ln.acctno = lnschd.acctno and lnschd.reftype = 'P'
    and df.acctno = tran.acctno and sb.codeid = df.codeid
    and tran.txnum = tl.txnum and tran.txdate = tl.txdate
    and tran.txdate >= v_FrDate and tran.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and sb.symbol like V_SYMBOL and tran.tltxcd like V_TLTXCD
    AND TRAN.TLTXCD <> '2684'
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    group by tran.txdate, tran.txnum, lnschd.overduedate, tran.tltxcd, cf.custodycd, df.afacctno,df.groupid, cf.fullname, df.rrtype, tl.txdesc,sb.symbol
    having sum(case when ap.txtype ='D' then -tran.namt else tran.namt end) <>0

    union all -- giao dich tra no cam co MS 8809
    select '01' orderid, od.txdate, od.txnum, lnschd.overduedate expdate,'8809' tltxcd, cf.custodycd, af.acctno,
        df.groupid, cf.fullname, df.rrtype, 'Ban chung khoan cam co trong deal' txdesc, sb.symbol,
        od.execqtty debit_namt,
        0  credit_namt
    from    (Select * from dfmast union all select * from dfmasthist) df,
            (select od.txdate, od.orderid, od.txnum, od.CODEID, sec.symbol,od.AFACCTNO,od.SEACCTNO,refid , exprice, sum(ORDERQTTY) ORDERQTTY, sum(nvl(ode.EXECQTTY,0)) EXECQTTY
                    from (SELECT * FROM odmast where deltd <> 'Y' UNION ALL SELECT * FROM odmasthist where deltd <> 'Y') od,
                         (SELECT * FROM odmapext where deltd <> 'Y' UNION ALL SELECT * FROM odmapexthist where deltd <> 'Y') ode, SECURITIES_INFO SEC
                    where exectype='MS'-- AND orstatus = '4'
                    AND nvl(od.EXECQTTY,0)>0
                    AND od.codeid=sec.codeid and od.orderid = ode.orderid(+)
                    group by od.txdate,od.txnum, od.orderid,od.CODEID, sec.symbol,od.AFACCTNO,od.SEACCTNO,refid , exprice ) od
        , vw_lnmast_all ln, sbsecurities sb, cfmast cf, afmast af, vw_lnschd_all lnschd
    where
    ln.acctno = df.lnacctno AND od.refid = df.acctno
    and od.codeid = sb.codeid and lnschd.reftype = 'P' and ln.acctno = lnschd.acctno
    and cf.custid = af.custid and af.acctno = df.afacctno
    and od.txdate >= v_FrDate and od.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and sb.symbol like V_SYMBOL and '8809' like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

    /*select '01' orderid, tl.txdate, tl.txnum, lnschd.overduedate expdate, tl.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype, 'Ban chung khoan cam co trong deal' txdesc, sb.symbol,
        tl.msgamt debit_namt,
        0  credit_namt
    from vw_tllog_all tl, vw_odmast_all od, (Select * from dfmast union all select * from dfmasthist) df, (select * from odmapext union all select * from odmapexthist) om,
        lnmast ln, sbsecurities sb, cfmast cf, afmast af, lnschd
    where tl.tltxcd = '8809' and tl.msgacct = od.orderid and od.orderid = om.orderid
    and df.acctno = om.refid and ln.acctno = df.lnacctno AND tl.deltd <> 'Y' AND  od.deltd <> 'Y'
    and od.codeid = sb.codeid and lnschd.reftype = 'P' and ln.acctno = lnschd.acctno
    and cf.custid = af.custid and af.acctno = df.afacctno
    and tl.txdate >= v_FrDate and tl.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and sb.symbol like V_SYMBOL and tl.tltxcd like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE*/

    union all
    select '02' orderid, tran.txdate, tran.txnum, lnschd.overduedate expdate, tran.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype,
        CASE WHEN ap.field in ('PRINNML','PRINOVD')  THEN tl.txdesc || '_Goc'
             WHEN ap.field in ('INTNMLACR','INTOVDACR','INTNMLOVD','INTDUE')  THEN tl.txdesc || '_Lai'
             WHEN ap.field in ('FEEINTNMLOVD','FEEINTOVDACR','FEEINTNMLACR','FEEINTDUE') THEN tl.txdesc || '_Phi'
             END txdesc, 'Money' symbol,
        sum(case when ap.txtype = 'D' then tran.namt  else 0 end) dedit_amt, --tru tien vao no la tang tien vao tai khoan DF
        sum(case when ap.txtype = 'C'  then tran.namt else 0 end) credit_amt
    from vw_lntran_all tran, apptx ap, vw_lnmast_all ln, cfmast cf, afmast af,
         (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df, vw_tllog_all tl, vw_lnschd_all lnschd
    where ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.txcd = tran.txcd
    and ap.field in ('PRINNML','PRINOVD','INTNMLACR','INTOVDACR','INTNMLOVD','INTDUE','FEEINTNMLOVD','FEEINTOVDACR','FEEINTNMLACR','FEEINTDUE')
    AND tran.tltxcd NOT IN ('2648','2646','2636','2665')
    and tran.acctno = ln.acctno and tran.deltd <> 'Y' AND tl.deltd <> 'Y'
    and cf.custid = af.custid and af.acctno = df.afacctno
    and tl.txnum = tran.txnum and tl.txdate = tran.txdate
    and df.lnacctno = tran.acctno
    and lnschd.acctno = ln.acctno and lnschd.reftype = 'P'
    and tran.txdate >= v_FrDate and tran.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and tran.tltxcd like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    group by  tran.txdate, tran.txnum, lnschd.overduedate, tran.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype,
        CASE WHEN ap.field in ('PRINNML','PRINOVD')  THEN tl.txdesc || '_Goc'
             WHEN ap.field in ('INTNMLACR','INTOVDACR','INTNMLOVD','INTDUE')  THEN tl.txdesc || '_Lai'
             WHEN ap.field in ('FEEINTNMLOVD','FEEINTOVDACR','FEEINTNMLACR','FEEINTDUE') THEN tl.txdesc || '_Phi'
             END
    having sum(case when ap.txtype = 'D' then tran.namt  else 0 end) - sum(case when ap.txtype = 'C'  then tran.namt else 0 end) <> 0

    UNION ALL
    SELECT '02' orderid, tran.txdate, tran.txnum, lnschd.overduedate expdate, tran.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype,
        CASE WHEN ap.field in ('PRINPAID')  THEN tl.txdesc || '_Goc'
             WHEN ap.field in ('INTPAID')  THEN tl.txdesc || '_Lai'
             WHEN ap.field in ('FEEINTPAID') THEN tl.txdesc || '_Phi'
             END txdesc, 'Money' symbol,
        sum(case when ap.txtype = 'C' then tran.namt
                 else 0 end) dedit_amt, --tru tien vao no la tang tien vao tai khoan DF
        sum(case when ap.txtype = 'D' then tran.namt
                else 0 end) credit_amt
    from vw_lntran_all tran, apptx ap, vw_lnmast_all ln, cfmast cf, afmast af,
         (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df, vw_tllog_all tl, vw_lnschd_all lnschd
    where ap.apptype = 'LN' and ap.txtype in ('D','C') and ap.txcd = tran.txcd
    and ap.field in ('PRINPAID','INTPAID','FEEINTPAID')
    AND tran.tltxcd IN ('2648','2646','2636','2665')
    and tran.acctno = ln.acctno and tran.deltd <> 'Y' AND tl.deltd <> 'Y'
    and cf.custid = af.custid and af.acctno = df.afacctno
    and tl.txnum = tran.txnum and tl.txdate = tran.txdate
    and df.lnacctno = tran.acctno
    and lnschd.acctno = ln.acctno and lnschd.reftype = 'P'
    and tran.txdate >= v_FrDate and tran.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and tran.tltxcd like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    group by  tran.txdate, tran.txnum, lnschd.overduedate, tran.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype,
        CASE WHEN ap.field in ('PRINPAID')  THEN tl.txdesc || '_Goc'
             WHEN ap.field in ('INTPAID')  THEN tl.txdesc || '_Lai'
             WHEN ap.field in ('FEEINTPAID') THEN tl.txdesc || '_Phi'
             END
    having sum(case when ap.txtype = 'C' then tran.namt
                 else 0 end) - sum(case when ap.txtype = 'D' then tran.namt
                else 0 end) <> 0

    union all -- giao dich giai ngan chung khoan
    select '01' orderid, tran.txdate, tran.txnum, lnschd.overduedate expdate, tran.tltxcd,  cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype, tl.txdesc, sb.symbol,
        sum(case when ap.txtype = 'D' then tran.namt else 0 end) debit_namt,
        sum(case WHEN ap.txtype = 'C' then tran.namt else 0 end) credit_namt --chi lay giao dich tang, giai ngan ck la tang so luong ck o DF
    from vw_setran_all tran , (Select * from dfmast union all select * from dfmasthist) df, vw_lnmast_all ln,
    vw_tllog_all tl, sbsecurities sb, cfmast cf, afmast af, apptx ap, vw_lnschd_all lnschd--, vw_tllogfld_all fld
    where --tl.txdate=fld.txdate AND tl.txnum=fld.txnum AND fld.cvalue = df.groupid AND fld.fldcd = '20' -- truong hop 2688 sinh ra 2673 se ko bi lap lai
    df.txdate = tran.txdate and df.txnum = tran.txnum
    and ap.apptype = 'SE' and ap.txtype =  'C' and ap.txcd = tran.txcd and tran.deltd <> 'Y' AND tl.deltd <> 'Y'
    and ln.acctno = df.lnacctno and tl.txdate = tran.txdate and tl.txnum = tran.txnum
    and ln.acctno = lnschd.acctno and lnschd.reftype = 'P'
    and tran.txdate >= v_FrDate and tran.txdate <= V_ToDate
    and sb.codeid = df.codeid and cf.custid = af.custid and af.acctno = df.afacctno
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and tran.tltxcd like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
    and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )
    group by tran.txdate, tran.txnum, lnschd.overduedate, tran.tltxcd, df.acctno, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype, tl.txdesc, sb.symbol
    HAVING sum(case when ap.txtype = 'D' then tran.namt else 0 end) + sum(case WHEN ap.txtype = 'C' then tran.namt else 0 end) <> 0

    UNION --voi loai mua cho ve, ko log vao setran hay dftran, ma duoc dua vao stdfmap
    select  '01' orderid, df.txdate, df.txnum, lnschd.overduedate expdate,
        tl.tltxcd,  cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype, tl.txdesc, sb.symbol,
        0 debit_namt,
        stdfmap.dfqtty credit_namt
    FROM (Select * from dfmast union all select * from dfmasthist) df , (SELECT * FROM stdfmap UNION ALL SELECT * FROM stdfmaphist) stdfmap,
        vw_tllog_all tl, cfmast cf, afmast af,  sbsecurities sb, vw_lnschd_all lnschd
    WHERE df.txdate = stdfmap.txdate AND df.acctno = stdfmap.dfacctno
    AND tl.txdate = df.txdate AND tl.txnum = df.txnum AND tl.deltd <> 'Y' AND stdfmap.deltd <> 'Y'
    AND af.custid = cf.custid AND af.acctno = df.afacctno
    AND lnschd.acctno  = df.lnacctno AND lnschd.reftype = 'P'
    AND sb.codeid = df.codeid
    and tl.txdate >= v_FrDate and tl.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and tl.tltxcd like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
     and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

    union all -- giao dich giai ngan tien
    select '02' orderid, tran.txdate, tran.txnum, lnschd.overduedate expdate, tran.tltxcd, cf.custodycd, df.afacctno,
        df.groupid, cf.fullname, df.rrtype, tran.txdesc,'Money' symbol,
         0  debit_namt,
        tran.msgamt credit_namt --giai ngan tien lam tang tai khoan tien o df
    from vw_tllog_all tran ,
         (SELECT * FROM dfgroup UNION ALL SELECT * FROM dfgrouphist) df, vw_lnmast_all ln,  cfmast cf, afmast af, vw_tllogfld_all fld, vw_lnschd_all lnschd
    where fld.txdate = tran.txdate and fld.txnum = tran.txnum and fld.fldcd = '20'
    and tran.deltd <> 'Y' and fld.cvalue = df.groupid and tran.tltxcd in ('2674','2624') --chaunh them 2624 ngay 24/09/2012
    and ln.acctno = df.lnacctno and ln.acctno = lnschd.acctno and lnschd.reftype = 'P'
    and cf.custid = af.custid and af.acctno = df.afacctno
    and tran.txdate >= v_FrDate and tran.txdate <= V_ToDate
    and cf.custodycd like V_STRCUSTODYCD and af.acctno like V_STRAFACCTNO
    and tran.tltxcd like V_TLTXCD
    and df.groupid like V_GROUPID and df.rrtype like V_STRRRTYPE
     and exists (select gu.grpid from tlgrpusers gu where af.careby = gu.grpid and gu.tlid = V_STRTLID )

    )

where orderid like V_TXTYPE and case when V_STROPTION = 'A' then 1 else instr(l_BRID_FILTER,substr(AFacctno,1,4)) end  <> 0
and symbol like V_SYMBOL
order by txdate, txnum ,orderid, groupid, credit_namt ,debit_namt,  txdesc)
;


EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
