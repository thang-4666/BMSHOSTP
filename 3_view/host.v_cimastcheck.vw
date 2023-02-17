SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW V_CIMASTCHECK
(ACTYPE, ACCTNO, CCYCD, AFACCTNO, CUSTID, 
 OPNDATE, CLSDATE, LASTDATE, DORMDATE, STATUS, 
 PSTATUS, ADVANCELINE, BALANCE, CRAMT, DRAMT, 
 CRINTACR, CIDEPOFEEACR, CRINTDT, ODINTACR, ODINTDT, 
 AVRBAL, MDEBIT, MCREDIT, AAMT, RAMT, 
 BAMT, EMKAMT, MMARGINBAL, MARGINBAL, ICCFCD, 
 ICCFTIED, ODLIMIT, ADINTACR, ADINTDT, FACRTRADE, 
 FACRDEPOSITORY, FACRMISC, MINBAL, ODAMT, NAMT, 
 FLOATAMT, HOLDBALANCE, PENDINGHOLD, PENDINGUNHOLD, COREBANK, 
 RECEIVING, NETTING, MBLOCK, MRTYPE, PP, 
 PPREF, AVLLIMIT, DEALLIMIT, NAVACCOUNT, OUTSTANDING, 
 SE_NAVACCOUNT, SE_OUTSTANDING, MRIRATE, AVLWITHDRAW, BALDEFOVD, 
 BALDEFOVD_RELEASED, DFDEBTAMT, DFINTDEBTAMT, BALDEFOVD_RELEASED_DEPOFEE, AVLADVANCE, 
 ADVANCEAMOUNT, PAIDAMT, SEASS, SEAMT, MARGINRATE, 
 EXECBUYAMT, BANKBALANCE, BANKAVLBAL, TDBALANCE, TDINTAMT, 
 TDODAMT, TDODINTACR, CALLAMT, ADDAMT, RCVAMT, 
 RCVADVAMT)
