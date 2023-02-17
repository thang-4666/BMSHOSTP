SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW VW_GENBUFCI
(CUSTODYCD, ACTYPE, AFACCTNO, DESC_STATUS, LASTDATE, 
 BALANCE, INTBALANCE, DFDEBTAMT, CRINTACR, AAMT, 
 BAMT, EMKAMT, FLOATAMT, ODAMT, RECEIVING, 
 NETTING, AVLADVANCE, MBLOCK, APMT, PAIDAMT, 
 ADVANCELINE, ADVLIMIT, MRIRATE, MRMRATE, MRLRATE, 
 DEALPAIDAMT, AVLWITHDRAW, BALDEFOVD, PP, AVLLIMIT, 
 NAVACCOUNT, OUTSTANDING, SE_NAVACCOUNT, SE_OUTSTANDING, MARGINRATE, 
 CIDEPOFEEACR, OVDCIDEPOFEE, CASH_RECEIVING_T0, CASH_RECEIVING_T1, CASH_RECEIVING_T2, 
 CASH_RECEIVING_T3, CASH_RECEIVING_TN, CASH_SENDING_T0, CASH_SENDING_T1, CASH_SENDING_T2, 
 CASH_SENDING_T3, CASH_SENDING_TN, CAREBY, MRODAMT, T0ODAMT, 
 DFODAMT, ACCOUNTTYPE, EXECBUYAMT, AUTOADV, AVLADV_T3, 
 AVLADV_T1, AVLADV_T2, CASH_PENDWITHDRAW, CASH_PENDTRANSFER, CASH_PENDING_SEND, 
 PPREF, BALDEFTRFAMT, CASHT2_SENDING_T0, CASHT2_SENDING_T1, CASHT2_SENDING_T2, 
 SUBCOREBANK, BANKBALANCE, BANKAVLBAL, SEAMT, SEASS, 
 TRFBUY_T0, TRFBUY_T1, TRFBUY_T2, TRFBUY_T3, TDBALANCE, 
 TDINTAMT, TDODAMT, TDODINTACR, CALLAMT, ADDAMT, 
 RCVAMT, RCVADVAMT, TRFBUYAMT, MRCRLIMIT, BANKINQIRYDT, 
 CASH_RECEIVING_T1_CLDRD1, CLAMTLIMIT, DCLAMTLIMIT)
