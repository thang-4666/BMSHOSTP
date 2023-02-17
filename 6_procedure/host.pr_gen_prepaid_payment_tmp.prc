SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE pr_gen_prepaid_payment_tmp
is
    p_err_code  varchar2(20);
    l_CURRDATE date;
    l_err_param varchar2(300);
    l_T0PRINDUE number(20,0);
    l_T0PRINNML number(20,0);
    l_T0PRINOVD number(20,0);
    l_AvlAmt    number(20,0);
    l_FEEOVD number(20,0);
    l_T0INTNMLOVD number(20,0);
    l_INTNMLOVD number(20,0);
    l_T0INTOVDACR number(20,0);
    l_INTOVDACR number(20,0);
    l_FEEDUE number(20,0);
    l_T0INTDUE number(20,0);
    l_INTDUE number(20,0);
    l_FEENML number(20,0);
    l_T0INTNMLACR number(20,0);
    l_INTNMLACR number(20,0);
    l_PRINOVD number(20,0);
    l_PRINDUE number(20,0);
    l_PRINNML number(20,0);
    l_FEEINTNMLOVD number(20,0);
    l_FEEINTNMLACR number(20,0);
    l_FEEINTOVDACR number(20,0);
    l_FEEINTDUE number(20,0);
    l_ADVPAYFEE number(20,0);
    l_SplitRate number(20,8);
    l_maxdebtcf number(20,0);


    --DF
    v_totalpaidamt  number;
    l_DayDue        number;
    l_prinamt   number;
    l_intamt   number;
    l_feeamt   number;
    l_amtpaid   number;
    l_duepaid   varchar2(10);