BEQUEATH DEFINER
AS 
SELECT ci.actype, ci.acctno, ci.ccycd,
                   ci.afacctno, ci.custid, ci.opndate,
                   ci.clsdate, ci.lastdate, ci.dormdate,
                   ci.status, ci.pstatus,
                   af.advanceline advanceline,
                   ci.balance - NVL (secureamt, 0) - ci.trfbuyamt balance, ci.cramt,
                   ci.dramt, ci.crintacr,ci.CIDEPOFEEACR, ci.crintdt,
                   ci.odintacr, ci.odintdt, ci.avrbal,
                   ci.mdebit, ci.mcredit, ci.aamt, ci.ramt,
                   NVL (secureamt, 0) + ci.trfbuyamt bamt, ci.emkamt, ci.mmarginbal,
                   ci.marginbal, ci.iccfcd, ci.iccftied,
                   ci.odlimit, ci.adintacr, ci.adintdt,
                   ci.facrtrade, ci.facrdepository, ci.facrmisc,
                   ci.minbal, ci.odamt, ci.namt, ci.floatamt,
                   ci.holdbalance, ci.pendinghold,
                   ci.pendingunhold, ci.corebank, ci.receiving,
                   ci.netting, ci.mblock, mr.actype mrtype,
                   round(
                    nvl(adv.avladvance,0) + nvl(balance,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline  - nvl(ramt,0)/* - ci.depofeeamt*/ + least(af.mrcrlimitmax +af.mrcrlimit- ci.dfodamt,af.mrcrlimit)
                    ,0) pp,
                   round(
                    nvl(adv.avladvance,0) + nvl(balance,0) + nvl(ci.BANKAVLBAL,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline  - nvl(ramt,0) /*- ci.depofeeamt*/ + least(af.mrcrlimitmax+af.mrcrlimit - ci.dfodamt,af.mrcrlimit)
                    ,0) ppref,
                    nvl(adv.avladvance,0)
                   + AF.mrcrlimitmax+af.mrcrlimit - dfodamt
                   + af.advanceline
                   + balance
                   - odamt
                   - dfdebtamt
                   - dfintdebtamt
                   - NVL (overamt, 0)
                   - NVL (secureamt, 0) - ci.trfbuyamt
                   - ramt
                   /*- ci.depofeeamt*/ avllimit,
                   greatest(least(
                                    AF.mrcrlimitmax - dfodamt,
                                    AF.mrcrlimitmax - dfodamt + af.advanceline -odamt
                                    ),
                                0
                        ) deallimit,
                   0 navaccount, 0 outstanding, 0 se_navaccount, 0 se_outstanding,af.mrirate,
                   GREATEST ( nvl(adv.avladvance,0) + balance
                             - odamt
                             - dfdebtamt
                             - dfintdebtamt
                             - NVL (advamt, 0)
                             - NVL (secureamt, 0) - ci.trfbuyamt
                             - ramt
                             - nvl(pd.dealpaidamt,0)
                            /* - ci.depofeeamt*/,
                             0
                            ) avlwithdraw,
                   greatest(
                        nvl(adv.avladvance,0) + balance - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt - NVL (overamt, 0) - nvl(secureamt,0) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0)/* - ci.depofeeamt*/
                        ,0) BALDEFOVD,
                   GREATEST (  round(least(nvl(adv.avladvance,0) + balance ,
                                    nvl(adv.avladvance,0) + balance  +
                                    af.advanceline -NVL (advamt, 0)-
                                    nvl(secureamt,0) - ci.trfbuyamt-ramt
                            ),0
                   ) ,0) baldefovd_released,
                   dfdebtamt,
                   dfintdebtamt,
                   GREATEST ( nvl(adv.avladvance,0) + balance
                             - odamt
                             - dfdebtamt
                             - dfintdebtamt
                             - NVL (advamt, 0)
                             - NVL (secureamt, 0) - ci.trfbuyamt
                             - ramt
                             - nvl(pd.dealpaidamt,0),
                             0
                            ) baldefovd_released_depofee,  -- Su dung de check khi thu phi luu ky
                   nvl(adv.avladvance,0) avladvance, nvl(adv.advanceamount,0) advanceamount, nvl(adv.paidamt,0) paidamt,
                   0 SEASS, -- tk binh thuong SEASS = 0
                   0 SEAMT,
                   100000 Marginrate,
                   nvl(b.execbuyamt,0) execbuyamt,ci.BANKBALANCE,ci.BANKAVLBAL,
                   nvl(td.tdbalance,0) tdbalance,
                   nvl(td.TDINTAMT,0) TDINTAMT,
                   nvl(td.TDODAMT,0) TDODAMT,
                   nvl(td.TDODINTACR,0) TDODINTACR,
                   0  CALLAMT,
                   greatest(-(nvl(adv.avladvance,0) + nvl(balance,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - NVL (advamt, 0)
                            - nvl(secureamt,0) - ci.trfbuyamt  - nvl(ramt,0)/* - ci.depofeeamt*/
                            + least(af.mrcrlimitmax + af.mrcrlimit- ci.dfodamt,af.mrcrlimit)),0) addamt, --Phan PP bi am
                   nvl(adv.rcvamt,0) rcvamt, --Tien cho ve tru phi thue
                   nvl(adv.aamt,0) rcvadvamt --Tien dang ung truoc


              FROM cimast ci,
                    afmast af, aftype aft, mrtype mr,
                    (SELECT * FROM v_getbuyorderinfo) b,
                    (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt , sum(rcvamt) rcvamt, sum(aamt) aamt
                                from v_getAccountAvlAdvance
                        group by afacctno) adv,
                (select * from v_getdealpaidbyaccount p) pd,
                (select (100 - to_number(varvalue))/100 trfbuyrate from sysvar where grname = 'SYSTEM' and varname = 'TRFBUYRATE') trfr,
                (select mst.afacctno, sum(MST.BALANCE) TDBALANCE,
                                    sum(FN_TDMASTINTRATIO(MST.ACCTNO,getcurrdate,
                                                    MST.BALANCE)) TDINTAMT, sum(ODAMT) TDODAMT, sum(ODINTACR) TDODINTACR
                                from tdmast mst
                                where  MST.DELTD<>'Y' AND MST.status in ('N','A')
                                group by mst.afacctno) td

       WHERE ci.acctno = af.acctno
       and af.actype = aft.actype
         AND aft.mrtype = mr.actype
         and mr.mrtype  in('L','N')
        and  ci.acctno =    b.afacctno(+)
        and ci.acctno =adv.afacctno(+)
        and  ci.acctno= pd.afacctno(+)
        and  ci.acctno= td.afacctno(+)
  -- TK MAGIN KO GROUP
  union all
    SELECT
                ACTYPE,ACCTNO,CCYCD,AFACCTNO,CUSTID,OPNDATE,CLSDATE,LASTDATE,
                DORMDATE,STATUS,PSTATUS, ADVANCELINE, BALANCE,CRAMT,DRAMT,CRINTACR, cidepofeeacr, CRINTDT,ODINTACR,ODINTDT,
                AVRBAL,MDEBIT,MCREDIT,AAMT,RAMT,BAMT,EMKAMT,MMARGINBAL,MARGINBAL,ICCFCD,ICCFTIED,
                ODLIMIT,ADINTACR,ADINTDT,FACRTRADE,FACRDEPOSITORY,FACRMISC,MINBAL,ODAMT,NAMT,FLOATAMT,
                HOLDBALANCE,PENDINGHOLD,PENDINGUNHOLD,COREBANK,RECEIVING,NETTING,MBLOCK,mrtype,PP,PPREF,AVLLIMIT,DEALLIMIT,
                NAVACCOUNT,OUTSTANDING,SE_NAVACCOUNT,SE_OUTSTANDING,MRIRATE,
                TRUNC(
                    GREATEST(
                        (CASE WHEN MRIRATE>0 THEN least(NAVACCOUNT*100/MRIRATE + (OUTSTANDING-ADVANCELINE),AVLLIMIT-ADVANCELINE) ELSE NAVACCOUNT + OUTSTANDING END)
                    ,0)
                ,0) AVLWITHDRAW,
                --Neu co bao lanh T0 thi khong duoc rut
                greatest(case when isChkSysCtrlDefault = 'Y' then
                    least(
                        (MARGINRATE74/100 - MRIRATIO/100) * sereal + greatest(0,balance+nvl(bamt,0)+nvl(avladvance,0)-ovamt-dueamt/*-depofeeamt*/)
                        ,
                       TRUNC(
                        (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING-ADVANCELINE) * MRIRATE)/MRIRATE,0),BALDEFOVD,AVLLIMIT-ADVANCELINE) ELSE BALDEFOVD END)
                    ,0))
                else
                    TRUNC(
                        (CASE WHEN MRIRATE>0  THEN LEAST(GREATEST((100* NAVACCOUNT + (OUTSTANDING-ADVANCELINE) * MRIRATE)/MRIRATE,0),BALDEFOVD,AVLLIMIT-ADVANCELINE) ELSE BALDEFOVD END)
                    ,0)
                end,0) BALDEFOVD,
                baldefovd_Released,
                DFDEBTAMT, dfintdebtamt,
                TRUNC
                ((CASE
                     WHEN mrirate > 0
                        THEN LEAST (GREATEST (  (  100 * navaccount
                                                 +   (  outstanding /*+ depofeeamt */- advanceline
                                                     )
                                                   * mrirate
                                                )
                                              / mrirate,
                                              0
                                             ),
                                    baldefovd /*+ depofeeamt*/,
                                    avllimit /*+ depofeeamt */- advanceline
                                   )
                     ELSE baldefovd /*+ depofeeamt*/
                  END
                 )  ,
                 0
                ) Baldefovd_Released_Depofee,  -- Su dung de check khi thu phi luu ky
                avladvance, advanceamount, paidamt, SEASS, SEAMT,MARGINRATE, execbuyamt,BANKBALANCE,BANKAVLBAL,
                tdbalance,
                TDINTAMT,TDODAMT,TDODINTACR,
                case when (mrlrate <= marginrate AND marginrate < mrmrate) then
                     greatest(round((case when nvl(marginrate,0) * mrmrate =0 then - nvl(se_outstanding,0)
                            else greatest( 0,- nvl(se_outstanding,0) - nvl(se_navaccount,0) *100/mrmrate) end),0),0)
                else 0 end  CALLAMT,
                case when (marginrate<mrlrate) or dueamt + ovamt>1 then
                    round(greatest(round((case when marginrate*mrmrate =0 then - se_outstanding else
                                            greatest( 0,- se_outstanding - se_navaccount *100/mrmrate) end),0),
                                     greatest(ovamt + dueamt  - greatest(balance + nvl(avladvance,0)/* -depofeeamt*/,0) ,0)
                                   )
                         ,0)
                else 0 end addamt,
                rcvamt,rcvadvamt
                FROM
                    (SELECT cidepofeeacr, af.advanceline,ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                        ci.balance-nvl(se.secureamt,0) - ci.trfbuyamt balance, ci.DFDEBTAMT,
                        ci.cramt,ci.dramt,ci.crintacr,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                        nvl(se.secureamt,0) + ci.trfbuyamt bamt,
                        ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                        ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                        ci.pendinghold,ci.pendingunhold,ci.corebank,ci.receiving,ci.netting,ci.mblock, ci.dfintdebtamt,
                        greatest(
                             nvl(se.avladvance,0) + balance - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt /*- ci.depofeeamt*/
                             ,0) BALDEFOVD,
                        greatest(ci.balance - nvl(se.secureamt,0) -ci.trfbuyamt + nvl(se.avladvance,0) - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - af.advanceline,0) BALDEFOVD_RLSODAMT ,
                        greatest(round(least(nvl(se.avladvance,0) + balance ,nvl(se.avladvance,0) + balance  + af.advanceline -NVL (se.advamt, 0)-nvl(se.secureamt,0) -ci.trfbuyamt-ramt),0) ,0) baldefovd_released,
                        round(ci.balance - nvl(se.secureamt,0) -ci.trfbuyamt
                                 + nvl(se.avladvance,0) + least(nvl(se.mrcrlimitmax,0)+nvl(af.mrcrlimit,0) - dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt  /*- ci.depofeeamt*/,0)
                            PP,
                        round(ci.balance + nvl(ci.BANKAVLBAL,0) - nvl(se.secureamt,0)  -ci.trfbuyamt
                                 + nvl(se.avladvance,0) + least(nvl(se.mrcrlimitmax,0)+nvl(af.mrcrlimit,0) - dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0)) - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt  /*- ci.depofeeamt*/,0)
                            PPREF,
                        round(
                            nvl(se.avladvance,0) + nvl(af.advanceline,0) + nvl(se.mrcrlimitmax,0)- dfodamt + balance +nvl(af.mrcrlimit,0)- odamt - ci.dfdebtamt - ci.dfintdebtamt - nvl(se.secureamt,0) -ci.trfbuyamt - ramt /*- ci.depofeeamt*/
                        ,0) AVLLIMIT,
                        greatest(least(nvl(se.mrcrlimitmax,0) - dfodamt,
                                nvl(se.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt),0) deallimit,
                        least(nvl(se.SEASS,0),nvl(SE.mrcrlimitmax,0) - dfodamt) NAVACCOUNT,
                        nvl(af.advanceline,0) + ci.balance+LEAST(nvl(af.mrcrlimit,0),nvl(se.secureamt,0) + ci.trfbuyamt) + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - NVL (se.advamt, 0)-nvl(se.secureamt,0) -ci.trfbuyamt - ci.ramt OUTSTANDING, --kHI DAT LENH THI THEM PHAN T0
                        af.mrirate,af.mrmrate,af.mrlrate,
                        se.chksysctrl,
                        nvl(se.avladvance,0) avladvance, nvl(se.advanceamount,0) advanceamount, nvl(se.paidamt,0) paidamt,
                        nvl(se.SEASS,0) SEASS,nvl(se.SEAMT,0) SEAMT, nvl(margin74amt,0) margin74amt, nvl(sereal,0) sereal,
                        af.MRIRATIO, nvl(MARGINRATE74,0) MARGINRATE74, depofeeamt, ci.dueamt, ci.ovamt, af.isMarginAcc, AF.isChkSysCtrlDefault, mr.actype mrtype,
                        nvl(se.execbuyamt,0) execbuyamt,ci.BANKBALANCE,ci.BANKAVLBAL,
                        nvl(se.rcvamt,0) rcvamt, --Tien cho ve tru phi thue
                        nvl(se.aamt,0) rcvadvamt, --Tien dang ung truoc
                        nvl(td.tdbalance,0) tdbalance,
                        nvl(td.TDINTAMT,0) TDINTAMT,
                        nvl(td.TDODAMT,0) TDODAMT,
                        nvl(td.TDODINTACR,0) TDODINTACR,
                        se.MARGINRATE,
                        nvl(se.navaccount,0) se_navaccount,
                        nvl(se.outstanding,0) se_outstanding
                   from cimast ci,
                        ( SELECT af.*,
                            CASE WHEN (exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y')
                                        or exists (select 1 from afidtype afi, lntype lnt where afi.aftype = af.actype and afi.objname = 'LN.LNTYPE' and afi.actype = lnt.actype and lnt.chksysctrl = 'Y'))
                                    THEN 'Y' ELSE 'N' END isMarginAcc,
                            CASE WHEN exists (select 1 from aftype aft, lntype lnt where aft.actype = af.actype and aft.lntype = lnt.actype and lnt.chksysctrl = 'Y')
                                    THEN 'Y' ELSE 'N' END isChkSysCtrlDefault
                            from afmast af
                        ) af,
                        aftype aft, mrtype mr,
                        (select * from v_getsecmarginratio) se,
                        (select * from v_getsecmarginratio_74) se74,
                        (select TRFACCTNO, nvl(sum(ln.PRINOVD + ln.INTOVDACR + ln.INTNMLOVD + ln.OPRINOVD + ln.OPRINNML + ln.OINTNMLOVD + ln.OINTOVDACR+ln.OINTDUE+ln.OINTNMLACR + nvl(lns.nml,0) + nvl(lns.intdue,0)),0) OVDAMT,
                                                       nvl(sum(ln.PRINNML - nvl(nml,0)+ ln.INTNMLACR),0) NMLMARGINAMT,
                                            nvl(sum(decode(lnt.chksysctrl,'Y',1,0)*(ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intdue+ln.intovdacr+ln.intnmlovd+ln.feeintnmlacr+ln.feeintdue+ln.feeintovdacr+ln.feeintnmlovd)),0) margin74amt
                                        from lnmast ln, lntype lnt, (select acctno, sum(nml) nml, sum(intdue) intdue  from lnschd
                                                            where reftype = 'P' and  overduedate = to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR') group by acctno) lns
                                        where ln.actype = lnt.actype and ln.acctno = lns.acctno(+) and ln.ftype = 'AF'
                                        group by ln.trfacctno) OVDAF,
                        (select afacctno, sum(amt) receivingamt from stschd
                            where duetype = 'RM' and status <> 'C' and deltd <> 'Y' group by afacctno) sts_rcv,
                        (select (100 - to_number(varvalue))/100 trfbuyrate from sysvar where grname = 'SYSTEM' and varname = 'TRFBUYRATE') trfr,
                        (select mst.afacctno, sum(MST.BALANCE) TDBALANCE,
                                    sum(FN_TDMASTINTRATIO(MST.ACCTNO,getcurrdate,
                                                    MST.BALANCE)) TDINTAMT, sum(ODAMT) TDODAMT, sum(ODINTACR) TDODINTACR
                                from tdmast mst
                                where  MST.DELTD<>'Y' AND MST.status in ('N','A')
                                group by mst.afacctno) td
                   WHERE ci.acctno = af.acctno
                     and   af.actype = aft.actype
                     AND aft.mrtype = mr.actype
                     and mr.mrtype  in   ('S','T')
                     AND (LENGTH (af.groupleader) = 0 OR af.groupleader IS NULL)
                     and ci.acctno= se.afacctno(+)
                     and ci.acctno= se74.afacctno(+)
                     and   ci.acctno= OVDAF.TRFACCTNO (+)
                     AND ci.acctno = sts_rcv.afacctno (+)
                     and  ci.acctno= td.afacctno(+)
                 )
/
