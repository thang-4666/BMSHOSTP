SET DEFINE OFF;
CREATE OR REPLACE PACKAGE cspks_brokerinquiry IS
procedure pr_getSEAccountInfo
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2,
    p_getfullrectype IN varchar2 default '0',
    P_TLID IN varchar2 default 'ALL',
    P_SYMBOL IN varchar2 default 'ALL',
    P_CUSTODYCD IN varchar2 default 'ALL'
    );

  procedure pr_getSubAccountInfo
      (p_refcursor in out pkg_report.ref_cursor,
      p_afacctno  IN  varchar2);
  procedure pr_getSubAccountInfonew
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2);
  procedure pr_getcashinvesment
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2);

  procedure pr_getoutstanding
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2);
END cspks_brokerinquiry;
 
 
 
 
/


CREATE OR REPLACE PACKAGE BODY cspks_brokerinquiry
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

---------------------------------pr_OpenLoanAccount------------------------------------------------
procedure pr_getSubAccountInfo
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2
    )
IS
    l_marginrate number;
    l_navaccount number;
    l_outstanding number;
BEGIN
    plog.setendsection(pkgctx, 'pr_getSubAccountInfo');


    --Dong bo thong tin len Buffer
    /*if length(nvl(p_afacctno,'X')) =10 then
        jbpks_auto.pr_gen_buf_ci_account(p_afacctno);
    end if;*/
    /*select nvl(sum(marginrate),0),nvl(sum(navaccount),0) navaccount,nvl(sum(-outstanding),0) outstanding
        into l_marginrate ,l_navaccount, l_outstanding
        from v_getsecmarginratio where afacctno = p_afacctno;*/


    /*Open p_refcursor for
    select
        --1.Tien tren tieu khoan
        max(ci.balance - nvl(b.SECUREDAMT,0) + nvl(rcv.rcvamt,0)) BALANCE, --Tien tren tieu khoan
            --1.1 Tien mat
            max(ci.balance- nvl(b.SECUREDAMT,0)) CIBALANCE, --Tien mat
            --1.2 Tien cho ve
            max(nvl(rcv.rcvamt,0)) RCVAMT, -- Tien ban cho nhan ve
        --Khong dung nua
        max(nvl(ln.dfamt,0)) DFODAMT,
        sum(nvl(df.DFSEAMT,0)) DFSEAMT,
        --3.Tong phai tra
        max(nvl(ln.dfamt,0) + nvl(ln.t0amt,0) + nvl(ln.mramt,0) + ci.depofeeamt + ci.trfbuyamt + nvl(b.SECUREDAMT,0) + nvl(odadv.rcvadv,0)) TOTALODAMT, --Tong phai tra
            --3.1
            max(nvl(ln.dfamt,0)) DFAMT, --No Deal
            --3.2
            max(nvl(ln.t0amt,0)) T0AMT, --No bao lanh
            --3.3
            max(nvl(ln.mramt,0)) MRAMT, --No Margin
            --3.4
            max(ci.depofeeamt) DEPOFEEAMT, --No phi luu ky
            --3.5
            max(ci.trfbuyamt) TRFBUYAMT, --ky quy mua tra cham
            --3.6
            max(nvl(b.SECUREDAMT,0)) SECUREDAMT, --ky quy mua
            --3.7
            max(nvl(odadv.rcvadv,0)) RCVADV, --No ung truoc
        --2.Tong gia tri chung khoan
        sum(nvl(v.SEREAL,0)) TOTALSEAMT, -- Tong gia tri chung khoan
        --4.Tai san thuc co = 1+2-3
        max(ci.balance + nvl(rcv.rcvamt,0)) + sum(nvl(v.SEREAL,0))
            - max(nvl(ln.dfamt,0) + nvl(ln.t0amt,0) + nvl(ln.mramt,0) + ci.depofeeamt + ci.trfbuyamt + nvl(b.SECUREDAMT,0) + nvl(odadv.rcvadv,0)) NETASSVAL,--Tai san thuc co
        --5.Suc mua co ban
        round(max(ci.balance - nvl(b.SECUREDAMT,0) - ci.trfbuyamt + nvl(adv.avladvance,0) + af.advanceline)
                                + least(max(nvl(af.mrcrlimitmax,0)+ nvl(af.mrcrlimit,0)  - ci.dfodamt),max(nvl(af.mrcrlimit,0)) + max(nvl(sec.seamt,0)))
                                - max(nvl(ci.odamt,0))  - max(ci.depofeeamt),0) PP0, --Suc mua co ban
        --6. Ty le Margin
        round(l_marginrate,4) MARGINRATE, --Ty le ky quy = 1/Ty le thuc te
        --7. Ty le ky quy
        case when l_navaccount=0  then 0 else round(greatest(l_outstanding,0)/l_navaccount,4)*100 end DEBTRATE,
            --7.1 Du no
            greatest(l_outstanding,0) OUTSTANDING,
            --7.2 Tai san
            l_navaccount NAVACCOUNT,
        --8. Ty le vay
        case when sum(nvl(v.SEREAL,0))=0 then 100 else round(((sum(nvl(v.SEREAL,0)) - greatest(l_outstanding,0))/sum(nvl(v.SEREAL,0))),4)*100 end MARGINRATE_74
    from cfmast cf, (select * from afmast where acctno = p_afacctno) af,
        (select * from cimast where acctno = p_afacctno)ci,
        (select * from v_getsecmargininfo where afacctno = p_afacctno) sec,
        (select * from vw_getsecmargindetail dt, sbsecurities sb where dt.codeid= sb.codeid and sb.sectype <> '004' and afacctno = p_afacctno) v,
        (select afacctno, sum(depoamt) AVLADVANCE
            from v_getaccountavladvance
            where afacctno = p_afacctno group by afacctno) adv,
        (select  sts.afacctno,sum(sts.amt+sts.aamt - exfeeamt) rcvamt from v_advanceSchedule sts where afacctno = p_afacctno group by afacctno) rcv,
        (select afacctno, nvl(sum(secureamt),0) SECUREDAMT
            from v_getbuyorderinfo
            where afacctno = p_afacctno group by afacctno) b,
        (select trfacctno,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
            from lnmast where trfacctno = p_afacctno group by trfacctno) ln,
        (select acctno, sum(amt + feeamt) odadv,sum(amt) rcvadv from adschd where acctno = p_afacctno and status <> 'C' group by acctno) odadv,
        (SELECT DF.AFACCTNO,  SUM((DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) * CURRPRICE) DFSEAMT
                        FROM v_getdealinfo DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO) DF
    where cf.custid = af.custid and af.acctno = ci.afacctno
    and af.acctno = adv.afacctno(+)
    and af.acctno = rcv.afacctno(+)
    and af.acctno = b.afacctno(+)
    and af.acctno = ln.trfacctno(+)
    and af.acctno = odadv.acctno(+)
    and af.acctno = sec.afacctno(+)
    and af.acctno = v.afacctno(+)
    and af.acctno=df.afacctno (+)
    and af.acctno = p_afacctno;*/
    Open p_refcursor for
    SELECT  a.BALANCE,
            a.CIBALANCE,
            a.RCVAMT,
            a.TOTALSEAMT,
            a.tradeseamt,
            a.rcvseamt,
            a.buyingseamt,
            a.TOTALODAMT,
            a.DFAMT,
            a.T0AMT,
            a.MRAMT,
            a.DEPOFEEAMT,
            a.TRFBUYAMT,
            a.SECUREDAMT,
            a.RCVADV,
            a.NETASSVAL,
            a.SESECURED,
            a.bankavlbal,
            a.PP0,
            a.mrrate,
            ROUND(GREATEST(
                            ROUND(CASE WHEN a.MARGINRATE * a.MRIRATE = 0 THEN - a.OUTSTANDING
                                        ELSE greatest( 0,- a.outstanding - a.navaccount *100/a.mrirate) END
                                        , 0)
                            , a.NETODAMT)
                    ,0) ADDVND,
            a.mrcrlimitmax,
            a.advanceline,
            a.avllimit

    FROM
    (
        select
            --1.Tien tren tieu khoan
            max(ci.balance  + nvl(rcv.rcvamt,0)) BALANCE, --Tien tren tieu khoan
                --1.1 Tien mat
                max(ci.balance) CIBALANCE, --Tien mat
                --1.2 Tien cho ve
                max(nvl(rcv.rcvamt,0)) RCVAMT, -- Tien ban cho nhan ve
            --2.Tong gia tri chung khoan
            sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty - v.buyingqtty)*v.basicprice,0)) TOTALSEAMT, -- Tong gia tri chung khoan
                --2.1 Chung khoan san co
                sum(nvl((v.trade-v.execqtty)*v.basicprice,0)) tradeseamt,
                --2.1 Chung khoan cho ve
                sum(nvl((v.receiving+v.buyqtty - v.buyingqtty)*v.basicprice,0)) rcvseamt,
            --5.Tong gia tri chung khoan cho khop
            sum(nvl((v.buyingqtty)*v.basicprice,0)) buyingseamt, -- Tong gia tri chung khoan
            --3.Tong phai tra
            max(nvl(ln.dfamt,0) + nvl(ln.t0amt,0) + nvl(ln.mramt,0) + ci.depofeeamt + ci.trfbuyamt + nvl(b.SECUREDAMT,0) + nvl(odadv.rcvadv,0)) TOTALODAMT, --Tong phai tra
                --3.1
                max(nvl(ln.dfamt,0)) DFAMT, --No Deal
                --3.2
                max(nvl(ln.t0amt,0)) T0AMT, --No bao lanh
                --3.3
                max(nvl(ln.mramt,0)) MRAMT, --No Margin
                --3.4
                max(ci.depofeeamt) DEPOFEEAMT, --No phi luu ky
                --3.5
                max(ci.trfbuyamt) TRFBUYAMT, --ky quy mua tra cham
                --3.6
                max(nvl(b.SECUREDAMT,0)) SECUREDAMT, --ky quy mua
                --3.7
                max(nvl(odadv.rcvadv,0)) RCVADV, --No ung truoc
            --4.Tai san thuc co = 1+2-3
            max(ci.balance + nvl(rcv.rcvamt,0))
                + sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty - v.buyingqtty)*v.basicprice,0))
                - max(nvl(ln.dfamt,0)
                        + nvl(ln.t0amt,0)
                        + nvl(ln.mramt,0)
                       -- + ci.depofeeamt
                        + ci.trfbuyamt
                        + nvl(b.SECUREDAMT,0)
                        + nvl(odadv.rcvadv,0)) NETASSVAL,--Tai san thuc co
            --6.Ky quy yeu cau
            --sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty)*v.basicprice,0)) - least(max(nvl(af.mrcrlimitmax,0)  - ci.dfodamt),sum(nvl(v.SEAMT,0))) SESECURED,
            sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty)*v.basicprice,0)) - sum(nvl(v.SEAMT,0)) SESECURED,
            --7.So du kha dung tai ngan hang + so tien BSC hold
            max(ci.bankavlbal) bankavlbal,
            --8.Suc mua co ban
            --round(max(ci.balance + (ci.bankavlbal) - nvl(b.SECUREDAMT,0) - ci.trfbuyamt + nvl(adv.avladvance,0) + af.advanceline)
            --                        + least(max(nvl(af.mrcrlimitmax,0)+ nvl(af.mrcrlimit,0)  - ci.dfodamt),max(nvl(af.mrcrlimit,0)) + max(nvl(sec.seamt,0)))
            --                        - max(nvl(ci.odamt,0))  - max(ci.depofeeamt),0) PP0, --Suc mua co ban
                --4+7-6
                --4
                max(ci.balance + nvl(rcv.rcvamt,0))
                    + sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty - v.buyingqtty)*v.basicprice,0))
                    - max(nvl(ln.dfamt,0)
                            + nvl(ln.t0amt,0)
                            + nvl(ln.mramt,0)
                           -- + ci.depofeeamt
                            + ci.trfbuyamt
                            + nvl(b.SECUREDAMT,0)
                            + nvl(odadv.rcvadv,0))
                --7
                + max(ci.bankavlbal)
                --6
                - (sum(nvl((v.trade-v.execqtty+v.receiving+v.buyqtty)*v.basicprice,0)) - sum(nvl(v.SEAMT,0)))
                PP0, --Suc mua co ban
            --9. Ty le ky quy
            case when sum(case when nvl(v.seass,0)>0 then nvl(v.SEREAL,0) else 0 end) = 0 then 100
                else
                least(round((max(ci.balance + nvl(rcv.rcvamt,0)) + sum(case when nvl(v.seass,0)>0 then nvl(v.SEREAL,0) else 0 end) + max(ci.bankavlbal )
                - max(nvl(ln.dfamt,0) + nvl(ln.t0amt,0) + nvl(ln.mramt,0) /*+ ci.depofeeamt*/ + ci.trfbuyamt + nvl(b.SECUREDAMT,0) + nvl(odadv.rcvadv,0))) / sum(case when nvl(v.seass,0)>0 then nvl(v.SEREAL,0) else 0 end),4) * 100,100)
                end mrrate,
            --10. So tien can nop them
                --10.1 NAVACCOUNT
                least(max(nvl(sec.SEASS,0)), max(af.mrcrlimitmax)  - max(ci.dfodamt)) NAVACCOUNT,
                --10.2 OUTSTANDING
                max(nvl(adv.avladvance,0) + ci.balance
                        +LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)
                        - nvl(b.SECUREDAMT,0) - ci.trfbuyamt - nvl (b.overamt, 0)- ci.odamt - ci.ramt - ci.dfdebtamt - ci.dfintdebtamt) OUTSTANDING,
                --10.3 MARGINRATE
                MAX(round((case when ci.balance
                                +LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)
                                + nvl(adv.avladvance,0) - ci.odamt - nvl(b.SECUREDAMT,0) - ci.trfbuyamt - ci.ramt>=0 then 100000
                            else least( nvl(sec.SEASS,0), af.mrcrlimitmax - ci.dfodamt) /
                                    abs(ci.balance
                                        +LEAST(nvl(af.MRCRLIMIT,0),nvl(b.SECUREDAMT,0) + ci.trfbuyamt)
                                        + nvl(adv.avladvance,0) - ci.odamt - nvl(b.SECUREDAMT,0) - ci.trfbuyamt - ci.ramt)
                            end),4) * 100) MARGINRATE,
                --10.4 NET ODAMT
                MAX(greatest(ci.dueamt+ci.ovamt/*+depofeeamt*/ - ci.balance - nvl(adv.avladvance,0),0) ) NETODAMT,
                --10.5 AF.MRIRATE
                MAX(af.mrirate) mrirate,
                max(af.mrcrlimitmax) mrcrlimitmax,
                max(af.advanceline) advanceline,
                max(nvl(adv.avladvance,0) + af.mrcrlimitmax+af.mrcrlimit-ci.dfodamt + af.advanceline + ci.balance - ci.odamt- ci.dfdebtamt - ci.dfintdebtamt - nvl (b.overamt, 0)-nvl(b.SECUREDAMT,0) - ci.trfbuyamt - ci.ramt /*- ci.depofeeamt-CI.CIDEPOFEEACR*/) AVLLIMIT
        from cfmast cf, (select * from afmast where acctno = p_afacctno) af,
            (select * from cimast where acctno = p_afacctno)ci,
            (select * from v_getsecmargininfo where afacctno = p_afacctno) sec,
            (select * from vw_getsecmargindetail dt, sbsecurities sb where dt.codeid= sb.codeid and sb.sectype <> '004' and afacctno = p_afacctno) v,
            (select afacctno, sum(depoamt) AVLADVANCE
                from v_getaccountavladvance
                where afacctno = p_afacctno group by afacctno) adv,
            (select  sts.afacctno,sum(sts.amt+sts.aamt - exfeeamt) rcvamt from v_advanceSchedule sts where afacctno = p_afacctno group by afacctno) rcv,
            (select afacctno, nvl(sum(secureamt),0) SECUREDAMT, nvl(sum(overamt),0) OVERAMT
                from v_getbuyorderinfo
                where afacctno = p_afacctno group by afacctno) b,
            (select trfacctno,
                    nvl(sum(case when ftype = 'DF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) dfamt,
                    nvl(sum(case when ftype = 'DF' then prinnml+prinovd else 0 end),0) dfodamt,
                    nvl(sum(case when ftype = 'AF' then oprinnml+oprinovd+ointnmlacr+ointnmlovd+ointovdacr+ointdue else 0 end),0) t0amt,
                    nvl(sum(case when ftype = 'AF' then prinnml+prinovd+intnmlacr+intnmlovd+intovdacr+intdue+feeintnmlacr+feeintnmlovd+feeintovdacr+feeintdue else 0 end),0) mramt
                from lnmast where trfacctno = p_afacctno group by trfacctno) ln,
            (select acctno, sum(amt + feeamt) odadv,sum(amt) rcvadv from adschd where deltd <> 'Y' and acctno = p_afacctno and status <> 'C' group by acctno) odadv,
            (SELECT DF.AFACCTNO,  SUM((DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) * CURRPRICE) DFSEAMT
                            FROM v_getdealinfo DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO) DF
        where cf.custid = af.custid and af.acctno = ci.afacctno
        and af.acctno = adv.afacctno(+)
        and af.acctno = rcv.afacctno(+)
        and af.acctno = b.afacctno(+)
        and af.acctno = ln.trfacctno(+)
        and af.acctno = odadv.acctno(+)
        and af.acctno = sec.afacctno(+)
        and af.acctno = v.afacctno(+)
        and af.acctno=df.afacctno (+)
        and af.acctno = p_afacctno
    ) a;

    plog.setendsection(pkgctx, 'pr_getSubAccountInfo');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_getSubAccountInfo');
  return;
END pr_getSubAccountInfo;

procedure pr_getSubAccountInfonew
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2)
IS
    l_marginrate number;
    l_navaccount number;
    l_outstanding number;
    L_MARGININDAY NUMBER(20);
    v_ismargin varchar2(1);
    l_dclamtlimit NUMBER;