begin

    SELECT TO_DATE (varvalue, systemnums.c_date_format)
               INTO l_CURRDATE
               FROM sysvar
               WHERE grname = 'SYSTEM' AND varname = 'CURRDATE';
    delete from lnpaidalloc_tmp;
    delete from lnpaidalloc_dtl;

    --lnAdvPayment
    l_duepaid:='OVD';
    for rec in
    (
            SELECT ci.acctno trfacctno,
                round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) AVLBAL
            FROM CIMAST ci, afmast af, aftype aft, mrtype mrt,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv,
                v_getbuyorderinfo b,
                v_getsecmargininfo sec,
                (select trfacctno, sum(avlamt) avlamt
                    from lnpaidalloc_dtl
                    group by trfacctno) dtl
            WHERE ci.acctno = af.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = b.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = dtl.trfacctno(+)
            and round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) > 0
            and exists (select 1 from lnmast where ftype = 'AF' and trfacctno = ci.acctno
                            and prinnml + prinovd + intnmlacr + intdue + intovdacr + intnmlovd + feeintnmlacr + feeintdue + feeintovdacr + feeintnmlovd
                                                    + oprinnml + oprinovd + ointnmlacr + ointdue + ointovdacr + ointnmlovd > 0)
            order by ci.acctno
    )
    loop -- rec
        if cspks_lnproc.fn_Gen_Prepaid_Payment_tmp(rec.trfacctno, rec.AVLBAL, 'R', l_duepaid ,p_err_code) <> systemnums.c_success then
            return;
        end if;

        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid, lp.autoid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt - lp.paidamt) AvlAmt,

                sum(case when reftype = 'GP' then ls.intovd - nvl(dtl.T0INTNMLOVD,0) else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin- nvl(dtl.T0INTOVDACR,0) else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd- nvl(dtl.T0PRINOVD,0) else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue- nvl(dtl.T0INTDUE,0) else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.T0PRINDUE,0) else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr- nvl(dtl.T0INTNMLACR,0) else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' then ls.nml- nvl(dtl.T0PRINNML,0) else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd- nvl(dtl.FEEOVD,0) else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd- nvl(dtl.INTNMLOVD,0) else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd- nvl(dtl.FEEINTNMLOVD,0) else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin- nvl(dtl.INTOVDACR,0) else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr- nvl(dtl.FEEINTOVDACR,0) else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd- nvl(dtl.PRINOVD,0) else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue- nvl(dtl.FEEDUE,0) else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue- nvl(dtl.INTDUE,0) else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue- nvl(dtl.FEEINTDUE,0) else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.PRINDUE,0) else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee- nvl(dtl.FEENML,0) else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr- nvl(dtl.INTNMLACR,0) else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr- nvl(dtl.FEEINTNMLACR,0) else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' then ls.nml- nvl(dtl.PRINNML,0) else 0 end) PRINNML

            from lnmast ln, lnpaidalloc_tmp lp, lnschd ls,
            (SELECT max(trfacctno) trfacctno, max(acctno) acctno, lnschdid, max(autoid) autoid, max(financetype) financetype,
                   sum(advpayfee) advpayfee, sum(avlamt) avlamt, sum(t0intnmlovd) t0intnmlovd, sum(t0intovdacr) t0intovdacr, sum(t0prinovd) t0prinovd,
                   sum(t0intdue) t0intdue, sum(t0prindue) t0prindue, sum(t0intnmlacr) t0intnmlacr, sum(t0prinnml) t0prinnml, sum(feeovd) feeovd,
                   sum(intnmlovd) intnmlovd, sum(feeintnmlovd) feeintnmlovd, sum(intovdacr) intovdacr, sum(feeintovdacr) feeintovdacr,
                   sum(prinovd) prinovd, sum(feedue) feedue, sum(intdue) intdue, sum(feeintdue) feeintdue, sum(prindue) prindue, sum(feenml) feenml,
                   sum(intnmlacr) intnmlacr, sum(feeintnmlacr) feeintnmlacr, sum(prinnml) prinnml
            from lnpaidalloc_dtl
            group by lnschdid
            ) dtl
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and ln.trfacctno = rec.trfacctno and instr(ls.reftype,'P') > 0
            and lp.amt > lp.paidamt and lp.status = 'P'
            and ls.autoid = dtl.lnschdid (+)
            group by ln.trfacctno, ln.acctno, ls.autoid, lp.autoid
            order by lp.autoid
        )
        loop -- rec2
            l_AvlAmt:= rec2.AvlAmt;
            --So tien phai tra cho tung khoan
            -- Bao lanh
            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLOVD := round(least(l_AvlAmt, rec2.T0INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTOVDACR := round(least(l_AvlAmt, rec2.T0INTOVDACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            End If;
            --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_T0INTDUE := round(least(l_AvlAmt, rec2.T0INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_T0INTDUE;
            End If;
            --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLACR := round(least(l_AvlAmt, rec2.T0INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            End If;
            --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;

            -- CL
            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLOVD := round(least(l_AvlAmt, rec2.FEEINTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            End If;
            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTDUE := round(least(l_AvlAmt, rec2.FEEINTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
            End If;
            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLACR := round(least(l_AvlAmt, rec2.FEEINTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            End If;

            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLOVD := round(least(l_AvlAmt, rec2.INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_INTOVDACR := round(least(l_AvlAmt, rec2.INTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_INTOVDACR;
            End If;
            --13.INTDUE
            l_INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_INTDUE := round(least(l_AvlAmt, rec2.INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_INTDUE;
            End If;
            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLACR := round(least(l_AvlAmt, rec2.INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEOVD := round(least(l_AvlAmt, rec2.FEEOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEOVD;
            End If;
            --16.FEEDUE
            l_FEEDUE := 0;
            If l_AvlAmt > 0 Then
                l_FEEDUE := round(least(l_AvlAmt, rec2.FEEDUE),0);
                l_AvlAmt := l_AvlAmt - l_FEEDUE;
            End If;
            --17.FEENML
            l_FEENML := 0;
            If l_AvlAmt > 0 Then
                l_FEENML := round(least(l_AvlAmt, rec2.FEENML),0);
                l_AvlAmt := l_AvlAmt - l_FEENML;
            End If;

            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;
            --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;

            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTOVDACR := round(least(l_AvlAmt, rec2.FEEINTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
            End If;

           insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
           advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
           t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
           intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
           prinovd, feedue, intdue, feeintdue, prindue, feenml,
           intnmlacr, feeintnmlacr, prinnml,ftype)

           select rec2.trfacctno, rec2.acctno, rec2.lnschdid,rec2.autoid, rec2.financetype,
           l_ADVPAYFEE advpayfee, rec2.avlamt, l_T0INTNMLOVD t0intnmlovd, l_t0intovdacr t0intovdacr, l_t0prinovd t0prinovd,
           l_t0intdue t0intdue, l_t0prindue t0prindue, l_t0intnmlacr t0intnmlacr, l_t0prinnml t0prinnml, l_feeovd feeovd,
           l_intnmlovd intnmlovd, l_feeintnmlovd feeintnmlovd, l_intovdacr intovdacr, l_feeintovdacr feeintovdacr,
           l_prinovd prinovd, l_feedue feedue, l_intdue intdue, l_feeintdue feeintdue, l_prindue prindue, l_feenml feenml,
           l_intnmlacr intnmlacr, l_feeintnmlacr feeintnmlacr, l_prinnml prinnml, 'R' ftype
           from dual;


           update lnpaidalloc_tmp
            set status = 'C'
            where status = 'P'
            and autoid = rec2.autoid;

        end loop;
    end loop;


    --lnAdvPayment
    l_duepaid:='NML';
    for rec in
    (
            SELECT ci.acctno trfacctno,
                round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) AVLBAL
            FROM CIMAST ci, afmast af, aftype aft, mrtype mrt,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv,
                v_getbuyorderinfo b,
                v_getsecmargininfo sec,
                (select trfacctno, sum(avlamt) avlamt
                    from lnpaidalloc_dtl
                    group by trfacctno) dtl
            WHERE ci.acctno = af.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = b.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = dtl.trfacctno(+)
            and round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) > 0
            and exists (select 1 from lnmast where ftype = 'AF' and trfacctno = ci.acctno
                            and prinnml + prinovd + intnmlacr + intdue + intovdacr + intnmlovd + feeintnmlacr + feeintdue + feeintovdacr + feeintnmlovd
                                                    + oprinnml + oprinovd + ointnmlacr + ointdue + ointovdacr + ointnmlovd > 0)
            order by ci.acctno
    )
    loop -- rec
        if cspks_lnproc.fn_Gen_Prepaid_Payment_tmp(rec.trfacctno, rec.AVLBAL, 'R', l_duepaid ,p_err_code) <> systemnums.c_success then
            return;
        end if;

        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid, lp.autoid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt - lp.paidamt) AvlAmt,

                sum(case when reftype = 'GP' then ls.intovd - nvl(dtl.T0INTNMLOVD,0) else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin- nvl(dtl.T0INTOVDACR,0) else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd- nvl(dtl.T0PRINOVD,0) else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue- nvl(dtl.T0INTDUE,0) else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.T0PRINDUE,0) else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr- nvl(dtl.T0INTNMLACR,0) else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' then ls.nml- nvl(dtl.T0PRINNML,0) else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd- nvl(dtl.FEEOVD,0) else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd- nvl(dtl.INTNMLOVD,0) else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd- nvl(dtl.FEEINTNMLOVD,0) else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin- nvl(dtl.INTOVDACR,0) else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr- nvl(dtl.FEEINTOVDACR,0) else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd- nvl(dtl.PRINOVD,0) else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue- nvl(dtl.FEEDUE,0) else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue- nvl(dtl.INTDUE,0) else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue- nvl(dtl.FEEINTDUE,0) else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.PRINDUE,0) else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee- nvl(dtl.FEENML,0) else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr- nvl(dtl.INTNMLACR,0) else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr- nvl(dtl.FEEINTNMLACR,0) else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' then ls.nml- nvl(dtl.PRINNML,0) else 0 end) PRINNML

            from lnmast ln, lnpaidalloc_tmp lp, lnschd ls,
            (SELECT max(trfacctno) trfacctno, max(acctno) acctno, lnschdid, max(autoid) autoid, max(financetype) financetype,
                   sum(advpayfee) advpayfee, sum(avlamt) avlamt, sum(t0intnmlovd) t0intnmlovd, sum(t0intovdacr) t0intovdacr, sum(t0prinovd) t0prinovd,
                   sum(t0intdue) t0intdue, sum(t0prindue) t0prindue, sum(t0intnmlacr) t0intnmlacr, sum(t0prinnml) t0prinnml, sum(feeovd) feeovd,
                   sum(intnmlovd) intnmlovd, sum(feeintnmlovd) feeintnmlovd, sum(intovdacr) intovdacr, sum(feeintovdacr) feeintovdacr,
                   sum(prinovd) prinovd, sum(feedue) feedue, sum(intdue) intdue, sum(feeintdue) feeintdue, sum(prindue) prindue, sum(feenml) feenml,
                   sum(intnmlacr) intnmlacr, sum(feeintnmlacr) feeintnmlacr, sum(prinnml) prinnml
            from lnpaidalloc_dtl
            group by lnschdid
            ) dtl
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and ln.trfacctno = rec.trfacctno and instr(ls.reftype,'P') > 0
            and lp.amt > lp.paidamt and lp.status = 'P'
            and ls.autoid = dtl.lnschdid (+)
            group by ln.trfacctno, ln.acctno, ls.autoid, lp.autoid
            order by lp.autoid
        )
        loop -- rec2
            l_AvlAmt:= rec2.AvlAmt;
            --So tien phai tra cho tung khoan
            -- Bao lanh
            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLOVD := round(least(l_AvlAmt, rec2.T0INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTOVDACR := round(least(l_AvlAmt, rec2.T0INTOVDACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            End If;
            --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_T0INTDUE := round(least(l_AvlAmt, rec2.T0INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_T0INTDUE;
            End If;
            --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLACR := round(least(l_AvlAmt, rec2.T0INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            End If;
            --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;

            -- CL
            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLOVD := round(least(l_AvlAmt, rec2.FEEINTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            End If;
            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTDUE := round(least(l_AvlAmt, rec2.FEEINTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
            End If;
            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLACR := round(least(l_AvlAmt, rec2.FEEINTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            End If;

            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLOVD := round(least(l_AvlAmt, rec2.INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_INTOVDACR := round(least(l_AvlAmt, rec2.INTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_INTOVDACR;
            End If;
            --13.INTDUE
            l_INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_INTDUE := round(least(l_AvlAmt, rec2.INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_INTDUE;
            End If;
            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLACR := round(least(l_AvlAmt, rec2.INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEOVD := round(least(l_AvlAmt, rec2.FEEOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEOVD;
            End If;
            --16.FEEDUE
            l_FEEDUE := 0;
            If l_AvlAmt > 0 Then
                l_FEEDUE := round(least(l_AvlAmt, rec2.FEEDUE),0);
                l_AvlAmt := l_AvlAmt - l_FEEDUE;
            End If;
            --17.FEENML
            l_FEENML := 0;
            If l_AvlAmt > 0 Then
                l_FEENML := round(least(l_AvlAmt, rec2.FEENML),0);
                l_AvlAmt := l_AvlAmt - l_FEENML;
            End If;

            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;
            --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;

            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTOVDACR := round(least(l_AvlAmt, rec2.FEEINTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
            End If;

           insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
           advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
           t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
           intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
           prinovd, feedue, intdue, feeintdue, prindue, feenml,
           intnmlacr, feeintnmlacr, prinnml,ftype)

           select rec2.trfacctno, rec2.acctno, rec2.lnschdid,rec2.autoid, rec2.financetype,
           l_ADVPAYFEE advpayfee, rec2.avlamt, l_T0INTNMLOVD t0intnmlovd, l_t0intovdacr t0intovdacr, l_t0prinovd t0prinovd,
           l_t0intdue t0intdue, l_t0prindue t0prindue, l_t0intnmlacr t0intnmlacr, l_t0prinnml t0prinnml, l_feeovd feeovd,
           l_intnmlovd intnmlovd, l_feeintnmlovd feeintnmlovd, l_intovdacr intovdacr, l_feeintovdacr feeintovdacr,
           l_prinovd prinovd, l_feedue feedue, l_intdue intdue, l_feeintdue feeintdue, l_prindue prindue, l_feenml feenml,
           l_intnmlacr intnmlacr, l_feeintnmlacr feeintnmlacr, l_prinnml prinnml, 'R' ftype
           from dual;


           update lnpaidalloc_tmp
            set status = 'C'
            where status = 'P'
            and autoid = rec2.autoid;

        end loop;
    end loop;








    --lnAutoPayment
    l_duepaid:='OVD';
    for rec in
    (
            SELECT ci.acctno trfacctno,
                round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) AVLBAL
            FROM CIMAST ci, afmast af, aftype aft, mrtype mrt,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv,
                v_getbuyorderinfo b,
                v_getsecmargininfo sec,
                (select trfacctno, sum(avlamt) avlamt
                    from lnpaidalloc_dtl
                    group by trfacctno) dtl
            WHERE ci.acctno = af.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = b.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = dtl.trfacctno(+)
            and round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) > 0
            and exists (select 1 from lnmast where ftype = 'AF' and trfacctno = ci.acctno
                            and prinnml + prinovd + intnmlacr + intdue + intovdacr + intnmlovd + feeintnmlacr + feeintdue + feeintovdacr + feeintnmlovd
                                                    + oprinnml + oprinovd + ointnmlacr + ointdue + ointovdacr + ointnmlovd > 0)
            order by ci.acctno
    )
    loop -- rec
        if cspks_lnproc.fn_Gen_Prepaid_Payment_tmp(rec.trfacctno, rec.AVLBAL, 'N',l_duepaid, p_err_code) <> systemnums.c_success then
            return;
        end if;

        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid, lp.autoid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt - lp.paidamt) AvlAmt,

                sum(case when reftype = 'GP' then ls.intovd - nvl(dtl.T0INTNMLOVD,0) else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin- nvl(dtl.T0INTOVDACR,0) else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd- nvl(dtl.T0PRINOVD,0) else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue- nvl(dtl.T0INTDUE,0) else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.T0PRINDUE,0) else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr- nvl(dtl.T0INTNMLACR,0) else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' then ls.nml- nvl(dtl.T0PRINNML,0) else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd- nvl(dtl.FEEOVD,0) else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd- nvl(dtl.INTNMLOVD,0) else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd- nvl(dtl.FEEINTNMLOVD,0) else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin- nvl(dtl.INTOVDACR,0) else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr- nvl(dtl.FEEINTOVDACR,0) else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd- nvl(dtl.PRINOVD,0) else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue- nvl(dtl.FEEDUE,0) else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue- nvl(dtl.INTDUE,0) else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue- nvl(dtl.FEEINTDUE,0) else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.PRINDUE,0) else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee- nvl(dtl.FEENML,0) else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr- nvl(dtl.INTNMLACR,0) else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr- nvl(dtl.FEEINTNMLACR,0) else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' then ls.nml- nvl(dtl.PRINNML,0) else 0 end) PRINNML

            from lnmast ln, lnpaidalloc_tmp lp, lnschd ls,
            (SELECT max(trfacctno) trfacctno, max(acctno) acctno, lnschdid, max(autoid) autoid, max(financetype) financetype,
                   sum(advpayfee) advpayfee, sum(avlamt) avlamt, sum(t0intnmlovd) t0intnmlovd, sum(t0intovdacr) t0intovdacr, sum(t0prinovd) t0prinovd,
                   sum(t0intdue) t0intdue, sum(t0prindue) t0prindue, sum(t0intnmlacr) t0intnmlacr, sum(t0prinnml) t0prinnml, sum(feeovd) feeovd,
                   sum(intnmlovd) intnmlovd, sum(feeintnmlovd) feeintnmlovd, sum(intovdacr) intovdacr, sum(feeintovdacr) feeintovdacr,
                   sum(prinovd) prinovd, sum(feedue) feedue, sum(intdue) intdue, sum(feeintdue) feeintdue, sum(prindue) prindue, sum(feenml) feenml,
                   sum(intnmlacr) intnmlacr, sum(feeintnmlacr) feeintnmlacr, sum(prinnml) prinnml
            from lnpaidalloc_dtl
            group by lnschdid
            ) dtl
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and ln.trfacctno = rec.trfacctno and instr(ls.reftype,'P') > 0
            and lp.amt > lp.paidamt and lp.status = 'P'
            and ls.autoid = dtl.lnschdid (+)
            group by ln.trfacctno, ln.acctno, ls.autoid, lp.autoid
            order by lp.autoid
        )
        loop -- rec2
            l_AvlAmt:= rec2.AvlAmt;
            --So tien phai tra cho tung khoan
            -- Bao lanh
            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLOVD := round(least(l_AvlAmt, rec2.T0INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTOVDACR := round(least(l_AvlAmt, rec2.T0INTOVDACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            End If;
            --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_T0INTDUE := round(least(l_AvlAmt, rec2.T0INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_T0INTDUE;
            End If;
            --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLACR := round(least(l_AvlAmt, rec2.T0INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            End If;
            --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;

            -- CL
            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLOVD := round(least(l_AvlAmt, rec2.FEEINTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            End If;
            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTDUE := round(least(l_AvlAmt, rec2.FEEINTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
            End If;
            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLACR := round(least(l_AvlAmt, rec2.FEEINTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            End If;

            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLOVD := round(least(l_AvlAmt, rec2.INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_INTOVDACR := round(least(l_AvlAmt, rec2.INTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_INTOVDACR;
            End If;
            --13.INTDUE
            l_INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_INTDUE := round(least(l_AvlAmt, rec2.INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_INTDUE;
            End If;
            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLACR := round(least(l_AvlAmt, rec2.INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEOVD := round(least(l_AvlAmt, rec2.FEEOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEOVD;
            End If;
            --16.FEEDUE
            l_FEEDUE := 0;
            If l_AvlAmt > 0 Then
                l_FEEDUE := round(least(l_AvlAmt, rec2.FEEDUE),0);
                l_AvlAmt := l_AvlAmt - l_FEEDUE;
            End If;
            --17.FEENML
            l_FEENML := 0;
            If l_AvlAmt > 0 Then
                l_FEENML := round(least(l_AvlAmt, rec2.FEENML),0);
                l_AvlAmt := l_AvlAmt - l_FEENML;
            End If;

            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;
            --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;

            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTOVDACR := round(least(l_AvlAmt, rec2.FEEINTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
            End If;

           insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
           advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
           t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
           intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
           prinovd, feedue, intdue, feeintdue, prindue, feenml,
           intnmlacr, feeintnmlacr, prinnml, ftype)

           select rec2.trfacctno, rec2.acctno, rec2.lnschdid, rec2.autoid, rec2.financetype,
           l_ADVPAYFEE advpayfee, rec2.avlamt, l_T0INTNMLOVD t0intnmlovd, l_t0intovdacr t0intovdacr, l_t0prinovd t0prinovd,
           l_t0intdue t0intdue, l_t0prindue t0prindue, l_t0intnmlacr t0intnmlacr, l_t0prinnml t0prinnml, l_feeovd feeovd,
           l_intnmlovd intnmlovd, l_feeintnmlovd feeintnmlovd, l_intovdacr intovdacr, l_feeintovdacr feeintovdacr,
           l_prinovd prinovd, l_feedue feedue, l_intdue intdue, l_feeintdue feeintdue, l_prindue prindue, l_feenml feenml,
           l_intnmlacr intnmlacr, l_feeintnmlacr feeintnmlacr, l_prinnml prinnml , 'N' ftype
           from dual;

           update lnpaidalloc_tmp
            set status = 'C'
            where status = 'P'
            and autoid = rec2.autoid;

        end loop;
    end loop;



    --lnAutoPayment
    l_duepaid:='NML';
    for rec in
    (
            SELECT ci.acctno trfacctno,
                round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) AVLBAL
            FROM CIMAST ci, afmast af, aftype aft, mrtype mrt,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv,
                v_getbuyorderinfo b,
                v_getsecmargininfo sec,
                (select trfacctno, sum(avlamt) avlamt
                    from lnpaidalloc_dtl
                    group by trfacctno) dtl
            WHERE ci.acctno = af.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = b.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = dtl.trfacctno(+)
            and round(BALANCE + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) > 0
            and exists (select 1 from lnmast where ftype = 'AF' and trfacctno = ci.acctno
                            and prinnml + prinovd + intnmlacr + intdue + intovdacr + intnmlovd + feeintnmlacr + feeintdue + feeintovdacr + feeintnmlovd
                                                    + oprinnml + oprinovd + ointnmlacr + ointdue + ointovdacr + ointnmlovd > 0)
            order by ci.acctno
    )
    loop -- rec
        if cspks_lnproc.fn_Gen_Prepaid_Payment_tmp(rec.trfacctno, rec.AVLBAL, 'N',l_duepaid, p_err_code) <> systemnums.c_success then
            return;
        end if;

        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid, lp.autoid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt - lp.paidamt) AvlAmt,

                sum(case when reftype = 'GP' then ls.intovd - nvl(dtl.T0INTNMLOVD,0) else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin- nvl(dtl.T0INTOVDACR,0) else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd- nvl(dtl.T0PRINOVD,0) else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue- nvl(dtl.T0INTDUE,0) else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.T0PRINDUE,0) else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr- nvl(dtl.T0INTNMLACR,0) else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' then ls.nml- nvl(dtl.T0PRINNML,0) else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd- nvl(dtl.FEEOVD,0) else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd- nvl(dtl.INTNMLOVD,0) else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd- nvl(dtl.FEEINTNMLOVD,0) else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin- nvl(dtl.INTOVDACR,0) else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr- nvl(dtl.FEEINTOVDACR,0) else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd- nvl(dtl.PRINOVD,0) else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue- nvl(dtl.FEEDUE,0) else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue- nvl(dtl.INTDUE,0) else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue- nvl(dtl.FEEINTDUE,0) else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.PRINDUE,0) else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee- nvl(dtl.FEENML,0) else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr- nvl(dtl.INTNMLACR,0) else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr- nvl(dtl.FEEINTNMLACR,0) else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' then ls.nml- nvl(dtl.PRINNML,0) else 0 end) PRINNML

            from lnmast ln, lnpaidalloc_tmp lp, lnschd ls,
            (SELECT max(trfacctno) trfacctno, max(acctno) acctno, lnschdid, max(autoid) autoid, max(financetype) financetype,
                   sum(advpayfee) advpayfee, sum(avlamt) avlamt, sum(t0intnmlovd) t0intnmlovd, sum(t0intovdacr) t0intovdacr, sum(t0prinovd) t0prinovd,
                   sum(t0intdue) t0intdue, sum(t0prindue) t0prindue, sum(t0intnmlacr) t0intnmlacr, sum(t0prinnml) t0prinnml, sum(feeovd) feeovd,
                   sum(intnmlovd) intnmlovd, sum(feeintnmlovd) feeintnmlovd, sum(intovdacr) intovdacr, sum(feeintovdacr) feeintovdacr,
                   sum(prinovd) prinovd, sum(feedue) feedue, sum(intdue) intdue, sum(feeintdue) feeintdue, sum(prindue) prindue, sum(feenml) feenml,
                   sum(intnmlacr) intnmlacr, sum(feeintnmlacr) feeintnmlacr, sum(prinnml) prinnml
            from lnpaidalloc_dtl
            group by lnschdid
            ) dtl
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and ln.trfacctno = rec.trfacctno and instr(ls.reftype,'P') > 0
            and lp.amt > lp.paidamt and lp.status = 'P'
            and ls.autoid = dtl.lnschdid (+)
            group by ln.trfacctno, ln.acctno, ls.autoid, lp.autoid
            order by lp.autoid
        )
        loop -- rec2
            l_AvlAmt:= rec2.AvlAmt;
            --So tien phai tra cho tung khoan
            -- Bao lanh
            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLOVD := round(least(l_AvlAmt, rec2.T0INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTOVDACR := round(least(l_AvlAmt, rec2.T0INTOVDACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            End If;
            --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_T0INTDUE := round(least(l_AvlAmt, rec2.T0INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_T0INTDUE;
            End If;
            --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLACR := round(least(l_AvlAmt, rec2.T0INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            End If;
            --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;

            -- CL
            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLOVD := round(least(l_AvlAmt, rec2.FEEINTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            End If;
            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTDUE := round(least(l_AvlAmt, rec2.FEEINTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
            End If;
            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLACR := round(least(l_AvlAmt, rec2.FEEINTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            End If;

            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLOVD := round(least(l_AvlAmt, rec2.INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_INTOVDACR := round(least(l_AvlAmt, rec2.INTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_INTOVDACR;
            End If;
            --13.INTDUE
            l_INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_INTDUE := round(least(l_AvlAmt, rec2.INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_INTDUE;
            End If;
            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLACR := round(least(l_AvlAmt, rec2.INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEOVD := round(least(l_AvlAmt, rec2.FEEOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEOVD;
            End If;
            --16.FEEDUE
            l_FEEDUE := 0;
            If l_AvlAmt > 0 Then
                l_FEEDUE := round(least(l_AvlAmt, rec2.FEEDUE),0);
                l_AvlAmt := l_AvlAmt - l_FEEDUE;
            End If;
            --17.FEENML
            l_FEENML := 0;
            If l_AvlAmt > 0 Then
                l_FEENML := round(least(l_AvlAmt, rec2.FEENML),0);
                l_AvlAmt := l_AvlAmt - l_FEENML;
            End If;

            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;
            --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;

            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTOVDACR := round(least(l_AvlAmt, rec2.FEEINTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
            End If;

           insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
           advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
           t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
           intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
           prinovd, feedue, intdue, feeintdue, prindue, feenml,
           intnmlacr, feeintnmlacr, prinnml, ftype)

           select rec2.trfacctno, rec2.acctno, rec2.lnschdid, rec2.autoid, rec2.financetype,
           l_ADVPAYFEE advpayfee, rec2.avlamt, l_T0INTNMLOVD t0intnmlovd, l_t0intovdacr t0intovdacr, l_t0prinovd t0prinovd,
           l_t0intdue t0intdue, l_t0prindue t0prindue, l_t0intnmlacr t0intnmlacr, l_t0prinnml t0prinnml, l_feeovd feeovd,
           l_intnmlovd intnmlovd, l_feeintnmlovd feeintnmlovd, l_intovdacr intovdacr, l_feeintovdacr feeintovdacr,
           l_prinovd prinovd, l_feedue feedue, l_intdue intdue, l_feeintdue feeintdue, l_prindue prindue, l_feenml feenml,
           l_intnmlacr intnmlacr, l_feeintnmlacr feeintnmlacr, l_prinnml prinnml , 'N' ftype
           from dual;

           update lnpaidalloc_tmp
            set status = 'C'
            where status = 'P'
            and autoid = rec2.autoid;

        end loop;
    end loop;

    --LNAdvPaymentAftSendMoney
    l_duepaid:='OVD';
    for rec in
    (
            SELECT ci.acctno trfacctno,
                round(BALANCE -NVL (trf.amt, 0) + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) AVLBAL
            FROM CIMAST ci, afmast af, aftype aft, mrtype mrt,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv,
                v_getbuyorderinfo b,
                v_getsecmargininfo sec,
                (select trfacctno, sum(avlamt) avlamt
                    from lnpaidalloc_dtl
                    group by trfacctno) dtl,
                (select sum (amt) amt, afacctno from
                    (
                        select mst.afacctno,sum(mst.amt + case when od.feeacr >0 then feeacr else execamt * odt.deffeerate/100 end) amt
                            from stschd mst, odmast od, odtype odt
                            where mst.orgorderid = od.orderid and od.odtype = odt.actype
                            and MST.DUETYPE='SM' AND MST.STATUS='N' AND MST.DELTD<>'Y'
                            and cleardate= mst.txdate
                            group by mst.afacctno
                        union
                        SELECT sts.AFACCTNO, sts.AMT + od.feeacr AMT
                            FROM STSCHD sts, odmast od
                            WHERE sts.orgorderid =od.orderid and  DUETYPE='SM' AND sts.STATUS='C'
                            and sts.AMT > 0
                            and sts.cleardate = l_CURRDATE
                     ) group by afacctno
                ) trf --Du kien tien phai giao lenh mua + Phi
            WHERE ci.acctno = af.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = b.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = dtl.trfacctno(+)
            and ci.acctno = trf.afacctno (+)
            and round(BALANCE -NVL (trf.amt, 0) + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) > 0
            and exists (select 1 from lnmast where ftype = 'AF' and trfacctno = ci.acctno
                            and prinnml + prinovd + intnmlacr + intdue + intovdacr + intnmlovd + feeintnmlacr + feeintdue + feeintovdacr + feeintnmlovd
                                                    + oprinnml + oprinovd + ointnmlacr + ointdue + ointovdacr + ointnmlovd > 0)
            order by ci.acctno
    )
    loop -- rec
        if cspks_lnproc.fn_Gen_Prepaid_Payment_tmp(rec.trfacctno, rec.AVLBAL, 'L',l_duepaid, p_err_code) <> systemnums.c_success then
            return;
        end if;

        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid, lp.autoid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt - lp.paidamt) AvlAmt,

                sum(case when reftype = 'GP' then ls.intovd - nvl(dtl.T0INTNMLOVD,0) else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin- nvl(dtl.T0INTOVDACR,0) else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd- nvl(dtl.T0PRINOVD,0) else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue- nvl(dtl.T0INTDUE,0) else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.T0PRINDUE,0) else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr- nvl(dtl.T0INTNMLACR,0) else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' then ls.nml- nvl(dtl.T0PRINNML,0) else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd- nvl(dtl.FEEOVD,0) else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd- nvl(dtl.INTNMLOVD,0) else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd- nvl(dtl.FEEINTNMLOVD,0) else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin- nvl(dtl.INTOVDACR,0) else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr- nvl(dtl.FEEINTOVDACR,0) else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd- nvl(dtl.PRINOVD,0) else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue- nvl(dtl.FEEDUE,0) else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue- nvl(dtl.INTDUE,0) else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue- nvl(dtl.FEEINTDUE,0) else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.PRINDUE,0) else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee- nvl(dtl.FEENML,0) else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr- nvl(dtl.INTNMLACR,0) else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr- nvl(dtl.FEEINTNMLACR,0) else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' then ls.nml- nvl(dtl.PRINNML,0) else 0 end) PRINNML

            from lnmast ln, lnpaidalloc_tmp lp, lnschd ls,
            (SELECT max(trfacctno) trfacctno, max(acctno) acctno, lnschdid, max(autoid) autoid, max(financetype) financetype,
                   sum(advpayfee) advpayfee, sum(avlamt) avlamt, sum(t0intnmlovd) t0intnmlovd, sum(t0intovdacr) t0intovdacr, sum(t0prinovd) t0prinovd,
                   sum(t0intdue) t0intdue, sum(t0prindue) t0prindue, sum(t0intnmlacr) t0intnmlacr, sum(t0prinnml) t0prinnml, sum(feeovd) feeovd,
                   sum(intnmlovd) intnmlovd, sum(feeintnmlovd) feeintnmlovd, sum(intovdacr) intovdacr, sum(feeintovdacr) feeintovdacr,
                   sum(prinovd) prinovd, sum(feedue) feedue, sum(intdue) intdue, sum(feeintdue) feeintdue, sum(prindue) prindue, sum(feenml) feenml,
                   sum(intnmlacr) intnmlacr, sum(feeintnmlacr) feeintnmlacr, sum(prinnml) prinnml
            from lnpaidalloc_dtl
            group by lnschdid
            ) dtl
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and ln.trfacctno = rec.trfacctno and instr(ls.reftype,'P') > 0
            and lp.amt > lp.paidamt and lp.status = 'P'
            and ls.autoid = dtl.lnschdid (+)
            group by ln.trfacctno, ln.acctno, ls.autoid, lp.autoid
            order by lp.autoid
        )
        loop -- rec2
            l_AvlAmt:= rec2.AvlAmt;
            --So tien phai tra cho tung khoan
            -- Bao lanh
            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLOVD := round(least(l_AvlAmt, rec2.T0INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTOVDACR := round(least(l_AvlAmt, rec2.T0INTOVDACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            End If;
            --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_T0INTDUE := round(least(l_AvlAmt, rec2.T0INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_T0INTDUE;
            End If;
            --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLACR := round(least(l_AvlAmt, rec2.T0INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            End If;
            --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;

            -- CL
            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLOVD := round(least(l_AvlAmt, rec2.FEEINTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            End If;
            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTDUE := round(least(l_AvlAmt, rec2.FEEINTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
            End If;
            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLACR := round(least(l_AvlAmt, rec2.FEEINTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            End If;

            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLOVD := round(least(l_AvlAmt, rec2.INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_INTOVDACR := round(least(l_AvlAmt, rec2.INTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_INTOVDACR;
            End If;
            --13.INTDUE
            l_INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_INTDUE := round(least(l_AvlAmt, rec2.INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_INTDUE;
            End If;
            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLACR := round(least(l_AvlAmt, rec2.INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEOVD := round(least(l_AvlAmt, rec2.FEEOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEOVD;
            End If;
            --16.FEEDUE
            l_FEEDUE := 0;
            If l_AvlAmt > 0 Then
                l_FEEDUE := round(least(l_AvlAmt, rec2.FEEDUE),0);
                l_AvlAmt := l_AvlAmt - l_FEEDUE;
            End If;
            --17.FEENML
            l_FEENML := 0;
            If l_AvlAmt > 0 Then
                l_FEENML := round(least(l_AvlAmt, rec2.FEENML),0);
                l_AvlAmt := l_AvlAmt - l_FEENML;
            End If;

            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;
            --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;

            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTOVDACR := round(least(l_AvlAmt, rec2.FEEINTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
            End If;

           insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
           advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
           t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
           intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
           prinovd, feedue, intdue, feeintdue, prindue, feenml,
           intnmlacr, feeintnmlacr, prinnml, ftype)

           select rec2.trfacctno, rec2.acctno, rec2.lnschdid, rec2.autoid, rec2.financetype,
           l_ADVPAYFEE advpayfee, rec2.avlamt, l_T0INTNMLOVD t0intnmlovd, l_t0intovdacr t0intovdacr, l_t0prinovd t0prinovd,
           l_t0intdue t0intdue, l_t0prindue t0prindue, l_t0intnmlacr t0intnmlacr, l_t0prinnml t0prinnml, l_feeovd feeovd,
           l_intnmlovd intnmlovd, l_feeintnmlovd feeintnmlovd, l_intovdacr intovdacr, l_feeintovdacr feeintovdacr,
           l_prinovd prinovd, l_feedue feedue, l_intdue intdue, l_feeintdue feeintdue, l_prindue prindue, l_feenml feenml,
           l_intnmlacr intnmlacr, l_feeintnmlacr feeintnmlacr, l_prinnml prinnml, 'L' ftype
           from dual;

           update lnpaidalloc_tmp
            set status = 'C'
            where status = 'P'
            and autoid = rec2.autoid;

        end loop;
    end loop;


    --LNAdvPaymentAftSendMoney
    l_duepaid:='NML';
    for rec in
    (
            SELECT ci.acctno trfacctno,
                round(BALANCE -NVL (trf.amt, 0) + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) AVLBAL
            FROM CIMAST ci, afmast af, aftype aft, mrtype mrt,
                (select sum(depoamt) avladvance,afacctno
                    from v_getAccountAvlAdvance group by afacctno) adv,
                v_getbuyorderinfo b,
                v_getsecmargininfo sec,
                (select trfacctno, sum(avlamt) avlamt
                    from lnpaidalloc_dtl
                    group by trfacctno) dtl,
                (select sum (amt) amt, afacctno from
                    (
                        select mst.afacctno,sum(mst.amt + case when od.feeacr >0 then feeacr else execamt * odt.deffeerate/100 end) amt
                            from stschd mst, odmast od, odtype odt
                            where mst.orgorderid = od.orderid and od.odtype = odt.actype
                            and MST.DUETYPE='SM' AND MST.STATUS='N' AND MST.DELTD<>'Y'
                            and cleardate= mst.txdate
                            group by mst.afacctno
                        union
                        SELECT sts.AFACCTNO, sts.AMT + od.feeacr AMT
                            FROM STSCHD sts, odmast od
                            WHERE sts.orgorderid =od.orderid and  DUETYPE='SM' AND sts.STATUS='C'
                            and sts.AMT > 0
                            and sts.cleardate = l_CURRDATE
                     ) group by afacctno
                ) trf --Du kien tien phai giao lenh mua + Phi
            WHERE ci.acctno = af.acctno
            and af.actype = aft.actype and aft.mrtype = mrt.actype
            and ci.acctno = adv.afacctno(+)
            and ci.acctno = b.afacctno(+)
            and ci.acctno = sec.afacctno(+)
            and ci.acctno = dtl.trfacctno(+)
            and ci.acctno = trf.afacctno (+)
            and round(BALANCE -NVL (trf.amt, 0) + (case when l_duepaid='OVD' then nvl(avladvance,0) else 0 end)-nvl(dtl.avlamt,0)/*-depofeeamt*/,0) > 0
            and exists (select 1 from lnmast where ftype = 'AF' and trfacctno = ci.acctno
                            and prinnml + prinovd + intnmlacr + intdue + intovdacr + intnmlovd + feeintnmlacr + feeintdue + feeintovdacr + feeintnmlovd
                                                    + oprinnml + oprinovd + ointnmlacr + ointdue + ointovdacr + ointnmlovd > 0)
            order by ci.acctno
    )
    loop -- rec
        if cspks_lnproc.fn_Gen_Prepaid_Payment_tmp(rec.trfacctno, rec.AVLBAL, 'L',l_duepaid, p_err_code) <> systemnums.c_success then
            return;
        end if;

        for rec2 in
        (
            select ln.trfacctno, ln.acctno, ls.autoid lnschdid, lp.autoid,
                max(case when ln.ftype = 'AF' then 1 else 0 end) FINANCETYPE,
                max(ln.ADVPAYFEE) ADVPAYFEE, sum(lp.amt - lp.paidamt) AvlAmt,

                sum(case when reftype = 'GP' then ls.intovd - nvl(dtl.T0INTNMLOVD,0) else 0 end) T0INTNMLOVD,
                sum(case when reftype = 'GP' then ls.intovdprin- nvl(dtl.T0INTOVDACR,0) else 0 end) T0INTOVDACR,
                sum(case when reftype = 'GP' then ls.ovd- nvl(dtl.T0PRINOVD,0) else 0 end) T0PRINOVD,
                sum(case when reftype = 'GP' then ls.intdue- nvl(dtl.T0INTDUE,0) else 0 end) T0INTDUE,
                sum(case when reftype = 'GP' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.T0PRINDUE,0) else 0 end) T0PRINDUE,
                sum(case when reftype = 'GP' then ls.intnmlacr- nvl(dtl.T0INTNMLACR,0) else 0 end) T0INTNMLACR,
                sum(case when reftype = 'GP' then ls.nml- nvl(dtl.T0PRINNML,0) else 0 end) T0PRINNML,

                sum(case when reftype = 'P' then ls.feeovd- nvl(dtl.FEEOVD,0) else 0 end) FEEOVD,
                sum(case when reftype = 'P' then ls.intovd- nvl(dtl.INTNMLOVD,0) else 0 end) INTNMLOVD,
                sum(case when reftype = 'P' then ls.feeintnmlovd- nvl(dtl.FEEINTNMLOVD,0) else 0 end) FEEINTNMLOVD,
                sum(case when reftype = 'P' then ls.intovdprin- nvl(dtl.INTOVDACR,0) else 0 end) INTOVDACR,
                sum(case when reftype = 'P' then ls.feeintovdacr- nvl(dtl.FEEINTOVDACR,0) else 0 end) FEEINTOVDACR,
                sum(case when reftype = 'P' then ls.ovd- nvl(dtl.PRINOVD,0) else 0 end) PRINOVD,
                sum(case when reftype = 'P' then ls.feedue- nvl(dtl.FEEDUE,0) else 0 end) FEEDUE,
                sum(case when reftype = 'P' then ls.intdue- nvl(dtl.INTDUE,0) else 0 end) INTDUE,
                sum(case when reftype = 'P' then ls.feeintdue- nvl(dtl.FEEINTDUE,0) else 0 end) FEEINTDUE,
                sum(case when reftype = 'P' and overduedate = l_CURRDATE then ls.nml- nvl(dtl.PRINDUE,0) else 0 end) PRINDUE,
                sum(case when reftype = 'P' then ls.fee- nvl(dtl.FEENML,0) else 0 end) FEENML,
                sum(case when reftype = 'P' then ls.intnmlacr- nvl(dtl.INTNMLACR,0) else 0 end) INTNMLACR,
                sum(case when reftype = 'P' then ls.feeintnmlacr- nvl(dtl.FEEINTNMLACR,0) else 0 end) FEEINTNMLACR,
                sum(case when reftype = 'P' then ls.nml- nvl(dtl.PRINNML,0) else 0 end) PRINNML

            from lnmast ln, lnpaidalloc_tmp lp, lnschd ls,
            (SELECT max(trfacctno) trfacctno, max(acctno) acctno, lnschdid, max(autoid) autoid, max(financetype) financetype,
                   sum(advpayfee) advpayfee, sum(avlamt) avlamt, sum(t0intnmlovd) t0intnmlovd, sum(t0intovdacr) t0intovdacr, sum(t0prinovd) t0prinovd,
                   sum(t0intdue) t0intdue, sum(t0prindue) t0prindue, sum(t0intnmlacr) t0intnmlacr, sum(t0prinnml) t0prinnml, sum(feeovd) feeovd,
                   sum(intnmlovd) intnmlovd, sum(feeintnmlovd) feeintnmlovd, sum(intovdacr) intovdacr, sum(feeintovdacr) feeintovdacr,
                   sum(prinovd) prinovd, sum(feedue) feedue, sum(intdue) intdue, sum(feeintdue) feeintdue, sum(prindue) prindue, sum(feenml) feenml,
                   sum(intnmlacr) intnmlacr, sum(feeintnmlacr) feeintnmlacr, sum(prinnml) prinnml
            from lnpaidalloc_dtl
            group by lnschdid
            ) dtl
            where ln.acctno = lp.lnacctno and lp.lnschdid = ls.autoid
            and ln.trfacctno = rec.trfacctno and instr(ls.reftype,'P') > 0
            and lp.amt > lp.paidamt and lp.status = 'P'
            and ls.autoid = dtl.lnschdid (+)
            group by ln.trfacctno, ln.acctno, ls.autoid, lp.autoid
            order by lp.autoid
        )
        loop -- rec2
            l_AvlAmt:= rec2.AvlAmt;
            --So tien phai tra cho tung khoan
            -- Bao lanh
            --01.T0INTNMLOVD
            l_T0INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLOVD := round(least(l_AvlAmt, rec2.T0INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLOVD;
            End If;
            --02.T0INTOVDACR
            l_T0INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTOVDACR := round(least(l_AvlAmt, rec2.T0INTOVDACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTOVDACR;
            End If;
            --03.T0PRINOVD
            l_T0PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINOVD := round(least(l_AvlAmt, rec2.T0PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINOVD;
            end if;
            --04.T0INTDUE
            l_T0INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_T0INTDUE := round(least(l_AvlAmt, rec2.T0INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_T0INTDUE;
            End If;
            --05.T0PRINDUE
            l_T0PRINDUE := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINDUE := round(least(l_AvlAmt, rec2.T0PRINDUE),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINDUE;
            End If;
            --06.T0INTNMLACR
            l_T0INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_T0INTNMLACR := round(least(l_AvlAmt, rec2.T0INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_T0INTNMLACR;
            End If;
            --07.T0PRINNML
            l_T0PRINNML := 0;
            If l_AvlAmt > 0 Then
                l_T0PRINNML := round(least(l_AvlAmt, rec2.T0PRINNML),0);
                l_AvlAmt := l_AvlAmt - l_T0PRINNML;
            End If;

            -- CL
            -- Phi
            --08.FEEINTNMLOVD
            l_FEEINTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLOVD := round(least(l_AvlAmt, rec2.FEEINTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLOVD;
            End If;
            --09.FEEINTDUE
            l_FEEINTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTDUE := round(least(l_AvlAmt, rec2.FEEINTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTDUE;
            End If;
            --10.FEEINTNMLACR
            l_FEEINTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_FEEINTNMLACR := round(least(l_AvlAmt, rec2.FEEINTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_FEEINTNMLACR;
            End If;

            -- Lai

            --11.INTNMLOVD
            l_INTNMLOVD := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLOVD := round(least(l_AvlAmt, rec2.INTNMLOVD),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLOVD;
            End If;
            --12.INTOVDACR
            l_INTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_INTOVDACR := round(least(l_AvlAmt, rec2.INTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_INTOVDACR;
            End If;
            --13.INTDUE
            l_INTDUE := 0;
            If l_AvlAmt > 0 Then
                 l_INTDUE := round(least(l_AvlAmt, rec2.INTDUE),0);
                 l_AvlAmt := l_AvlAmt - l_INTDUE;
            End If;
            --14.INTNMLACR
            l_INTNMLACR := 0;
            If l_AvlAmt > 0 Then
                l_INTNMLACR := round(least(l_AvlAmt, rec2.INTNMLACR),0);
                l_AvlAmt := l_AvlAmt - l_INTNMLACR;
            End If;

            --15.FEEOVD
            l_FEEOVD := 0;
            If l_AvlAmt > 0 Then
                l_FEEOVD := round(least(l_AvlAmt, rec2.FEEOVD),0);
                l_AvlAmt := l_AvlAmt - l_FEEOVD;
            End If;
            --16.FEEDUE
            l_FEEDUE := 0;
            If l_AvlAmt > 0 Then
                l_FEEDUE := round(least(l_AvlAmt, rec2.FEEDUE),0);
                l_AvlAmt := l_AvlAmt - l_FEEDUE;
            End If;
            --17.FEENML
            l_FEENML := 0;
            If l_AvlAmt > 0 Then
                l_FEENML := round(least(l_AvlAmt, rec2.FEENML),0);
                l_AvlAmt := l_AvlAmt - l_FEENML;
            End If;

            -- Goc
            --18.PRINOVD
            l_PRINOVD := 0;
            If l_AvlAmt > 0 Then
                l_PRINOVD := round(least(l_AvlAmt, rec2.PRINOVD),0);
                l_AvlAmt := l_AvlAmt - l_PRINOVD;
            End If;
            --19.PRINDUE
            l_PRINDUE := 0;
            If l_AvlAmt > 0 Then
               l_PRINDUE := round(least(l_AvlAmt, rec2.PRINDUE),0);
               l_AvlAmt := l_AvlAmt - l_PRINDUE;
            End If;
            --20.PRINNML
            l_PRINNML := 0;
            if rec2.PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_PRINNML := round(least(rec2.PRINNML, l_AvlAmt * 1 / (1+REC2.ADVPAYFEE/100)),0);
                     l_AvlAmt := l_AvlAmt - l_PRINNML;
                End If;
            end if;
            --21.ADVPAYFEE
            l_ADVPAYFEE := 0;
            if l_PRINNML > 0 then
                If l_AvlAmt > 0 Then
                     l_ADVPAYFEE := round(rec2.FINANCETYPE * round(least(l_AvlAmt, l_PRINNML * REC2.ADVPAYFEE / 100 ),0),0);
                     l_AvlAmt := l_AvlAmt - l_ADVPAYFEE;
                End If;
            end if;

            -- Lai & Phi
            --22.FEEINTOVDACR
            l_FEEINTOVDACR := 0;
            If l_AvlAmt > 0 Then
                 l_FEEINTOVDACR := round(least(l_AvlAmt, rec2.FEEINTOVDACR),0);
                 l_AvlAmt := l_AvlAmt - l_FEEINTOVDACR;
            End If;

           insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
           advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
           t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
           intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
           prinovd, feedue, intdue, feeintdue, prindue, feenml,
           intnmlacr, feeintnmlacr, prinnml, ftype)

           select rec2.trfacctno, rec2.acctno, rec2.lnschdid, rec2.autoid, rec2.financetype,
           l_ADVPAYFEE advpayfee, rec2.avlamt, l_T0INTNMLOVD t0intnmlovd, l_t0intovdacr t0intovdacr, l_t0prinovd t0prinovd,
           l_t0intdue t0intdue, l_t0prindue t0prindue, l_t0intnmlacr t0intnmlacr, l_t0prinnml t0prinnml, l_feeovd feeovd,
           l_intnmlovd intnmlovd, l_feeintnmlovd feeintnmlovd, l_intovdacr intovdacr, l_feeintovdacr feeintovdacr,
           l_prinovd prinovd, l_feedue feedue, l_intdue intdue, l_feeintdue feeintdue, l_prindue prindue, l_feenml feenml,
           l_intnmlacr intnmlacr, l_feeintnmlacr feeintnmlacr, l_prinnml prinnml, 'L' ftype
           from dual;

           update lnpaidalloc_tmp
            set status = 'C'
            where status = 'P'
            and autoid = rec2.autoid;

        end loop;
    end loop;


    --Tra no cho DF
    for rec in
    (
        select a.* , LEAST (a.sumamt,a.DFBLOCKORG) dfblockamt_least, ROUND(a.sumamt - LEAST (a.sumamt,a.dfblockamt)) CIPAID
            from (
              SELECT v.*, cf.custodycd, cf.fullname, cf.idcode, cf.ADDRESS , df.orgamt, df.rlsamt+df.dfamt dfpaidamt,
                            ROUND(fn_getamt4grpdeal(v.GROUPID,0,5)) sumamt, df.dfblockamt DFBLOCKORG,
                        greatest(getavlciwithdraw (v.afacctno, 'N'),0) CIAVLWITHDRAW
                    FROM v_getgrpdealformular v, afmast af, cfmast cf, dfgroup df, DFTYPE DFT
                    where af.custid=cf.custid and v.afacctno=af.acctno and v.groupid=df.groupid
                          AND DF.ACTYPE = DFT.ACTYPE AND DFT.ISVSD <> 'Y'
                    AND v.VNDSELLDF >0
              ) a
    )
    loop
        -- Neu tra lai thu vao ky tra goc cuoi cung thi treo khoan tra no vao` trong DFGROUP roi lam = tay
        if nvl(instr('L', rec.INTPAIDMETHOD),0) >0 and (rec.CURAMT <= (rec.VNDSELLDF + rec.DFBLOCKORG)) and  (rec.VNDSELLDF+ rec.DFBLOCKORG <  rec.sumamt)   then
            SELECT  TO_DATE((SELECT VARVALUE FROM SYSVAR WHERE VARNAME='CURRDATE'),'DD/MM/RRRR') - TO_DATE(OVERDUEDATE,'DD/MM/RRRR') into l_DayDue
                         FROM LNSCHD WHERE ACCTNO  = rec.LNACCTNO AND REFTYPE='P';
            if l_DayDue >= 0 then
            -- Neu qua han
                l_amtpaid:= rec.VNDSELLDF + rec.DFBLOCKORG;
                insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
               advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
               t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
               intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
               prinovd, feedue, intdue, feeintdue, prindue, feenml,
               intnmlacr, feeintnmlacr, prinnml, ftype)

               select rec.afacctno trfacctno, ln.acctno, ln.autoid lnschdid, ln.autoid autoid, 0 financetype,
               0 advpayfee, l_amtpaid avlamt, 0 t0intnmlovd, 0 t0intovdacr, 0 t0prinovd,
               0 t0intdue, 0 t0prindue, 0 t0intnmlacr, 0 t0prinnml, 0 feeovd,
               least(l_amtpaid, greatest(l_amtpaid-ovd - nml - INTOVD,0), INTOVDPRIN) intnmlovd,
               least(l_amtpaid, greatest(l_amtpaid-ovd - nml - INTOVD - INTOVDPRIN,0),FEEINTNMLOVD) feeintnmlovd,
               least(l_amtpaid, greatest(l_amtpaid-ovd - nml,0),INTOVD) intovdacr,
               least(l_amtpaid, greatest(l_amtpaid-ovd - nml - INTOVD - INTOVDPRIN - FEEINTNMLOVD,0),FEEINTOVDACR)  feeintovdacr,
               least(ovd, l_amtpaid) prinovd, 0 feedue, 0 intdue, 0 feeintdue, 0 prindue, 0 feenml,
               0 intnmlacr, 0 feeintnmlacr, least(l_amtpaid, greatest(l_amtpaid-ovd,0),NML) prinnml, 'D' ftype
               from lnschd ln
               where reftype='P' and ACCTNO  = rec.LNACCTNO;


            else
                --Khong tra no, chi cap nhat vao trong DFGROUP
                insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
               advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
               t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
               intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
               prinovd, feedue, intdue, feeintdue, prindue, feenml,
               intnmlacr, feeintnmlacr, prinnml, ftype)

                select rec.afacctno trfacctno, ln.acctno, ln.autoid lnschdid, ln.autoid autoid, 0 financetype,
               0 advpayfee, l_amtpaid avlamt, 0 t0intnmlovd, 0 t0intovdacr, 0 t0prinovd,
               0 t0intdue, 0 t0prindue, 0 t0intnmlacr, 0 t0prinnml, 0 feeovd,
               0 intnmlovd,
               0 feeintnmlovd,
               0 intovdacr,
               0  feeintovdacr,
               0 prinovd, 0 feedue, 0 intdue, 0 feeintdue, 0 prindue, 0 feenml,
               0 intnmlacr, 0 feeintnmlacr, 0 prinnml, 'D' ftype
               from lnschd ln
               where reftype='P' and ACCTNO  = rec.LNACCTNO;
            end if;
        else

            l_prinamt :=round(fn_getamt4grpdeal(rec.GROUPID,least(rec.DFBLOCKAMT + rec.VNDSELLDF, rec.SUMAMT),0));
            l_intamt :=round(fn_getamt4grpdeal(rec.GROUPID,least(rec.DFBLOCKAMT + rec.VNDSELLDF, rec.SUMAMT),1));
            l_feeamt :=round(fn_getamt4grpdeal(rec.GROUPID,least(rec.DFBLOCKAMT + rec.VNDSELLDF, rec.SUMAMT),2));

            insert into lnpaidalloc_dtl (trfacctno, acctno, lnschdid, autoid, financetype,
               advpayfee, avlamt, t0intnmlovd, t0intovdacr, t0prinovd,
               t0intdue, t0prindue, t0intnmlacr, t0prinnml, feeovd,
               intnmlovd, feeintnmlovd, intovdacr, feeintovdacr,
               prinovd, feedue, intdue, feeintdue, prindue, feenml,
               intnmlacr, feeintnmlacr, prinnml, ftype)

                select rec.afacctno trfacctno, ln.acctno, ln.autoid lnschdid, ln.autoid autoid, 0 financetype,
               0 advpayfee, l_amtpaid avlamt, 0 t0intnmlovd, 0 t0intovdacr, 0 t0prinovd,
               0 t0intdue, 0 t0prindue, 0 t0intnmlacr, 0 t0prinnml, 0 feeovd,
               greatest(least(INTOVDPRIN, l_intamt-INTOVD),0) intnmlovd,
               least(FEEINTNMLOVD, l_feeamt) feeintnmlovd,
               least(INTOVD, l_intamt) intovdacr,
               greatest(least(FEEINTOVDACR, l_feeamt-FEEINTNMLOVD),0)  feeintovdacr,
               least(ovd, l_prinamt) prinovd, 0 feedue, 0 intdue, 0 feeintdue, 0 prindue, 0 feenml,
               greatest(least(INTNMLACR, l_intamt-INTOVD-INTOVDPRIN),0) intnmlacr,
               greatest(least(FEEINTNMLACR, l_feeamt-FEEINTNMLOVD-FEEINTOVDACR),0) feeintnmlacr,
               greatest(least(nml, l_prinamt-ovd),0) prinnml, 'D' ftype
               from lnschd ln
               where reftype='P' and ACCTNO  = rec.LNACCTNO;
        end if;
    end loop;
exception when others then
    dbms_output.put_line('err:' || dbms_utility.format_error_backtrace);
end;

 
 
 
 
/