BEQUEATH DEFINER
AS 
select cf.custodycd, ci.actype, ci.acctno afacctno,cd1.cdcontent desc_status,
                   ci.lastdate, ci.balance  - nvl (secureamt, 0) - ci.trfbuyamt balance,
                   ci.balance intbalance, dfdebtamt, ci.crintacr,ci.aamt,  nvl (secureamt, 0) + ci.trfbuyamt bamt,
                   ci.emkamt,ci.floatamt, ci.odamt,ci.receiving,ci.netting,nvl(adv.advanceamount,0) avladvance,
                   ci.mblock,nvl(adv.advanceamount,0) apmt, nvl(adv.paidamt,0) paidamt,
                   af.advanceline,nvl(af.mrcrlimitmax,0) advlimit, af.mrirate,af.mrmrate,af.mrlrate,
                    0 dealpaidamt,
                   greatest(
                        nvl(adv.avladvance,0) + balance - ci.buysecamt
                        - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - nvl (overamt, 0) - nvl(secureamt,0)+least(af.mrcrlimit,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0)- ci.depofeeamt-ceil(ci.cidepofeeacr)
                        ,0) avlwithdraw,
                   greatest(
                        nvl(adv.avladvance,0) + balance - ci.buysecamt
                        - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - nvl (overamt, 0) - nvl(secureamt,0)+least(af.mrcrlimit,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0)- ci.depofeeamt-ceil(ci.cidepofeeacr)
                        ,0) baldefovd,
                    round(
                    nvl(adv.avladvance,0) + nvl(balance ,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - nvl (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline - nvl(ramt,0) +af.clamtlimit/*- ci.depofeeamt*/ + least(af.mrcrlimitmax + af.mrcrlimit- ci.dfodamt,af.mrcrlimit)
                    ,0) pp,
                       nvl(adv.avladvance,0)
                   + af.mrcrlimitmax +af.mrcrlimit - dfodamt
                   + af.advanceline
                   + balance
                   - odamt
                   - dfdebtamt
                   - dfintdebtamt
                   - nvl (overamt, 0)
                   - nvl (secureamt, 0) - ci.trfbuyamt
                   - ramt
                   /*- ci.depofeeamt
                   -ci.cidepofeeacr*/ avllimit,
                  0 navaccount, 0 outstanding,0  se_navaccount, 0 se_outstanding,
                  100000 marginrate,ci.cidepofeeacr,  nvl(ci.depofeeamt,0) ovdcidepofee,
                   nvl(cash_receiving_t0,0) cash_receiving_t0,
                    nvl(cash_receiving_t1,0) cash_receiving_t1,
                    nvl(cash_receiving_t2,0) cash_receiving_t2,
                    nvl(cash_receiving_t3,0) cash_receiving_t3,
                    nvl(cash_receiving_tn,0) cash_receiving_tn,
                    nvl(cash_sending_t0,0) cash_sending_t0,
                    nvl(cash_sending_t1,0) cash_sending_t1,
                    nvl(cash_sending_t2,0)  cash_sending_t2,
                    nvl(cash_sending_t3,0) cash_sending_t3,
                    nvl(cash_sending_tn,0) cash_sending_tn,
                    af.careby,
                     nvl(ln.mrodamt,0) mrodamt,nvl(ln.t0odamt,0) t0odamt,nvl(dfg.dfamt,0) dfodamt,
                    (case when cf.custatcom ='N' then 'O' when af.corebank ='Y' then 'B' else 'C' end) accounttype,
                   nvl(b.execbuyamt,0) execbuyamt,
                   af.autoadv, nvl(st.avladv_t3,0) avladv_t3, nvl(st.avladv_t1,0) avladv_t1,
                   nvl(st.avladv_t2,0) avladv_t2, nvl(pw.pdwithdraw,0) cash_pendwithdraw, nvl(pdtrf.pdtrfamt,0) cash_pendtransfer,
                   nvl (secureamt, 0) + ci.trfbuyamt -- ky quy + tra cham /*+nvl (al.advamt,0)*/
                        + nvl(cash_sending_t0,0)+nvl(cash_sending_t1,0)+nvl(cash_sending_t2,0) -- cho giao qua ngay
                        - ci.trfamt -- tra cham (vi cho giao qua ngay da bao gom tra cham)
                        + nvl(st.buy_feeacr,0)
                        - nvl(st.execamtinday,0)+nvl(pw.pdwithdraw,0)+nvl(pdtrf.pdtrfamt,0) cash_pending_send,

                    round(
                    nvl(adv.avladvance,0) + nvl(balance ,0) + nvl(bankavlbal,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - nvl (advamt, 0)- nvl(secureamt,0) - ci.trfbuyamt + advanceline - nvl(ramt,0)+af.clamtlimit /*- ci.depofeeamt*/ + least(af.mrcrlimitmax + af.mrcrlimit - ci.dfodamt,af.mrcrlimit)
                    ,0) ppref,
                    greatest(
                        nvl(adv.avladvance,0) + balance - ci.buysecamt
                        - ovamt - dueamt - ci.dfdebtamt - ci.dfintdebtamt - nvl (overamt, 0) - nvl(secureamt,0)+least(af.mrcrlimit,nvl(secureamt,0)+ ci.trfbuyamt) - ci.trfbuyamt - ramt-nvl(pd.dealpaidamt,0)- ci.depofeeamt-ceil(ci.cidepofeeacr)
                        ,0) baldeftrfamt,
                    0 casht2_sending_t0,
                    0 casht2_sending_t1,
                    0 casht2_sending_t2,
                    af.alternateacct subcorebank,
                    ci.bankbalance,ci.bankavlbal,
                     0 seamt,0 seass,

                    nvl(trf.trfbuy_t0,0) trfbuy_t0, nvl(trf.trfbuy_t1,0) trfbuy_t1, nvl(trf.trfbuy_t2,0) trfbuy_t2, nvl(trf.trfbuy_t3,0) trfbuy_t3,
                     nvl(td.tdbalance,0) tdbalance,nvl(td.tdintamt,0) tdintamt
                     , nvl(td.tdodamt,0) tdodamt, nvl(td.tdodintacr,0) tdodintacr,
                   0  callamt,  greatest(-(nvl(adv.avladvance,0) + nvl(balance ,0) - nvl(odamt,0) - nvl(dfdebtamt,0) - nvl(dfintdebtamt,0) - nvl (advamt, 0)
                            - nvl(secureamt,0) - ci.trfbuyamt  - nvl(ramt,0) /*- ci.depofeeamt*/
                            + least(af.mrcrlimitmax + af.mrcrlimit- ci.dfodamt,af.mrcrlimit)),0) addamt,
                   nvl(adv.rcvamt,0) rcvamt, nvl(adv.aamt,0) rcvadvamt,
                    ci.trfbuyamt, af.mrcrlimit, ci.bankinqirydt,
                    nvl(cash_receiving_t1_cldrd1,0) cash_receiving_t1_cldrd1,af.clamtlimit,  GREATEST(LEAST(nvl(b.secureamt,0) -
                                 GREATEST( ci.balance + af.advanceline +  nvl(adv.avladvance,0)+
                                           + LEAST(nvl(af.MRCRLIMIT,0),nvl(b.secureamt,0) + ci.trfbuyamt)
                                         ,0)
                         , af.clamtlimit)  ,0) Dclamtlimit
          from cimast ci
                   inner join afmast af on ci.acctno = af.acctno
                   inner join aftype aft on af.actype=aft.actype
                   inner join mrtype mrt on aft.mrtype=mrt.actype
                   inner join cfmast cf on ci.custid = cf.custid
                   inner join (select * from allcode cd1  where cd1.cdtype = 'CI' and cd1.cdname = 'STATUS') cd1 on ci.status = cd1.cdval
                   left join (select *
                                from v_getbuyorderinfo
                               ) b
                               on ci.acctno = b.afacctno
                   left join
                            (select sum(depoamt) avladvance,afacctno, sum(advamt) advanceamount, sum(paidamt) paidamt, sum(rcvamt) rcvamt, sum(aamt) aamt
                                from v_getaccountavladvance
                                group by afacctno) adv
                                on adv.afacctno=ci.acctno
                   left join
                            (select *
                                from v_getdealpaidbyaccount p
                              ) pd
                            on pd.afacctno=ci.acctno
                    left join
                            (select mst.afacctno, sum(mst.balance) tdbalance,
                                    sum(fn_tdmastintratio(mst.acctno,getcurrdate,
                                                    mst.balance)) tdintamt, sum(odamt) tdodamt, sum(odintacr) tdodintacr
                                from tdmast mst
                                where  mst.deltd<>'Y' and mst.status in ('N','A')
                                group by mst.afacctno) td
                            on td.afacctno = ci.acctno

            left join
                    (select afacctno,
                                sum(nvl(case when st.duetype='RM' and st.rday=0 then st.st_amt else 0 end,0)) cash_receiving_t0,
                                sum(nvl(case when st.duetype='RM' and st.rday=1 then st.st_amt else 0 end,0)) cash_receiving_t1,
                                sum(nvl(case when st.duetype='RM' and st.rday=2 then st.st_amt else 0 end,0)) cash_receiving_t2,
                                sum(nvl(case when st.duetype='RM' and st.rday=3 then st.st_amt else 0 end,0)) cash_receiving_t3,
                                sum(nvl(case when st.duetype='RM' and st.rday>3 then st.st_amt else 0 end,0)) cash_receiving_tn,
                                sum(nvl(case when st.duetype='RS' and st.trfday=0 then st.st_amt else 0 end,0)) cash_sending_t0,
                                sum(nvl(case when st.duetype='RS' and st.trfday=1 then st.st_amt else 0 end,0)) cash_sending_t1,
                                sum(nvl(case when st.duetype='RS' and st.trfday=2 then st.st_amt else 0 end,0)) cash_sending_t2,
                                sum(nvl(case when st.duetype='RS' and st.trfday=3 then st.st_amt else 0 end,0)) cash_sending_t3,
                                sum(nvl(case when st.duetype='RS' and st.trfday>3 then st.st_amt else 0 end,0)) cash_sending_tn,
                                sum(nvl(case when st.duetype='RS' and st.trfday>=1 and st.trfday<=3 and st.txdate < st.currdate then st.feeacr else 0 end,0)) buy_feeacr,
                                sum(nvl(case when st.duetype='RS' and st.trfday=1 then st.execamtinday else 0 end,0)) execamtinday,
                                sum(case when st.duetype='RM' and st.tday=2 then st.st_amt-st.st_aamt-st.st_famt+st.st_paidamt+st.st_paidfeeamt-st.feeacr-st.taxsellamt else 0 end) avladv_t1,
                                sum(case when st.duetype='RM' and st.tday=1 then st.st_amt-st.st_aamt-st.st_famt+st.st_paidamt+st.st_paidfeeamt-st.feeacr-st.taxsellamt else 0 end) avladv_t2,
                                sum(case when st.duetype='RM' and st.tday=0 then st.st_amt-st.st_aamt-st.st_famt+st.st_paidamt+st.st_paidfeeamt-st.feeacr-st.taxsellamt else 0 end) avladv_t3,--,
                                --sum(nvl(case when st.duetype='sm' and st.ist2 = 'y' and st.t2dt = 0 then st.st_amt else 0 end,0)) casht2_sending_t0,
                                --sum(nvl(case when st.duetype='sm' and st.ist2 = 'y' and st.t2dt = 1 then st.st_amt else 0 end,0)) casht2_sending_t1,
                                --sum(nvl(case when st.duetype='sm' and st.ist2 = 'y' and st.t2dt = 2 then st.st_amt else 0 end,0)) casht2_sending_t2
                             sum(nvl(case when st.duetype='RM' and st.rday=1 and st.clearday=1 then st.st_amt else 0 end,0)) cash_receiving_t1_cldrd1
                        from   vw_bd_pending_settlement st where (duetype='RM' or duetype='SM' or duetype = 'RS')
                        group by afacctno) st
                    on st.afacctno=ci.acctno
               left join
                        (select     df.afacctno, sum(
                                ln.prinnml + ln.prinovd + round(ln.intnmlacr,0) + round(ln.intovdacr,0) +
                                round(ln.intnmlovd,0)+round(ln.intdue,0)+
                                ln.oprinnml+ln.oprinovd+round(ln.ointnmlacr,0)+round(ln.ointovdacr,0)+round(ln.ointnmlovd,0) +
                                round(ln.ointdue,0)+round(ln.fee,0)+round(ln.feedue,0)+round(ln.feeovd,0) +
                                round(ln.feeintnmlacr,0) + round(ln.feeintovdacr,0) +round(ln.feeintnmlovd,0)+round(ln.feeintdue,0)
                                ) dfamt
                         from dfgroup df, lnmast ln
                        where df.lnacctno = ln.acctno
                        group by afacctno) dfg
                        on dfg.afacctno=ci.acctno
                    left join
                        (
                        select trfacctno afacctno,
                            sum(ln.prinnml + ln.prinovd + ln.intnmlacr + ln.intovdacr + ln.intnmlovd+ln.intdue
                                + ln.fee+ln.feedue+ln.feeovd+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd+ln.feeintdue+ln.feefloatamt) mrodamt,
                            sum(ln.oprinnml+ln.oprinovd+ln.ointnmlacr+ln.ointovdacr+
                            ln.ointnmlovd+ln.ointdue) t0odamt
                            from lnmast ln
                            where ftype ='AF'
                                and ln.prinnml + ln.prinovd + ln.intnmlacr + ln.intovdacr +
                                    ln.intnmlovd+ln.intdue + ln.oprinnml+ln.oprinovd+ln.ointnmlacr+ln.ointovdacr+
                                    ln.ointnmlovd+ln.ointdue >0
                            group by trfacctno
                        ) ln
                 on ln.afacctno=ci.acctno
                  left join
                     (
                         select tl.msgacct, sum(tl.msgamt) pdwithdraw
                         from tllog tl
                         where tl.tltxcd in ('1100','1121','1110','1144','1199','1107','1108','1110','1131','1132') and tl.txstatus = '4' and tl.deltd = 'N'
                         group by tl.msgacct
                     ) pw
                     on ci.acctno = pw.msgacct
                     left join
                     (
                         select cir.acctno, sum(amt+feeamt) pdtrfamt
                         from ciremittance cir
                         where cir.rmstatus = 'P' and cir.deltd = 'N'
                         group by cir.acctno
                     ) pdtrf
                     on ci.acctno = pdtrf.acctno
                      left join
                  (select * from vw_gettrfbuyamt_byday ) trf
                   on ci.acctno = trf.afacctno
              where mrt.mrtype='N'

    UNION

     select
     custodycd, actype,  afacctno, desc_status,
     lastdate,  balance,intbalance,dfdebtamt,crintacr,aamt,bamt,emkamt,floatamt,odamt,receiving,netting,advanceamount avladvance,
     mblock,advanceamount apmt,paidamt,advanceline ,mrcrlimitmax advlimit,mrirate,mrmrate,mrlrate,
      0 dealpaidamt,
     trunc(  greatest(
                        (case when mrirate>0  then least(greatest((100* navaccount + (outstanding_hold_depofee-advanceline) * mrirate)/mrirate,0),baldefovd,avllimit-advanceline) else baldefovd end)
                    ,0)
                ,0) avlwithdraw,
     trunc(
              greatest(
                        (case when mrirate>0  then least(greatest((100* navaccount + (outstanding_hold_depofee-advanceline) * mrirate)/mrirate,0),baldefovd,avllimit-advanceline) else baldefovd end)
                    ,0)
                ,0) baldefovd, pp, avllimit,navaccount,outstanding, se_navaccount, se_outstanding,
      marginrate ,cidepofeeacr ,nvl(depofeeamt,0) ovdcidepofee,
      nvl(cash_receiving_t0,0) cash_receiving_t0,
     cash_receiving_t1, cash_receiving_t2, cash_receiving_t3, cash_receiving_tn, cash_sending_t0,
     cash_sending_t1,  cash_sending_t2, cash_sending_t3, cash_sending_tn,careby,
     mrodamt, t0odamt, dfodamt, accounttype, execbuyamt, autoadv,  avladv_t3, avladv_t1,
     avladv_t2,  pdwithdraw  cash_pendwithdraw, pdtrfamt cash_pendtransfer,
      cash_pending_send,
                    ppref,  trunc(  greatest(
                        (case when mrirate>0  then least(greatest((100* navaccount + (outstanding_hold_depofee-advanceline) * mrirate)/mrirate,0),baldefovd,avllimit-advanceline) else baldefovd end)
                    ,0)
                ,0) baldeftrfamt,
                    0 casht2_sending_t0,
                    0 casht2_sending_t1,
                    0 casht2_sending_t2,
                    alternateacct subcorebank,
                    bankbalance,bankavlbal,
                    seamt,seass,
                     trfbuy_t0,  trfbuy_t1, trfbuy_t2, trfbuy_t3,
                    tdbalance,tdintamt,tdodamt,tdodintacr,

               case when (mrlrate <= marginrate and marginrate < mrmrate) then
                     greatest(round((case when nvl(marginrate,0) * mrmrate =0 then - nvl(se_outstanding,0)
                            else greatest( 0,- nvl(se_outstanding,0) - nvl(se_navaccount,0) *100/mrmrate) end),0),0)
                else 0 end     callamt,case when (marginrate<mrlrate) or dueamt + ovamt>1 then
                    round(greatest(round((case when marginrate*mrmrate =0 then - se_outstanding else
                                            greatest( 0,- se_outstanding - se_navaccount *100/mrmrate) end),0),
                                     greatest(ovamt + dueamt - greatest(balance + nvl(avladvance,0)/* - depofeeamt*/,0),0)
                                   )
                         ,0)
                else 0 end addamt,
                rcvamt, rcvadvamt,  trfbuyamt, mrcrlimit,bankinqirydt,
                   cash_receiving_t1_cldrd1,clamtlimit,dclamtlimit

                from
                    (select cf.custodycd,cd1.cdcontent desc_status, cidepofeeacr, af.advanceline,ci.actype,ci.acctno,ci.ccycd,ci.afacctno,ci.custid,ci.opndate,ci.clsdate,ci.lastdate,ci.dormdate,ci.status,ci.pstatus,
                   balance   intbalance,
                        ci.balance -nvl(se.secureamt,0) - ci.trfbuyamt balance,
                        ci.balance  + nvl(se.avladvance,0) avlbal,
                        ci.dfdebtamt,
                        ci.cramt,ci.dramt,ci.crintacr,ci.crintdt,ci.odintacr,ci.odintdt,ci.avrbal,ci.mdebit,ci.mcredit,ci.aamt,ci.ramt,
                        nvl(se.secureamt,0) + ci.trfbuyamt bamt,
                        ci.emkamt,ci.mmarginbal,ci.marginbal,ci.iccfcd,ci.iccftied,ci.odlimit,ci.adintacr,ci.adintdt,
                        ci.facrtrade,ci.facrdepository,ci.facrmisc,ci.minbal,ci.odamt,ci.namt,ci.floatamt,ci.holdbalance,
                        ci.pendinghold,ci.pendingunhold,
                        ci.corebank,
                        (case when ci.corebank = 'Y' then ci.corebank else af.alternateacct end) allowcorebank,
                        ci.receiving,ci.netting,ci.mblock, ci.dfintdebtamt,
                        greatest(
                             nvl(se.avladvance,0) + balance - ci.buysecamt - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt - ci.depofeeamt-ceil(ci.cidepofeeacr)
                             ,0) baldefovd,

                        nvl(se.avladvance,0) + balance - ci.buysecamt - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt
                        baldefovd_released_depofee,
                        greatest(ci.balance - ci.buysecamt - nvl(se.secureamt,0) - ci.trfbuyamt + nvl(se.avladvance,0) - ci.dfdebtamt - ci.dfintdebtamt - ci.depofeeamt-ceil(ci.cidepofeeacr) - af.advanceline,0) baldefovd_rlsodamt ,
                        greatest(round(least(nvl(se.avladvance,0) + balance - ci.buysecamt ,nvl(se.avladvance,0) + balance - ci.buysecamt  + af.advanceline -nvl (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt -ramt),0) ,0) baldefovd_released,
                        round(ci.balance  - nvl(se.secureamt,0) - ci.trfbuyamt - nvl(se.overamt,0) + nvl(se.avladvance,0) + af.advanceline
                            + least(nvl(se.mrcrlimitmax,0)+ nvl(af.mrcrlimit,0)  - dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0))
                            - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt+af.clamtlimit  /*- ci.depofeeamt*/,0)
                            pp,
                        round(ci.balance  + nvl(bankavlbal,0) - nvl(se.secureamt,0) - ci.trfbuyamt - nvl(se.overamt,0) + nvl(se.avladvance,0) + af.advanceline
                                 + least(nvl(se.mrcrlimitmax,0) + nvl(af.mrcrlimit,0)- dfodamt,nvl(af.mrcrlimit,0) + nvl(se.seamt,0))
                            - nvl(ci.odamt,0) - ci.dfdebtamt - ci.dfintdebtamt - ramt +af.clamtlimit  /*- ci.depofeeamt*/,0)
                            ppref, -- luon luon ban pp khi ko tra cham
                        round(
                            nvl(se.avladvance,0) + nvl(af.advanceline,0) + nvl(se.mrcrlimitmax,0) + nvl(af.mrcrlimit,0)- dfodamt + balance  - odamt - ci.dfdebtamt - ci.dfintdebtamt - nvl(se.secureamt,0) - ci.trfbuyamt - ramt /*- ci.depofeeamt-ceil(ci.cidepofeeacr)*/
                        ,0) avllimit,
                        greatest(least(nvl(se.mrcrlimitmax,0) - dfodamt,
                                nvl(se.mrcrlimitmax,0) - dfodamt + nvl(af.advanceline,0) -odamt),0) deallimit,
                        least( nvl(se.seass,0),nvl(se.mrcrlimitmax,0) - dfodamt) navaccount,
                        nvl(af.advanceline,0) + ci.balance  + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt /*- ci.depofeeamt*/ - nvl (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt+ least(af.mrcrlimit,nvl(se.secureamt,0) + ci.trfbuyamt) - ci.ramt outstanding, --khi dat lenh thi them phan t0
                                                nvl(af.advanceline,0) + ci.balance  + nvl(se.avladvance,0)- ci.odamt - ci.dfdebtamt - ci.dfintdebtamt - ci.depofeeamt-ceil(ci.cidepofeeacr) - nvl (se.advamt, 0)-nvl(se.secureamt,0) - ci.trfbuyamt+ least(af.mrcrlimit,nvl(se.secureamt,0) + ci.trfbuyamt) - ci.ramt outstanding_hold_depofee, --khi dat lenh thi them phan t0
                        af.mrirate,af.mrmrate,af.mrlrate,
                        se.chksysctrl,
                        nvl(se.avladvance,0) avladvance, nvl(se.advanceamount,0) advanceamount, nvl(se.paidamt,0) paidamt,
                        nvl(se.seass,0) seass, nvl(se.seamt,0) seamt, nvl(margin74amt,0) margin74amt,
                        af.mriratio, depofeeamt, ci.dueamt, ci.ovamt, nvl(se.execbuyamt,0) execbuyamt,
                        ci.bankbalance,ci.bankavlbal,
                        nvl(se.rcvamt,0) rcvamt, --tien cho ve tru phi thue
                        nvl(se.aamt,0) rcvadvamt, --tien dang ung truoc
                        nvl(td.tdbalance,0) tdbalance,
                       nvl(td.tdintamt,0) tdintamt,
                       nvl(td.tdodamt,0) tdodamt,
                       nvl(td.tdodintacr,0) tdodintacr,
                       se.marginrate,
                       nvl(se.navaccount,0) se_navaccount,
                       nvl(se.outstanding,0) se_outstanding,
                       greatest(
                          balance - ci.buysecamt - ci.ovamt - ci.dueamt - ci.dfdebtamt - ci.dfintdebtamt - ramt - ci.depofeeamt-ceil(ci.cidepofeeacr)
                             ,0) baldefovd_released_adv,
                             af.mrcrlimitmax,
                             nvl(cash_receiving_t0,0) cash_receiving_t0,
                    nvl(cash_receiving_t1,0) cash_receiving_t1,
                    nvl(cash_receiving_t2,0) cash_receiving_t2,
                    nvl(cash_receiving_t3,0) cash_receiving_t3,
                    nvl(cash_receiving_tn,0) cash_receiving_tn,
                    nvl(cash_sending_t0,0) cash_sending_t0,
                    nvl(cash_sending_t1,0) cash_sending_t1,
                    nvl(cash_sending_t2,0)  cash_sending_t2,
                    nvl(cash_sending_t3,0) cash_sending_t3,
                    nvl(cash_sending_tn,0) cash_sending_tn,cf.careby,
                    nvl(ln.mrodamt,0) mrodamt,nvl(ln.t0odamt,0) t0odamt,nvl(dfg.dfamt,0) dfodamt,
                    (case when cf.custatcom ='N' then 'O' when af.corebank ='Y' then 'B' else 'C' end) accounttype,
                    af.autoadv, nvl(st.avladv_t3,0) avladv_t3, nvl(st.avladv_t1,0) avladv_t1,
                    nvl(st.avladv_t2,0) avladv_t2, nvl(pw.pdwithdraw,0) pdwithdraw, nvl(pdtrf.pdtrfamt,0) pdtrfamt,
                    nvl(se.secureamt,0) + ci.trfbuyamt -- ky quy + tra cham /*+nvl (al.advamt,0)*/
                        + nvl(cash_sending_t0,0)+nvl(cash_sending_t1,0)+nvl(cash_sending_t2,0) -- cho giao qua ngay
                        - ci.trfamt -- tra cham (vi cho giao qua ngay da bao gom tra cham)
                        + nvl(st.buy_feeacr,0)
                        - nvl(st.execamtinday,0)+nvl(pw.pdwithdraw,0)+nvl(pdtrf.pdtrfamt,0) cash_pending_send,
                        alternateacct,
                 nvl(trf.trfbuy_t0,0) trfbuy_t0, nvl(trf.trfbuy_t1,0) trfbuy_t1, nvl(trf.trfbuy_t2,0) trfbuy_t2, nvl(trf.trfbuy_t3,0) trfbuy_t3,
                  ci.trfbuyamt, af.mrcrlimit, ci.bankinqirydt,
                    nvl(cash_receiving_t1_cldrd1,0) cash_receiving_t1_cldrd1,af.clamtlimit,se.dclamtlimit

                   from cimast ci
                   inner join afmast af on ci.acctno=af.acctno
                   inner join aftype aft on af.actype=aft.actype
                   inner join mrtype mrt on aft.mrtype=mrt.actype
                   inner join cfmast cf on ci.custid=cf.custid
                   inner join (select * from allcode cd1  where cd1.cdtype = 'CI' and cd1.cdname = 'STATUS') cd1 on ci.status = cd1.cdval
                   left join (select * from v_getsecmarginratio ) se on se.afacctno=ci.acctno
                        left join (select trfacctno, nvl(sum(ln.prinovd + ln.intovdacr + ln.intnmlovd + ln.oprinovd + ln.oprinnml + ln.ointnmlovd + ln.ointovdacr+ln.ointdue+ln.ointnmlacr + nvl(lns.nml,0) + nvl(lns.intdue,0)),0) ovdamt,
                                                       nvl(sum(ln.prinnml - nvl(nml,0)+ ln.intnmlacr),0) nmlmarginamt,
                                            nvl(sum(decode(lnt.chksysctrl,'Y',1,0)*(ln.prinnml+ln.prinovd+ln.intnmlacr+ln.intdue+ln.intovdacr+ln.intnmlovd+ln.feeintnmlacr+ln.feeintdue+ln.feeintovdacr+ln.feeintnmlovd)),0) margin74amt
                                        from lnmast ln, lntype lnt, (select acctno, sum(nml) nml, sum(intdue) intdue  from lnschd
                                                            where reftype = 'P' and  overduedate = to_date(cspks_system.fn_get_sysvar('SYSTEM','CURRDATE'),'DD/MM/RRRR') group by acctno) lns
                                        where ln.actype = lnt.actype and ln.acctno = lns.acctno(+) and ln.ftype = 'AF'
                                        group by ln.trfacctno) ovdaf on ovdaf.trfacctno = ci.acctno
                        left join (select afacctno, sum(amt) receivingamt from stschd where  duetype = 'RM' and status <> 'C' and deltd <> 'Y' group by afacctno) sts_rcv
                                on ci.acctno = sts_rcv.afacctno
                        left join
                            (select mst.afacctno, sum(mst.balance) tdbalance,
                                    sum(fn_tdmastintratio(mst.acctno,getcurrdate,
                                                    mst.balance)) tdintamt, sum(odamt) tdodamt, sum(odintacr) tdodintacr
                                from tdmast mst
                                where  mst.deltd<>'Y' and mst.status in ('N','A')
                                group by mst.afacctno) td
                            on td.afacctno = ci.acctno
                             left join
                    (select afacctno,
                                sum(nvl(case when st.duetype='RM' and st.rday=0 then st.st_amt else 0 end,0)) cash_receiving_t0,
                                sum(nvl(case when st.duetype='RM' and st.rday=1 then st.st_amt else 0 end,0)) cash_receiving_t1,
                                sum(nvl(case when st.duetype='RM' and st.rday=2 then st.st_amt else 0 end,0)) cash_receiving_t2,
                                sum(nvl(case when st.duetype='RM' and st.rday=3 then st.st_amt else 0 end,0)) cash_receiving_t3,
                                sum(nvl(case when st.duetype='RM' and st.rday>3 then st.st_amt else 0 end,0)) cash_receiving_tn,
                                sum(nvl(case when st.duetype='RS' and st.trfday=0 then st.st_amt else 0 end,0)) cash_sending_t0,
                                sum(nvl(case when st.duetype='RS' and st.trfday=1 then st.st_amt else 0 end,0)) cash_sending_t1,
                                sum(nvl(case when st.duetype='RS' and st.trfday=2 then st.st_amt else 0 end,0)) cash_sending_t2,
                                sum(nvl(case when st.duetype='RS' and st.trfday=3 then st.st_amt else 0 end,0)) cash_sending_t3,
                                sum(nvl(case when st.duetype='RS' and st.trfday>3 then st.st_amt else 0 end,0)) cash_sending_tn,
                                sum(nvl(case when st.duetype='RS' and st.trfday>=1 and st.trfday<=3 and st.txdate < st.currdate then st.feeacr else 0 end,0)) buy_feeacr,
                                sum(nvl(case when st.duetype='RS' and st.trfday=1 then st.execamtinday else 0 end,0)) execamtinday,
                                sum(case when st.duetype='RM' and st.tday=2 then st.st_amt-st.st_aamt-st.st_famt+st.st_paidamt+st.st_paidfeeamt-st.feeacr-st.taxsellamt else 0 end) avladv_t1,
                                sum(case when st.duetype='RM' and st.tday=1 then st.st_amt-st.st_aamt-st.st_famt+st.st_paidamt+st.st_paidfeeamt-st.feeacr-st.taxsellamt else 0 end) avladv_t2,
                                sum(case when st.duetype='RM' and st.tday=0 then st.st_amt-st.st_aamt-st.st_famt+st.st_paidamt+st.st_paidfeeamt-st.feeacr-st.taxsellamt else 0 end) avladv_t3,--,
                                --sum(nvl(case when st.duetype='sm' and st.ist2 = 'y' and st.t2dt = 0 then st.st_amt else 0 end,0)) casht2_sending_t0,
                                --sum(nvl(case when st.duetype='sm' and st.ist2 = 'y' and st.t2dt = 1 then st.st_amt else 0 end,0)) casht2_sending_t1,
                                --sum(nvl(case when st.duetype='sm' and st.ist2 = 'y' and st.t2dt = 2 then st.st_amt else 0 end,0)) casht2_sending_t2
                             sum(nvl(case when st.duetype='rm' and st.rday=1 and st.clearday=1 then st.st_amt else 0 end,0)) cash_receiving_t1_cldrd1
                        from   vw_bd_pending_settlement st where (duetype='RM' or duetype='SM' or duetype = 'RS')
                        group by afacctno) st
                        on st.afacctno=ci.acctno
                           left join
                        (select     df.afacctno, sum(
                                ln.prinnml + ln.prinovd + round(ln.intnmlacr,0) + round(ln.intovdacr,0) +
                                round(ln.intnmlovd,0)+round(ln.intdue,0)+
                                ln.oprinnml+ln.oprinovd+round(ln.ointnmlacr,0)+round(ln.ointovdacr,0)+round(ln.ointnmlovd,0) +
                                round(ln.ointdue,0)+round(ln.fee,0)+round(ln.feedue,0)+round(ln.feeovd,0) +
                                round(ln.feeintnmlacr,0) + round(ln.feeintovdacr,0) +round(ln.feeintnmlovd,0)+round(ln.feeintdue,0)
                                ) dfamt
                         from dfgroup df, lnmast ln
                        where df.lnacctno = ln.acctno
                        group by afacctno) dfg
                        on dfg.afacctno=ci.acctno
                    left join
                        (
                        select trfacctno afacctno,
                            sum(ln.prinnml + ln.prinovd + ln.intnmlacr + ln.intovdacr + ln.intnmlovd+ln.intdue
                                + ln.fee+ln.feedue+ln.feeovd+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd+ln.feeintdue+ln.feefloatamt) mrodamt,
                            sum(ln.oprinnml+ln.oprinovd+ln.ointnmlacr+ln.ointovdacr+
                            ln.ointnmlovd+ln.ointdue) t0odamt
                            from lnmast ln
                            where ftype ='AF'
                                and ln.prinnml + ln.prinovd + ln.intnmlacr + ln.intovdacr +
                                    ln.intnmlovd+ln.intdue + ln.oprinnml+ln.oprinovd+ln.ointnmlacr+ln.ointovdacr+
                                    ln.ointnmlovd+ln.ointdue >0
                            group by trfacctno
                        ) ln
                 on ln.afacctno=ci.acctno
                  left join
                     (
                         select tl.msgacct, sum(tl.msgamt) pdwithdraw
                         from tllog tl
                         where tl.tltxcd in ('1100','1121','1110','1144','1199','1107','1108','1110','1131','1132') and tl.txstatus = '4' and tl.deltd = 'N'
                         group by tl.msgacct
                     ) pw
                     on ci.acctno = pw.msgacct
                     left join
                     (
                         select cir.acctno, sum(amt+feeamt) pdtrfamt
                         from ciremittance cir
                         where cir.rmstatus = 'P' and cir.deltd = 'N'
                         group by cir.acctno
                     ) pdtrf
                     on ci.acctno = pdtrf.acctno
                      left join
                  (select * from vw_gettrfbuyamt_byday ) trf
                   on ci.acctno = trf.afacctno
                   where mrt.mrtype in ('T','F')
                             )
/