BEGIN
    plog.setendsection(pkgctx, 'pr_getSubAccountInfonew');
    --Dong bo thong tin len Buffer
    /*if length(nvl(p_afacctno,'X')) =10 then
        jbpks_auto.pr_gen_buf_ci_account(p_afacctno);
    end if;*/
    SELECT case when (MR.MRTYPE  = 'N' or mr.mrtype = 'L') then 'N' else 'Y' end ismargin into v_ismargin
    from afmast mst,aftype af, mrtype mr
    where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=p_afacctno;

    L_MARGININDAY:=FN_GET_MARGIN_EXECBUYAMT(p_afacctno);
    SELECT dclamtlimit INTO l_dclamtlimit FROM  v_getsecmarginratio  WHERE afacctno = p_afacctno;
    Open p_refcursor for
    select v_ismargin ismargin,
           --1.Tien tren tieu khoan
           BALANCE - holdbalance balance, --Tien tren tieu khoan
               --1.1 --Tien khong ky han
               cibalance - holdbalance CIBALANCE ,
               --1.2 Tien co ky han
               TDBALANCE ,
               --1.3 Tien cho ve
               AVLADVANCE RCVAMT   , -- Tien ban cho nhan ve
               --1.4 Lai tien gui chua thanh toan
               INTBALANCE ,
           --2.Tong gia tri chung khoan
           TOTALSEAMT,
           ---- 2.0 chung khoan mua da khop tinh theo gia tham chieu.
            totalbuyamt,
               --2.1 Chung khoan duoc phep ky quy
               MRQTTYAMT_CURR  MRQTTYAMT,
               --2.2 Chung khoan khong duoc phep ky quy
               NONMRQTTYAMT_CURR NONMRQTTYAMT,
               --2.3 Chung khoan cam co
               DFQTTYAMT_CURR DFQTTYAMT,
           --3.Tong phai tra
           TOTALODAMT, --Tong phai tra
               --3.0 No T3
               trfbuyamt,
               --3.1 No T3 chua thanh toan, ky quy
               secureamt , --No ky quy
               --3.2 No bao lanh
               T0AMT    , --No bao lanh
               --3.3 No vay margin
               MRAMT  , --No Margin
               --3.4 No vay ung truoc
               rcvadvamt ,
               --3.5 No vay cam co chung khoan
               dfodamt ,
               --3.6 Vay cam co tien gui
               TDODAMT,
               --3.7 No vay phi luu ky
               DEPOFEEAMT , --No phi luu ky
                ---- 3.8 PHI LUU KY TRONG HAN
                DEPOFEEAMTACR,
           --4. Tai san thuc co = 1+2-3
           balance - holdbalance + totalseamt - totalodamt NETASSVAL,
           --5. Ky quy yeu cau
           SESECURED,
               --5.1 CHung khoan hien co
               SESECURED_AVL ,
               --5.2 CHung khoan cho ve
               SESECURED_BUY ,
           --6. Ky quy hien co
           --qttyamt +  balance + rcvamt + mrcrlimit + bankavlbal - totalodamt ACCOUNTVALUE,
           (MRQTTYAMT) +  CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt+paidamt) ACCOUNTVALUE,
               --6.1 CHung khoan duoc phep ky quy
               --QTTYAMT ,
               (MRQTTYAMT) QTTYAMT,
               --6.2 Tien khong ky han
               CIBALANCE CIBALANCE2,
               --6.3 Tien gui co ky han ky quy
               mrcrlimit ,
               --6.4 SO du kha dung tai ngan hang
               BANKAVLBAL ,
               --6.5 No phai tra
               -(totalodamt-dfodamt+paidamt) totalodamt2,
               --6.6 Tien cho ve
               rcvamt,
           --7. Thang du tai san
           --qttyamt +  balance + rcvamt + mrcrlimit + bankavlbal - totalodamt -SESECURED PP0,
           --ROUND((MRQTTYAMT) +  CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt+paidamt) -SESECURED,15) PP0,
          GREATEST( mst.pp,0) PP0,
           --8. Ty le ky quy hien tai
        /*   case when (MRQTTYAMT) +  CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt+paidamt) < 0 then 0 else
                case when (MRQTTYAMT)=0 then 100 else
                    round(((MRQTTYAMT) +  least(CIBALANCE + rcvamt + mrcrlimit + bankavlbal - (totalodamt-dfodamt+paidamt),0))/(MRQTTYAMT),3)*100
                end
           end MRRATE,*/
            MARGINRATE MRRATE,
           --round((TOTALSEAMT +  balance + rcvamt + mrcrlimit + bankavlbal - totalodamt)/qttyamt,4)*100 end MRRATE
            mst.mrcrlimitmax,
            mst.advanceline,
            mst.avllimit,
            bankinqirydt,
            holdbalance,
            ---Tien cho ve T1
            mst.avlreceiving_t1 cash_receiving_t1,
            ---Tien cho ve T2
            -- Rut toi da
            AVLWITHDRAW,
            --Tien phai nop them
            callamt,
            mst.avlreceiving_t2 cash_receiving_t2,
            -----Tien cho ve T3
            mst.avlreceiving_t3 cash_receiving_t3,
            ---Tien co tuc cho ve avladv_t3+avladv_t2+avladv_t1
            mst.careceiving
            ,mst.pp, mst.marginrate, mst.afstatus
            ,mst.ADD_TO_MRCRATE, mst.ADD_TO_MRIRATE
            ,greatest(case when mst.SE_TO_MRCRATE <0 then 0 else mst.SE_TO_MRCRATE end,0 ) SE_TO_MRCRATE
            ,greatest(case when mst.SE_TO_MRIRATE <0 then 0 else mst.SE_TO_MRIRATE end,0) SE_TO_MRIRATE
            , LEAST ( greatest(SE_TO_MRCRATEUB ,0) , GREATEST( se_outstanding*(-1),0) )     SE_TO_MRCRATEUB
            , LEAST ( greatest(SE_TO_MRIRATEUB  ,0),GREATEST( se_outstanding*(-1),0)  )      SE_TO_MRIRATEUB
            , mst.BALDEFOVD
            , mst.buyamt buyqtty
            ,L_MARGININDAY MARGIN_EXECBUYAMT
            , rptmrirate ,rptmrmrate,rptmrlrate,rptmrcrate,rptmrwrate,ADDVND,RECEIVINGAMT, nvl(ADDAMOUNT,0)  ADDAMOUNT,
            nvl(ADDAMOUNTI,0) ADDAMOUNTI,
            BAMT,l_dclamtlimit dclamtlimit,clamtlimit,afstatus_en

    from
    (
        select
                --1.Tien tren tieu khoan
                round(ci.balance + ci.bamt /*+ CI.AVLADVANCE */ + nvl( adv.receivingamt,0)+ ci.tdbalance + ci.crintacr  /*+ci.tdintamt */) BALANCE, --Tien tren tieu khoan
                    --1.1 --Tien khong ky han
                    ci.balance + ci.bamt CIBALANCE,
                    --1.2 Tien co ky han
                    ci.tdbalance TDBALANCE,
                    --1.3 Tien cho ve
                    ci.rcvamt RCVAMT, -- Tien ban cho nhan ve
                    --1.4 Lai tien gui chua thanh toan
                    round(ci.crintacr + ci.tdintamt) INTBALANCE,
                --2.Tong gia tri chung khoan
                    -- nvl(sec.mrqttyamt_curr,0) + nvl(sec.nonmrqttyamt_curr,0) + nvl(sec.dfqttyamt_curr,0) TOTALSEAMT,
                    nvl(sec.totalamt,0) TOTALSEAMT,
                    -- 2.2 tong gia tri mua khop tinh theo gia tham chieu.
                    nvl(sec.totalbuyamt,0) totalbuyamt,
                    --2.1 Chung khoan duoc phep ky quy
                    nvl(sec.mrqttyamt_curr,0) MRQTTYAMT_curr,
                    nvl(sec.mrqttyamt,0) MRQTTYAMT,
                    --2.2 Chung khoan khong duoc phep ky quy
                    nvl(sec.NONMRQTTYAMT_curr,0) NONMRQTTYAMT_curr,
                    nvl(sec.NONMRQTTYAMT,0) NONMRQTTYAMT,
                    --2.1 Chung khoan cam co
                    nvl(sec.DFQTTYAMT_curr,0) DFQTTYAMT_curr,
                    nvl(sec.DFQTTYAMT,0) DFQTTYAMT,
                --3.Tong phai tra
                    ci.dfodamt + ci.t0odamt + ci.mrodamt
                        + ci.ovdcidepofee + ci.cidepofeeacr + ci.execbuyamt + ci.trfbuyamt + ci.rcvadvamt + TDODAMT TOTALODAMT, --Tong phai tra
                    --3.1 No T3
                    ci.trfbuyamt,
                    --3.2 No bao lanh
                    ci.t0odamt T0AMT, --No bao lanh
                    ----3.3 No ky quy
                    --ci.bamt-ci.trfbuyamt  secureamt, --No ky quy
                    ci.execbuyamt secureamt, --No ky quy da khop
                    --3.3 No vay margin
                    ci.mrodamt MRAMT, --No Margin
                    --3.4 No vay ung truoc
                    ci.rcvadvamt,
                    --3.5 No vay cam co chung khoan, phai tra ban deal
                    ci.dfodamt,ci.paidamt,
                    --3.6 Vay cam co tien gui
                    ci.TDODAMT,
                    --3.7 No vay phi luu ky
                    ci.ovdcidepofee DEPOFEEAMT, --No phi luu ky
                    --3.7 No vay phi luu ky TRONG HAN
                    ci.cidepofeeacr DEPOFEEAMTACR,

                --4. Tai san thuc co = 1+2-3
                --5. Ky quy yeu cau
                nvl(MRQTTYAMT,0)  - nvl(MR_QTTYAMT,0) + (ci.bamt-ci.trfbuyamt-ci.execbuyamt) - nvl(MR_QTTYAMT_BUY,0)  SESECURED,
                    --5.1 CHung khoan hien co
                    nvl(MRQTTYAMT,0)  - nvl(MR_QTTYAMT,0) SESECURED_AVL,
                    --5.2 CHung khoan cho ve
                    --nvl(MRQTTYAMT_BUY,0)  - nvl(MR_QTTYAMT_BUY,0) SESECURED_BUY,
                    (ci.bamt-ci.trfbuyamt-ci.execbuyamt) - nvl(MR_QTTYAMT_BUY,0) SESECURED_BUY,
                --6. Ky quy hien co
                    --6.1 CHung khoan duoc phep ky quy
                    nvl(MRQTTYAMT,0) /*+ NONMRQTTYAMT*/ /*+ nvl(MRQTTYAMT_BUY,0)*/ /*+ NONMRQTTYAMT_BUY*/ QTTYAMT,
                    --6.2 Tien khong ky han
                    --BALANCE ,
                    --6.3 Tien gui co ky han ky quy
                    ci.mrcrlimit,
                    --6.4 SO du kha dung tai ngan hang
                    case when af.alternateacct = 'Y' or af.corebank ='Y' then cim.BANKAVLBAL else 0 end BANKAVLBAL,
                    --No phai tra
                --7. Thang du tai san
                    --Ky quy hien co - Ky quy yeu cau
                --8. Ty le ky quy hien tai
                    --Ky quy hien co / Chung khoan duoc phep ky quy
                    af.mrcrlimitmax,
                    ci.advanceline,
                    ci.avllimit,
                    ROUND(AVLWITHDRAW+ci.BANKAVLBAL) AVLWITHDRAW,
                    to_char(cim.bankinqirydt,'hh24:MI:ss') bankinqirydt,
                    cim.holdbalance,
                    --Tien cho ve T1
                    ci.avladv_t1,
                    ---Tien cho ve T2
                    ci.avladv_t2,
                    -----Tien cho ve T3
                    ci.avladv_t3,
                    ---Tien co tuc cho ve
                    ci.callamt,--Tien phai nop them
                     CI.RECEIVING - CI.CASH_RECEIVING_T3 - (CI.CASH_RECEIVING_T1-CI.CASH_RECEIVING_T1_CLDRD1) - CI.CASH_RECEIVING_T2 careceiving --TIEN CO TUC CHO VE
                    --ci.receiving-(ci.cash_receiving_t1+ci.cash_receiving_t2) careceiving
                    --begin chaunh
                    , ci.MARGINRATE --8.ty le margin hien tai (ctck)
                    , ci.PP --9.Suc mua co ban
                    , case when cf.custatcom <> 'Y' then UTF8NUMS.c_const_AccountInfo_binhthuong
                            --dieu kien call
                           when mrt.mrtype = 'T' and aft.istrfbuy <> 'Y' and
                                    ((AFT.MNEMONIC <>'T3'
                                    AND (
                                    (af.mrlrate <= ci.marginrate AND ci.marginrate < AF.MRMRATE )-- Rtt<Rcall
                                    OR (AF.Mrlrate<=ci.MARGINRATE AND ci.MARGINRATE<AF.MRCRATE AND AF.Callday>0
                                    -- Rtt<Rt.call va call k ngay lien tiep
                                    )
                                    )
                                    AND (AF.CALLDAY<AF.K1DAYS ))
                                    or ((cim.dueamt-GREATEST(0,CIm.BALANCE+NVL(ci.AVLADVANCE,0)- CIm.BUYSECAMT))>1))
                                AND CIm.OVAMT =0
                                AND (AF.CALLDAY < AF.K1DAYS or af.callday = 0)
                                AND af.mrlrate <= ci.marginrate
                           then UTF8NUMS.c_const_AccountInfo_call
                           --dieu kien
                           when af.actype <> '0000'
                                and (
                                (aft.mnemonic <>'T3' and
                                       ((ci.marginrate<af.mrlrate and af.mrlrate <> 0)
                                       OR (ci.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))
                                       )
                                )
                                or (CIM.OVAMT-GREATEST(0,CIM.BALANCE+NVL(ci.AVLADVANCE,0)- CIM.BUYSECAMT))>1 )
                           then 'Xu ly'
                           --canh bao margin
                           when af.actype <> '0000'
                                    and (CIM.OVAMT+CIM.DUEAMT=0)
                                    AND (
                                      (AFT.MNEMONIC <>'T3') and
                                                    ((ci.marginrate<AF.MRwRATE and ci.marginrate>=AF.MRCRATE)-- chi pham ti le canh bao
                                                    OR (ci.MARGINRATE<AF.MRCRATE AND ci.MARGINRATE>=AF.MRMRATE AND AF.Callday=0)-- vi pham R thoat Call nhung callday=0
                                                    /*OR EXISTS (SELECT * FROM LNSCHD SCHD,LNMAST MST,LNTYPE TYPE --den ngay canh bao
                                                              WHERE MST.ACCTNO=SCHD.ACCTNO AND MST.TRFACCTNO=AF.ACCTNO AND MST.ACTYPE=TYPE.ACTYPE
                                                              AND fn_get_prevdate(SCHD.OVERDUEDATE,TYPE.Warningdays)=GETCURRDATE)*/
                                                    )

                                       )
                           then UTF8NUMS.c_const_AccountInfo_canhbao

                          when af.status ='B' and af.isdebtt0 ='N'  THEN  UTF8NUMS.c_const_AccountInfo_phongtoa

                          when  af.status ='B' and af.isdebtt0 ='Y' THEN   UTF8NUMS.c_const_AccountInfo_ptbl

                      else UTF8NUMS.c_const_AccountInfo_binhthuong
                      end afstatus --10.trang thai tieu khoan
                    , case when aft.mnemonic<>'T3' then
                            round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(  LEAST( ci.se_outstanding+ l_dclamtlimit,0)  ,0) else greatest( 0,- LEAST( ci.se_outstanding+ l_dclamtlimit,0)  - nvl(ci.se_navaccount,0) *100/AF.MRCRATE) end),0)
                            else 0
                        end ADD_TO_MRCRATE -- 12.So tien can nop them
                    , case when aft.mnemonic<>'T3' then
                            round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - nvl(LEAST( ci.se_outstanding+ l_dclamtlimit,0),0) else greatest( 0,- LEAST( ci.se_outstanding+ l_dclamtlimit,0)  - nvl(ci.se_navaccount,0) *100/AF.MRIRATE) end),0)
                            else 0
                        end ADD_TO_MRIRATE -- 11. So tien can bo sung ve Rat
                      , round((af.mrirate/100 * round(-LEAST( ci.se_outstanding+ l_dclamtlimit,0)) - ci.seass)*100/mrt.MRIRATIO) SE_TO_MRIRATE
                    , round((af.MRCRATE/100 * round(-LEAST( ci.se_outstanding+ l_dclamtlimit,0)) - ci.seass) *100/mrt.MRIRATIO) SE_TO_MRCRATE
                    , round((-af.mrirate/100 * LEAST( ci.se_outstanding+ l_dclamtlimit,0) - ci.seass) / (af.mrirate/100 - 0.5)) SE_TO_MRIRATEUB --x =   TA(Rat/Rtt - 1)/(Rat - 0.5)
                    , round((-af.mrcrate/100 * LEAST( ci.se_outstanding+ l_dclamtlimit,0) - ci.seass) / (af.MRCRATE/100 - 0.5)) SE_TO_MRCRATEUB --x =   TA(Rat/Rtt - 1)/(Rat - 0.5)
                    , ci.BALDEFOVD --so tien co the rut
                    , nvl(vw.secureamt ,0) buyamt  -- gt mua trong ngay  ke ca phi
                    , af.mrirate rptmrirate ,af.mrmrate rptmrmrate,af.mrlrate rptmrlrate,AF.MRCRATE rptmrcrate,AF.MRWRATE rptmrwrate,
                    CI.AVLADVANCE,
                    round(greatest(round((case when nvl(ci.marginrate,0) * af.mrmrate =0 then - LEAST( ci.se_outstanding+ l_dclamtlimit,0) else
                     greatest( 0,- LEAST( ci.se_outstanding+ l_dclamtlimit,0) - ci.navaccount *100/AF.MRCRATE) end),0),greatest(cim.ovamt +ROUND(cim.dueamt) /*+ci.depofeeamt*/ - cim.balance - nvl(ci.avladvance,0),0)),0) addvnd
                    , nvl( adv.receivingamt,0)  RECEIVINGAMT,

                    --amount de tinh so ck can bo xung
                 GREATEST( Round((

                 round(greatest(round((case when /*nvl(sec.marginrate,0) **/ af.mrcrate =0 then - ci.outstanding else
                         greatest( 0,- ci.outstanding - ci.navaccount *100/(AF.MRCRATE))*(1+AF.Mrexrate/100) end),0),0),0)

                 - nvl( od.SELLAMOUNT,0)) / (1 + af.MREXRATE / 100) * (af.MRCRATE) / 100, 0),0)

                  ADDAMOUNT,
                           --amount de tinh so ck can bo xung
                 GREATEST( Round((
                 round(greatest(round((case when /*nvl(sec.marginrate,0) **/ af.mrcrate =0 then - ci.outstanding else
                         greatest( 0,- ci.outstanding - ci.navaccount *100/(AF.MRIRATE))*(1+AF.Mrexrate/100) end),0),0),0)
                 - nvl( od.SELLAMOUNT,0)) / (1 + af.MREXRATE / 100) * (af.MRIRATE) / 100, 0),0)

                  ADDAMOUNTI,
                  st.avlreceiving_t1, st.avlreceiving_t2,st.avlreceiving_t3,ci.se_outstanding,
                  ci.BAMT,af.clamtlimit
                   , case when cf.custatcom <> 'Y' then 'Normal'
                            --dieu kien call
                           when mrt.mrtype = 'T' and aft.istrfbuy <> 'Y' and
                                    ((AFT.MNEMONIC <>'T3'
                                    AND (
                                    (af.mrlrate <= ci.marginrate AND ci.marginrate < AF.MRMRATE )-- Rtt<Rcall
                                    OR (AF.Mrlrate<=ci.MARGINRATE AND ci.MARGINRATE<AF.MRCRATE AND AF.Callday>0
                                    -- Rtt<Rt.call va call k ngay lien tiep
                                    )
                                    )
                                    AND (AF.CALLDAY<AF.K1DAYS ))
                                    or ((cim.dueamt-GREATEST(0,CIm.BALANCE+NVL(ci.AVLADVANCE,0)- CIm.BUYSECAMT))>1))
                                AND CIm.OVAMT =0
                                AND (AF.CALLDAY < AF.K1DAYS or af.callday = 0)
                                AND af.mrlrate <= ci.marginrate
                           then 'CALL'
                           --dieu kien
                           when af.actype <> '0000'
                                and (
                                (aft.mnemonic <>'T3' and
                                       ((ci.marginrate<af.mrlrate and af.mrlrate <> 0)
                                       OR (ci.marginrate<AF.MRCRATE AND (AF.CALLDAY >=AF.K1DAYS  ))
                                       )
                                )
                                or (CIM.OVAMT-GREATEST(0,CIM.BALANCE+NVL(ci.AVLADVANCE,0)- CIM.BUYSECAMT))>1 )
                           then 'liquidate'
                           --canh bao margin
                           when af.actype <> '0000'
                                    and (CIM.OVAMT+CIM.DUEAMT=0)
                                    AND (
                                      (AFT.MNEMONIC <>'T3') and
                                                    ((ci.marginrate<AF.MRwRATE and ci.marginrate>=AF.MRCRATE)-- chi pham ti le canh bao
                                                    OR (ci.MARGINRATE<AF.MRCRATE AND ci.MARGINRATE>=AF.MRMRATE AND AF.Callday=0)-- vi pham R thoat Call nhung callday=0
                                                    /*OR EXISTS (SELECT * FROM LNSCHD SCHD,LNMAST MST,LNTYPE TYPE --den ngay canh bao
                                                              WHERE MST.ACCTNO=SCHD.ACCTNO AND MST.TRFACCTNO=AF.ACCTNO AND MST.ACTYPE=TYPE.ACTYPE
                                                              AND fn_get_prevdate(SCHD.OVERDUEDATE,TYPE.Warningdays)=GETCURRDATE)*/
                                                    )

                                       )
                           then 'Warning'

                          when af.status ='B' and af.isdebtt0 ='N'  THEN  'Block'

                          when  af.status ='B' and af.isdebtt0 ='Y' THEN   'Block T0'

                      else 'Normal'
                      end afstatus_en --10.trang thai tieu khoan
     from buf_ci_account ci, afmast af, cimast cim,
                (select afacctno,
                    sum(case when mrratioloan>0 then  QTTY*BASICPRICE else 0 end) MRQTTYAMT,
                    sum(case when mrratioloan>0 then  QTTY*currprice else 0 end) MRQTTYAMT_CURR,
                    sum(case when mrratioloan>0 then  QTTY*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT,
                    sum(case when mrratioloan>0 then  0 else QTTY*BASICPRICE end) NONMRQTTYAMT,
                    sum(case when mrratioloan>0 then  0 else QTTY*currprice end) NONMRQTTYAMT_CURR,
                    sum(DFQTTY * BASICPRICE) DFQTTYAMT,
                    sum(DFQTTY * currprice) DFQTTYAMT_CURR,
                    sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE else 0 end) MRQTTYAMT_BUY,
                    sum(case when mrratioloan>0 then  buyingqtty*BASICPRICE*mrratioloan/100  else 0 end) MR_QTTYAMT_BUY,
                    sum(case when mrratioloan>0 then  0 else buyingqtty*BASICPRICE end) NONMRQTTYAMT_BUY,
                    sum(buyqtty) buyqtty,
                    sum(totalamt) totalamt,
                    SUM(totalbuyamt) totalbuyamt
                 from (
                        select afacctno,mrratioloan,basicprice,nvl(st.closeprice,basicprice) currprice,
                                 AVLMRQTTY qtty,AVLDFQTTY dfqtty,
                                 buyingqtty
                                 ,buyqtty, (buyqtty+receiving-buyingqtty)*nvl(closeprice,basicprice) totalbuyamt,
                                 (buyqtty-buyingqtty+trade+mortage+receiving+BLOCKed+RESTRICTQTTY+ABSTANDING+Remainqtty)
                                 *nvl(closeprice,basicprice) totalamt
                                 from buf_se_account se, sbsecurities sb ,stockinfor st
                                 where afacctno = p_afacctno and se.codeid= sb.codeid and sb.symbol = st.symbol(+)
                        /*select afacctno,mrratioloan,basicprice,
                                AVLMRQTTY qtty,AVLDFQTTY dfqtty,
                                buyingqtty
                                from buf_se_account se where afacctno =p_afacctno*/
                    ) SE group by afacctno

                ) sec, aftype aft, mrtype mrt, cfmast cf  , v_getbuyorderinfo vw,
                (SELECT SUM(execamt-righttax-incometaxamt-brkfeeamt) receivingamt , acctno
                 FROM VW_ADVANCESCHEDULE
                 GROUP BY acctno) adv,
                 (select od.afacctno,
                        round(greatest(
                        least(sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)/(1+nvl(rsk.advrate,0)*getnonworkingday(3)/360)/*Gia tri tien ve tinh theo ty le UTTB*/),
                        sum(od.remainqtty*od.quoteprice*(1-odt.deffeerate/100-to_number(sy.varvalue)/100)-nvl(rsk.advminfee,0)/*Gia tri tien ve tinh theo phi UTTB toi thieu*/))
                        - sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(rsk.mrirate,100) = 0 then 100 else nvl(rsk.mrirate,100) end) )
                        ,0)
                        ) sellamount,
                 round(greatest(sum(od.remainqtty*least(nvl(rsk.mrpriceloan,0),marginprice)*nvl(rsk.mrratiorate,0)/(case when nvl(rsk.mrirate,100) = 0 then 100 else nvl(rsk.mrirate,100) end) ),0)) lostass
                 from odmast od, odtype odt,
                        (select af.acctno, af.mrirate, nvl(adt.advrate,0)/100 advrate,nvl(adt.advminfee,0) advminfee, rsk.*
                            from afmast af, afserisk rsk, aftype aft, adtype adt
                            where af.actype = rsk.actype(+)
                            and af.actype = aft.actype and aft.adtype = adt.actype
                        ) rsk,
                    securities_info sec,
                    sysvar sy
                        where od.exectype in ('NS','MS') --and isdisposal = 'Y'
                        and od.afacctno = rsk.acctno(+) and od.codeid = rsk.codeid(+)
                        and od.codeid = sec.codeid
                        and od.actype = odt.actype
                        and sy.varname = 'ADVSELLDUTY'
                        and od.remainqtty > 0
                 group by afacctno) od,
                    (select afacctno,
                               /* sum(case when st.duetype='RM' and st.tday=2 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t1,
                                sum(case when st.duetype='RM' and st.tday=1 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t2,
                                sum(case when st.duetype='RM' and st.tday=0 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t3--,*/
                                --T2 NAMNT
                                sum(case when st.duetype='RM' and st.rday=1 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t1,
                                sum(case when st.duetype='RM' and st.rday=2 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t2,
                                sum(case when st.duetype='RM' and st.rday=3 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t3
                                --END T2 NAMNT
                        from   vw_bd_pending_settlement st where (duetype='RM' or duetype='SM' or duetype = 'RS')
                        group by afacctno) st
            where ci.afacctno = p_afacctno and ci.afacctno = af.acctno and af.acctno = cim.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype  and cf.custid = af.custid
            and  ci.afacctno = sec.afacctno(+)
            AND ci.afacctno=vw.afacctno(+)
            AND ci.afacctno=adv.acctno(+)
            AND ci.afacctno=od.afacctno(+)
            AND ci.afacctno=st.afacctno(+)

    ) MST;

    plog.setendsection(pkgctx, 'pr_getSubAccountInfonew');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_getSubAccountInfonew');
  return;
END pr_getSubAccountInfonew;


procedure pr_getSEAccountInfo
    (p_refcursor in out pkg_report.ref_cursor,
        p_afacctno  IN  varchar2,
        p_getfullrectype IN varchar2 default '0',
        P_TLID IN varchar2 default 'ALL',
        P_SYMBOL IN varchar2 default 'ALL',
        P_CUSTODYCD IN varchar2 default 'ALL'
        )
IS
    l_marginrate number;
    l_afacctno varchar2(20);
    L_STRTLID   VARCHAR2(10);
    L_SYMBOL    VARCHAR2(50);
    L_CUSTODYCD VARCHAR2(50);
BEGIN
    plog.setendsection(pkgctx, 'pr_getSEAccountInfo');

    if(p_afacctno is null or upper(p_afacctno) = 'ALL') then
        l_afacctno := '%';
    else
        l_afacctno := p_afacctno;
    end if;

    IF(P_TLID IS NULL OR UPPER(P_TLID) = 'ALL') THEN
        L_STRTLID := '%';
    ELSE
        L_STRTLID := P_TLID;
    END IF;

    IF(P_SYMBOL IS NULL OR UPPER(P_SYMBOL) = 'ALL') THEN
        L_SYMBOL := '%';
    ELSE
        L_SYMBOL := P_SYMBOL;
    END IF;

     IF(P_CUSTODYCD IS NULL OR UPPER(P_CUSTODYCD) = 'ALL') THEN
        L_CUSTODYCD := '%';
    ELSE
        L_CUSTODYCD := P_CUSTODYCD;
    END IF;


    /*Open p_refcursor for
    select replace(sb.symbol, '_WFT','') symbol,case when instr(sb.symbol,'_WFT')>0 then 'Wait for trade' else 'Trading' end SETYPE,
       --(nvl(se.trade,0) + nvl(v.receiving,0) - nvl(v.execqtty,0) + nvl(v.buyqtty,0)) qtty,
       nvl(se.trade,0) - NVL (b.secureamt, 0) qtty,
       nvl(v.receiving,0) + nvl(od.execqtty,0) receiving,
       NVL (od.remainqtty, 0) buying,
       se.blocked ,
       (nvl(se.trade,0) - NVL (b.secureamt, 0) + nvl(v.receiving,0) + nvl(od.execqtty,0) + NVL (od.remainqtty, 0) ) * sb.basicprice mkval,
       nvl(v.ratecl,0) ratecl, nvl(v.pricecl,0) pricecl, nvl(df.dfqtty,0) dfqtty, nvl(df.dfqtty,0) * sb.basicprice dfmkval
    from (select * from semast where afacctno = p_afacctno) se,
        (select * from vw_getsecmargindetail where afacctno = p_afacctno) v,
        (select afacctno, codeid, sum(od.remainqtty)  remainqtty, sum(execqtty) execqtty from odmast od, sysvar sy
            where sy.grname = 'SYSTEM' and sy.varname = 'CURRDATE' and od.TXDATE = TO_DATE(sy.VARVALUE,'DD/MM/RRRR')
            and od.exectype in ('NB','BC') and deltd <> 'Y'
            group by afacctno, codeid ) od,
        (select df.afacctno, df.codeid, sum((df.dfqtty + df.rcvqtty + df.blockqtty + df.carcvqtty)  - nvl(sel.SECUREAMT,0)) dfqtty
            from dfmast df, v_getdealsellorderinfo sel
            where df.acctno = sel.dfacctno(+) and df.afacctno = p_afacctno
        group by df.afacctno, df.codeid) df,
        v_getsellorderinfo b,
        securities_info sb,
        sbsecurities sbs
    where se.afacctno = v.afacctno(+) and se.codeid = v.codeid(+)
    and se.afacctno = od.afacctno(+) and se.codeid = od.codeid(+)
    and se.acctno = b.seacctno(+)
    and se.afacctno = p_afacctno
    and se.codeid = sb.codeid
    and se.afacctno = df.afacctno(+) and se.codeid = df.codeid(+)
    and nvl(se.trade,0) - NVL (b.secureamt, 0) + nvl(v.receiving,0) + nvl(od.execqtty,0) + NVL (od.remainqtty, 0) + se.blocked + nvl(df.dfqtty,0) > 0
    and replace(sb.symbol, '_WFT','') = sbs.symbol and sbs.sectype <> '004'
    order by sb.symbol;*/
    IF p_getfullrectype = '0' THEN
        Open p_refcursor for
            select custodycd, afacctno ,symbol,




--                (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT  - buyingqtty) totalqtty,
                  (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED +WITHDRAW + CARECEIVING + ODRECEIVING+ MATCHINGAMT  /*- buyingqtty*/+ SECURITIES_RECEIVING_T3) totalqtty,
                   TRADE,DFTRADING,ABSTANDING,RESTRICTQTTY,BLOCKED,CARECEIVING,
                   SECURITIES_RECEIVING_T0, SECURITIES_RECEIVING_T1, SECURITIES_RECEIVING_T2,SECURITIES_RECEIVING_T3,
                   MATCHINGAMT,COSTPRICE FIFOCOSTPRICE,COSTPRICE,
                   --11. Gia tri
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT/*- buyingqtty*/ +WITHDRAW + SECURITIES_RECEIVING_T3) * COSTPRICE FIFOAMT,
                   --13. Gia tri thi truong
                   BASICPRICE,
                    (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT/*- buyingqtty*/+WITHDRAW + SECURITIES_RECEIVING_T3) * BASICPRICE MKTAMT,
                   --14. Lai lo du tinh
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- BUYINGQTTY*/+WITHDRAW + SECURITIES_RECEIVING_T3) * (BASICPRICE-COSTPRICE) PNLAMT,
                    --15. % Lai lo du tinh
                   case when COSTPRICE = 0 then '----' else  to_char(round((BASICPRICE-COSTPRICE)/COSTPRICE,4) * 100,'999,999,999,990.99')||'%' end PNLRATE,
                   (case when TRADE > 0 and instr(symbol,'_WFT') <= 0 then 'Y' else 'N' end) ISSELL,
                   SECURERATIO,SESECURED,SEMARGIN,
























                   closeprice,change,reference
                   , SENDING, ALL_DEPOSIT, WITHDRAW + RETAIL WITHDRAW,
                   mst.MRRATIORATE, SEAMT*(least(mst.secbasicprice,mst.secmarginprice,nvl(afs.mrpricerate,0))) SEAMT,
                   recustid,refullname,  PRODUCTTYPE
            from
            (
                select custodycd, se.afacctno, nvl( re.recustid,'') recustid, nvl( re.refullname,'') refullname,
                    --1. Ma chung khoan
                    SE.symbol,
                    --3.Kha dung
                    nvl(trade,0) TRADE,





                    --4.1 Cam co
                    nvl(dftrading,0) DFTRADING,
                    --4.2.Chung khoan CC VSD
                    nvl(abstanding,0) ABSTANDING,
                    --5.Chung khoan HCCN
                    nvl(restrictqtty,0) RESTRICTQTTY,
                    --6.Khoi luong phong toa
                    nvl(blocked,0) BLOCKED,
                    /*--7. Chung khoan quyen cho ve
                    se.receiving -( nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)+nvl(securities_receiving_t3,0)
                        --PhuNh Comment T0 chua vao receiving trong semast
                        --+nvl(securities_receiving_t0,0)
                        ) CARECEIVING,*/
                    --7. Chung khoan quyen cho ve
                    (buyqtty - buyingqtty) + se.receiving -( nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)+nvl(securities_receiving_t3,0)
                        --PhuNh Comment T0 chua vao receiving trong semast
                        +nvl(securities_receiving_t0,0)
                        ) CARECEIVING,
                    --8. Chung khoan cho ve
                    nvl(securities_receiving_t0,0) + nvl(securities_receiving_t1,0) +
                    nvl(securities_receiving_t2,0) odreceiving,
                        --8.1 Cho ve T0
                        nvl(securities_receiving_t0,0) SECURITIES_RECEIVING_T0,
                        --8.1 Cho ve T1
                        nvl(securities_receiving_t1,0) SECURITIES_RECEIVING_T1,
                        --8.1 Cho ve T2
                        nvl(securities_receiving_t2,0)SECURITIES_RECEIVING_T2,
                    nvl(securities_receiving_t3,0) securities_receiving_t3,
                    --9. Chung khoan cho khop
                    --PhuNh securities_sending_t0 -> securities_sending_t3

                    --greatest(se.buyingqtty + se.secured - securities_sending_t3,0) MATCHINGAMT,
                    --T2 NAMNT
                    greatest(SE.remainqtty,0) MATCHINGAMT,
                    --END T2 NAMNT
                    --10. Gia von trung binh
                   -- NVL( NVL(se1.costprice,se.COSTPRICE),0) fifocostprice,NVL( NVL(se1.costprice,se.COSTPRICE),0) COSTPRICE,
                     NVL( NVL(se1.costprice,nvl(se.AVGCOSTPRICE,se.costprice)),0) COSTPRICE,
                    --12. Gia thi truong
                    case when st.closeprice is null
                      then  nvl(sec.basicprice,se.basicprice)
                    else to_number(nvl(st.closeprice,0)) end basicprice,
                    se.deposit + se.senddeposit DEPOSIT,
                    se.MRRATIOLOAN,

                    --12. BUYINGQTTY
                    se.buyingqtty,
                    (100-MRRATIOLOAN) SECURERATIO,
                   (trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                     securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn +
                     buyingqtty - securities_sending_t3) * (1-mrratioloan/100) * nvl(sec.basicprice,se.basicprice)  SESECURED,
                   (trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                     securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn +
                     buyingqtty - securities_sending_t3) * (mrratioloan/100) * nvl(sec.basicprice,se.basicprice)  SEMARGIN
















                    ,st.closeprice,st.change,st.reference
                    , SECURITIES_SENDING_T0 + SECURITIES_SENDING_T1 +
                      SECURITIES_SENDING_T2 + SECURITIES_SENDING_T3 +
                      SECURITIES_SENDING_TN SENDING, DEPOSIT + SENDDEPOSIT ALL_DEPOSIT, WITHDRAW
                      ,SE.MRRATIORATE,
                      (trade + secured + securities_receiving_t0 + securities_receiving_t1 +
                     securities_receiving_t2 + securities_receiving_t3 + securities_receiving_tn +
                     buyingqtty - securities_sending_t3) * (SE.MRRATIORATE/100) /** BASICPRICE*/  SEAMT,
                     se.codeid, af.actype, nvl(sec.basicprice,0) secbasicprice , nvl(sec.marginprice,0) secmarginprice,
                     se.retail, af.PRODUCTTYPE

                from buf_se_account se, stockinfor st,(SELECT symbol,nvl(AVGCOSTPRICE,costprice) costprice,afacctno FROM  buf_se_account WHERE instr(symbol,'_WFT')=0 )se1,/*, tlgrpusers tl, tlgroups gr*/











                    afmast af, securities_info sec, ---, afserisk afs

                    (SELECT RE.AFACCTNO, MAX( CF.FULLNAME) REFULLNAME ,MAX(CF.CUSTID) reCUSTID
                    FROM reaflnk re, retype ret,cfmast cf
                    WHERE substr( re.reacctno,11) = ret.actype
                    AND substr(re.reacctno,1,10) = cf.custid
                    AND ret.rerole IN ('RM','CS')
                    AND RE.status ='A'
                    GROUP BY AFACCTNO) re
                where se.afacctno like l_afacctno
                    AND SE.SYMBOL LIKE L_SYMBOL
                    and se.afacctno = af.acctno
                    and se.codeid = sec.codeid(+)
                    AND REPLACE( se.symbol,'_WFT','') = se1.symbol(+)
                    AND SE.afacctno = se1.afacctno(+)
                    ---and
                    AND se.symbol=st.symbol(+)
                    AND AF.custid = RE.afacctno(+)
                    AND SE.custodycd LIKE L_CUSTODYCD
                    /*AND SE.careby = tl.grpid and tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE L_STRTLID*/
                    AND EXISTS(
                            SELECT *
                            FROM tlgrpusers tl, tlgroups gr
                            WHERE SE.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE L_STRTLID
                            )

                ) mst
                left join
                afserisk afs
                on mst.codeid =  afs.codeid and mst.actype = afs.actype
            where (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- buyingqtty*/ + ALL_DEPOSIT+SECURITIES_RECEIVING_T3+WITHDRAW+SENDING+retail) > 0
            order by afacctno,symbol;
        ELSE
            Open p_refcursor for
            select custodycd, afacctno ,symbol,




                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- buyingqtty*/ + WITHDRAW + SECURITIES_RECEIVING_T3) totalqtty,

                   TRADE,DFTRADING,ABSTANDING,RESTRICTQTTY,BLOCKED,CARECEIVING,
                   SECURITIES_RECEIVING_T0, SECURITIES_RECEIVING_T1, SECURITIES_RECEIVING_T2,SECURITIES_RECEIVING_T3,
                   MATCHINGAMT,COSTPRICE FIFOCOSTPRICE,COSTPRICE,
                   --11. Gia tri
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- buyingqtty*/ + WITHDRAW + SECURITIES_RECEIVING_T3) * COSTPRICE FIFOAMT,
                   --13. Gia tri thi truong
                   BASICPRICE,
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- buyingqtty*/ + WITHDRAW + SECURITIES_RECEIVING_T3) * BASICPRICE MKTAMT,
                   --14. Lai lo du tinh
                   (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- buyingqtty*/ + WITHDRAW + SECURITIES_RECEIVING_T3) * (BASICPRICE-COSTPRICE) PNLAMT,
                    --15. % Lai lo du tinh
                   case when COSTPRICE = 0 then '0' else  to_char(round((BASICPRICE-COSTPRICE)/COSTPRICE,4) * 100,'999,999,999,990.99')||'%' end PNLRATE






















                    ,closeprice,change,reference
                    , SENDING,   ALL_DEPOSIT, WITHDRAW + RETAIL WITHDRAW,
                    MRRATIORATE
            from
            (
                select custodycd, se.afacctno,
                    --1. Ma chung khoan
                    SE.symbol,
                    --3.Kha dung
                    nvl(trade,0) TRADE,





                    --4.1 Cam co
                    nvl(dftrading,0) DFTRADING,
                    --4.2.Chung khoan CC VSD
                    nvl(abstanding,0) ABSTANDING,
                    --5.Chung khoan HCCN
                    nvl(restrictqtty,0) RESTRICTQTTY,
                    --6.Khoi luong phong toa
                    nvl(blocked,0) BLOCKED,
                    --7. Chung khoan quyen cho ve
                    (buyqtty - buyingqtty) + se.receiving -( nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)+nvl(securities_receiving_t3,0)
                        --PhuNh Comment T0 chua vao receiving trong semast
                        + nvl(securities_receiving_t0,0)

                        ) CARECEIVING,
                    /*--7. Chung khoan quyen cho ve
                    se.receiving -( nvl(securities_receiving_t1,0)+nvl(securities_receiving_t2,0)+nvl(securities_receiving_t3,0)
                        --PhuNh Comment T0 chua vao receiving trong semast
                        --+nvl(securities_receiving_t0,0)
                        ) CARECEIVING,*/
                    --8. Chung khoan cho ve
                    nvl(securities_receiving_t0,0) + nvl(securities_receiving_t1,0) +
                    nvl(securities_receiving_t2,0) odreceiving,
                        --8.1 Cho ve T0
                        nvl(securities_receiving_t0,0) SECURITIES_RECEIVING_T0,
                        --8.1 Cho ve T1
                        nvl(securities_receiving_t1,0) SECURITIES_RECEIVING_T1,
                        --8.1 Cho ve T2
                        nvl(securities_receiving_t2,0)SECURITIES_RECEIVING_T2,
                    nvl(securities_receiving_t3,0) securities_receiving_t3,
                    --9. Chung khoan cho khop
                    --PhuNh securities_sending_t0 -> securities_sending_t3

                    --greatest(se.buyingqtty + se.secured - securities_sending_t3,0) MATCHINGAMT,
                         --T2 NAMNT
                    greatest(SE.remainqtty,0) MATCHINGAMT,
                    --END T2 NAMNT
                    --10. Gia von trung binh
                   -- NVL( NVL(se1.costprice,se.COSTPRICE),0) fifocostprice,NVL(nvl(se1.COSTPRICE,se.COSTPRICE),0) COSTPRICE,
                      NVL( NVL(se1.costprice,nvl(se.AVGCOSTPRICE,se.costprice)),0) COSTPRICE,
                    --12. Gia thi truong
                    case when st.closeprice is null
                      then  nvl(sec.basicprice,se.basicprice)
                    else to_number(nvl(st.closeprice,0)) end basicprice,
                    se.deposit + se.senddeposit DEPOSIT,
                    se.MRRATIOLOAN,
                    --12. BUYINGQTTY
                    se.buyingqtty,st.closeprice,st.change,st.reference
















                    ,SECURITIES_SENDING_TN SENDING, DEPOSIT + SENDDEPOSIT ALL_DEPOSIT, WITHDRAW
                    ,SE.MRRATIORATE,RETAIL
                from buf_se_account se, stockinfor st,(SELECT symbol,nvl(AVGCOSTPRICE,costprice) costprice,afacctno FROM  buf_se_account WHERE instr(symbol,'_WFT')=0 )se1/*, tlgrpusers tl, tlgroups gr*/,











                        securities_info SEC
                where se.afacctno like l_afacctno
                    AND SE.SYMBOL LIKE L_SYMBOL
                    AND se.symbol=st.symbol(+)
                    AND SE.custodycd LIKE L_CUSTODYCD
                    and se.codeid = sec.codeid(+)
                    AND REPLACE( se.symbol,'_WFT','') = se1.symbol(+)
                    AND SE.afacctno = se1.afacctno(+)
                    /*AND SE.careby = tl.grpid and tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE L_STRTLID*/
                    AND EXISTS(
                            SELECT *
                            FROM tlgrpusers tl, tlgroups gr
                            WHERE SE.careby = tl.grpid AND tl.grpid= gr.grpid and gr.grptype='2' and tl.tlid LIKE L_STRTLID
                            )
                      AND NOT EXISTS(SELECT * FROM sbsecurities sec
                                        WHERE se.codeid = sec.codeid
                                              AND (sec.sectype IN ('004','009')
                                                    OR sec.tradeplace NOT IN ('001','002','005'))
                                        )
                )
            where (TRADE + DFTRADING + ABSTANDING + RESTRICTQTTY + BLOCKED + CARECEIVING + ODRECEIVING + MATCHINGAMT /*- buyingqtty */+ ALL_DEPOSIT+SECURITIES_RECEIVING_T3+WITHDRAW+SENDING+retail) > 0
            order by afacctno,symbol;
        END IF;

    plog.setendsection(pkgctx, 'pr_getSEAccountInfo');
