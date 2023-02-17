SET DEFINE OFF;
CREATE OR REPLACE FUNCTION fn_cimastcheck_for_report (
      pv_condvalue   IN   VARCHAR2,
      pv_tblname     IN   VARCHAR2,
      pv_fldkey      IN   VARCHAR2
   )
      RETURN txpks_check.cimastcheck_arrtype
   IS
      l_margintype            CHAR (1);
      l_actype                VARCHAR2 (4);
      l_groupleader           VARCHAR2 (10);
      l_baldefovd             NUMBER (20, 0);
      l_baldefovd_Released    NUMBER (20, 0);

      l_pp                    NUMBER (20, 0);
      l_avllimit              NUMBER (20, 0);
      l_deallimit             NUMBER (20, 0);
      l_navaccount            NUMBER (20, 0);
      l_outstanding           NUMBER (20, 0);
      l_mrirate               NUMBER (20, 4);

      l_baldefovd_Released_depofee    NUMBER (20, 0);

      l_cimastcheck_rectype   txpks_check.cimastcheck_rectype;
      l_cimastcheck_arrtype   txpks_check.cimastcheck_arrtype;
      l_i                     NUMBER (10);
      pv_refcursor            pkg_report.ref_cursor;
      l_count number;
      l_isMarginAcc varchar2(1);

      l_avladvance  NUMBER; -- TheNN added
      l_advanceamount NUMBER; -- TheNN added
      l_paidamt       NUMBER; -- TheNN added
      l_EXECBUYAMT       NUMBER; -- TheNN added
      l_TRFBUYRATE       NUMBER;
   BEGIN
         -- Proc
        --l_TRFBUYRATE:= (100 - to_number(cspks_system.fn_get_sysvar('SYSTEM', 'TRFBUYRATE')))/100;
        select (100 - to_number(varvalue))/100 into l_TRFBUYRATE from sysvar where grname ='SYSTEM' and varname ='TRFBUYRATE';
      SELECT mr.mrtype, af.actype, mst.groupleader
        INTO l_margintype, l_actype, l_groupleader
        FROM afmast mst, aftype af, mrtype mr
       WHERE mst.actype = af.actype
         AND af.mrtype = mr.actype
         AND mst.acctno = pv_condvalue;

      IF l_margintype = 'N' or l_margintype = 'L'
      THEN
         --Tai khoan binh thuong khong Margin
         OPEN pv_refcursor FOR
            SELECT ci.actype, ci.acctno, ci.ccycd,
                   ci.afacctno, ci.custid, ci.opndate,
                   ci.clsdate, ci.lastdate, ci.dormdate,
                   ci.status, ci.pstatus,
                   af.advanceline,
                   ci.balance - NVL (secureamt, 0) - ci.trfbuyamt balance,
                   ci.balance + nvl(adv.avladvance,0) avlbal,
                   ci.cramt,
                   ci.dramt, ci.crintacr,ci.CIDEPOFEEACR, ci.crintdt,
                   ci.odintacr, ci.odintdt, ci.avrbal,
                   ci.mdebit, ci.mcredit, ci.aamt, ci.ramt,
                   NVL (secureamt, 0) + ci.trfbuyamt bamt, ci.emkamt, ci.mmarginbal,
                   ci.marginbal, ci.iccfcd, ci.iccftied,
                   ci.odlimit, ci.adintacr, ci.adintdt,
                   ci.facrtrade, ci.facrdepository, ci.facrmisc,
                   ci.minbal, ci.odamt, ci.dueamt, ci.ovamt, ci.namt, ci.floatamt,
                   ci.holdbalance, ci.pendinghold,
                   ci.pendingunhold, ci.corebank,
                   (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                   ci.receiving,
                   ci.netting, ci.mblock, l_margintype mrtype,
                   round(
                    nvl(adv.avladvance,0) + nvl(balance,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0)  - ci.trfbuyamt + advanceline - nvl(ramt,0) /*- ci.depofeeamt*/ + least(af.mrcrlimitmax +af.mrcrlimit - ci.dfodamt,af.mrcrlimit)
                    ,0) pp,
                   round(
                    nvl(adv.avladvance,0) + nvl(balance,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline - nvl(ramt,0) /*- ci.depofeeamt*/ + least(af.mrcrlimitmax + af.mrcrlimit- ci.dfodamt,af.mrcrlimit)
                    ,0) ppref,
                    nvl(adv.avladvance,0)
                   + AF.mrcrlimitmax + af.mrcrlimit - dfodamt
                   + af.advanceline
                   + balance
                   - odamt
                   - dfdebtamt
                   - dfintdebtamt
                   - NVL (overamt, 0)
                   - NVL (secureamt, 0) - ci.trfbuyamt
                   - ramt
                 /*  - CI.DEPOFEEAMT
                   - CI.CIDEPOFEEACR*/ avllimit,
                   greatest(least(
                                    AF.mrcrlimitmax - dfodamt,
                                    AF.mrcrlimitmax - dfodamt + af.advanceline -odamt
                                    ),
                                0
                        ) deallimit,
                   0 navaccount, 0 outstanding, af.mrirate,
                   GREATEST ( nvl(adv.avladvance,0) + balance
                             - odamt
                             - dfdebtamt
                             - dfintdebtamt
                             - NVL (advamt, 0)
                             - NVL (secureamt, 0) - ci.trfbuyamt
                             - ramt
                             - nvl(pd.dealpaidamt,0)
                             - CI.DEPOFEEAMT
                             - CI.CIDEPOFEEACR,
                             0
                            ) avlwithdraw,
                   nvl(adv.avladvance,0) + balance - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0) - nvl(secureamt,0) - CI.TRFBUYAMT+LEAST(AF.MRCRLIMIT,nvl(secureamt,0) + CI.TRFBUYAMT) - ramt-nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT- CI.CIDEPOFEEACR
                   BALDEFOVD,

                   GREATEST (  round(least(nvl(adv.avladvance,0) + balance ,
                                    nvl(adv.avladvance,0) + balance  +
                                    af.advanceline -NVL (advamt, 0)-
                                    nvl(secureamt,0) - ci.trfbuyamt-RAMT
                                    + LEAST(AF.MRCRLIMIT,nvl(secureamt,0) + CI.TRFBUYAMT)
                            ),0
                   ) ,0) baldefovd_released,
                   dfdebtamt,
                   dfintdebtamt,
                   GREATEST ( nvl(adv.avladvance,0) + balance
                             - odamt
                             - dfdebtamt
                             - dfintdebtamt
                             - NVL (advamt, 0)
                             - NVL (secureamt, 0) - CI.TRFBUYAMT
                             +LEAST(AF.MRCRLIMIT,nvl(secureamt,0) + CI.TRFBUYAMT)
                             - ramt
                             - nvl(pd.dealpaidamt,0)
                             ,
                             0
                            ) baldefovd_released_depofee,  -- Su dung de check khi thu phi luu ky
                   nvl(adv.avladvance,0) avladvance, nvl(adv.advanceamount,0) advanceamount, nvl(adv.paidamt,0) paidamt, 0 SEASS, nvl(b.execbuyamt,0) execbuyamt
              FROM cimast ci INNER JOIN afmast af ON ci.acctno = af.acctno
                   LEFT JOIN (SELECT *
                                FROM v_getbuyorderinfo
                               WHERE afacctno = pv_condvalue) b
                               ON ci.acctno = b.afacctno
                   left join
                            (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt
                                from v_getAccountAvlAdvance
                                where afacctno = pv_condvalue group by afacctno) adv
                                on adv.afacctno=ci.acctno
                   LEFT JOIN
                            (select *
                                from v_getdealpaidbyaccount p
                                where p.afacctno = pv_CONDVALUE) pd
                            on pd.afacctno=ci.acctno
             WHERE ci.acctno = pv_condvalue;
      ELSIF     l_margintype in  ('S','T')
            AND (LENGTH (l_groupleader) = 0 OR l_groupleader IS NULL)
      THEN
            select count(1)
                into l_count
            from afmast af
            where af.acctno = pv_condvalue
            and (exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y')
                or exists (select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y'));

            if l_count > 0 then
                l_isMarginAcc:='Y';
            else
                l_isMarginAcc:='N';
            end if;


         --Tai khoan margin khong tham gia group
         OPEN pv_refcursor FOR
                SELECT
                ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,
                DORMDATE,STATUS,PSTATUS,ADVANCELINE, BALANCE,AVLBAL,CRAMT,DRAMT,CRINTACR, cidepofeeacr, CRINTDT,ODINTACR,ODINTDT,
                AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,
                ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,dueamt, ovamt,NAMT,FLOATAMT,
                HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,allowcorebank,RECEIVING,NETTING,MBLOCK,l_margintype mrtype,PP,PPREF,AVLLIMIT,DEALLIMIT,
                NAVACCOUNT,OUTSTANDING,MRIRATE,
                TRUNC(
                    GREATEST(
                        (CASE WHEN MRIRATE>0 THEN least(NAVACCOUNT*100/MRIRATE + (OUTSTANDING_HOLD_DEPOFEE-ADVANCELINE),AVLLIMIT-ADVANCELINE) ELSE NAVACCOUNT + OUTSTANDING END)
                    ,0)
                ,0) AVLWITHDRAW,
                --Neu co bao lanh T0 thi khong duoc rut
                TRUNC(
                            (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING_HOLD_DEPOFEE-ADVANCELINE) * MRIRATE)/MRIRATE,0),BALDEFOVD,AVLLIMIT-ADVANCELINE) ELSE BALDEFOVD END)
                        ,0)
                BALDEFOVD,
                baldefovd_Released,
                DFDEBTAMT, dfintdebtamt,
                TRUNC
                ((CASE
                     WHEN mrirate > 0
                        THEN LEAST (GREATEST (  (  100 * navaccount
                                                 +   (  outstanding /*+ depofeeamt*/ - advanceline
                                                     )
                                                   * mrirate
                                                )
                                              / mrirate,
                                              0
                                             ),
                                    baldefovd + depofeeamt+CIDEPOFEEACR,
                                    avllimit /*+ depofeeamt +CIDEPOFEEACR*/ - advanceline
                                   )
                     ELSE baldefovd + DEPOFEEAMT+CIDEPOFEEACR
                  END
                 )  ,
                 0
                ) Baldefovd_Released_Depofee,  -- Su dung de check khi thu phi luu ky
                avladvance, advanceamount, paidamt, SEASS, execbuyamt
                FROM
                    (SELECT cidepofeeacr, af.advanceline,ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                        ci.balance-nvl(se.secureamt,0) - ci.trfbuyamt balance,
                        ci.balance + nvl(se.avladvance,0) avlbal,
                        ci.DFDEBTAMT,
                        ci.cramt,ci.dramt,ci.crintacr,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                        nvl(se.secureamt,0) + ci.trfbuyamt bamt,
                        ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                        ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                        ci.pendinghold,ci.pendingunhold,ci.corebank,
                        (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                        ci.receiving,ci.netting,ci.mblock, ci.dfintdebtamt,
                             nvl(se.avladvance,0) + balance - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt - CI.DEPOFEEAMT-CI.CIDEPOFEEACR
                        BALDEFOVD,
                        greatest(ci.balance - nvl(se.secureamt,0) - ci.trfbuyamt + nvl(se.avladvance,0) - ci.dfdebtamt - ci.dfintdebtamt - CI.DEPOFEEAMT-CI.CIDEPOFEEACR - af.advanceline,0) BALDEFOVD_RLSODAMT ,
                        greatest(round(least(nvl(se.avladvance,0) + balance ,nvl(se.avladvance,0) + balance  + af.advanceline -NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt-ramt),0) ,0) baldefovd_released,
                        round(ci.balance - nvl(se.secureamt,0) - ci.trfbuyamt- nvl(se.overamt,0)
                                 + nvl(se.avladvance,0) + least(nvl(se.mrcrlimitmax,0) +nvl(af.mrcrlimit,0)- dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt  /*- ci.depofeeamt*/,0)
                            PP,
                        round(ci.balance - nvl(se.secureamt,0) - ci.trfbuyamt - nvl(se.overamt,0)
                                 + nvl(se.avladvance,0) + least(nvl(se.mrcrlimitmax,0)+nvl(af.mrcrlimit,0) - dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt  /*- ci.depofeeamt*/,0)
                            PPREF,
                        round(
                            nvl(se.avladvance,0) + nvl(af.advanceline,0) + nvl(se.mrcrlimitmax,0) +nvl(af.mrcrlimit,0)- dfodamt + balance - odamt - ci.dfdebtamt - ci.dfintdebtamt - nvl(se.secureamt,0) - ci.trfbuyamt - ramt /*- CI.DEPOFEEAMT-CI.CIDEPOFEEACR*/
                        ,0) AVLLIMIT,
                        greatest(least(nvl(se.mrcrlimitmax,0) - dfodamt,
                                nvl(se.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt),0) deallimit,
                        least(nvl(se.SEASS,0),nvl(SE.mrcrlimitmax,0) - dfodamt) NAVACCOUNT,
                        nvl(af.advanceline,0) + ci.balance +least(nvl(af.mrcrlimit,0),nvl(se.secureamt,0) + ci.trfbuyamt) + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt - ci.ramt OUTSTANDING, --kHI DAT LENH THI THEM PHAN T0
                        nvl(af.advanceline,0) + ci.balance +least(nvl(af.mrcrlimit,0),nvl(se.secureamt,0) + ci.trfbuyamt) + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt - ci.depofeeamt-CI.CIDEPOFEEACR- NVL (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt - ci.ramt OUTSTANDING_HOLD_DEPOFEE, --kHI DAT LENH THI THEM PHAN T0
                        af.mrirate,
                        se.chksysctrl,
                        nvl(se.avladvance,0) avladvance, nvl(se.advanceamount,0) advanceamount, nvl(se.paidamt,0) paidamt,
                        nvl(se.SEASS,0) SEASS, nvl(margin74amt,0) margin74amt, nvl(sereal,0) sereal,
                        af.MRIRATIO, nvl(MARGINRATE74,0) MARGINRATE74, depofeeamt, ci.dueamt, ci.ovamt, nvl(se.execbuyamt,0) execbuyamt
                   from cimast ci inner join afmast af on ci.acctno=af.acctno
                        left join (select * from v_getsecmarginratio where afacctno = pv_CONDVALUE) se on se.afacctno=ci.acctno
                        left join (select * from v_getsecmarginratio_74 where afacctno = pv_CONDVALUE) se74 on se74.afacctno=ci.acctno
                        left join (select TRFACCTNO, nvl(sum(ln.PRINOVD + ln.INTOVDACR + ln.INTNMLOVD + ln.OPRINOVD + ln.OPRINNML + ln.OINTNMLOVD + ln.OINTOVDACR+ln.OINTDUE+ln.OINTNMLACR + nvl(lns.nml,0) + nvl(lns.intdue,0)),0) OVDAMT,
                                                       nvl(sum(ln.PRINNML - nvl(nml,0)+ ln.INTNMLACR),0) NMLMARGINAMT,
                                            nvl(sum(decode(lnt.chksysctrl,'Y',1,0)*(ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intdue+ln.intovdacr+ln.intnmlovd+ln.feeintnmlacr+ln.feeintdue+ln.feeintovdacr+ln.feeintnmlovd)),0) margin74amt
                                        from lnmast ln, lntype lnt, (select acctno, sum(nml) nml, sum(intdue) intdue  from lnschd
                                                            where reftype = 'P' and  overduedate = to_date(fn_get_sysvar_for_report('SYSTEM','CURRDATE'),'DD/MM/RRRR') group by acctno) lns
                                        where ln.actype = lnt.actype and ln.acctno = lns.acctno(+) and ln.ftype = 'AF'
                                        and ln.trfacctno = pv_CONDVALUE
                                        group by ln.trfacctno) OVDAF on OVDAF.TRFACCTNO = ci.acctno
                        left join (select afacctno, sum(amt) receivingamt from stschd where afacctno = pv_CONDVALUE and duetype = 'RM' and status <> 'C' and deltd <> 'Y' group by afacctno) sts_rcv
                                on ci.acctno = sts_rcv.afacctno
                   WHERE ci.acctno = pv_CONDVALUE);

      ELSE
         --Tai khoan margin join theo group
         SELECT LEAST(SUM((NVL(AF.MRCRLIMIT,0) + NVL(SE.SEAMT,0)+
                                    NVL(adv.avladvance,0)))
                            ,sum(nvl(adv.avladvance,0)+ greatest(NVL(AF.MRCRLIMITMAX,0)+NVL(AF.MRCRLIMIT,0)- dfodamt,0)))
                       + sum(BALANCE - ODAMT- dfdebtamt- dfintdebtamt - NVL (ADVAMT, 0)-NVL(SECUREAMT,0) - RAMT/* - ci.depofeeamt*/) PP,
                GREATEST (SUM ( NVL (AF.mrcrlimitmax, 0)+NVL(AF.MRCRLIMIT,0) - dfodamt
                               + balance
                               - odamt
                               - dfdebtamt
                               - dfintdebtamt
                               - NVL (secureamt, 0)
                               - ramt
                             /* - CI.DEPOFEEAMT
                              - CI.CIDEPOFEEACR*/
                              ),
                          0
                         ) avllimit,
                greatest(least(sum(nvl(AF.mrcrlimitmax,0) - dfodamt),
                        sum(nvl(AF.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt)),0) deallimit,
                --GREATEST (
                    SUM (nvl(adv.avladvance,0) + balance - dfdebtamt
                             - dfintdebtamt- ovamt - dueamt - RAMT- CI.DEPOFEEAMT-CI.CIDEPOFEEACR)
                --, 0)
                baldefovd,
                greatest(round(least(sum(nvl(adv.avladvance,0) + balance ),
                                    sum(nvl(adv.avladvance,0) + balance  +
                                    af.advanceline -NVL (advamt, 0)-
                                    nvl(secureamt,0)-ramt)
                            ),0
                   ),0) baldefovd_released,
                SUM (  /*NVL (af.mrcrlimit, 0)
                     +*/ NVL (se.seass, 0)
                    ) navaccount,
                SUM (  ci.balance
                     + NVL (adv.avladvance, 0)
                     - ci.odamt
                     - ci.dfdebtamt
                     - ci.dfintdebtamt
                     - NVL (b.secureamt, 0)
                     - ci.ramt
                     + least(nvl(af.mrcrlimit,0),NVL (b.secureamt, 0))
                    ) outstanding,
                SUM (CASE
                        WHEN af.acctno <> pv_condvalue
                           THEN 0
                        ELSE af.mrirate
                     END) mrirate,
                GREATEST (SUM (nvl(adv.avladvance,0) + balance - dfdebtamt
                             - dfintdebtamt- ovamt - dueamt - ramt), 0) baldefovd_released_depofee, -- Su dung de check khi thu phi luu ky,
                nvl(adv.avladvance,0) avladvance, nvl(adv.advanceamount,0) advanceamount, nvl(adv.paidamt,0) paidamt
           INTO l_pp,
                l_avllimit,
                l_deallimit,
                l_baldefovd,
                l_baldefovd_Released,
                l_navaccount,
                l_outstanding,
                l_mrirate,
                l_baldefovd_Released_depofee,
                l_avladvance,
                l_advanceamount,
                l_paidamt
           FROM cimast ci INNER JOIN afmast af ON ci.acctno = af.acctno
                                          AND af.groupleader = l_groupleader
                LEFT JOIN (SELECT b.*
                             FROM v_getbuyorderinfo b, afmast af
                            WHERE b.afacctno = af.acctno
                              AND af.groupleader = l_groupleader) b ON ci.acctno =
                                                                         b.afacctno
                LEFT JOIN (SELECT b.*
                             FROM v_getsecmargininfo b, afmast af
                            WHERE b.afacctno = af.acctno
                              AND af.groupleader = l_groupleader) se ON se.afacctno =
                                                                          ci.acctno
                left join
                        (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt
                            from v_getAccountAvlAdvance b , afmast af where b.afacctno =af.acctno and af.groupleader=l_groupleader group by afacctno) adv
                        on adv.afacctno=ci.acctno
                ;

         OPEN pv_refcursor FOR
            SELECT ci.actype, ci.acctno, ci.ccycd,
                   ci.afacctno, ci.custid, ci.opndate,
                   ci.clsdate, ci.lastdate, ci.dormdate,
                   ci.status, ci.pstatus,
                   af.advanceline,
                   ci.balance  - NVL (secureamt, 0) balance,
                   ci.balance + l_avladvance avlbal,
                   ci.cramt,
                   ci.dramt, ci.crintacr,ci.CIDEPOFEEACR, ci.crintdt,
                   ci.odintacr, ci.odintdt, ci.avrbal,
                   ci.mdebit, ci.mcredit, ci.aamt, ci.ramt,
                   NVL (secureamt, 0) bamt, ci.emkamt, ci.mmarginbal,
                   ci.marginbal, ci.iccfcd, ci.iccftied,
                   ci.odlimit, ci.adintacr, ci.adintdt,
                   ci.facrtrade, ci.facrdepository, ci.facrmisc,
                   ci.minbal, ci.odamt, ci.namt, ci.floatamt,
                   ci.holdbalance, ci.pendinghold,
                   ci.pendingunhold, ci.corebank, ci.receiving,
                   ci.netting, ci.mblock,l_margintype mrtype,
                   greatest(NVL (af.advanceline, 0) + l_pp,0) pp,
                   NVL (af.advanceline, 0) + l_avllimit avllimit,
                   l_avllimit avlmrlimit,l_deallimit deallimit,
                   l_navaccount navaccount, l_outstanding outstanding,
                   l_mrirate mrirate,
                   TRUNC
                      (GREATEST ((CASE
                                     WHEN l_mrirate > 0
                                        THEN   least(l_navaccount * 100 / l_mrirate
                                             + l_outstanding,l_avllimit)
                                     ELSE l_navaccount + l_outstanding
                                  END
                                 )- nvl(pd.dealpaidamt,0),
                                 0
                                ),
                       0
                      ) avlwithdraw,
                   TRUNC
                      ((CASE
                           WHEN l_mrirate > 0
                              THEN LEAST (GREATEST (  (  100 * l_navaccount
                                                       +   l_outstanding
                                                         * l_mrirate
                                                      )
                                                    / l_mrirate,
                                                    0
                                                   ),
                                          --l_baldefovd,
                                          greatest(balance - dfdebtamt-dfintdebtamt - ovamt-dueamt - ramt-af.advanceline,0),
                                          l_avllimit
                                         )
                           ELSE GREATEST (  balance
                                          - odamt
                                          - dfdebtamt-dfintdebtamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt,
                                          0
                                         )
                        END
                       ) - nvl(pd.dealpaidamt,0) - CI.DEPOFEEAMT-CI.CIDEPOFEEACR,
                       0
                      ) baldefovd,
                      l_baldefovd_Released baldefovd_Released,
                      dfdebtamt, dfintdebtamt,
                      TRUNC
                      ((CASE
                           WHEN l_mrirate > 0
                              THEN LEAST (GREATEST (  (  100 * l_navaccount
                                                       +   l_outstanding
                                                         * l_mrirate
                                                      )
                                                    / l_mrirate,
                                                    0
                                                   ),
                                          --l_baldefovd,
                                          greatest(balance - dfdebtamt-dfintdebtamt - ovamt-dueamt - ramt-af.advanceline,0),
                                          l_avllimit
                                         )
                           ELSE GREATEST (  balance
                                          - odamt
                                          - dfdebtamt-dfintdebtamt
                                          - NVL (advamt, 0)
                                          - NVL (secureamt, 0)
                                          - ramt,
                                          0
                                         )
                        END
                       ) - nvl(pd.dealpaidamt,0),
                       0
                      ) baldefovd_Released_depofee, -- Su dung check khi thu phi luu ky
                      l_avladvance avladvance,
                        l_advanceamount advanceamount,
                        l_paidamt paidamt, l_EXECBUYAMT EXECBUYAMT, nvl(pd.dealpaidamt,0) dealpaidamt, nvl(se.SEASS,0) SEASS
              FROM cimast ci INNER JOIN afmast af ON ci.acctno = af.acctno
                   LEFT JOIN (SELECT *
                                FROM v_getbuyorderinfo
                               WHERE afacctno = pv_condvalue) b ON ci.acctno =
                                                                     b.afacctno
                   LEFT JOIN (SELECT *
                                FROM v_getsecmargininfo se
                               WHERE se.afacctno = pv_condvalue) se ON se.afacctno =
                                                                         ci.acctno
                   LEFT JOIN
                              (select *
                                  from v_getdealpaidbyaccount p where p.afacctno = pv_condvalue) pd
                              on pd.afacctno=ci.acctno
             WHERE ci.acctno = pv_condvalue;
      END IF;

      l_i := 0;
      LOOP
         FETCH pv_refcursor
          INTO l_cimastcheck_rectype;

         l_cimastcheck_arrtype (l_i) := l_cimastcheck_rectype;
         EXIT WHEN pv_refcursor%NOTFOUND;
         l_i := l_i + 1;
      END LOOP;
      --close pv_refcursor;
      /*FETCH pv_refcursor
          bulk collect INTO l_cimastcheck_arrtype;
      close pv_refcursor;*/
      RETURN l_cimastcheck_arrtype;
   EXCEPTION
      WHEN OTHERS
      THEN
         if pv_refcursor%ISOPEN THEN
            CLOSE pv_refcursor;
         END IF;
         RETURN l_cimastcheck_arrtype;
   END fn_cimastcheck_for_report;

 
 
 
 
/
