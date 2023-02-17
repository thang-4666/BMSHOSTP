SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "GETBALANCE" (
        PV_REFCURSOR IN OUT PKG_REPORT.REF_CURSOR,
        pv_afacctno IN VARCHAR2
        )
  IS
    v_margintype char(1);
    v_actype varchar2(4);
    v_groupleader varchar2(10);
    v_baldefovd number(20,0);
    v_pp number(20,0);
    v_avllimit number(20,0);
    v_navaccount number(20,0);
    v_outstanding   number(20,0);
    v_mrirate number(20,4);
BEGIN

    SELECT MR.MRTYPE,af.actype,mst.groupleader into v_margintype,v_actype,v_groupleader from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype and mst.acctno=pv_afacctno;
        if v_margintype='N' then
            --Tai khoan binh thuong khong Margin
            OPEN PV_REFCURSOR FOR
                    SELECT cf.custodycd, cf.fullname, af.aftype, af.acctno afacctno, af.isotc,
                   af.custid, greatest(ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt,0) balance, ci.mblock mortagesell,
                   NVL (advamt, 0) + NVL (v.secureamt, 0)+ ci.trfbuyamt bamt,(case when ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt<0 then -(ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0) - ci.trfbuyamt) else 0 end ) + ci.odamt + NVL (v.overamt, 0) - NVL (advamt, 0) odamt,
                   ci.crintacr crintacr, NVL (b.advancepayment, 0) advancepayment,NVL (b.amt, 0) amt,
                   (  ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0) - ci.trfbuyamt+ NVL (ci.mblock, 0) + NVL (c.a_amt, 0)
                    + (SELECT NVL(SUM (CASE WHEN exectype IN ('NS', 'SS', 'MS') THEN remainqtty * si.currprice ELSE 0 END ), 0) remainsecured
                         FROM odmast, securities_info si WHERE odmast.codeid = si.codeid AND afacctno = pv_afacctno AND deltd = 'N')
                    + (SELECT NVL (SUM (CASE WHEN odmast.exectype IN ('NB', 'BC') THEN quoteprice * remainqtty * (1+odtype.deffeerate/100) ELSE 0 END ),0 ) remainsecured
                         FROM odmast,odtype  WHERE odmast.actype = odtype.actype and afacctno = pv_afacctno AND odmast.deltd = 'N')
                    + NVL (b.rsamt, 0) + NVL (b.amt, 0) - NVL (b.advancepayment, 0) ) netaccountvalue,
                   (NVL (c.a_amt, 0) + NVL (b.rsamt, 0)) marketvalueofsecurities,
                   (CASE WHEN ci.balance - ci.odamt - NVL (advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt < 0 THEN 0 ELSE ci.balance - ci.odamt - NVL (advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt END) cashforwithdrawl,
                   (  ci.balance+least(nvl(af.mrcrlimit,0), NVL (v.secureamt, 0)+ ci.trfbuyamt) - ci.odamt - NVL (v.secureamt, 0)- ci.trfbuyamt + af.advanceline - NVL (v.overamt, 0) ) moneyavaiableforinvestment
              FROM cfmast cf, afmast af, cimast ci, v_getbuyorderinfo v,
                   (SELECT MAX (st.afacctno) afacctno, SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (amt, 0) ELSE 0 END) amt,
                           SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (st.aamt, 0) - NVL (st.paidamt, 0) ELSE 0 END ) advancepayment,
                           SUM (CASE WHEN (st.duetype) = 'RS' THEN st.qtty * si.currprice ELSE 0 END ) rsamt
                      FROM stschd st, securities_info si
                     WHERE st.codeid = si.codeid
                       AND st.duetype IN ('RM', 'RS') AND st.status = 'N' AND st.afacctno = pv_afacctno AND st.deltd = 'N') b,
                   (SELECT SUM (  (  se.trade - NVL (secured.secureamt, 0) + se.withdraw + se.transfer + se.mortage - NVL (secured.securemtg, 0) + se.margin + se.blocked + se.pending ) * (si.currprice) ) a_amt
                      FROM semast se, securities_info si,
                            v_getsellorderinfo secured
                     WHERE se.afacctno = pv_afacctno AND se.codeid = si.codeid AND se.acctno = secured.seacctno(+)) c
             WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND af.acctno = v.afacctno(+) AND af.acctno = pv_afacctno;
        elsif v_margintype<>'N' and (length(v_groupleader)=0 or v_groupleader is null) then
            --Tai khoan margin khong tham gia group
            OPEN PV_REFCURSOR FOR
            SELECT cf.custodycd, cf.fullname, af.aftype, af.acctno afacctno, af.isotc,
                   af.custid, greatest(ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt,0) balance, ci.mblock mortagesell,
                   NVL (advamt, 0) + NVL (v.secureamt, 0)+ ci.trfbuyamt bamt,(case when ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt<0 then -(ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt) else 0 end) + ci.odamt + NVL (v.overamt, 0) - NVL (advamt, 0) odamt,
                   ci.crintacr crintacr, NVL (b.advancepayment, 0) advancepayment,NVL (b.amt, 0) amt,
                   (  ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)- ci.trfbuyamt + NVL (ci.mblock, 0) + NVL (c.a_amt, 0)
                    + (SELECT NVL(SUM (CASE WHEN odmast.exectype IN ('NS', 'SS', 'MS') THEN remainqtty * si.currprice ELSE 0 END ), 0) remainsecured
                         FROM odmast, securities_info si WHERE odmast.codeid = si.codeid AND afacctno = pv_afacctno AND odmast.deltd = 'N')
                    + (SELECT NVL (SUM (CASE WHEN odmast.exectype IN ('NB', 'BC') THEN quoteprice * remainqtty * (1+odtype.deffeerate/100) ELSE 0 END ),0 ) remainsecured
                         FROM odmast,odtype  WHERE odmast.actype = odtype.actype and afacctno = pv_afacctno AND odmast.deltd = 'N')
                    + NVL (b.rsamt, 0) + NVL (b.amt, 0) - NVL (b.advancepayment, 0) ) netaccountvalue,
                   (NVL (c.a_amt, 0) + NVL (b.rsamt, 0)) marketvalueofsecurities,
                   /*greatest(ci.balance - ci.odamt - NVL (advamt, 0) - NVL (v.secureamt, 0),0) cashforwithdrawl,
                   (  ci.balance - ci.odamt - NVL (v.secureamt, 0) + af.advanceline - NVL (v.overamt, 0) ) moneyavaiableforinvestment,*/
                   greatest(least((nvl(af.mrcrlimit,0) + nvl(se.seamt,0)+
                                nvl(se.receivingamt,0))
                        ,nvl(af.mrcrlimitmax,0)+nvl(af.mrcrlimit,0))
                   + af.advanceline + ci.balance- ci.odamt - nvl(v.secureamt,0)- ci.trfbuyamt - ci.ramt,0) moneyavaiableforinvestment,
                   TRUNC((CASE WHEN af.mrirate>0
                            THEN GREATEST(LEAST(100* (/*nvl(af.MRCRLIMIT,0) +*/  nvl(se.SEASS,0))/af.mrirate + (ci.balance+least(nvl(af.MRCRLIMIT,0),nvl(v.secureamt,0)+ ci.trfbuyamt)+ nvl(se.receivingamt,0)- ci.odamt - NVL (v.advamt, 0)-nvl(v.secureamt,0)- ci.trfbuyamt - ci.ramt),
                                greatest(ci.balance- ci.ovamt-ci.dueamt - ci.ramt-af.advanceline,0)
                                ,(af.advanceline + nvl(af.mrcrlimitmax,0) + ci.balance- ci.odamt - nvl (v.overamt, 0)-nvl(v.secureamt,0)- ci.trfbuyamt - ci.ramt)-nvl(af.advanceline,0)),0)
                            ELSE greatest(ci.balance- ci.ovamt-ci.dueamt - ci.ramt-af.advanceline,0)-nvl(af.advanceline,0) END),0) cashforwithdrawl
              FROM cfmast cf, afmast af, cimast ci, v_getbuyorderinfo v,
                   (SELECT MAX (st.afacctno) afacctno, SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (amt, 0) ELSE 0 END) amt,
                           SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (st.aamt, 0) - NVL (st.paidamt, 0) ELSE 0 END ) advancepayment,
                           SUM (CASE WHEN (st.duetype) = 'RS' THEN st.qtty * si.currprice ELSE 0 END ) rsamt
                      FROM stschd st, securities_info si
                     WHERE st.codeid = si.codeid
                       AND st.duetype IN ('RM', 'RS') AND st.status = 'N' AND st.afacctno = pv_afacctno AND st.deltd = 'N') b,
                   (SELECT SUM (  (  se.trade - NVL (secured.secureamt, 0) + se.withdraw + se.transfer + se.mortage - NVL (secured.securemtg, 0) + se.margin + se.blocked + se.pending ) * (si.currprice) ) a_amt
                      FROM semast se, securities_info si, v_getsellorderinfo secured
                     WHERE se.afacctno = pv_afacctno AND se.codeid = si.codeid AND se.acctno = secured.seacctno(+)) c,
                     (select * from v_getsecmargininfo where afacctno = pv_afacctno) SE
             WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND af.acctno = v.afacctno(+) AND af.acctno = pv_afacctno
             and af.acctno = se.afacctno(+);
        else
            --Tai khoan margin join theo group
            SELECT LEAST(SUM((NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(SE.RECEIVINGAMT,0)))
                            ,sum(NVL(AF.MRCRLIMITMAX,0)+NVL(AF.MRCRLIMIT,0)))
                       + sum(BALANCE- ODAMT - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT) PP,
                   greatest(sum(nvl(AF.mrcrlimitmax,0)+NVL(AF.MRCRLIMIT,0) + balance- odamt - nvl(secureamt,0) - ramt),0) avllimit,
                   GREATEST(SUM(balance- ovamt-dueamt - ramt),0) baldefovd,
                   SUM(/*nvl(af.MRCRLIMIT,0) + */ nvl(se.SEASS,0))  NAVACCOUNT,
                   SUM(cimast.balance+least(NVL(AF.MRCRLIMIT,0),nvl(b.secureamt,0))+ nvl(se.receivingamt,0)- cimast.odamt - nvl(b.secureamt,0) - cimast.ramt) OUTSTANDING,
                   SUM(CASE WHEN AF.ACCTNO <> v_groupleader THEN 0 ELSE AF.MRIRATE END) MRIRATE
               into v_pp,v_avllimit, v_baldefovd,v_navaccount,v_outstanding,v_mrirate
               from cimast inner join afmast af on cimast.acctno=af.acctno and af.groupleader=v_groupleader
               left join
                (select b.* from v_getbuyorderinfo  b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) b
                on  cimast.acctno = b.afacctno
                LEFT JOIN
                (select b.* from v_getsecmargininfo b, afmast af where b.afacctno =af.acctno and af.groupleader=v_groupleader) se
                on se.afacctno=cimast.acctno;

            OPEN PV_REFCURSOR FOR
                    SELECT cf.custodycd, cf.fullname, af.aftype, af.acctno afacctno, af.isotc,
                   af.custid, greatest(ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0),0) balance, ci.mblock mortagesell,
                   NVL (advamt, 0) + NVL (v.secureamt, 0) bamt,(case when ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)<0 then -(ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0)) else 0 end) + ci.odamt + NVL (v.overamt, 0) - NVL (advamt, 0) odamt,
                   ci.crintacr crintacr, NVL (b.advancepayment, 0) advancepayment,NVL (b.amt, 0) amt,
                   (  ci.balance - NVL (v.advamt, 0) - NVL (v.secureamt, 0) + NVL (ci.mblock, 0) + NVL (c.a_amt, 0)
                    + (SELECT NVL(SUM (CASE WHEN exectype IN ('NS', 'SS', 'MS') THEN remainqtty * si.currprice ELSE 0 END ), 0) remainsecured
                         FROM odmast, securities_info si WHERE odmast.codeid = si.codeid AND afacctno = pv_afacctno AND deltd = 'N')
                    + (SELECT NVL (SUM (CASE WHEN odmast.exectype IN ('NB', 'BC') THEN quoteprice * remainqtty * (1 + odtype.deffeerate/100) ELSE 0 END ),0 ) remainsecured
                         FROM odmast,odtype  WHERE odmast.actype = odtype.actype and afacctno = pv_afacctno AND odmast.deltd = 'N')
                    + NVL (b.rsamt, 0) + NVL (b.amt, 0) - NVL (b.advancepayment, 0) ) netaccountvalue,
                   (NVL (c.a_amt, 0) + NVL (b.rsamt, 0)) marketvalueofsecurities,
                   TRUNC((case when v_mrirate>0
                                then least(greatest((100* v_navaccount + v_outstanding * v_mrirate)/v_mrirate,0),
                                                    --v_baldefovd,
                                                    greatest(balance- ovamt-dueamt - ramt-af.advanceline,0),
                                                    v_avllimit)
                             else greatest(balance- odamt - NVL (advamt, 0)-nvl(secureamt,0) - ramt,0)
                             end),0)  cashforwithdrawl,
                   greatest(nvl(af.advanceline,0) + v_pp,0) moneyavaiableforinvestment
              FROM cfmast cf, afmast af, cimast ci, v_getbuyorderinfo v,
                   (SELECT MAX (st.afacctno) afacctno, SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (amt, 0) ELSE 0 END) amt,
                           SUM (CASE WHEN (st.duetype) = 'RM' THEN NVL (st.aamt, 0) - NVL (st.paidamt, 0) ELSE 0 END ) advancepayment,
                           SUM (CASE WHEN (st.duetype) = 'RS' THEN st.qtty * si.currprice ELSE 0 END ) rsamt
                      FROM stschd st, securities_info si
                     WHERE st.codeid = si.codeid
                       AND st.duetype IN ('RM', 'RS') AND st.status = 'N' AND st.afacctno = pv_afacctno AND st.deltd = 'N') b,
                   (SELECT SUM (  (  se.trade - NVL (secured.secureamt, 0) + se.withdraw + se.transfer + se.mortage - NVL (secured.securemtg, 0) + se.margin + se.blocked + se.pending ) * (si.currprice) ) a_amt
                      FROM semast se, securities_info si, v_getsellorderinfo secured
                     WHERE se.afacctno = pv_afacctno AND se.codeid = si.codeid AND se.acctno = secured.seacctno(+)) c
             WHERE cf.custid = af.custid AND af.acctno = ci.afacctno AND af.acctno = v.afacctno(+) AND af.acctno = pv_afacctno;
        end if;
   EXCEPTION
    WHEN others THEN
        return;
END;

 
 
 
 
/