EXCEPTION
WHEN OTHERS
THEN

  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_getSEAccountInfo');
  return;
END pr_getSEAccountInfo;

procedure pr_getcashinvesment
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2)
IS
    l_marginrate number;
    l_navaccount number;
    l_outstanding number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_getcashinvesment');
    --Dong bo thong tin len Buffer
    /*if length(nvl(p_afacctno,'X')) =10 then
        jbpks_auto.pr_gen_buf_ci_account(p_afacctno);
    end if;*/


    Open p_refcursor for
    SELECT B.CUSTODYCD, B.AFACCTNO, PP, BALDEFOVD, AVLWITHDRAW, (BALANCE+ BAMT) BALANCE, INTBALANCE,
           AAMT, EMKAMT, PAIDAMT, CASH_RECEIVING_T0, st.avlreceiving_t1 CASH_RECEIVING_T1, st.avlreceiving_t2 CASH_RECEIVING_T2,
          st.avlreceiving_t3    CASH_RECEIVING_T3,
          /* RECEIVING - CASH_RECEIVING_T0 - (CASH_RECEIVING_T1-CASH_RECEIVING_T1_CLDRD1) -
         CASH_RECEIVING_T2 RECEIVING_RIGHT, */
         nvl(ca.careceiving,0) RECEIVING_RIGHT,
         BAMT,
           CASE WHEN T.TRFBUYEXT > 0 THEN CASH_SENDING_T0 ELSE EXECBUYAMT END NETTING,
           CASHT2_SENDING_T0 CASH_SENDING_T0, CASHT2_SENDING_T1 CASH_SENDING_T1, CASHT2_SENDING_T2 CASH_SENDING_T2,
           MRODAMT, T0ODAMT, DFODAMT, AVLADVANCE,
           EXECBUYAMT, BALDEFTRFAMT, T.ACTYPE, M.MRCRLIMIT, TRFBUY_T0,TRFBUY_T1,TRFBUY_T2,TRFBUY_T3
           ,RCVAMT, APMT, BAMT SECUAMT, NVL(TD.TDAMT,0) TDAMT
         FROM BUF_CI_ACCOUNT B, AFMAST M, AFTYPE T,
           (SELECT SUM(amt) careceiving, afacctno caacctno  FROM caschd WHERE  status IN ('I','S','H') AND ISEXEC ='Y'
                        GROUP BY afacctno) CA,
            (
                SELECT AFACCTNO, SUM(balance) TDAMT FROM TDMAST
                WHERE BUYINGPOWER = 'N' AND DELTD = 'N'
                    GROUP BY AFACCTNO
            )td,
           (select afacctno,
                  /* sum(case when st.duetype='RM' and st.tday=2 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t1,
                   sum(case when st.duetype='RM' and st.tday=1 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t2,
                   sum(case when st.duetype='RM' and st.tday=0 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t3--,*/

                   sum(case when st.duetype='RM' and st.rday=1 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t1,
                   sum(case when st.duetype='RM' and st.rday=2 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t2,
                   sum(case when st.duetype='RM' and st.rday=3 then st.st_amt -st.feeacr-st.taxsellamt else 0 end) avlreceiving_t3--,

            from   vw_bd_pending_settlement st where (duetype='RM' or duetype='SM' or duetype = 'RS')
                 group by afacctno) st

        WHERE B.AFACCTNO = M.ACCTNO AND M.ACTYPE = T.ACTYPE
        AND  B.AFACCTNO = p_afacctno AND M.ACCTNO = TD.AFACCTNO(+)
        and b.AFACCTNO =st.afacctno(+)
         AND B.AFACCTNO = CA.caacctno (+)
                ORDER BY CUSTODYCD, AFACCTNO;

    plog.setendsection(pkgctx, 'pr_getcashinvesment');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_getcashinvesment');
  return;
END pr_getcashinvesment;

procedure pr_getoutstanding
    (p_refcursor in out pkg_report.ref_cursor,
    p_afacctno  IN  varchar2)
IS
    l_marginrate number;
    l_navaccount number;
    l_outstanding number;
BEGIN
    plog.setbeginsection(pkgctx, 'pr_getoutstanding');
    --Dong bo thong tin len Buffer
    /*if length(nvl(p_afacctno,'X')) =10 then
        jbpks_auto.pr_gen_buf_ci_account(p_afacctno);
    end if;*/


    Open p_refcursor for
    SELECT TY.TYPENAME, CF.CUSTODYCD, AF.ACCTNO AFACCTNO, LN.ACCTNO LNACCTNO,
                 to_char(SCHD.RLSDATE,'dd/mm/yyyy') RLSDATE ,
                 SCHD.NML + SCHD.OVD + SCHD.INTNMLACR  + SCHD.INTOVD + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTNMLOVD + SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR TOTALAMT,
                 SCHD.NML + SCHD.OVD PRINCIPAL,
                 SCHD.NML + SCHD.OVD + SCHD.PAID RLSAMT,
                 SCHD.PAID PRINPAID,
                 SCHD.INTPAID + SCHD.FEEINTPAID + SCHD.FEEINTPREPAID INTPAID, 0 DFRATE, to_char( DAYS) DAYS,
                 SCHD.INTNMLACR   + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE INTNML,
                 SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR + SCHD.INTOVD + SCHD.FEEINTNMLOVD  INTOVD,
                  to_char(SCHD.OVERDUEDATE,'dd/mm/yyyy') OVERDUEDATE, to_char( NVL(V_DEAL.IRATE, 0)) IRATE,
                to_char( NVL(V_DEAL.RTTDF, 0)) RTTDF,to_char( NVL(V_DEAL.ODCALLRTTDF, 0)) ODCALLRTTDF, SCHD.REFTYPE
            FROM CFMAST CF, AFMAST AF, LNMAST LN, LNTYPE TY,
                 (SELECT LNSCHD.*,
                          DATEDIFF('D', RLSDATE, GETCURRDATE) DAYS
                     FROM LNSCHD
                    WHERE REFTYPE IN ('GP', 'P')
                      AND DUENO = 0) SCHD, V_GETGRPDEALFORMULAR V_DEAL
           WHERE AF.CUSTID = CF.CUSTID
             AND AF.ACCTNO = LN.TRFACCTNO
             AND LN.ACTYPE = TY.ACTYPE
             AND SCHD.ACCTNO = LN.ACCTNO
             AND LN.ACCTNO = V_DEAL.LNACCTNO(+)
             AND AF.ACCTNO = p_afacctno
             AND SCHD.NML + SCHD.OVD + SCHD.INTNMLACR + SCHD.INTOVDPRIN + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTOVDACR + SCHD.INTOVD + SCHD.FEEINTNMLOVD > 0
union all

    SELECT '' TYPENAME, '' CUSTODYCD, ''  AFACCTNO, '' LNACCTNO,
                 '' RLSDATE,
                 sum(SCHD.NML + SCHD.OVD + SCHD.INTNMLACR  + SCHD.INTOVD + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTNMLOVD + SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR) TOTALAMT,
                 sum(SCHD.NML + SCHD.OVD) PRINCIPAL,
                 sum(SCHD.NML + SCHD.OVD + SCHD.PAID) RLSAMT,
                 sum(SCHD.PAID) PRINPAID,
                 sum(SCHD.INTPAID + SCHD.FEEINTPAID + SCHD.FEEINTPREPAID) INTPAID, 0 DFRATE,'' DAYS,
                 sum(SCHD.INTNMLACR  + SCHD.INTOVD + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTNMLOVD) INTNML,
                 sum(SCHD.INTOVDPRIN + SCHD.FEEINTOVDACR) INTOVD,
                 '' OVERDUEDATE, '' IRATE,
                 '' RTTDF, '' ODCALLRTTDF, '' REFTYPE
            FROM CFMAST CF, AFMAST AF, LNMAST LN, LNTYPE TY,
                 (SELECT LNSCHD.*,
                          DATEDIFF('D', RLSDATE, GETCURRDATE) DAYS
                     FROM LNSCHD
                    WHERE REFTYPE IN ('GP', 'P')
                      AND DUENO = 0) SCHD, V_GETGRPDEALFORMULAR V_DEAL
           WHERE AF.CUSTID = CF.CUSTID
             AND AF.ACCTNO = LN.TRFACCTNO
             AND LN.ACTYPE = TY.ACTYPE
             AND SCHD.ACCTNO = LN.ACCTNO
             AND LN.ACCTNO = V_DEAL.LNACCTNO(+)
             AND AF.ACCTNO = p_afacctno
             AND SCHD.NML + SCHD.OVD + SCHD.INTNMLACR + SCHD.INTOVDPRIN + SCHD.INTDUE + SCHD.FEEINTNMLACR + SCHD.FEEINTDUE + SCHD.FEEINTOVDACR + SCHD.INTOVD + SCHD.FEEINTNMLOVD > 0


           ;


    plog.setendsection(pkgctx, 'pr_getoutstanding');
EXCEPTION
WHEN OTHERS
THEN
  plog.error (pkgctx, SQLERRM || dbms_utility.format_error_backtrace);
  plog.setendsection (pkgctx, 'pr_getoutstanding');
  return;
END pr_getoutstanding;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('cspks_brokerinquiry',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
