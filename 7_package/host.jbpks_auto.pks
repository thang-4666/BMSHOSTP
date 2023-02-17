SET DEFINE OFF;
CREATE OR REPLACE PACKAGE jbpks_auto
IS
    /*----------------------------------------------------------------------------------------------------
     ** Module   : COMMODITY SYSTEM
     ** and is copyrighted by FSS.
     **
     **    All rights reserved.  No part of this work may be reproduced, stored in a retrieval system,
     **    adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
     **    graphic, optic recording or otherwise, translated in any language or computer language,
     **    without the prior written permission of Financial Software Solutions. JSC.
     **
     **  MODIFICATION HISTORY
     **  Person      Date           Comments
     **  FSS      20-mar-2010    Created
     ** (c) 2008 by Financial Software Solutions. JSC.
     ----------------------------------------------------------------------------------------------------*/

  PROCEDURE pr_gen_ci_buffer;
  PROCEDURE pr_gen_se_buffer;
  PROCEDURE pr_gen_od_buffer;
  PROCEDURE pr_SECMAST_GENERATE_LOG;
  PROCEDURE pr_process_od_bankaccount;
  PROCEDURE pr_trg_account_log (p_acctno in VARCHAR2, p_mod varchar2);
  procedure pr_gen_buf_ci_account(p_acctno varchar2 default null);
  procedure pr_gen_buf_se_account(p_acctno varchar2 default null);
  PROCEDURE pr_gen_buf_od_account(p_acctno varchar2 default null);
  FUNCTION fn_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2; -- HAM THUC HIEN LAY SO HIEU LENH GOC CUA LENH
  PROCEDURE pr_gen_rm_transfer;
END;
/


CREATE OR REPLACE PACKAGE BODY jbpks_auto
IS
   -- declare log context
   pkgctx   plog.log_ctx;
   logrow   tlogdebug%ROWTYPE;

FUNCTION fn_GetRootOrderID
    (p_OrderID       IN  VARCHAR2
    ) RETURN VARCHAR2
AS
    v_Found     BOOLEAN;
    v_TempOrderid   varchar2(20);
    v_TempRootOrderID varchar2(20);

BEGIN
    v_Found := FALSE;
    v_TempOrderid := p_OrderID;

    WHILE v_Found = FALSE
    LOOP
        SELECT NVL(OD.REFORDERID, '0000')
        INTO v_TempRootOrderID
        FROM ODMAST OD WHERE OD.ORDERID = v_TempOrderid;
        IF v_TempRootOrderID <> '0000' THEN
            v_TempOrderid := v_TempRootOrderID;
            v_Found := FALSE;
        ELSE
            v_Found := TRUE;
        END IF;
    END LOOP;

    RETURN v_TempOrderid;

EXCEPTION
  WHEN OTHERS THEN
    plog.error(pkgctx, sqlerrm);
    plog.setendsection(pkgctx, 'fn_GetRootOrderID');
    RETURN '0000';
END;

procedure pr_gen_buf_ci_account(p_acctno varchar2 default null)
  IS
  v_acctno varchar2(50);
  v_margintype char(1);
  v_actype varchar2(4);
  v_groupleader varchar2(10);
  v_ci_arr txpks_check.cimastcheck_arrtype;

BEGIN
    plog.setBeginsection(pkgctx, 'pr_gen_buf_ci_account');
    PLOG.INFO(pkgctx,'Begin pr_gen_buf_ci_account');

    if p_acctno is null or p_acctno='ALL' then
        delete from buf_ci_account;
        --commit;
        For rec in (
                    SELECT mst.acctno,MR.MRTYPE,af.actype,mst.groupleader
                    --into v_margintype,v_actype,v_groupleader
                    from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype
                    order by mst.acctno
        )
        loop
            V_ACCTNO:=rec.acctno;
            v_margintype:=rec.MRTYPE;
            v_actype:=rec.actype;
            v_groupleader:=rec.groupleader;

            v_ci_arr := txpks_check.fn_CIMASTcheck(V_ACCTNO,'CIMAST','ACCTNO');
            --PLOG.debug(pkgctx,'ppppppp: ' || v_ci_arr(0).pp);

            --if v_margintype in ('N','L') then
             --Tai khoan binh thuong khong Margin
             INSERT INTO buf_ci_account (CUSTODYCD,ACTYPE,AFACCTNO,DESC_STATUS,LASTDATE,
                    BALANCE,INTBALANCE,DFDEBTAMT,CRINTACR,AAMT,BAMT,
                    EMKAMT,FLOATAMT,ODAMT,RECEIVING, NETTING, AVLADVANCE,MBLOCK,APMT,PAIDAMT,
                    ADVANCELINE,ADVLIMIT,MRIRATE,MRMRATE,MRLRATE,DEALPAIDAMT,
                    AVLWITHDRAW,BALDEFOVD,PP,AVLLIMIT,NAVACCOUNT,OUTSTANDING,SE_NAVACCOUNT,SE_OUTSTANDING,
                    MARGINRATE,CIDEPOFEEACR,OVDCIDEPOFEE,
                    CASH_RECEIVING_T0,CASH_RECEIVING_T1,CASH_RECEIVING_T2,CASH_RECEIVING_T3,CASH_RECEIVING_TN,
                    CASH_SENDING_T0,CASH_SENDING_T1,CASH_SENDING_T2,CASH_SENDING_T3,CASH_SENDING_TN,CAREBY,
                    MRODAMT,T0ODAMT,DFODAMT,ACCOUNTTYPE,EXECBUYAMT,AUTOADV,AVLADV_T3,AVLADV_T1,AVLADV_T2,
                        CASH_PENDWITHDRAW,CASH_PENDTRANSFER,CASH_PENDING_SEND, PPREF,BALDEFTRFAMT,
                    CASHT2_SENDING_T0,CASHT2_SENDING_T1,CASHT2_SENDING_T2,SUBCOREBANK,BANKBALANCE,BANKAVLBAL, SEAMT,SEASS,
                    TRFBUY_T0,TRFBUY_T1,TRFBUY_T2,TRFBUY_T3,TDBALANCE,TDINTAMT,TDODAMT,TDODINTACR,CALLAMT, ADDAMT,RCVAMT, RCVADVAMT,TRFBUYAMT,mrcrlimit,bankinqirydt,
                    CASH_RECEIVING_T1_CLDRD1,clamtlimit,dclamtlimit)
             SELECT
                    cf.CUSTODYCD, v_ci_arr(0).actype actype, mst.afacctno, cd1.cdcontent desc_status,v_ci_arr(0).lastdate lastdate,
                    v_ci_arr(0).balance balance,
                    mst.balance intbalance, v_ci_arr(0).dfdebtamt DFDEBTAMT,
                    v_ci_arr(0).crintacr crintacr, v_ci_arr(0).aamt aamt,
                    v_ci_arr(0).bamt bamt, mst.emkamt,mst.floatamt,
                    mst.odamt, mst.receiving, mst.netting,v_ci_arr(0).advanceamount avlAdvance, mst.mblock,
                    v_ci_arr(0).advanceamount apmt,v_ci_arr(0).paidamt paidamt,
                    v_ci_arr(0).advanceline,nvl(af.mrcrlimitmax,0) advlimit, af.mrirate,af.mrmrate,af.mrlrate,
                    0 dealpaidamt,
                    v_ci_arr(0).baldefovd avlwithdraw,
                    v_ci_arr(0).baldefovd baldefovd,
                    v_ci_arr(0).pp pp,
                    v_ci_arr(0).avllimit avllimit,
                    v_ci_arr(0).navaccount  NAVACCOUNT,
                    v_ci_arr(0).OUTSTANDING OUTSTANDING,
                    v_ci_arr(0).se_navaccount  se_NAVACCOUNT,
                    v_ci_arr(0).se_OUTSTANDING se_OUTSTANDING,
                    /*round((case when mst.balance+least(NVL(af.mrcrlimit,0),v_ci_arr(0).bamt)+v_ci_arr(0).avladvance- mst.odamt- mst.dfdebtamt - mst.dfintdebtamt
                                    -v_ci_arr(0).bamt - mst.ramt-nvl(mst.depofeeamt,0)>=0 then 100000
                                else ( v_ci_arr(0).SEASS
                                    + v_ci_arr(0).avladvance)
                                    / abs(mst.balance+least(NVL(af.mrcrlimit,0),v_ci_arr(0).bamt)+v_ci_arr(0).avladvance- mst.odamt- mst.dfdebtamt - mst.dfintdebtamt
                                           -v_ci_arr(0).bamt - mst.ramt-nvl(mst.depofeeamt,0)) end),4) * 100 MARGINRATE,*/
                    v_ci_arr(0).Marginrate,
                    mst.cidepofeeacr,
                    nvl(mst.depofeeamt,0) OVDCIDEPOFEE,
                    nvl(CASH_RECEIVING_T0,0) CASH_RECEIVING_T0,
                    nvl(CASH_RECEIVING_T1,0) CASH_RECEIVING_T1,
                    nvl(CASH_RECEIVING_T2,0) CASH_RECEIVING_T2,
                    nvl(CASH_RECEIVING_T3,0) CASH_RECEIVING_T3,
                    nvl(CASH_RECEIVING_TN,0) CASH_RECEIVING_TN,
                    nvl(CASH_SENDING_T0,0) CASH_SENDING_T0,
                    nvl(CASH_SENDING_T1,0) CASH_SENDING_T1,
                    nvl(CASH_SENDING_T2,0)  CASH_SENDING_T2,
                    nvl(CASH_SENDING_T3,0) CASH_SENDING_T3,
                    nvl(CASH_SENDING_TN,0) CASH_SENDING_TN,
                    cf.careby,
                    nvl(ln.mrodamt,0) MRODAMT,nvl(ln.t0odamt,0) T0ODAMT,nvl(dfg.dfamt,0) DFODAMT,
                    (case when cf.custatcom ='N' then 'O' when af.corebank ='Y' then 'B' else 'C' end) ACCOUNTTYPE,
                    v_ci_arr(0).EXECBUYAMT EXECBUYAMT, af.autoadv, nvl(ST.AVLADV_T3,0) AVLADV_T3, nvl(ST.avladv_t1,0) avladv_t1,
                    nvl(ST.avladv_t2,0) avladv_t2, nvl(pw.pdwithdraw,0) pdwithdraw, nvl(pdtrf.pdtrfamt,0) pdtrfamt,
                    v_ci_arr(0).bamt -- ky quy + tra cham /*+NVL (al.advamt,0)*/
                        + nvl(CASH_SENDING_T0,0)+nvl(CASH_SENDING_T1,0)+nvl(CASH_SENDING_T2,0) -- cho giao qua ngay
                        - mst.trfamt -- tra cham (vi cho giao qua ngay da bao gom tra cham)
                        + nvl(ST.BUY_FEEACR,0)
                        - nvl(ST.EXECAMTINDAY,0)+nvl(pw.pdwithdraw,0)+nvl(pdtrf.pdtrfamt,0) CASH_PENDING_SEND,
                    v_ci_arr(0).PPREF, v_ci_arr(0).BALDEFOVD,
                    0 CASHT2_SENDING_T0,
                    0 CASHT2_SENDING_T1,
                    0 CASHT2_SENDING_T2,
                    af.alternateacct SUBCOREBANK,
                    v_ci_arr(0).BANKBALANCE,v_ci_arr(0).BANKAVLBAL,
                    v_ci_arr(0).SEAMT,v_ci_arr(0).SEASS,
                    nvl(trf.TRFBUY_T0,0) TRFBUY_T0, nvl(trf.TRFBUY_T1,0) TRFBUY_T1, nvl(trf.TRFBUY_T2,0) TRFBUY_T2, nvl(trf.TRFBUY_T3,0) TRFBUY_T3,
                    v_ci_arr(0).tdbalance,v_ci_arr(0).TDINTAMT,v_ci_arr(0).TDODAMT,v_ci_arr(0).TDODINTACR,
                    v_ci_arr(0). callamt, v_ci_arr(0).addamt,
                    v_ci_arr(0). rcvamt, v_ci_arr(0).rcvadvamt,
                    mst.trfbuyamt, af.mrcrlimit, mst.bankinqirydt,
                    NVL(CASH_RECEIVING_T1_CLDRD1,0) CASH_RECEIVING_T1_CLDRD1, v_ci_arr(0).clamtlimit,
                     v_ci_arr(0).dclamtlimit
               FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND mst.acctno = V_ACCTNO
                    INNER JOIN cfmast cf ON cf.custid = af.custid
                    inner join (select * from allcode cd1  where cd1.cdtype = 'CI' AND cd1.cdname = 'STATUS') cd1 on mst.status = cd1.cdval
                    /*left join
                    (select * from v_getbuyorderinfo where afacctno = V_ACCTNO) al
                     on mst.acctno = al.afacctno*/
                    /*LEFT JOIN
                    (select * from v_getsecmargininfo where afacctno = V_ACCTNO) SE
                    on se.afacctno = mst.acctno*/
                    /*LEFT JOIN
                    (select aamt,depoamt avladvance, advamt advanceamount,afacctno, paidamt from v_getAccountAvlAdvance where afacctno = V_ACCTNO) adv
                    on adv.afacctno=MST.acctno*/
                   /* LEFT JOIN
                    (select * from v_getdealpaidbyaccount p where p.afacctno = V_ACCTNO) pd
                    on pd.afacctno=mst.acctno*/
                    LEFT JOIN
                    (SELECT AFACCTNO,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=0 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T0,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T1,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=2 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T2,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T3,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY>3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_TN,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=0 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T0,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=1 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T1,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=2 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T2,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T3,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY>3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_TN,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY>=1 AND ST.TRFDAY<=3 AND ST.TXDATE < ST.CURRDATE THEN ST.FEEACR ELSE 0 END,0)) BUY_FEEACR,
                                sum(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=1 THEN ST.EXECAMTINDAY ELSE 0 END,0)) EXECAMTINDAY,
                                SUM(CASE WHEN ST.DUETYPE='RM' AND ST.TDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT+ST.ST_PAIDAMT+ST.ST_PAIDFEEAMT-ST.FEEACR-ST.TAXSELLAMT ELSE 0 END) avladv_t1,
                                SUM(CASE WHEN ST.DUETYPE='RM' AND ST.TDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT+ST.ST_PAIDAMT+ST.ST_PAIDFEEAMT-ST.FEEACR-ST.TAXSELLAMT ELSE 0 END) avladv_t2,
                                SUM(CASE WHEN ST.DUETYPE='RM' AND ST.TDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT+ST.ST_PAIDAMT+ST.ST_PAIDFEEAMT-ST.FEEACR-ST.TAXSELLAMT ELSE 0 END) avladv_t3,--,
                                --SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.ist2 = 'Y' AND st.T2DT = 0 THEN ST.ST_AMT ELSE 0 END,0)) CASHT2_SENDING_T0,
                                --SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.ist2 = 'Y' AND st.T2DT = 1 THEN ST.ST_AMT ELSE 0 END,0)) CASHT2_SENDING_T1,
                                --SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.ist2 = 'Y' AND st.T2DT = 2 THEN ST.ST_AMT ELSE 0 END,0)) CASHT2_SENDING_T2
                             SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 AND ST.CLEARDAY=1 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T1_CLDRD1
                        FROM   VW_BD_PENDING_SETTLEMENT ST WHERE (DUETYPE='RM' OR DUETYPE='SM' OR DUETYPE = 'RS') AND ST.AFACCTNO = V_ACCTNO
                        GROUP BY AFACCTNO) ST
                    on ST.AFACCTNO=MST.acctno

                    left join
                        (select     df.afacctno, sum(
                                ln.PRINNML + ln.PRINOVD + round(ln.INTNMLACR,0) + round(ln.INTOVDACR,0) +
                                round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                                ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0) +
                                round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0) +
                                round(ln.FEEINTNMLACR,0) + round(ln.FEEINTOVDACR,0) +round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)
                                ) dfAMT
                         from dfgroup df, lnmast ln
                        where df.lnacctno = ln.acctno AND df.afacctno = V_ACCTNO
                        group by afacctno) dfg
                        on dfg.AFACCTNO=MST.acctno
                    left join
                        (
                        select trfacctno afacctno,
                            sum(ln.PRINNML + ln.PRINOVD + ln.INTNMLACR + ln.INTOVDACR + ln.INTNMLOVD+ln.INTDUE
                                + ln.fee+ln.feedue+ln.feeovd+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd+ln.feeintdue+ln.feefloatamt) mrodamt,
                            sum(ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+
                            ln.OINTNMLOVD+ln.OINTDUE) t0odamt
                            from lnmast ln
                            where ftype ='AF'
                                and ln.PRINNML + ln.PRINOVD + ln.INTNMLACR + ln.INTOVDACR +
                                    ln.INTNMLOVD+ln.INTDUE + ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+
                                    ln.OINTNMLOVD+ln.OINTDUE >0
                                AND ln.trfacctno = V_ACCTNO
                            group by trfacctno
                        ) ln
                    on ln.AFACCTNO=MST.acctno
                     LEFT JOIN
                     (
                         SELECT tl.msgacct, sum(tl.msgamt) pdwithdraw
                         FROM tllog tl
                         WHERE tl.tltxcd IN ('1100','1121','1110','1144','1199','1107','1108','1110','1131','1132') AND tl.txstatus = '4' AND tl.deltd = 'N'
                             AND tl.msgacct = V_ACCTNO
                         GROUP BY tl.msgacct
                     ) pw
                     ON mst.acctno = pw.msgacct
                     LEFT JOIN
                     (
                         SELECT cir.acctno, sum(amt+feeamt) pdtrfamt
                         FROM ciremittance cir
                         WHERE cir.rmstatus = 'P' AND cir.deltd = 'N'
                             AND cir.acctno = V_ACCTNO
                         GROUP BY cir.acctno
                     ) pdtrf
                     ON mst.acctno = pdtrf.acctno
                     left join
                     (select * from vw_gettrfbuyamt_byDay where afacctno = V_ACCTNO) trf
                     on mst.acctno = trf.afacctno
                     ;
        end loop;
    else
        delete from buf_ci_account where afacctno = p_acctno;
        SELECT MR.MRTYPE,af.actype,mst.groupleader
                    into v_margintype,v_actype,v_groupleader
                    from afmast mst,aftype af, mrtype mr where mst.actype=af.actype and af.mrtype=mr.actype
                    and mst.acctno = p_acctno;
        V_ACCTNO:=p_acctno;
        --PLOG.debug(pkgctx,'p_acctno: ' || V_ACCTNO);

        v_ci_arr := txpks_check.fn_CIMASTcheck(V_ACCTNO,'CIMAST','ACCTNO');
        --PLOG.debug(pkgctx,'ppppppp: ' || v_ci_arr(0).pp);

        --if v_margintype in ('N','L') then
             --Tai khoan binh thuong khong Margin
             INSERT INTO buf_ci_account (CUSTODYCD,ACTYPE,AFACCTNO,DESC_STATUS,LASTDATE,
                    BALANCE,INTBALANCE,DFDEBTAMT,CRINTACR,AAMT,BAMT,
                    EMKAMT,FLOATAMT,ODAMT,RECEIVING, NETTING, AVLADVANCE,MBLOCK,APMT,PAIDAMT,
                    ADVANCELINE,ADVLIMIT,MRIRATE,MRMRATE,MRLRATE,DEALPAIDAMT,
                    AVLWITHDRAW,BALDEFOVD,PP,AVLLIMIT,NAVACCOUNT,OUTSTANDING,se_NAVACCOUNT,se_OUTSTANDING,
                    MARGINRATE,CIDEPOFEEACR,OVDCIDEPOFEE,
                    CASH_RECEIVING_T0,CASH_RECEIVING_T1,CASH_RECEIVING_T2,CASH_RECEIVING_T3,CASH_RECEIVING_TN,
                    CASH_SENDING_T0,CASH_SENDING_T1,CASH_SENDING_T2,CASH_SENDING_T3,CASH_SENDING_TN,CAREBY,
                    MRODAMT,T0ODAMT,DFODAMT,ACCOUNTTYPE,EXECBUYAMT,AUTOADV,AVLADV_T3,AVLADV_T1,AVLADV_T2,
                        CASH_PENDWITHDRAW,CASH_PENDTRANSFER,CASH_PENDING_SEND,PPREF,BALDEFTRFAMT,
                    CASHT2_SENDING_T0,CASHT2_SENDING_T1,CASHT2_SENDING_T2,SUBCOREBANK,BANKBALANCE,BANKAVLBAL, SEAMT,SEASS,
                    TRFBUY_T0,TRFBUY_T1,TRFBUY_T2,TRFBUY_T3,TDBALANCE,TDINTAMT,TDODAMT,TDODINTACR,CALLAMT, ADDAMT,RCVAMT, RCVADVAMT,TRFBUYAMT,mrcrlimit,bankinqirydt,
                    CASH_RECEIVING_T1_CLDRD1,clamtlimit,dclamtlimit)
             SELECT
                    cf.CUSTODYCD, v_ci_arr(0).actype actype, mst.afacctno, cd1.cdcontent desc_status,v_ci_arr(0).lastdate lastdate,
                    v_ci_arr(0).balance balance,
                    mst.balance intbalance, v_ci_arr(0).dfdebtamt DFDEBTAMT,
                    v_ci_arr(0).crintacr crintacr, v_ci_arr(0).aamt aamt,
                    v_ci_arr(0).bamt bamt, mst.emkamt,mst.floatamt,
                    mst.odamt, mst.receiving, mst.netting,v_ci_arr(0).advanceamount avlAdvance, mst.mblock,
                    v_ci_arr(0).advanceamount apmt,v_ci_arr(0).paidamt paidamt,
                    v_ci_arr(0).advanceline,nvl(af.mrcrlimitmax,0) advlimit, af.mrirate,af.mrmrate,af.mrlrate,
                    0 dealpaidamt,
                    v_ci_arr(0).baldefovd avlwithdraw,
                    v_ci_arr(0).baldefovd baldefovd,
                    v_ci_arr(0).pp pp,
                    v_ci_arr(0).avllimit avllimit,
                    v_ci_arr(0).navaccount  NAVACCOUNT,
                    v_ci_arr(0).OUTSTANDING OUTSTANDING,
                    v_ci_arr(0).se_navaccount  se_NAVACCOUNT,
                    v_ci_arr(0).se_OUTSTANDING se_OUTSTANDING,
                    /*round((case when mst.balance+least(NVL(af.mrcrlimit,0),v_ci_arr(0).bamt)+v_ci_arr(0).avladvance- mst.odamt- mst.dfdebtamt - mst.dfintdebtamt
                                    -v_ci_arr(0).bamt - mst.ramt-nvl(mst.depofeeamt,0)>=0 then 100000
                                else ( v_ci_arr(0).SEASS
                                    + v_ci_arr(0).avladvance)
                                    / abs(mst.balance+least(NVL(af.mrcrlimit,0),v_ci_arr(0).bamt)+v_ci_arr(0).avladvance- mst.odamt- mst.dfdebtamt - mst.dfintdebtamt
                                            -v_ci_arr(0).bamt - mst.ramt-nvl(mst.depofeeamt,0)) end),4) * 100 MARGINRATE,*/
                    v_ci_arr(0).marginrate,
                    mst.cidepofeeacr,
                    nvl(mst.depofeeamt,0) OVDCIDEPOFEE,
                    nvl(CASH_RECEIVING_T0,0) CASH_RECEIVING_T0,
                    nvl(CASH_RECEIVING_T1,0) CASH_RECEIVING_T1,
                    nvl(CASH_RECEIVING_T2,0) CASH_RECEIVING_T2,
                    nvl(CASH_RECEIVING_T3,0) CASH_RECEIVING_T3,
                    nvl(CASH_RECEIVING_TN,0) CASH_RECEIVING_TN,
                    nvl(CASH_SENDING_T0,0) CASH_SENDING_T0,
                    nvl(CASH_SENDING_T1,0) CASH_SENDING_T1,
                    nvl(CASH_SENDING_T2,0)  CASH_SENDING_T2,
                    nvl(CASH_SENDING_T3,0) CASH_SENDING_T3,
                    nvl(CASH_SENDING_TN,0) CASH_SENDING_TN,
                    cf.careby,
                    nvl(ln.mrodamt,0) MRODAMT,nvl(ln.t0odamt,0) T0ODAMT,nvl(dfg.dfamt,0) DFODAMT,
                    (case when cf.custatcom ='N' then 'O' when af.corebank ='Y' then 'B' else 'C' end) ACCOUNTTYPE,
                    v_ci_arr(0).EXECBUYAMT EXECBUYAMT, af.autoadv, nvl(ST.AVLADV_T3,0) AVLADV_T3, nvl(ST.avladv_t1,0) avladv_t1,
                    nvl(ST.avladv_t2,0) avladv_t2, nvl(pw.pdwithdraw,0) pdwithdraw, nvl(pdtrf.pdtrfamt,0) pdtrfamt,
                    v_ci_arr(0).bamt -- ky quy + tra cham /*+NVL (al.advamt,0)*/
                        + nvl(CASH_SENDING_T0,0)+nvl(CASH_SENDING_T1,0)+nvl(CASH_SENDING_T2,0) -- cho giao qua ngay
                        - mst.trfamt -- tra cham (vi cho giao qua ngay da bao gom tra cham)
                        + nvl(ST.BUY_FEEACR,0)
                        - nvl(ST.EXECAMTINDAY,0)+nvl(pw.pdwithdraw,0)+nvl(pdtrf.pdtrfamt,0) CASH_PENDING_SEND,
                    v_ci_arr(0).PPREF, v_ci_arr(0).BALDEFOVD,
                    0 CASHT2_SENDING_T0,
                    0 CASHT2_SENDING_T1,
                    0 CASHT2_SENDING_T2,
                    af.alternateacct SUBCOREBANK,
                    v_ci_arr(0).BANKBALANCE,v_ci_arr(0).BANKAVLBAL,
                    v_ci_arr(0).SEAMT,v_ci_arr(0).SEASS,
                    nvl(trf.TRFBUY_T0,0) TRFBUY_T0, nvl(trf.TRFBUY_T1,0) TRFBUY_T1, nvl(trf.TRFBUY_T2,0) TRFBUY_T2, nvl(trf.TRFBUY_T3,0) TRFBUY_T3,
                    v_ci_arr(0).tdbalance,v_ci_arr(0).TDINTAMT,v_ci_arr(0).TDODAMT,v_ci_arr(0).TDODINTACR,
                    v_ci_arr(0).callamt, v_ci_arr(0).addamt,
                    v_ci_arr(0). rcvamt, v_ci_arr(0).rcvadvamt,
                    mst.trfbuyamt, af.mrcrlimit, mst.bankinqirydt,
                    NVL(CASH_RECEIVING_T1_CLDRD1,0) CASH_RECEIVING_T1_CLDRD1,v_ci_arr(0).clamtlimit,v_ci_arr(0).dclamtlimit
               FROM cimast mst inner join afmast af on af.acctno = mst.afacctno AND mst.acctno = V_ACCTNO
                    INNER JOIN cfmast cf ON cf.custid = af.custid
                    inner join (select * from allcode cd1  where cd1.cdtype = 'CI' AND cd1.cdname = 'STATUS') cd1 on mst.status = cd1.cdval
                    /*left join
                    (select * from v_getbuyorderinfo where afacctno = V_ACCTNO) al
                     on mst.acctno = al.afacctno*/
                    /*LEFT JOIN
                    (select * from v_getsecmargininfo where afacctno = V_ACCTNO) SE
                    on se.afacctno = mst.acctno*/
                    /*LEFT JOIN
                    (select aamt,depoamt avladvance, advamt advanceamount,afacctno, paidamt from v_getAccountAvlAdvance where afacctno = V_ACCTNO) adv
                    on adv.afacctno=MST.acctno*/
                   /* LEFT JOIN
                    (select * from v_getdealpaidbyaccount p where p.afacctno = V_ACCTNO) pd
                    on pd.afacctno=mst.acctno*/
                    LEFT JOIN
                    (SELECT AFACCTNO,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=0 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T0,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T1,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=2 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T2,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T3,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY>3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_TN,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=0 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T0,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=1 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T1,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=2 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T2,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=3 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_T3,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY>4 THEN ST.ST_AMT ELSE 0 END,0)) CASH_SENDING_TN,
                                SUM(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY>=1 AND ST.TRFDAY<=3 AND ST.TXDATE < ST.CURRDATE THEN ST.FEEACR ELSE 0 END,0)) BUY_FEEACR,
                                sum(NVL(CASE WHEN ST.DUETYPE='RS' AND ST.TRFDAY=1 THEN ST.EXECAMTINDAY ELSE 0 END,0)) EXECAMTINDAY,
                                SUM(CASE WHEN ST.DUETYPE='RM' AND ST.TDAY=2 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT+ST.ST_PAIDAMT+ST.ST_PAIDFEEAMT-ST.FEEACR-ST.TAXSELLAMT ELSE 0 END) avladv_t1,
                                SUM(CASE WHEN ST.DUETYPE='RM' AND ST.TDAY=1 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT+ST.ST_PAIDAMT+ST.ST_PAIDFEEAMT-ST.FEEACR-ST.TAXSELLAMT ELSE 0 END) avladv_t2,
                                SUM(CASE WHEN ST.DUETYPE='RM' AND ST.TDAY=0 THEN ST.ST_AMT-ST.ST_AAMT-ST.ST_FAMT+ST.ST_PAIDAMT+ST.ST_PAIDFEEAMT-ST.FEEACR-ST.TAXSELLAMT ELSE 0 END) avladv_t3,--,
                                --SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.ist2 = 'Y' AND st.T2DT = 0 THEN ST.ST_AMT ELSE 0 END,0)) CASHT2_SENDING_T0,
                                --SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.ist2 = 'Y' AND st.T2DT = 1 THEN ST.ST_AMT ELSE 0 END,0)) CASHT2_SENDING_T1,
                                --SUM(NVL(CASE WHEN ST.DUETYPE='SM' AND ST.ist2 = 'Y' AND st.T2DT = 2 THEN ST.ST_AMT ELSE 0 END,0)) CASHT2_SENDING_T2
                                SUM(NVL(CASE WHEN ST.DUETYPE='RM' AND ST.RDAY=1 AND ST.CLEARDAY=1 THEN ST.ST_AMT ELSE 0 END,0)) CASH_RECEIVING_T1_CLDRD1
                        FROM
                            VW_BD_PENDING_SETTLEMENT ST WHERE (DUETYPE='RM' OR DUETYPE='SM' OR DUETYPE = 'RS') AND ST.AFACCTNO = V_ACCTNO
                        GROUP BY AFACCTNO) ST
                    on ST.AFACCTNO=MST.acctno
                    left join
                        (select     df.afacctno, sum(
                                ln.PRINNML + ln.PRINOVD + round(ln.INTNMLACR,0) + round(ln.INTOVDACR,0) +
                                round(ln.INTNMLOVD,0)+round(ln.INTDUE,0)+
                                ln.OPRINNML+ln.OPRINOVD+round(ln.OINTNMLACR,0)+round(ln.OINTOVDACR,0)+round(ln.OINTNMLOVD,0) +
                                round(ln.OINTDUE,0)+round(ln.FEE,0)+round(ln.FEEDUE,0)+round(ln.FEEOVD,0) +
                                round(ln.FEEINTNMLACR,0) + round(ln.FEEINTOVDACR,0) +round(ln.FEEINTNMLOVD,0)+round(ln.FEEINTDUE,0)
                                ) dfAMT
                         from dfgroup df, lnmast ln
                        where df.lnacctno = ln.acctno AND df.afacctno = V_ACCTNO
                        group by afacctno) dfg
                        on dfg.AFACCTNO=MST.acctno
                    left join
                        (
                        select trfacctno afacctno,
                            sum(ln.PRINNML + ln.PRINOVD + ln.INTNMLACR + ln.INTOVDACR + ln.INTNMLOVD+ln.INTDUE
                            + ln.fee+ln.feedue+ln.feeovd+ln.feeintnmlacr+ln.feeintovdacr+ln.feeintnmlovd+ln.feeintdue+ln.feefloatamt) mrodamt,
                            sum(ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+
                            ln.OINTNMLOVD+ln.OINTDUE) t0odamt
                            from lnmast ln
                            where ftype ='AF'
                                and ln.PRINNML + ln.PRINOVD + ln.INTNMLACR + ln.INTOVDACR +
                                    ln.INTNMLOVD+ln.INTDUE + ln.OPRINNML+ln.OPRINOVD+ln.OINTNMLACR+ln.OINTOVDACR+
                                    ln.OINTNMLOVD+ln.OINTDUE >0
                                AND ln.trfacctno = V_ACCTNO
                            group by trfacctno
                        ) ln
                    on ln.AFACCTNO=MST.acctno
                    /*LEFT JOIN
                     (
                            SELECT sts.afacctno,
                                sum(CASE WHEN fn_get_nextdate(sts.currdate,2) = sts.cleardate THEN sts.avladvamt ELSE 0 END) avladv_t2,
                                sum(CASE WHEN fn_get_nextdate(sts.currdate,1) = sts.cleardate THEN sts.avladvamt ELSE 0 END) avladv_t1,
                                sum(CASE WHEN fn_get_nextdate(sts.currdate,3) = sts.cleardate THEN sts.avladvamt ELSE 0 END) AVLADV_T3
                            FROM v_advanceSchedule sts
                            WHERE afacctno = V_ACCTNO
                            GROUP BY sts.afacctno
                        ) advdtl
                     ON mst.acctno = advdtl.afacctno*/
                     LEFT JOIN
                     (
                         SELECT tl.msgacct, sum(tl.msgamt) pdwithdraw
                         FROM tllog tl
                         WHERE tl.tltxcd IN ('1100','1121','1110','1144','1199','1107','1108','1110','1131','1132') AND tl.txstatus = '4' AND tl.deltd = 'N'
                             AND tl.msgacct = V_ACCTNO
                         GROUP BY tl.msgacct
                     ) pw
                     ON mst.acctno = pw.msgacct
                     LEFT JOIN
                     (
                         SELECT cir.acctno, sum(amt+feeamt) pdtrfamt
                         FROM ciremittance cir
                         WHERE cir.rmstatus = 'P' AND cir.deltd = 'N'
                             AND cir.acctno = V_ACCTNO
                         GROUP BY cir.acctno
                     ) pdtrf
                     ON mst.acctno = pdtrf.acctno
                     left join
                     (select * from vw_gettrfbuyamt_byDay where afacctno = V_ACCTNO) trf
                     on mst.acctno = trf.afacctno
                     ;

        --end if;
    end if;

    --commit;
    PLOG.INFO(pkgctx,'End pr_gen_buf_ci_account');
    plog.setendsection(pkgctx, 'pr_gen_buf_ci_account');
EXCEPTION WHEN others THEN
    plog.error(pkgctx, 'Error when then Account p_acctno:=' || nvl(p_acctno,'NULL'));
    plog.error(pkgctx, sqlerrm || 'Loi tai dong:' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_gen_buf_ci_account');
END pr_gen_buf_ci_account;



procedure pr_gen_buf_se_account(p_acctno varchar2 default null)
  IS
    l_curdate date;

BEGIN
    plog.setbeginsection(pkgctx, 'pr_gen_buf_se_account');
    l_curdate := getcurrdate;
    if p_acctno is null or p_acctno='ALL' then
        PLOG.INFO(pkgctx,'Begin pr_gen_buf_se_account');
        delete from buf_se_account;
        delete from buf_se_account_log;
        --commit;
        INSERT INTO buf_se_account_log (CUSTODYCD,ACCTNO,AFACCTNO,ACTYPE,LASTDATE,CODEID,STATUS,COSTPRICE,
                                    TRADE,WTRADE,MORTAGE,NETTING,SECURED,WITHDRAW,BLOCKED,DEPOSIT,
                                    SENDDEPOSIT,PREVQTTY,DTOCLOSE,DCRQTTY,DCRAMT,RECEIVING,SYMBOL,
                                    DESC_STATUS,ABSTANDING,AVLWITHDRAW,TOTAL_QTTY,DEAL_QTTY,
                                    SECURITIES_RECEIVING_T0,SECURITIES_RECEIVING_T1,SECURITIES_RECEIVING_T2,SECURITIES_RECEIVING_T3,SECURITIES_RECEIVING_TN,


                                    SECURITIES_SENDING_T0,SECURITIES_SENDING_T1,SECURITIES_SENDING_T2,SECURITIES_SENDING_T3,SECURITIES_SENDING_TN,CAREBY,REMAINQTTY,RESTRICTQTTY,DFTRADING,
                                    FIFOCOSTPRICE,AVGCOSTPRICE,BASICPRICE,MRRATIOLOAN,MRRATIORATE,BUYINGQTTY,BUYAMT,AVLMRQTTY,AVLDFQTTY,BUYQTTY,

                                    SECURITIES_RECEIVING_T1_CLDRD1,RETAIL)
        -- TheNN modified, 12-Jan-2012
        SELECT CF.CUSTODYCD,MST.ACCTNO, MST.AFACCTNO,MST.ACTYPE, MST.LASTDATE, MST.CODEID, MST.STATUS,
               MST.COSTPRICE,
               --MST.TRADE-NVL(B.SECUREAMT,0) TRADE,
                 MST.TRADE-NVL(B.SECUREAMT,0) + (case when ccy.domain IN ('STCK','CBND') then 1 else 0 end ) * (MST.Execbuyqtty+ MST.odreceiving) TRADE, --GW04
                 MST.WTRADE, MST.MORTAGE-NVL(B.SECUREMTG,0) + MST.STANDING MORTAGE , MST.NETTING,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) SECURED,
                  MST.WITHDRAW + mst.BLOCKWITHDRAW WITHDRAW,( MST.EMKQTTY) BLOCKED, MST.DEPOSIT, MST.SENDDEPOSIT,MST.PREVQTTY,
                 MST.DTOCLOSE,MST.DCRQTTY,MST.DCRAMT,
                 MST.RECEIVING, CCY.SYMBOL, CD1.CDCONTENT DESC_STATUS,
                 ABS(STANDING) ABSTANDING,
                 --MST.TRADE-NVL(B.SECUREAMT,0) AVLWITHDRAW,
                 MST.TRADE - (case when ccy.domain IN ('STCK','CBND') then greatest (0, NVL(B.SECUREAMT,0)  - MST.Execbuyqtty - mst.odreceiving) else NVL(B.SECUREAMT,0)  end ) AVLWITHDRAW, --GW04
                 (MST.TRADE+MST.MORTAGE+MST.BLOCKED+MST.NETTING+MST.WTRADE) TOTAL_QTTY,
                  NVL(DF.DEALQTTY,0) DEAL_QTTY,
                 NVL(ST.SECURITIES_RECEIVING_T0,0) SECURITIES_RECEIVING_T0,
                  NVL(ST.SECURITIES_RECEIVING_T1,0) SECURITIES_RECEIVING_T1,
                  NVL(ST.SECURITIES_RECEIVING_T2,0) SECURITIES_RECEIVING_T2,
                 NVL(ST.SECURITIES_RECEIVING_T3,0) SECURITIES_RECEIVING_T3,
                 NVL(ST.SECURITIES_RECEIVING_TN,0) SECURITIES_RECEIVING_TN,
                 NVL(ST.SECURITIES_SENDING_T0,0) SECURITIES_SENDING_T0,
                 NVL(ST.SECURITIES_SENDING_T1,0) SECURITIES_SENDING_T1,
                 NVL(ST.SECURITIES_SENDING_T2,0) SECURITIES_SENDING_T2,
                 NVL(ST.SECURITIES_SENDING_T3,0) SECURITIES_SENDING_T3,
                 NVL(ST.SECURITIES_SENDING_TN,0) SECURITIES_SENDING_TN,
                 mst.CAREBY,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) - NVL(ST.REMAINQTTY,0) - DECODE(CF.CUSTATCOM,'Y',0,NVL(B.EXECQTTY,0)) REMAINQTTY,
                 mst.BLOCKED RESTRICTQTTY,





                 nvl(dftrading,0) dftrading,nvl(co.costprice,0) fifocostprice,NVL(CO.AVGCOSTPRICE,0) AVGCOSTPRICE,inf.basicprice,
                 nvl(rsk1.mrratioloan,0) mrratioloan,nvl(rsk1.mrratiorate,0) mrratiorate,



                 nvl(od.buyingqtty,0) buyingqtty, nvl(od.buyamt,0) buyamt,
                 trade  + NVL(ST.SECURITIES_RECEIVING_T0,0) + NVL(ST.SECURITIES_RECEIVING_T1,0) +

                                NVL(ST.SECURITIES_RECEIVING_T2,0) + NVL(ST.SECURITIES_RECEIVING_T3,0) + NVL(ST.SECURITIES_RECEIVING_TN,0) --+ buyingqtty


                                - NVL(b.execqtty,0) + nvl(dfsecured_match,0) AVLMRQTTY,
                 NVL(DF.DEALQTTY,0) -  nvl(dfsecured_match,0)  AVLDFQTTY,nvl(od.buyqtty,0) buyqtty,






                 NVL(SECURITIES_RECEIVING_T1_CLDRD1,0) SECURITIES_RECEIVING_T1_CLDRD1, NVL( RETAIL.QTTY,0 ) RETAIL
              FROM (select se.*, af.actype afactype, af.careby from SEMAST se, afmast af where se.afacctno = af.acctno) MST,
                    CFMAST CF, ALLCODE CD1, v_getsellorderinfo B,SBSECURITIES CCY,SECURITIES_INFO INF,
                   (
                        SELECT AFACCTNO, CODEID, SYMBOL, SUM(REMAINQTTY) REMAINQTTY,
                            SUM(SECURITIES_RECEIVING_T0) SECURITIES_RECEIVING_T0,
                            SUM(SECURITIES_RECEIVING_T1) SECURITIES_RECEIVING_T1,
                            SUM(SECURITIES_RECEIVING_T2) SECURITIES_RECEIVING_T2,
                            SUM(SECURITIES_RECEIVING_T3) SECURITIES_RECEIVING_T3,
                            SUM(SECURITIES_RECEIVING_TN) SECURITIES_RECEIVING_TN,
                            SUM(SECURITIES_SENDING_T0) SECURITIES_SENDING_T0,
                            SUM(SECURITIES_SENDING_T1) SECURITIES_SENDING_T1,
                            SUM(SECURITIES_SENDING_T2) SECURITIES_SENDING_T2,
                            SUM(SECURITIES_SENDING_T3) SECURITIES_SENDING_T3,
                            SUM(SECURITIES_SENDING_TN) SECURITIES_SENDING_TN,
                            SUM(SECURITIES_RECEIVING_T1_CLDRD1) SECURITIES_RECEIVING_T1_CLDRD1
                        FROM
                        (
                        SELECT ST.*,
                            (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T0,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T1,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T2,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T3,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY>3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_TN,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T0,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T1,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T2,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T3,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY > 3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_TN,
                           (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=0 THEN ST.ST_QTTY ELSE 0 END) REMAINQTTY,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=1 AND ST.CLEARDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T1_CLDRD1
                        FROM VW_BD_PENDING_SETTLEMENT ST
                        WHERE DUETYPE='RS' OR DUETYPE='SS' OR DUETYPE = 'RM'
                        ) ST
                        GROUP BY ST.AFACCTNO, ST.CODEID, ST.SYMBOL
                   ) ST,





                   (SELECT DF.CODEID, DF.AFACCTNO,  SUM(DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) DEALQTTY, sum(df.dftrading) dftrading, sum(secured_match) dfsecured_match
                        FROM v_getdealinfo DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO) DF,

                  (  SELECT acctno,  SUM(qtty) QTTY from seretail where status not in ('C','R') GROUP BY ACCTNO )RETAIL,

                (SELECT av.acctno, av.codeid, nvl(fi.costprice,secostprice) costprice, AV.avgcostprice avgcostprice
                    FROM
                    (
                        select acctno, codeid,
                            round(sum((qtty-mapqtty) * costprice)/sum(qtty-mapqtty),4) costprice
                        from secmast
                        where qtty-mapqtty>0
                            and ptype ='I'
                            and deltd <> 'Y'
                            --AND acctno in ('0102004863','')
                        group by acctno, codeid
                    ) FI,

                  ( --SONLT 20150727 Tinh them gia von realtime theo cong thuc PHS
                        SELECT SE.AFACCTNO ACCTNO, SE.CODEID, max(se.costprice) secostprice,
                            CASE WHEN (MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) = 0 THEN 0 ELSE
                            ROUND
                                 (
                                (MAX(SE.PREVQTTY*SE.COSTPRICE)
                                 +SUM((NVL(SEC.INAMT,0))
                                    - (NVL(SEC.ODOUTAMT,0))
                                    -(NVL(SEC.OUTAMT,0))
                                    +((NVL(OT.DEFFEERATE,0)/100)*(CASE WHEN OD.EXECTYPE LIKE '%S' THEN 0 ELSE NVL(OD.EXECAMT,0)END))
                              ) - SUM(nvl(AMT,0))
                                 )/(MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))),0
                                 )
                            END
                            AVGCOSTPRICE
                        FROM (SELECT ACCTNO, CODEID, ORDERID,
                                     SUM(CASE WHEN PTYPE ='I' THEN QTTY ELSE 0 END) INQTTY,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NOT NULL THEN QTTY ELSE 0 END) ODOUTQTTY,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NULL THEN QTTY ELSE 0 END) OUTQTTY,
                                     SUM(CASE WHEN PTYPE ='I' THEN QTTY*COSTPRICE ELSE 0 END) INAMT,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NOT NULL THEN QTTY*RTCOSTPRICE ELSE 0 END) ODOUTAMT,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NULL THEN QTTY*COSTPRICE ELSE 0 END) OUTAMT,
                                     SUM(AMT) AMT
                              FROM SECMAST
                              WHERE TXDATE = l_curdate
                                    AND DELTD <> 'Y'
                              GROUP BY ACCTNO, CODEID, ORDERID
                              )SEC, ODMAST OD, ODTYPE OT, VW_SEMAST_CUSTODYCD SE
                        WHERE SEC.ORDERID = OD.ORDERID(+)
                            AND OD.ACTYPE = OT.ACTYPE(+)
                            AND SE.AFACCTNO = SEC.ACCTNO(+)
                            AND SE.CODEID = SEC.CODEID(+)
                           -- AND ((SE.PREVQTTY)+(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) > 0
                        GROUP BY SE.AFACCTNO, SE.CODEID, SE.CUSTODYCD
                        having (SUM(nvl(SEC.INQTTY,0)-nvl(SEC.OUTQTTY,0)-nvl(SEC.ODOUTQTTY,0) ) + max(nvl(SE.PREVQTTY,0)) > 0) or SUM(nvl(AMT,0)) >0
                    ) AV
                    WHERE AV.ACCTNO = FI.ACCTNO(+)
                        AND AV.CODEID = FI.CODEID(+)) co,
                    (  SELECT   afacctno || codeid seacctno, SUM (remainqtty) buyingqtty,SUM (remainqtty+execqtty) buyqtty, sum(remainqtty*quoteprice + execamt) buyamt
                        FROM   odmast
                       WHERE   exectype IN ('NB', 'BC')
                               AND txdate = l_curdate
                               AND deltd <> 'Y' AND remainqtty+execqtty > 0
                               AND stsstatus <> 'C'
                    GROUP BY   afacctno, codeid) od,
                    afserisk rsk1
              WHERE mst.CUSTID= CF.CUSTID
               AND MST.ACCTNO=B.SEACCTNO(+)
               AND MST.ACCTNO = RETAIL.ACCTNO(+)
               --AND MST.ACCTNO=dtl.ACCTNO(+)
               and mst.afacctno =co.acctno(+) and mst.codeid = co.codeid(+)
               --AND MST.ACCTNO = V_ACCTNO
               AND MST.CODEID= CCY.CODEID and CCY.SECTYPE<>'004' and ccy.codeid = inf.codeid
               AND MST.AFACCTNO=ST.AFACCTNO (+) AND MST.CODEID=ST.CODEID (+)
               AND MST.AFACCTNO=DF.AFACCTNO (+) AND MST.CODEID=DF.CODEID (+)
               AND TRIM(CD1.CDTYPE) = 'SE' AND TRIM(CD1.CDNAME)='STATUS'
               AND TRIM(MST.STATUS) = TRIM(CD1.CDVAL)
               and mst.afactype =rsk1.actype(+) and mst.codeid=rsk1.codeid(+)
               AND mst.acctno = od.seacctno (+)
        /*SELECT CF.CUSTODYCD,MST.ACCTNO, MST.AFACCTNO,MST.ACTYPE, MST.LASTDATE, MST.CODEID, MST.STATUS,
               MST.COSTPRICE, MST.TRADE-NVL(B.SECUREAMT,0) TRADE,
                 MST.WTRADE, MST.MORTAGE-NVL(B.SECUREMTG,0) MORTAGE , MST.NETTING,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) SECURED,
                 MST.WITHDRAW, MST.BLOCKED, MST.DEPOSIT, MST.SENDDEPOSIT,MST.PREVQTTY,
                 MST.DTOCLOSE,MST.DCRQTTY,MST.DCRAMT,
                 MST.RECEIVING, CCY.SYMBOL, CD1.CDCONTENT DESC_STATUS,
                 ABS(STANDING) ABSTANDING, MST.TRADE-NVL(B.SECUREAMT,0) AVLWITHDRAW,
                 (MST.TRADE+MST.MORTAGE+MST.BLOCKED+MST.NETTING+MST.WTRADE) TOTAL_QTTY,
                  NVL(DF.DEALQTTY,0) DEAL_QTTY,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T0,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T1,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T2,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T3,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY>3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_TN,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T0,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=-1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T1,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=-2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T2,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=-3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T3,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY<-3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_TN,
                 af.CAREBY,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) - (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=0 THEN ST.ST_QTTY ELSE 0 END) REMAINQTTY,
                 NVL(DTL.QTTY,0) RESTRICTQTTY
              FROM AFMAST AF, SEMAST MST,CFMAST CF, ALLCODE CD1, v_getsellorderinfo B,SBSECURITIES CCY,
                   (SELECT * FROM VW_BD_PENDING_SETTLEMENT WHERE DUETYPE='RS' OR DUETYPE='SS') ST,
                   (SELECT DF.CODEID, DF.AFACCTNO,  SUM(DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) DEALQTTY
                        FROM DFMAST DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO) DF,
                   (select acctno, sum(qtty) qtty
                    from semastdtl
                        where QTTYTYPE ='002' and qtty>0
                        and deltd <> 'Y'
                    group by acctno) dtl
              WHERE AF.ACCTNO = MST.AFACCTNO AND AF.CUSTID= CF.CUSTID
               AND MST.ACCTNO=B.SEACCTNO(+)
               AND MST.ACCTNO=dtl.ACCTNO(+)
               --AND MST.ACCTNO = V_ACCTNO
               AND MST.CODEID= CCY.CODEID and CCY.SECTYPE<>'004'
               AND MST.AFACCTNO=ST.AFACCTNO (+) AND MST.CODEID=ST.CODEID (+)
               AND MST.AFACCTNO=DF.AFACCTNO (+) AND MST.CODEID=DF.CODEID (+)
               AND TRIM(CD1.CDTYPE) = 'SE' AND TRIM(CD1.CDNAME)='STATUS'
               AND TRIM(MST.STATUS) = TRIM(CD1.CDVAL)*/;

        --commit;
        PLOG.INFO(pkgctx,'End pr_gen_buf_se_account');
    else
        PLOG.debug(pkgctx,'Begin pr_gen_buf_se_account' || p_acctno);
        plog.error('day la log p_acctno: '||p_acctno);
        delete from buf_se_account_log where acctno = p_acctno;
        delete from buf_se_account where afacctno = substrc(p_acctno,1,10);
        --commit;
        INSERT INTO buf_se_account_log (CUSTODYCD,ACCTNO,AFACCTNO,ACTYPE,LASTDATE,CODEID,STATUS,COSTPRICE,
                                    TRADE,WTRADE,MORTAGE,NETTING,SECURED,WITHDRAW,BLOCKED,DEPOSIT,
                                    SENDDEPOSIT,PREVQTTY,DTOCLOSE,DCRQTTY,DCRAMT,RECEIVING,SYMBOL,
                                    DESC_STATUS,ABSTANDING,AVLWITHDRAW,TOTAL_QTTY,DEAL_QTTY,
                                    SECURITIES_RECEIVING_T0,SECURITIES_RECEIVING_T1,SECURITIES_RECEIVING_T2,SECURITIES_RECEIVING_T3,SECURITIES_RECEIVING_TN,


                                    SECURITIES_SENDING_T0,SECURITIES_SENDING_T1,SECURITIES_SENDING_T2,SECURITIES_SENDING_T3,SECURITIES_SENDING_TN,CAREBY,REMAINQTTY,RESTRICTQTTY,DFTRADING,
                                    FIFOCOSTPRICE,AVGCOSTPRICE,BASICPRICE,MRRATIOLOAN,MRRATIORATE,BUYINGQTTY,buyamt,AVLMRQTTY,AVLDFQTTY,BUYQTTY,

                                    SECURITIES_RECEIVING_T1_CLDRD1,RETAIL)
        SELECT CF.CUSTODYCD,MST.ACCTNO, MST.AFACCTNO,MST.ACTYPE, MST.LASTDATE, MST.CODEID, MST.STATUS,
               MST.COSTPRICE, --MST.TRADE-NVL(B.SECUREAMT,0) TRADE,
                 MST.TRADE-NVL(B.SECUREAMT,0) + (case when ccy.domain IN ('STCK','CBND') then 1 else 0 end ) * (MST.Execbuyqtty+ MST.odreceiving) TRADE, --GW04
                 MST.WTRADE, MST.MORTAGE-NVL(B.SECUREMTG,0) + MST.STANDING MORTAGE , MST.NETTING,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) SECURED,
                 MST.WITHDRAW + mst.BLOCKWITHDRAW WITHDRAW , (MST.EMKQTTY) BLOCKED , MST.DEPOSIT, MST.SENDDEPOSIT,MST.PREVQTTY,
                 MST.DTOCLOSE,MST.DCRQTTY,MST.DCRAMT,
                 MST.RECEIVING, CCY.SYMBOL, CD1.CDCONTENT DESC_STATUS,
                 ABS(STANDING) ABSTANDING, --MST.TRADE-NVL(B.SECUREAMT,0) AVLWITHDRAW,
                 MST.TRADE - (case when ccy.domain IN ('STCK','CBND') then greatest (0, NVL(B.SECUREAMT,0)  - MST.Execbuyqtty - mst.odreceiving) else NVL(B.SECUREAMT,0)  end ) AVLWITHDRAW, --GW04
                 (MST.TRADE+MST.MORTAGE+MST.BLOCKED+MST.NETTING+MST.WTRADE) TOTAL_QTTY,
                  NVL(DF.DEALQTTY,0) DEAL_QTTY,
                 NVL(ST.SECURITIES_RECEIVING_T0,0) SECURITIES_RECEIVING_T0,
                  NVL(ST.SECURITIES_RECEIVING_T1,0) SECURITIES_RECEIVING_T1,
                  NVL(ST.SECURITIES_RECEIVING_T2,0) SECURITIES_RECEIVING_T2,
                 NVL(ST.SECURITIES_RECEIVING_T3,0) SECURITIES_RECEIVING_T3,
                 NVL(ST.SECURITIES_RECEIVING_TN,0) SECURITIES_RECEIVING_TN,
                 NVL(ST.SECURITIES_SENDING_T0,0) SECURITIES_SENDING_T0,
                 NVL(ST.SECURITIES_SENDING_T1,0) SECURITIES_SENDING_T1,
                 NVL(ST.SECURITIES_SENDING_T2,0) SECURITIES_SENDING_T2,
                 NVL(ST.SECURITIES_SENDING_T3,0) SECURITIES_SENDING_T3,
                 NVL(ST.SECURITIES_SENDING_TN,0) SECURITIES_SENDING_TN,
                 mst.CAREBY,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) - NVL(ST.REMAINQTTY,0) - DECODE(CF.CUSTATCOM,'Y',0,NVL(B.EXECQTTY,0)) REMAINQTTY,
                 mst.BLOCKED RESTRICTQTTY,
                 nvl(dftrading,0) dftrading,

                 --nvl(co.costprice,0) fifocostprice,inf.basicprice,
                  nvl(phs.costprice,0) fifocostprice,NVL(phs.AVGCOSTPRICE,0) AVGCOSTPRICE,

                  inf.basicprice,

                 nvl(rsk1.mrratioloan,0) mrratioloan,nvl(rsk1.mrratiorate,0) mrratiorate,



                 nvl(od.buyingqtty,0) buyingqtty, nvl(od.buyamt,0) buyamt,
                 trade  + NVL(ST.SECURITIES_RECEIVING_T0,0) + NVL(ST.SECURITIES_RECEIVING_T1,0) +

                                NVL(ST.SECURITIES_RECEIVING_T2,0) + NVL(ST.SECURITIES_RECEIVING_T3,0) + NVL(ST.SECURITIES_RECEIVING_TN,0) --+ buyingqtty


                                - /*NVL(ST.SECURITIES_SENDING_T3,0)*/ NVL(b.execqtty,0) + nvl(dfsecured_match,0) AVLMRQTTY,
                 NVL(DF.DEALQTTY,0) -  nvl(dfsecured_match,0)  AVLDFQTTY,nvl(od.buyqtty,0) buyqtty,




                 NVL(SECURITIES_RECEIVING_T1_CLDRD1,0) SECURITIES_RECEIVING_T1_CLDRD1, NVL( RETAIL.QTTY,0 ) RETAIL
              FROM (select se.*, af.actype afactype, af.careby from SEMAST se, afmast af where se.afacctno = af.acctno) MST,
                    CFMAST CF, ALLCODE CD1, v_getsellorderinfo B,SBSECURITIES CCY,SECURITIES_INFO inf,
                   (
                        SELECT AFACCTNO, CODEID, SYMBOL, SUM(REMAINQTTY) REMAINQTTY,
                            SUM(SECURITIES_RECEIVING_T0) SECURITIES_RECEIVING_T0,
                            SUM(SECURITIES_RECEIVING_T1) SECURITIES_RECEIVING_T1,
                            SUM(SECURITIES_RECEIVING_T2) SECURITIES_RECEIVING_T2,
                            SUM(SECURITIES_RECEIVING_T3) SECURITIES_RECEIVING_T3,
                            SUM(SECURITIES_RECEIVING_TN) SECURITIES_RECEIVING_TN,
                            SUM(SECURITIES_SENDING_T0) SECURITIES_SENDING_T0,
                            SUM(SECURITIES_SENDING_T1) SECURITIES_SENDING_T1,
                            SUM(SECURITIES_SENDING_T2) SECURITIES_SENDING_T2,
                            SUM(SECURITIES_SENDING_T3) SECURITIES_SENDING_T3,
                            SUM(SECURITIES_SENDING_TN) SECURITIES_SENDING_TN,
                            SUM(SECURITIES_RECEIVING_T1_CLDRD1) SECURITIES_RECEIVING_T1_CLDRD1
                        FROM
                        (
                        SELECT ST.*,
                            (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T0,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T1,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T2,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T3,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY>3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_TN,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T0,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T1,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T2,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY=3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T3,
                           (CASE WHEN ST.DUETYPE='RM' AND ST.TRFDAY >3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_TN,
                           (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=0 THEN ST.ST_QTTY ELSE 0 END) REMAINQTTY,
                           (CASE WHEN ST.DUETYPE='RS' AND ST.RDAY=1 AND ST.CLEARDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T1_CLDRD1
                        FROM VW_BD_PENDING_SETTLEMENT ST
                        WHERE DUETYPE='RS' OR DUETYPE='SS' OR DUETYPE = 'RM'
                        ) ST
                        GROUP BY ST.AFACCTNO, ST.CODEID, ST.SYMBOL
                   ) ST,






                   (SELECT DF.CODEID, DF.AFACCTNO,  SUM(DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) DEALQTTY, sum(df.dftrading) dftrading, sum(secured_match) dfsecured_match
                        FROM v_getdealinfo DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO) DF,

                  (  SELECT acctno,  SUM(qtty) QTTY from seretail where status not in ('C','R') GROUP BY ACCTNO )RETAIL,
                   --( SELECT blocked  qtty ,0 dfqtty,acctno FROM semast) dtl,
                  (SELECT av.acctno, av.codeid, nvl(co.costprice,secostprice) costprice, AV.avgcostprice avgcostprice
                    FROM
                    (
                        select acctno, codeid,
                            round(sum((qtty-mapqtty) * costprice)/sum(qtty-mapqtty),4) costprice
                        from secmast
                        where qtty-mapqtty>0
                            and ptype ='I'
                            and deltd <> 'Y'
                            --AND acctno in ('0102004863','')
                        group by acctno, codeid

                    ) co,

                     ( --SONLT 20150727 Tinh them gia von realtime theo cong thuc PHS
                        SELECT SE.AFACCTNO ACCTNO, SE.CODEID, max(se.costprice) secostprice,
                            CASE WHEN (MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) = 0 THEN 0 ELSE
                            ROUND
                                 (
                                (MAX(SE.PREVQTTY*SE.COSTPRICE)
                                 +SUM((NVL(SEC.INAMT,0))
                                    - (NVL(SEC.ODOUTAMT,0))
                                    -(NVL(SEC.OUTAMT,0))
                                    +((NVL(OT.DEFFEERATE,0)/100)*(CASE WHEN OD.EXECTYPE LIKE '%S' THEN 0 ELSE NVL(OD.EXECAMT,0)END))
                             ) - SUM(nvl(AMT,0))
                                 )/(MAX(SE.PREVQTTY)+SUM(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))),0
                                 )
                            END
                            AVGCOSTPRICE
                        FROM (SELECT ACCTNO, CODEID, ORDERID,
                                     SUM(CASE WHEN PTYPE ='I' THEN QTTY ELSE 0 END) INQTTY,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NOT NULL THEN QTTY ELSE 0 END) ODOUTQTTY,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NULL THEN QTTY ELSE 0 END) OUTQTTY,
                                     SUM(CASE WHEN PTYPE ='I' THEN QTTY*COSTPRICE ELSE 0 END) INAMT,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NOT NULL THEN QTTY*RTCOSTPRICE ELSE 0 END) ODOUTAMT,
                                     SUM(CASE WHEN PTYPE ='O' AND ORDERID IS NULL THEN QTTY*COSTPRICE ELSE 0 END) OUTAMT,
                                     SUM(AMT) AMT
                              FROM SECMAST
                              WHERE TXDATE = l_curdate
                                    AND DELTD <> 'Y'
                              GROUP BY ACCTNO, CODEID, ORDERID
                              )SEC, ODMAST OD, ODTYPE OT, VW_SEMAST_CUSTODYCD SE
                        WHERE SEC.ORDERID = OD.ORDERID(+)
                            AND OD.ACTYPE = OT.ACTYPE(+)
                            AND SE.AFACCTNO = SEC.ACCTNO(+)
                            AND SE.CODEID = SEC.CODEID(+)
                           -- AND ((nvl(SE.PREVQTTY,0))+(NVL(SEC.INQTTY,0)-NVL(SEC.OUTQTTY,0)-NVL(SEC.ODOUTQTTY,0))) > 0
                        GROUP BY SE.AFACCTNO, SE.CODEID, SE.CUSTODYCD
                        having (SUM(nvl(SEC.INQTTY,0)-nvl(SEC.OUTQTTY,0)-nvl(SEC.ODOUTQTTY,0)  )+max(nvl(SE.PREVQTTY,0)) > 0  ) or SUM(nvl(AMT,0)) >0
                    ) AV
                    WHERE AV.ACCTNO = co.ACCTNO(+)
                        AND AV.CODEID = co.CODEID(+)) phs,


                    (  SELECT   afacctno || codeid seacctno, SUM (remainqtty) buyingqtty,SUM (remainqtty+execqtty) buyqtty, sum(remainqtty*quoteprice + execamt) buyamt
                        FROM   odmast
                       WHERE   exectype IN ('NB', 'BC')
                               AND txdate = l_curdate
                               AND stsstatus <> 'C'
                               AND deltd <> 'Y' AND remainqtty+execqtty > 0
                    GROUP BY   afacctno, codeid) od,

                    afserisk rsk1
              WHERE mst.CUSTID= CF.CUSTID
               AND MST.ACCTNO=B.SEACCTNO(+)
               AND MST.ACCTNO = RETAIL.ACCTNO(+)
               --AND MST.ACCTNO=dtl.ACCTNO(+)


               and mst.afacctno =phs.acctno(+) and mst.codeid = phs.codeid(+)

               AND MST.ACCTNO = p_acctno
               AND MST.CODEID= CCY.CODEID and CCY.SECTYPE<>'004' and ccy.codeid = inf.codeid
               AND MST.AFACCTNO=ST.AFACCTNO (+) AND MST.CODEID=ST.CODEID (+)
               AND MST.AFACCTNO=DF.AFACCTNO (+) AND MST.CODEID=DF.CODEID (+)
               AND TRIM(CD1.CDTYPE) = 'SE' AND TRIM(CD1.CDNAME)='STATUS'
               AND TRIM(MST.STATUS) = TRIM(CD1.CDVAL)
               AND mst.acctno = od.seacctno (+)
               and mst.afactype =rsk1.actype(+) and mst.codeid=rsk1.codeid(+);

        /*SELECT CF.CUSTODYCD,MST.ACCTNO, MST.AFACCTNO,MST.ACTYPE, MST.LASTDATE, MST.CODEID, MST.STATUS,
               MST.COSTPRICE, MST.TRADE-NVL(B.SECUREAMT,0) TRADE,
                 MST.WTRADE, MST.MORTAGE-NVL(B.SECUREMTG,0) MORTAGE , MST.NETTING,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) SECURED,
                 MST.WITHDRAW, MST.BLOCKED, MST.DEPOSIT, MST.SENDDEPOSIT,MST.PREVQTTY,
                 MST.DTOCLOSE,MST.DCRQTTY,MST.DCRAMT,
                 MST.RECEIVING, CCY.SYMBOL, CD1.CDCONTENT DESC_STATUS,
                 ABS(STANDING) ABSTANDING, MST.TRADE-NVL(B.SECUREAMT,0) AVLWITHDRAW,
                 (MST.TRADE+MST.MORTAGE+MST.BLOCKED+MST.NETTING+MST.WTRADE) TOTAL_QTTY,
                  NVL(DF.DEALQTTY,0) DEAL_QTTY,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T0,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T1,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T2,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY=3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_T3,
                 (CASE WHEN ST.DUETYPE='RS' AND ST.TDAY>3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_RECEIVING_TN,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=0 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T0,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=-1 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T1,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=-2 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T2,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=-3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_T3,
                 (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY<-3 THEN ST.ST_QTTY ELSE 0 END) SECURITIES_SENDING_TN,
                 af.CAREBY,
                 NVL(B.SECUREAMT,0)+NVL(B.SECUREMTG,0) - (CASE WHEN ST.DUETYPE='SS' AND ST.NDAY=0 THEN ST.ST_QTTY ELSE 0 END) REMAINQTTY,
                 NVL(DTL.QTTY,0) RESTRICTQTTY
              FROM AFMAST AF, SEMAST MST,CFMAST CF, ALLCODE CD1, v_getsellorderinfo B,SBSECURITIES CCY,
                   (SELECT * FROM VW_BD_PENDING_SETTLEMENT WHERE DUETYPE='RS' OR DUETYPE='SS') ST,
                   (SELECT DF.CODEID, DF.AFACCTNO,  SUM(DF.DFQTTY+DF.RCVQTTY+DF.BLOCKQTTY+DF.CARCVQTTY) DEALQTTY
                        FROM DFMAST DF WHERE DF.STATUS IN ('P','A','N') GROUP BY DF.CODEID, DF.AFACCTNO) DF,
                   (select acctno, sum(qtty) qtty
                    from semastdtl
                        where QTTYTYPE ='002' and qtty>0
                        and deltd <> 'Y'
                    group by acctno) dtl
              WHERE AF.ACCTNO = MST.AFACCTNO AND AF.CUSTID= CF.CUSTID
               AND MST.ACCTNO=B.SEACCTNO(+)
               AND MST.ACCTNO=dtl.ACCTNO(+)
               AND MST.ACCTNO = p_acctno
               AND MST.CODEID= CCY.CODEID and CCY.SECTYPE<>'004'
               AND MST.AFACCTNO=ST.AFACCTNO (+) AND MST.CODEID=ST.CODEID (+)
               AND MST.AFACCTNO=DF.AFACCTNO (+) AND MST.CODEID=DF.CODEID (+)
               AND TRIM(CD1.CDTYPE) = 'SE' AND TRIM(CD1.CDNAME)='STATUS'
               AND TRIM(MST.STATUS) = TRIM(CD1.CDVAL);*/





        --commit;
        PLOG.debug(pkgctx,'End pr_gen_buf_se_account' || p_acctno);
    end if;

    -- dong bo gia von giua ma thuong va ma wft
    begin
       if p_acctno is null or p_acctno='ALL' then
           plog.error(pkgctx, 'gen buff ALL begin:=' || systimestamp);
            insert into buf_se_account select * from buf_se_account_log;
            update buf_se_account s
            set avgcostprice = (select CEIL(b.newcostprice)newcostprice from (select nvl(sb.refcodeid , buf.codeid) codeid,buf.afacctno,
                                                        case when sum(buf.QTTY) =0 then 0 else nvl(sum(buf.QTTY*buf.avgcostprice)/sum(buf.QTTY),0) end newcostprice
                                                        from (select (trade+receiving+buyqtty-buyingqtty+SECURED)QTTY,l.* from buf_se_account_log l) buf, sbsecurities sb
                                                        where buf.codeid = sb.codeid
                                                        group by nvl(sb.refcodeid , buf.codeid) ,buf.afacctno)b
                                 where s.afacctno =b.afacctno and (s.codeid =b.codeid) )
            where  instr(s.symbol,'WFT')=0;



            update (select se.*,ss.refcodeid from buf_se_account se , sbsecurities ss where instr(se.symbol,'WFT')>0 and  se.codeid =ss.codeid )aa
            set aa.avgcostprice = ((select CEIL(b.newcostprice)newcostprice from (select nvl(sb.refcodeid , buf.codeid) codeid,buf.afacctno,
                                                        case when sum(buf.QTTY) =0 then 0 else nvl(sum(buf.QTTY*buf.avgcostprice)/sum(buf.QTTY),0) end newcostprice
                                                        from  (select (trade+receiving+buyqtty-buyingqtty+SECURED)QTTY,l.* from buf_se_account_log l) buf, sbsecurities sb
                                                        where buf.codeid = sb.codeid
                                                        group by nvl(sb.refcodeid , buf.codeid) ,buf.afacctno)b
                                 where aa.afacctno =b.afacctno and (aa.refcodeid =b.codeid) ));
          plog.error(pkgctx, 'gen buff ALL end:=' || systimestamp);
       else
          plog.error(pkgctx, 'gen buff begin:='||p_acctno||':' || systimestamp);
           insert into buf_se_account select distinct  se.* from buf_se_account_log se where afacctno= substr(p_acctno,1,10);
            update buf_se_account s
            set avgcostprice = (select CEIL(b.newcostprice)newcostprice from (select nvl(sb.refcodeid , buf.codeid) codeid,buf.afacctno,
                                                        case when sum(buf.QTTY) =0 then 0 else nvl(sum(buf.QTTY*buf.avgcostprice)/sum(buf.QTTY),0) end newcostprice
                                                        from  (select (trade+receiving+buyqtty-buyingqtty+SECURED)QTTY,l.* from buf_se_account_log l) buf, sbsecurities sb
                                                        where buf.codeid = sb.codeid and buf.afacctno= substr(p_acctno,1,10)
                                                        group by nvl(sb.refcodeid , buf.codeid) ,buf.afacctno)b
                                 where s.afacctno =b.afacctno and (s.codeid =b.codeid) )
            where  instr(s.symbol,'WFT')=0 and s.afacctno= substr(p_acctno,1,10);

            update (select se.*,ss.refcodeid from buf_se_account se , sbsecurities ss where instr(se.symbol,'WFT')>0 and  se.codeid =ss.codeid and se.afacctno =substr(p_acctno,1,10))aa
            set aa.avgcostprice = (select CEIL(b.newcostprice)newcostprice from (select nvl(sb.refcodeid , buf.codeid) codeid,buf.afacctno,
                                                        case when sum(buf.QTTY) =0 then 0 else nvl(sum(buf.QTTY*buf.avgcostprice)/sum(buf.QTTY),0) end newcostprice
                                                        from  (select (trade+receiving+buyqtty-buyingqtty+SECURED)QTTY,l.* from buf_se_account_log l) buf, sbsecurities sb
                                                        where buf.codeid = sb.codeid and buf.afacctno= substr(p_acctno,1,10)
                                                        group by nvl(sb.refcodeid , buf.codeid) ,buf.afacctno)b
                                 where aa.afacctno =b.afacctno and (aa.refcodeid =b.codeid));
          plog.error(pkgctx, 'gen buff end:='||p_acctno||':' || systimestamp);
       end if;
    end;


    plog.setENDsection(pkgctx, 'pr_gen_buf_se_account');
EXCEPTION WHEN others THEN
    plog.error(pkgctx, 'Error when then Account p_acctno:=' || nvl(p_acctno,'NULL'));
    plog.error(pkgctx, sqlerrm || 'Loi tai dong:' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_gen_buf_se_account');
END pr_gen_buf_se_account;

PROCEDURE pr_gen_buf_od_account (p_acctno varchar2 default null)
  IS
BEGIN
    plog.setBeginsection(pkgctx, 'pr_gen_buf_od_account');
    if p_acctno is null or p_acctno='ALL' then
        PLOG.INFO(pkgctx,'Begin pr_gen_buf_od_account');
        plog.error('day la log');
        delete from buf_od_account;
        --commit;
        INSERT INTO buf_od_account (PRICETYPE,DESC_EXECTYPE,SYMBOL,ORSTATUS,
               QUOTEPRICE,ORDERQTTY,REMAINQTTY,EXECQTTY,EXECAMT,
               CANCELQTTY,ADJUSTQTTY,AFACCTNO,CUSTODYCD,FEEDBACKMSG,
               EXECTYPE,CODEID,BRATIO,ORDERID,REFORDERID,TXDATE,TXTIME,SDTIME,
               TLNAME,CTCI_ORDER,TRADEPLACE,EDSTATUS,VIA,TIMETYPE,
               MATCHTYPE,CLEARDAY,EFFDATE,EXPDATE,CAREBY,ORSTATUSVALUE,HOSESESSION, USERNAME, ISCANCEL, ISADMEND,
               ROOTORDERID,TIMETYPEVALUE,MATCHTYPEVALUE,FOACCTNO,ISDISPOSAL,QUOTEQTTY ,LIMITPRICE , CONFIRMED, EN_ORSTATUS)
          SELECT PRICETYPE, DESC_EXECTYPE, SYMBOL, DESC_STATUS ORSTATUS, --CANCELSTATUS,
                  QUOTEPRICE/1000 QUOTEPRICE, QUANTITY ORDERQTTY, REMAINQTTY, EXECQTTY, EXECAMT, CANCELQTTY, ADJUSTQTTY,
                  AFACCTNO, CUSTODYCD, FEEDBACKMSG, EXECTYPE, CODEID, BRATIO, ACCTNO ORDERID, REFORDERID, TXDATE, DTL.TXTIME, SDTIME,
                  upper(tlname) tlname,CTCI_ORDER,tradeplace,edstatus,via,timetype,matchtype,clearday,effdate,expdate,CAREBY,ORSTATUSVALUE,HOSESESSION,
                  USERNAME, ISCANCEL, ISADMEND, ROOTORDERID, TIMETYPEVALUE,MATCHTYPEVALUE,FOACCTNO,ISDISPOSAL,QUOTEQTTY ,LIMITPRICE/1000 , CONFIRMED,
                  EN_DESC_STATUS EN_ORSTATUS
              FROM
              -- OD
              (SELECT CFMAST.CUSTODYCD, MST.TXDATE, MST.REFORDERID, MST.AFACCTNO, MST.orderid ACCTNO, '' ORGACCTNO, MST.EXECTYPE,MST.REFORDERID REFACCTNO,
                  MST.PRICETYPE, CD2.cdcontent DESC_EXECTYPE, TO_CHAR(sb.SYMBOL) SYMBOL, MST.orderqtty QUANTITY, MST.exprice PRICE,   TO_CHAR(CD0.cdcontent) feedbackmsg,
                  MST.QUOTEPRICE, 'Active' DESC_BOOK, MST.orstatus status,
                  --CD1.cdcontent DESC_STATUS,
                  case when  mst.cancelstatus ='N' then cd1.cdcontent else cd12.cdcontent end DESC_STATUS,
                  case when  mst.cancelstatus ='N' then cd1.en_cdcontent else cd12.en_cdcontent end EN_DESC_STATUS,
                  CD4.cdcontent DESC_TIMETYPE,
                  CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE, NVL(OOD.TXTIME,'') SDTIME,
                  MST.EXECQTTY, MST.EXECAMT, (CASE WHEN MST.EXECQTTY>0 THEN ROUND(MST.EXECAMT/1000/MST.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, MST.REMAINQTTY, mst.txtime, mst.CANCELQTTY, mst.ADJUSTQTTY,'A' BOOK,CD8.cdcontent VIA,mst.VIA VIACD,
                  (CASE WHEN MST.CANCELQTTY>0 THEN 'Cancelled'  WHEN MST.EDITSTATUS='C' THEN 'Cancelling' ELSE '----' END) CANCELSTATUS,(CASE WHEN MST.ADJUSTQTTY>0 THEN 'Amended'  WHEN MST.EDITSTATUS='A' THEN 'Amending' ELSE '----' END) AMENDSTATUS,
                  SYS.SYSVALUE CURRSECSSION,MST.HOSESESSION ODSECSSION, nvl(f.username,nvl(mk.tlname,'Auto')) maker, MST.CODEID, MST.BRATIO,
                  nvl(mk.tlname,mst.tlid) tlname,to_char(MAP.CTCI_ORDER) CTCI_ORDER,
                  cd10.cdcontent tradeplace,mst.EDITSTATUS edstatus,cd4.cdcontent timetype,cd5.cdcontent matchtype,mst.clearday,mst.txdate effdate,mst.expdate,
                  cf.CAREBY, MST.ORSTATUSVALUE,MST.HOSESESSION, MST.CUSTID USERNAME, MST.ISCANCEL ISCANCEL, MST.ISADMEND ISADMEND, MST.ROOTORDERID ROOTORDERID,
                  MST.TIMETYPE TIMETYPEVALUE, MST.MATCHTYPE MATCHTYPEVALUE,
                  CASE WHEN MST.ORDERID = F.orgacctno THEN F.acctno ELSE MST.ORDERID END FOACCTNO,mst.ISDISPOSAL,mst.quoteqtty , mst.limitprice , mst.confirmed
              FROM CFMAST, AFMAST CF, (select * from ood union select * from oodhist) OOD,
                (SELECT MST.*,
                   (CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C'
                        WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A'
                       -- Ducnv FF Gateway
                       --WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 then '5'
                       WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 and MST.ORSTATUS <> '6' THEN '5'
                       WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 and MST.ORSTATUS = '6' THEN '6'
                       --end Ducnv FF Gateway
                        WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3'
                        when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10'
                        WHEN MST.REMAINQTTY = 0 AND MST.EXECQTTY>0 AND MST.ORSTATUS = '4' THEN '12' ELSE MST.ORSTATUS END) ORSTATUSVALUE,
                   (CASE WHEN MST.ISBUYIN = 'N' AND ((MST.REMAINQTTY > 0 AND (MST.EDITSTATUS IS NULL OR MST.EDITSTATUS IN ('N')) AND MST.ORSTATUS IN ('8','2','4')
                            AND MST.MATCHTYPE = 'N' and MST.PRICETYPE<>'PLO') or (MST.PRICETYPE='PLO' and MST.ORSTATUS IN ('8')))
                            THEN 'Y' ELSE 'N' END) ISCANCEL,
                   --(CASE WHEN MST.REMAINQTTY > 0 AND (MST.EDITSTATUS IS NULL OR MST.EDITSTATUS IN ('N')) AND MST.ORSTATUS IN ('2','4','8')
                   --         AND MST.MATCHTYPE = 'N' AND MST.TRADEPLACE IN ('002','005') /*AND MST.ISDISPOSAL = 'N'*/
                   --         AND MST.TIMETYPE <> 'G' AND MST.PRICETYPE NOT IN ('MOK','MAK','ATO','ATC') THEN 'Y' ELSE 'N' END) ISADMEND,
                   --Them dieu kien cho sua lenh HNX va UPCOM khi trang thai dang cho gui
                   (CASE WHEN MST.ISBUYIN = 'N' AND MST.REMAINQTTY > 0 AND (MST.EDITSTATUS IS NULL OR MST.EDITSTATUS IN ('N')) AND MST.ORSTATUS IN ('2','4','8')
                            AND MST.MATCHTYPE = 'N' AND MST.TRADEPLACE IN ('001','002','005') /*AND MST.ISDISPOSAL = 'N'*/
                            AND MST.TIMETYPE <> 'G' AND (MST.PRICETYPE ='LO' or (MST.PRICETYPE='MTL' AND MST.ORSTATUS IN ('2','4')) or (MST.PRICETYPE='MP' AND MST.ORSTATUS IN ('2','4'))) THEN 'Y' ELSE 'N' END) ISADMEND,
                    fn_GetRootOrderID(MST.ORDERID) ROOTORDERID
                FROM
                    (SELECT OD1.*,OD2.EDSTATUS EDITSTATUS, SB.TRADEPLACE
                     from odmast OD1,
                     --DUCNV FF GATEWAY
                     (  SELECT *
                        FROM ODMAST
                        WHERE EDSTATUS IN ('C','A')
                         --PHUONGNTN ADD KO LAY LENH HUY/SUA BI TU CHOI
                          AND ORSTATUS <> '6' AND EXECTYPE IN ('AS','AB','CB','CS')
                     --END DUCNV FF GATEWAY
                     ) OD2,
                     SBSECURITIES SB
                     WHERE OD1.ORDERID=OD2.REFORDERID(+) AND substr(OD1.EXECTYPE,1,1) <> 'C'
                        AND substr(OD1.EXECTYPE,1,1) <> 'A'
                        AND SB.CODEID = OD1.CODEID
                   ) MST
                ) MST,sbsecurities sb,
                   --TLLOG TL,
                  ALLCODE CD0,ALLCODE CD1, ALLCODE CD2, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6, ALLCODE CD7, ALLCODE CD8, ALLCODE CD10,ALLCODE CD12,
                  ORDERSYS SYS,tlprofiles mk,fomast f,ordermap MAP
              WHERE MST.ORSTATUS <> '7' AND CF.ACCTNO=MST.AFACCTNO
                  --AND MST.AFACCTNO=V_PARAFILTER
                  AND MST.orderid=OOD.ORGORDERID(+)
                  --AND MST.TXNUM=TL.TXNUM(+) AND MST.TXDATE=TL.TXDATE(+) AND NVL(TL.TXSTATUS,'1')='1'
                  AND CFMAST.CUSTID=CF.CUSTID and sb.codeid = mst.codeid
                  AND CD0.CDNAME = 'ORSTATUS' AND CD0.CDTYPE ='OD' AND CD0.CDVAL=MST.ORSTATUS
                  AND CD1.cdtype ='OD' AND CD1.CDNAME='ORSTATUS'
                  AND CD1.CDVAL= MST.ORSTATUSVALUE--(CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C' WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A' WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 THEN '5' WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3' when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10' ELSE MST.ORSTATUS END)
                  AND SYS.SYSNAME='CONTROLCODE'
                  AND MAP.ORGORDERID(+)=ood.orgorderid
                  AND CD2.cdtype ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                  AND CD4.cdtype ='OD' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                  AND CD5.cdtype ='OD' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                  AND CD6.cdtype ='OD' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                  AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=MST.VIA
                  AND CD10.cdtype ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=sb.TRADEPLACE
                  AND cd12.cdtype = 'OD' AND cd12.cdname = 'CANCELSTATUS' and cd12.cdval=MST.cancelstatus
                  --AND EXISTS (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE' AND MST.TXDATE = TO_DATE(VARVALUE,'DD/MM/YYYY'))
                  AND CD7.cdtype ='OD' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE and mst.tlid =mk.tlid (+)
                  and mst.orderid = f.orgacctno(+) and mst.exectype = f.exectype(+)
              UNION ALL
              -- OD + FO
              SELECT CFMAST.CUSTODYCD, MST.EFFDATE TXDATE, '' REFORDERID, MST.AFACCTNO, MST.ACCTNO, MST.ORGACCTNO, MST.EXECTYPE,MST.REFACCTNO REFACCTNO, MST.PRICETYPE,
                  CD2.cdcontent DESC_EXECTYPE, MST.SYMBOL, MST.QUANTITY, (MST.PRICE * 1000) PRICE, MST.feedbackmsg,
                  MST.QUOTEPRICE, TO_CHAR(CD3.cdcontent) DESC_BOOK, MST.STATUS,
                  --CD9.cdcontent DESC_STATUS,
                  case when  REFOD.cancelstatus ='N' then cd9.cdcontent else cd12.cdcontent end DESC_STATUS,
                  case when  REFOD.cancelstatus ='N' then cd9.en_cdcontent else cd12.en_cdcontent end EN_DESC_STATUS,
                  CD4.cdcontent DESC_TIMETYPE,
                  CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE, NVL(OOD.TXTIME,'') SDTIME,
                  REFOD.EXECQTTY, REFOD.EXECAMT,(CASE WHEN REFOD.EXECQTTY>0 THEN ROUND(REFOD.EXECAMT/1000/REFOD.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, REFOD.REMAINQTTY, SUBSTR(MST.activatedt,12,9) txtime, REFOD.CANCELQTTY, REFOD.ADJUSTQTTY ,MST.BOOK BOOK,CD8.cdcontent VIA,REFOD.VIA VIACD,
                  (CASE WHEN REFOD.CANCELQTTY>0 THEN 'Cancelled'  WHEN REFOD.EDITSTATUS='C' THEN 'Cancelling' ELSE '----' END) CANCELSTATUS,(CASE WHEN REFOD.ADJUSTQTTY>0 THEN 'Amended' WHEN REFOD.EDITSTATUS='A' THEN 'Amending' ELSE '----' END) AMENDSTATUS,
                  SYS.SYSVALUE CURRSECSSION,REFOD.HOSESESSION ODSECSSION,MST.Username maker, MST.CODEID, MST.BRATIO,
                   nvl(tlpro.tlname,REFOD.TLID) tlname, to_char(MAP.CTCI_ORDER) CTCI_ORDER,
                   cd10.cdcontent tradeplace,nvl(REFOD.EDITSTATUS,'N') edstatus,cd4.cdcontent timetype,cd5.cdcontent matchtype,mst.clearday,mst.effdate,mst.expdate,
                   cf.CAREBY, REFOD.ORSTATUSVALUE ORSTATUSVALUE, '-' hosesession, MST.USERNAME USERNAME, REFOD.ISCANCEL, REFOD.ISADMEND, REFOD.ROOTORDERID,
                   REFOD.TIMETYPE TIMETYPEVALUE, REFOD.MATCHTYPE MATCHTYPEVALUE,
                   CASE WHEN REFOD.ORDERID = MST.orgacctno THEN MST.acctno ELSE REFOD.ORDERID END FOACCTNO,nvl(REFOD.ISDISPOSAL,'N') ISDISPOSAL,mst.quoteqtty , mst.limitprice , mst.confirmed
              FROM CFMAST, AFMAST CF, (select * from ood union select * from oodhist) OOD, FOMAST MST,
                (select OD1.*,OD2.EDSTATUS EDITSTATUS,
                    (CASE WHEN OD1.REMAINQTTY > 0 AND OD2.EDSTATUS='C' THEN 'C'
                          WHEN OD1.REMAINQTTY > 0 AND OD2.EDSTATUS='A' THEN 'A'
                          --Ducnv FF GATEWAY
                          --WHEN OD2.EDSTATUS IS NULL AND OD1.CANCELQTTY > 0 THEN '5'
                          WHEN OD2.EDSTATUS IS NULL AND OD1.CANCELQTTY > 0  and OD1.ORSTATUS <> '6' THEN '5'
                          WHEN OD2.EDSTATUS IS NULL AND OD1.CANCELQTTY > 0  and OD1.ORSTATUS = '6' THEN '6'
                          --end Ducnv FF GATEWAY
                          WHEN OD1.REMAINQTTY = 0 AND OD1.CANCELQTTY > 0 AND OD2.EDSTATUS='C' THEN '3'
                          when OD1.REMAINQTTY = 0 and OD1.ADJUSTQTTY>0 then '10'
                          WHEN OD1.REMAINQTTY = 0 AND OD1.EXECQTTY>0 AND OD1.ORSTATUS = '4' THEN '12' ELSE OD1.ORSTATUS END) ORSTATUSVALUE,
                    (CASE WHEN OD1.ISBUYIN = 'N' AND ((OD1.REMAINQTTY > 0 AND (OD2.EDSTATUS IS NULL OR OD2.EDSTATUS IN ('N')) AND OD1.ORSTATUS IN ('8','2','4')
                            AND OD1.MATCHTYPE = 'N' and OD1.PRICETYPE<>'PLO') or (OD1.PRICETYPE='PLO' and OD1.ORSTATUS IN ('8')))
                            THEN 'Y' ELSE 'N' END) ISCANCEL,

                --(CASE WHEN OD1.REMAINQTTY > 0 AND (OD2.EDSTATUS IS NULL OR OD2.EDSTATUS IN ('N')) AND OD1.ORSTATUS IN ('2','4')
                --            AND OD1.MATCHTYPE = 'N' AND SB.TRADEPLACE IN ('002','005') /*AND OD1.ISDISPOSAL = 'N'*/
                --            AND OD1.TIMETYPE <> 'G' AND OD1.PRICETYPE NOT IN ('MOK','MAK','ATO','ATC') THEN 'Y' ELSE 'N' END) ISADMEND,
                --Them dieu kien cho sua lenh HNX va UPCOM khi trang thai dang cho gui
                (CASE WHEN OD1.ISBUYIN = 'N' AND OD1.REMAINQTTY > 0 AND (OD2.EDSTATUS IS NULL OR OD2.EDSTATUS IN ('N')) AND OD1.ORSTATUS IN ('2','4','8')
                            AND OD1.MATCHTYPE = 'N' AND SB.TRADEPLACE IN ('001','002','005') /*AND OD1.ISDISPOSAL = 'N'*/
                            AND OD1.TIMETYPE <> 'G' AND (OD1.PRICETYPE ='LO' or (OD1.PRICETYPE='MTL' AND OD1.ORSTATUS IN ('2','4')) or (OD1.PRICETYPE='MP' AND OD1.ORSTATUS IN ('2','4'))) THEN 'Y' ELSE 'N' END) ISADMEND,
                   fn_GetRootOrderID(OD1.ORDERID)  ROOTORDERID
                    from odmast OD1,
                    --Ducnv FF GATEWAY
                    (SELECT *
                        FROM ODMAST
                        WHERE EDSTATUS IN ('C','A')
                     AND ORSTATUS <>'6'
                     --END Ducnv FF GATEWAY
                        ) OD2,
                    SBSECURITIES SB
                WHERE OD1.ORDERID=OD2.REFORDERID(+) AND substr(OD1.EXECTYPE,1,1) <> 'C'
                    AND substr(OD1.EXECTYPE,1,1) <> 'A'
                    AND OD1.CODEID = SB.CODEID) REFOD,
                  ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6,
                  ALLCODE CD7, ALLCODE CD8, ALLCODE CD9 ,ALLCODE CD10,ALLCODE CD12,
                  ORDERSYS SYS,sbsecurities sb,
                  tlprofiles tlpro,ordermap MAP
              WHERE  REFOD.ORSTATUS <> '7' AND MST.DELTD='N' AND CF.ACCTNO=MST.AFACCTNO
                  --AND MST.AFACCTNO=V_PARAFILTER
                  AND MST.ACCTNO=OOD.ORGORDERID(+)
                  AND MST.STATUS = 'A' AND MST.acctno = mst.orgacctno
                  AND MST.CODEID=SB.CODEID
                  AND CD1.cdtype ='FO' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.STATUS
                  AND SYS.SYSNAME='CONTROLCODE'  AND CFMAST.CUSTID=CF.CUSTID
                  AND CD2.cdtype ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                  AND CD3.cdtype ='FO' AND CD3.CDNAME='BOOK' AND CD3.CDVAL=MST.BOOK
                  AND CD4.cdtype ='FO' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                  AND CD5.cdtype ='FO' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                  AND CD6.cdtype ='FO' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                  AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=REFOD.VIA
                  AND CD7.cdtype ='FO' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
                  AND CD9.cdtype ='OD' AND CD9.CDNAME='ORSTATUS' AND CD9.CDVAL=REFOD.ORSTATUSVALUE
                  AND CD10.cdtype ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=sb.TRADEPLACE
                  AND cd12.cdtype = 'OD' AND cd12.cdname = 'CANCELSTATUS' and cd12.cdval=REFOD.cancelstatus
                  --AND EXISTS (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE' AND REFOD.TXDATE =  TO_DATE(VARVALUE,'DD/MM/YYYY'))
                  AND MST.ORGACCTNO=REFOD.ORDERID
                   AND REFOD.TLID=tlpro.tlid(+)
                  AND MAP.ORGORDERID(+)=REFOD.orderid
              UNION ALL
              -- FO
              SELECT CFMAST.CUSTODYCD, MST.EFFDATE TXDATE,'' REFORDERID, MST.AFACCTNO, MST.ACCTNO, MST.ORGACCTNO, MST.EXECTYPE,(CASE WHEN MST.STATUS='R' THEN '' ELSE MST.REFACCTNO END) REFACCTNO, MST.PRICETYPE,
                  CD2.cdcontent DESC_EXECTYPE, MST.SYMBOL, MST.QUANTITY-NVL(ROOT.ORDERQTTY,0) QUANTITY,(MST.PRICE * SYINFO.TRADEUNIT) PRICE, MST.feedbackmsg,
                  MST.QUOTEPRICE* SYINFO.TRADEUNIT QUOTEPRICE, TO_CHAR(CD3.cdcontent) DESC_BOOK, MST.STATUS,
                  CD1.cdcontent DESC_STATUS,
                  CD1.en_cdcontent EN_DESC_STATUS,
                  CD4.cdcontent DESC_TIMETYPE,
                  CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE, NVL(OOD.TXTIME,'') SDTIME,
                  MST.EXECQTTY, MST.EXECAMT,(CASE WHEN MST.EXECQTTY>0 THEN ROUND(MST.EXECAMT/1000/MST.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, MST.REMAINQTTY-NVL(ROOT.ORDERQTTY,0) REMAINQTTY, SUBSTR(MST.activatedt,12,9) txtime, mst.CANCELQTTY , mst.AMENDQTTY ADJUSTQTTY,MST.BOOK BOOK,CD8.cdcontent VIA,'T' VIACD,('----') CANCELSTATUS,('----') AMENDSTATUS,
                  SYS.SYSVALUE CURRSECSSION,'N' ODSECSSION,MST.Username maker, MST.CODEID, MST.BRATIO,
                   nvl(tlpro.tlname,mst.tlid) tlname, '' CTCI_ORDER,
                  cd10.cdcontent tradeplace,'N' edstatus,cd4.cdcontent timetype,cd5.cdcontent matchtype,mst.clearday,mst.effdate,mst.expdate,
                  cf.CAREBY, MST.STATUS ORSTATUSVALUE,'-' HOSESESSION, MST.USERNAME USERNAME,
                  CASE WHEN MST.ISBUYIN = 'N' AND MST.STATUS IN ('P','I','A','W') /*AND MST.ISDISPOSAL = 'N'*/ THEN 'Y' ELSE 'N' END ISCANCEL,
                  CASE WHEN MST.ISBUYIN = 'N' AND MST.STATUS IN ('P','I','A','W') AND SB.TRADEPLACE IN ('001','002','005') /*AND MST.ISDISPOSAL = 'N'*/
                  AND MST.TIMETYPE <> 'G' AND MST.PRICETYPE NOT IN ('MOK','MAK','ATO','ATC') THEN 'Y' ELSE 'N' END ISADMEND,
                  MST.ACCTNO ROOTORDERID, MST.TIMETYPE TIMETYPEVALUE, MST.MATCHTYPE MATCHTYPEVALUE, NVL(MST.ACCTNO,'') FOACCTNO, nvl(mst.ISDISPOSAL,'N') ISDISPOSAL,mst.quoteqtty , mst.limitprice , mst.confirmed
              FROM CFMAST, AFMAST CF, OOD, FOMAST MST, SECURITIES_INFO SYINFO,
                  ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, ALLCODE CD4, ALLCODE CD5,
                  ALLCODE CD6, ALLCODE CD7, ALLCODE CD8 ,ALLCODE CD10 ,
                  ORDERSYS SYS,sbsecurities sb,
                  (SELECT A.FOACCTNO, SUM (B.ORDERQTTY) ORDERQTTY FROM ROOTORDERMAP A, ODMAST B WHERE A.ORDERID=B.ORDERID AND STATUS='A' GROUP BY A.FOACCTNO) ROOT,
                  tlprofiles tlpro--, ordermap MAP
              WHERE MST.ACCTNO=ROOT.FOACCTNO(+) AND MST.STATUS<>'A' AND substr(MST.EXECTYPE,1,1) <> 'C' AND substr(MST.EXECTYPE,1,1) <> 'A'
              AND MST.DELTD='N' AND CF.ACCTNO=MST.AFACCTNO AND SYINFO.SYMBOL=MST.SYMBOL
                  --AND MST.AFACCTNO=V_PARAFILTER
                  AND MST.codeid= sb.codeid
                  and mst.status <> 'R'
                  AND MST.ACCTNO=OOD.ORGORDERID(+)
                  AND CD1.cdtype ='FO' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.status
                  AND SYS.SYSNAME='CONTROLCODE'  AND CFMAST.CUSTID=CF.CUSTID
                  AND CD2.cdtype ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                  AND CD3.cdtype ='FO' AND CD3.CDNAME='BOOK' AND CD3.CDVAL=MST.BOOK
                  AND CD4.cdtype ='FO' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                  AND CD5.cdtype ='FO' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                  AND CD6.cdtype ='FO' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                  AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=MST.VIA
                  AND CD7.cdtype ='FO' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
                  AND CD10.cdtype ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=sb.TRADEPLACE
                   AND tlpro.tlid(+)= mst.tlid
                  --AND MAP.ORGORDERID(+)= ood.orgorderid
              ) DTL
          ORDER BY REFORDERID, TXDATE DESC, TXTIME DESC, ACCTNO;
          PLOG.info(pkgctx,'End pr_gen_buf_od_account');
          plog.error(pkgctx, 'Error when then Account p_acctno:=' || nvl(p_acctno,'NULL'));
            plog.error(pkgctx, sqlerrm || 'Loi tai dong:' || dbms_utility.format_error_backtrace);
            plog.setendsection(pkgctx, 'pr_gen_buf_od_account');
    else
        PLOG.debug(pkgctx,'Begin pr_gen_buf_od_account' || p_acctno);
        plog.error('day la log'||p_acctno);
        delete from buf_od_account where orderid =p_acctno;
        --commit;
        INSERT INTO buf_od_account (PRICETYPE,DESC_EXECTYPE,SYMBOL,ORSTATUS,
               QUOTEPRICE,ORDERQTTY,REMAINQTTY,EXECQTTY,EXECAMT,
               CANCELQTTY,ADJUSTQTTY,AFACCTNO,CUSTODYCD,FEEDBACKMSG,
               EXECTYPE,CODEID,BRATIO,ORDERID,REFORDERID,TXDATE,TXTIME,SDTIME,
               TLNAME,CTCI_ORDER,TRADEPLACE,EDSTATUS,VIA,TIMETYPE,
               MATCHTYPE,CLEARDAY,EFFDATE,EXPDATE,CAREBY,ORSTATUSVALUE,HOSESESSION, USERNAME, ISCANCEL, ISADMEND,
               ROOTORDERID,TIMETYPEVALUE,MATCHTYPEVALUE,FOACCTNO,ISDISPOSAL,QUOTEQTTY ,LIMITPRICE , CONFIRMED,EN_ORSTATUS)
          SELECT PRICETYPE, DESC_EXECTYPE, SYMBOL, DESC_STATUS ORSTATUS, --CANCELSTATUS,
                  QUOTEPRICE/1000 QUOTEPRICE, QUANTITY ORDERQTTY, REMAINQTTY, EXECQTTY, EXECAMT, CANCELQTTY, ADJUSTQTTY,
                  AFACCTNO, CUSTODYCD, FEEDBACKMSG, EXECTYPE, CODEID, BRATIO, ACCTNO ORDERID, REFORDERID, TXDATE, DTL.TXTIME, SDTIME,
                  upper(tlname) tlname,CTCI_ORDER,tradeplace,edstatus,via,timetype,matchtype,clearday,effdate,expdate,CAREBY,ORSTATUSVALUE,HOSESESSION,
                  USERNAME, ISCANCEL, ISADMEND, ROOTORDERID,TIMETYPEVALUE,MATCHTYPEVALUE,FOACCTNO,ISDISPOSAL,QUOTEQTTY ,LIMITPRICE/1000 , CONFIRMED,
                  EN_DESC_STATUS EN_ORSTATUS
              FROM
              -- OD
              (SELECT CFMAST.CUSTODYCD, MST.TXDATE, MST.REFORDERID, MST.AFACCTNO, MST.orderid ACCTNO, '' ORGACCTNO, MST.EXECTYPE,MST.REFORDERID REFACCTNO,
                  MST.PRICETYPE, CD2.cdcontent DESC_EXECTYPE, TO_CHAR(sb.SYMBOL) SYMBOL, MST.orderqtty QUANTITY, MST.exprice PRICE,   TO_CHAR(CD0.cdcontent) feedbackmsg,
                  MST.QUOTEPRICE, 'Active' DESC_BOOK, MST.orstatus status,
                  --CD1.cdcontent DESC_STATUS,
                  case when  mst.cancelstatus ='N' then cd1.cdcontent else cd12.cdcontent end DESC_STATUS,
                  case when  mst.cancelstatus ='N' then cd1.en_cdcontent else cd12.en_cdcontent end EN_DESC_STATUS,
                  CD4.cdcontent DESC_TIMETYPE,
                  CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE, NVL(OOD.TXTIME,'') SDTIME,
                  MST.EXECQTTY, MST.EXECAMT, (CASE WHEN MST.EXECQTTY>0 THEN ROUND(MST.EXECAMT/1000/MST.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, MST.REMAINQTTY, mst.txtime, mst.CANCELQTTY, mst.ADJUSTQTTY,'A' BOOK,CD8.cdcontent VIA,mst.VIA VIACD,
                  (CASE WHEN MST.CANCELQTTY>0 THEN 'Cancelled'  WHEN MST.EDITSTATUS='C' THEN 'Cancelling' ELSE '----' END) CANCELSTATUS,(CASE WHEN MST.ADJUSTQTTY>0 THEN 'Amended'  WHEN MST.EDITSTATUS='A' THEN 'Amending' ELSE '----' END) AMENDSTATUS,
                  SYS.SYSVALUE CURRSECSSION,MST.HOSESESSION ODSECSSION, nvl(f.username,nvl(mk.tlname,'Auto')) maker, MST.CODEID, MST.BRATIO,
                  nvl(mk.tlname,mst.tlid) tlname,to_char(MAP.CTCI_ORDER) CTCI_ORDER,
                  cd10.cdcontent tradeplace,mst.EDITSTATUS edstatus,cd4.cdcontent timetype,cd5.cdcontent matchtype,mst.clearday,mst.txdate effdate,mst.expdate,
                  cf.CAREBY, MST.ORSTATUSVALUE,MST.HOSESESSION, MST.CUSTID USERNAME, MST.ISCANCEL ISCANCEL, MST.ISADMEND ISADMEND, MST.ROOTORDERID ROOTORDERID,
                  MST.TIMETYPE TIMETYPEVALUE, MST.MATCHTYPE MATCHTYPEVALUE,
                  CASE WHEN MST.ORDERID = F.orgacctno THEN F.acctno ELSE MST.ORDERID END FOACCTNO,mst.ISDISPOSAL,mst.quoteqtty , mst.limitprice , mst.confirmed
              FROM CFMAST, AFMAST CF, (select * from ood union select * from oodhist) OOD,
                (SELECT MST.*,
                   (CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C'
                        WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A'
                       -- Ducnv FF GATEWAY
                       --WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 then '5'
                       WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 and MST.ORSTATUS <> '6' THEN '5'
                       WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 and MST.ORSTATUS = '6' THEN '6'
                      -- end Ducnv FF GATEWAY
                        WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3'
                        when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10'
                        WHEN MST.REMAINQTTY = 0 AND MST.EXECQTTY>0 AND MST.ORSTATUS = '4' THEN '12' ELSE MST.ORSTATUS END) ORSTATUSVALUE,
                   (CASE WHEN MST.ISBUYIN = 'N' AND ((MST.REMAINQTTY > 0 AND (MST.EDITSTATUS IS NULL OR MST.EDITSTATUS IN ('N')) AND MST.ORSTATUS IN ('8','2','4')
                            AND MST.MATCHTYPE = 'N' and MST.PRICETYPE<>'PLO') or (MST.PRICETYPE='PLO' and MST.ORSTATUS IN ('8')))
                            THEN 'Y' ELSE 'N' END) ISCANCEL,
                   --(CASE WHEN MST.REMAINQTTY > 0 AND (MST.EDITSTATUS IS NULL OR MST.EDITSTATUS IN ('N')) AND MST.ORSTATUS IN ('2','4')
                   --         AND MST.MATCHTYPE = 'N' AND MST.TRADEPLACE IN ('002','005') /*AND MST.ISDISPOSAL = 'N'*/
                   --         AND MST.TIMETYPE <> 'G' AND MST.PRICETYPE NOT IN ('MOK','MAK','ATO','ATC') THEN 'Y' ELSE 'N' END) ISADMEND,
                   --Them dieu kien cho sua lenh HNX va UPCOM khi trang thai dang cho gui
                   (CASE WHEN MST.ISBUYIN = 'N' AND MST.REMAINQTTY > 0 AND (MST.EDITSTATUS IS NULL OR MST.EDITSTATUS IN ('N')) AND MST.ORSTATUS IN ('2','4','8')
                            AND MST.MATCHTYPE = 'N' AND MST.TRADEPLACE IN ('001','002','005') /*AND MST.ISDISPOSAL = 'N'*/
                            AND MST.TIMETYPE <> 'G' AND (MST.PRICETYPE ='LO' or (MST.PRICETYPE='MTL' AND MST.ORSTATUS IN ('2','4')) or (MST.PRICETYPE='MP' AND MST.ORSTATUS IN ('2','4'))) THEN 'Y' ELSE 'N' END) ISADMEND,
                    fn_GetRootOrderID(MST.ORDERID) ROOTORDERID
                FROM
                    (SELECT OD1.*,OD2.EDSTATUS EDITSTATUS, SB.TRADEPLACE
                     from odmast OD1,
                     --End Ducnv FF Gateway
                     (SELECT * FROM ODMAST
                     WHERE EDSTATUS IN ('C','A')
                     --PHUONGNTN ADD KO LAY LENH HUY/SUA BI TU CHOI
                     AND ORSTATUS <>'6' AND EXECTYPE IN ('AS','AB','CB','CS')
                     --END ADD
                     ) OD2,
                     --End Ducnv FF Gateway
                     SBSECURITIES SB
                     WHERE OD1.ORDERID=OD2.REFORDERID(+) AND substr(OD1.EXECTYPE,1,1) <> 'C'
                        AND substr(OD1.EXECTYPE,1,1) <> 'A'
                        AND SB.CODEID = OD1.CODEID
                   ) MST
                ) MST,sbsecurities sb,
                   --TLLOG TL,
                  ALLCODE CD0,ALLCODE CD1, ALLCODE CD2, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6, ALLCODE CD7, ALLCODE CD8, ALLCODE CD10,ALLCODE CD12,
                  ORDERSYS SYS,tlprofiles mk,fomast f,
                  ordermap MAP
              WHERE MST.ORSTATUS <> '7' AND CF.ACCTNO=MST.AFACCTNO
                  --AND MST.AFACCTNO=V_PARAFILTER
                  AND MST.ORDERID = p_acctno
                  AND MST.orderid=OOD.ORGORDERID(+)
                  --AND MST.TXNUM=TL.TXNUM(+) AND MST.TXDATE=TL.TXDATE(+) AND NVL(TL.TXSTATUS,'1')='1'
                  AND CFMAST.CUSTID=CF.CUSTID and sb.codeid = mst.codeid
                  AND CD0.CDNAME = 'ORSTATUS' AND CD0.CDTYPE ='OD' AND CD0.CDVAL=MST.ORSTATUS
                  AND CD1.cdtype ='OD' AND CD1.CDNAME='ORSTATUS'
                  AND CD1.CDVAL= MST.ORSTATUSVALUE--(CASE WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='C' THEN 'C' WHEN MST.REMAINQTTY <> 0 AND MST.EDITSTATUS='A' THEN 'A' WHEN MST.EDITSTATUS IS NULL AND MST.CANCELQTTY <> 0 THEN '5' WHEN MST.REMAINQTTY = 0 AND MST.CANCELQTTY <> 0 AND MST.EDITSTATUS='C' THEN '3' when MST.REMAINQTTY = 0 and MST.ADJUSTQTTY>0 then '10' ELSE MST.ORSTATUS END)
                  AND SYS.SYSNAME='CONTROLCODE'
                  AND MAP.ORGORDERID(+)=ood.orgorderid
                  AND CD2.cdtype ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                  AND CD4.cdtype ='OD' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                  AND CD5.cdtype ='OD' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                  AND CD6.cdtype ='OD' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                  AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=MST.VIA
                  AND CD10.cdtype ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=sb.TRADEPLACE
                  AND cd12.cdtype = 'OD' AND cd12.cdname = 'CANCELSTATUS' and cd12.cdval=MST.cancelstatus
                  --AND EXISTS (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE' AND MST.TXDATE = TO_DATE(VARVALUE,'DD/MM/YYYY'))
                  AND CD7.cdtype ='OD' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE and mst.tlid =mk.tlid (+)
                  and mst.orderid = f.orgacctno(+) and mst.exectype = f.exectype(+)
              UNION ALL
              -- OD + FO
              SELECT CFMAST.CUSTODYCD, MST.EFFDATE TXDATE, '' REFORDERID, MST.AFACCTNO, MST.ACCTNO, MST.ORGACCTNO, MST.EXECTYPE,MST.REFACCTNO REFACCTNO, MST.PRICETYPE,
                  CD2.cdcontent DESC_EXECTYPE, MST.SYMBOL, MST.QUANTITY, (MST.PRICE * 1000) PRICE, MST.feedbackmsg,
                  MST.QUOTEPRICE, TO_CHAR(CD3.cdcontent) DESC_BOOK, MST.STATUS,
                  --CD9.cdcontent DESC_STATUS,
                  case when  REFOD.cancelstatus ='N' then cd9.cdcontent else cd12.cdcontent end DESC_STATUS,
                  case when  REFOD.cancelstatus ='N' then cd9.en_cdcontent else cd12.en_cdcontent end EN_DESC_STATUS,
                  CD4.cdcontent DESC_TIMETYPE,
                  CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE, NVL(OOD.TXTIME,'') SDTIME,
                  REFOD.EXECQTTY, REFOD.EXECAMT,(CASE WHEN REFOD.EXECQTTY>0 THEN ROUND(REFOD.EXECAMT/1000/REFOD.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, REFOD.REMAINQTTY, SUBSTR(MST.activatedt,12,9) txtime, REFOD.CANCELQTTY, REFOD.ADJUSTQTTY ,MST.BOOK BOOK,CD8.cdcontent VIA,REFOD.VIA VIACD,
                  (CASE WHEN REFOD.CANCELQTTY>0 THEN 'Cancelled'  WHEN REFOD.EDITSTATUS='C' THEN 'Cancelling' ELSE '----' END) CANCELSTATUS,(CASE WHEN REFOD.ADJUSTQTTY>0 THEN 'Amended' WHEN REFOD.EDITSTATUS='A' THEN 'Amending' ELSE '----' END) AMENDSTATUS,
                  SYS.SYSVALUE CURRSECSSION,REFOD.HOSESESSION ODSECSSION,MST.Username maker, MST.CODEID, MST.BRATIO,
                   nvl(tlpro.tlname,REFOD.TLID) tlname, to_char(MAP.CTCI_ORDER) CTCI_ORDER,
                   cd10.cdcontent tradeplace,nvl(REFOD.EDITSTATUS,'N') edstatus,cd4.cdcontent timetype,cd5.cdcontent matchtype,mst.clearday,mst.effdate,mst.expdate,
                   cf.CAREBY, REFOD.ORSTATUSVALUE ORSTATUSVALUE, '-' hosesession, MST.USERNAME USERNAME, REFOD.ISCANCEL, REFOD.ISADMEND, REFOD.ROOTORDERID,
                   REFOD.TIMETYPE TIMETYPEVALUE, REFOD.MATCHTYPE MATCHTYPEVALUE,
                   CASE WHEN REFOD.ORDERID = MST.orgacctno THEN MST.acctno ELSE REFOD.ORDERID END FOACCTNO, nvl(REFOD.ISDISPOSAL,'N') ISDISPOSAL,mst.quoteqtty , mst.limitprice , mst.confirmed
              FROM CFMAST, AFMAST CF, (select * from ood union select * from oodhist) OOD, FOMAST MST,
                (select OD1.*,OD2.EDSTATUS EDITSTATUS,
                    (CASE WHEN OD1.REMAINQTTY > 0 AND OD2.EDSTATUS='C' THEN 'C'
                          WHEN OD1.REMAINQTTY > 0 AND OD2.EDSTATUS='A' THEN 'A'
                        -- Ducnv FF Gateway
                          --WHEN OD2.EDSTATUS IS NULL AND OD1.CANCELQTTY > 0 THEN '5'
                          WHEN OD2.EDSTATUS IS NULL AND OD1.CANCELQTTY > 0  and OD1.ORSTATUS <> '6' THEN '5'
                          WHEN OD2.EDSTATUS IS NULL AND OD1.CANCELQTTY > 0  and OD1.ORSTATUS = '6' THEN '6'
                          --end Ducnv FF Gateway
                          WHEN OD1.REMAINQTTY = 0 AND OD1.CANCELQTTY > 0 AND OD2.EDSTATUS='C' THEN '3'
                          when OD1.REMAINQTTY = 0 and OD1.ADJUSTQTTY>0 then '10'
                          WHEN OD1.REMAINQTTY = 0 AND OD1.EXECQTTY>0 AND OD1.ORSTATUS = '4' THEN '12' ELSE OD1.ORSTATUS END) ORSTATUSVALUE,
                    (CASE WHEN OD1.ISBUYIN = 'N' AND ((OD1.REMAINQTTY > 0 AND (OD2.EDSTATUS IS NULL OR OD2.EDSTATUS IN ('N')) AND OD1.ORSTATUS IN ('8','2','4')
                            AND OD1.MATCHTYPE = 'N' and OD1.PRICETYPE<>'PLO') or (OD1.PRICETYPE='PLO' and OD1.ORSTATUS IN ('8')))
                            THEN 'Y' ELSE 'N' END) ISCANCEL,
                   --(CASE WHEN OD1.REMAINQTTY > 0 AND (OD2.EDSTATUS IS NULL OR OD2.EDSTATUS IN ('N')) AND OD1.ORSTATUS IN ('2','4')
                   --         AND OD1.MATCHTYPE = 'N' AND SB.TRADEPLACE IN ('002','005') /*AND OD1.ISDISPOSAL = 'N'*/ AND OD1.TIMETYPE <> 'G'  AND   OD1.PRICETYPE NOT IN ('MOK','MAK','ATO','ATC') THEN 'Y'
                   --         WHEN OD1.PRICETYPE IN ('MOK','MAK','ATO','ATC') THEN 'N'
                   --         ELSE 'N' END) ISADMEND,
                   --Them dieu kien cho sua lenh HNX va UPCOM khi trang thai dang cho gui
                   (CASE WHEN OD1.ISBUYIN = 'N' AND OD1.REMAINQTTY > 0 AND (OD2.EDSTATUS IS NULL OR OD2.EDSTATUS IN ('N')) AND OD1.ORSTATUS IN ('2','4','8')
                            AND OD1.MATCHTYPE = 'N' AND SB.TRADEPLACE IN ('001','002','005') /*AND OD1.ISDISPOSAL = 'N'*/
                            AND OD1.TIMETYPE <> 'G'  AND (OD1.PRICETYPE ='LO' or (OD1.PRICETYPE='MTL' AND OD1.ORSTATUS IN ('2','4')) or (OD1.PRICETYPE='MP' AND OD1.ORSTATUS IN ('2','4'))) THEN 'Y'
                            ELSE 'N' END) ISADMEND,
                   fn_GetRootOrderID(OD1.ORDERID)  ROOTORDERID
                    from odmast OD1,
                    --Ducnv FF gateway
                    (SELECT * FROM ODMAST WHERE EDSTATUS IN ('C','A')
                     --PHUONGNTN ADD KO LAY LENH HUY/SUA BI TU CHOI
                     AND ORSTATUS <>'6'
                     --END ADD
                     ) OD2,
                     -- End Ducnv FF gateway
                     SBSECURITIES SB
                WHERE OD1.ORDERID=OD2.REFORDERID(+) AND substr(OD1.EXECTYPE,1,1) <> 'C'
                    AND substr(OD1.EXECTYPE,1,1) <> 'A'
                    AND OD1.CODEID = SB.CODEID) REFOD,
                  ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, ALLCODE CD4, ALLCODE CD5, ALLCODE CD6,
                  ALLCODE CD7, ALLCODE CD8, ALLCODE CD9 ,ALLCODE CD10,ALLCODE CD12,
                  ORDERSYS SYS,sbsecurities sb,
                  tlprofiles tlpro,ordermap MAP
              WHERE  REFOD.ORSTATUS <> '7' AND MST.DELTD='N' AND CF.ACCTNO=MST.AFACCTNO
                    AND MST.ACCTNO = p_acctno
                  --AND MST.AFACCTNO=V_PARAFILTER
                  AND MST.ACCTNO=OOD.ORGORDERID(+)
                  AND MST.STATUS = 'A' AND MST.acctno = mst.orgacctno
                  AND MST.CODEID=SB.CODEID
                  AND CD1.cdtype ='FO' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.STATUS
                  AND SYS.SYSNAME='CONTROLCODE'  AND CFMAST.CUSTID=CF.CUSTID
                  AND CD2.cdtype ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                  AND CD3.cdtype ='FO' AND CD3.CDNAME='BOOK' AND CD3.CDVAL=MST.BOOK
                  AND CD4.cdtype ='FO' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                  AND CD5.cdtype ='FO' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                  AND CD6.cdtype ='FO' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                  AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=REFOD.VIA
                  AND CD7.cdtype ='FO' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
                  AND CD9.cdtype ='OD' AND CD9.CDNAME='ORSTATUS' AND CD9.CDVAL=REFOD.ORSTATUSVALUE
                  AND CD10.cdtype ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=sb.TRADEPLACE
                  AND cd12.cdtype = 'OD' AND cd12.cdname = 'CANCELSTATUS' and cd12.cdval=REFOD.cancelstatus
                  --AND EXISTS (SELECT TO_DATE(VARVALUE,'DD/MM/YYYY') FROM SYSVAR WHERE GRNAME ='SYSTEM' AND VARNAME='CURRDATE' AND REFOD.TXDATE =  TO_DATE(VARVALUE,'DD/MM/YYYY'))
                  AND MST.ORGACCTNO=REFOD.ORDERID
                   AND REFOD.TLID=tlpro.tlid(+)
                  AND MAP.ORGORDERID(+)=REFOD.orderid
              UNION ALL
              -- FO
              SELECT CFMAST.CUSTODYCD, MST.EFFDATE TXDATE,'' REFORDERID, MST.AFACCTNO, MST.ACCTNO, MST.ORGACCTNO, MST.EXECTYPE,(CASE WHEN MST.STATUS='R' THEN '' ELSE MST.REFACCTNO END) REFACCTNO, MST.PRICETYPE,
                  CD2.cdcontent DESC_EXECTYPE, MST.SYMBOL, MST.QUANTITY-NVL(ROOT.ORDERQTTY,0) QUANTITY,(MST.PRICE * SYINFO.TRADEUNIT) PRICE, MST.feedbackmsg,
                  MST.QUOTEPRICE* SYINFO.TRADEUNIT QUOTEPRICE, TO_CHAR(CD3.cdcontent) DESC_BOOK, MST.STATUS,
                  CD1.cdcontent DESC_STATUS,
                  CD1.en_cdcontent EN_DESC_STATUS,
                  CD4.cdcontent DESC_TIMETYPE,
                  CD5.cdcontent DESC_MATCHTYPE, CD6.cdcontent DESC_NORK, CD7.cdcontent DESC_PRICETYPE, NVL(OOD.TXTIME,'') SDTIME,
                  MST.EXECQTTY, MST.EXECAMT,(CASE WHEN MST.EXECQTTY>0 THEN ROUND(MST.EXECAMT/1000/MST.EXECQTTY,2) ELSE 0 END) AVEXECPRICE, MST.REMAINQTTY-NVL(ROOT.ORDERQTTY,0) REMAINQTTY, SUBSTR(MST.activatedt,12,9) txtime, mst.CANCELQTTY , mst.AMENDQTTY ADJUSTQTTY,MST.BOOK BOOK,CD8.cdcontent VIA,'T' VIACD,('----') CANCELSTATUS,('----') AMENDSTATUS,
                  SYS.SYSVALUE CURRSECSSION,'N' ODSECSSION,MST.Username maker, MST.CODEID, MST.BRATIO,
                   nvl(tlpro.tlname,mst.tlid) tlname, '' CTCI_ORDER,
                  cd10.cdcontent tradeplace,'N' edstatus,cd4.cdcontent timetype,cd5.cdcontent matchtype,mst.clearday,mst.effdate,mst.expdate,
                  cf.CAREBY, MST.STATUS ORSTATUSVALUE,'-' HOSESESSION, MST.USERNAME USERNAME,
                  CASE WHEN MST.ISBUYIN = 'N' AND MST.STATUS IN ('P','I','A','W') /*AND MST.ISDISPOSAL = 'N'*/ THEN 'Y' ELSE 'N' END ISCANCEL,
                  CASE WHEN MST.ISBUYIN = 'N' AND MST.STATUS IN ('P','I','A','W') AND SB.TRADEPLACE IN ('001','002','005') /*AND MST.ISDISPOSAL = 'N'*/
                  AND MST.TIMETYPE <> 'G' AND   MST.PRICETYPE NOT IN ('MOK','MAK','ATO','ATC') THEN 'Y' ELSE 'N' END ISADMEND,
                  MST.ACCTNO ROOTORDERID,MST.TIMETYPE TIMETYPEVALUE, MST.MATCHTYPE MATCHTYPEVALUE, NVL(MST.ACCTNO,'') FOACCTNO, nvl(mst.ISDISPOSAL,'N') ISDISPOSAL,mst.quoteqtty , mst.limitprice , mst.confirmed
              FROM CFMAST, AFMAST CF, OOD, FOMAST MST, SECURITIES_INFO SYINFO,
                  ALLCODE CD1, ALLCODE CD2, ALLCODE CD3, ALLCODE CD4, ALLCODE CD5,
                  ALLCODE CD6, ALLCODE CD7, ALLCODE CD8 ,ALLCODE CD10 ,
                  ORDERSYS SYS,sbsecurities sb,
                  (SELECT A.FOACCTNO, SUM (B.ORDERQTTY) ORDERQTTY FROM ROOTORDERMAP A, ODMAST B WHERE A.ORDERID=B.ORDERID AND STATUS='A' GROUP BY A.FOACCTNO) ROOT,
                  tlprofiles tlpro--, ordermap MAP
              WHERE MST.ACCTNO=ROOT.FOACCTNO(+) AND MST.STATUS<>'A' AND substr(MST.EXECTYPE,1,1) <> 'C' AND substr(MST.EXECTYPE,1,1) <> 'A'
                    AND MST.DELTD='N' AND CF.ACCTNO=MST.AFACCTNO AND SYINFO.SYMBOL=MST.SYMBOL
                    AND MST.ACCTNO = p_acctno
                  --AND MST.AFACCTNO=V_PARAFILTER
                  AND MST.codeid= sb.codeid
                  AND MST.ACCTNO=OOD.ORGORDERID(+)
                  AND CD1.cdtype ='FO' AND CD1.CDNAME='STATUS' AND CD1.CDVAL=MST.status
                  AND SYS.SYSNAME='CONTROLCODE'  AND CFMAST.CUSTID=CF.CUSTID
                  AND CD2.cdtype ='OD' AND CD2.CDNAME='BUFEXECTYPE' AND CD2.CDVAL=MST.EXECTYPE||MST.MATCHTYPE
                  AND CD3.cdtype ='FO' AND CD3.CDNAME='BOOK' AND CD3.CDVAL=MST.BOOK
                  AND CD4.cdtype ='FO' AND CD4.CDNAME='TIMETYPE' AND CD4.CDVAL=MST.TIMETYPE
                  AND CD5.cdtype ='FO' AND CD5.CDNAME='MATCHTYPE' AND CD5.CDVAL=MST.MATCHTYPE
                  AND CD6.cdtype ='FO' AND CD6.CDNAME='NORK' AND CD6.CDVAL=MST.NORK
                  AND CD8.cdtype ='OD' AND CD8.CDNAME='VIA' AND CD8.CDVAL=MST.VIA
                  AND CD7.cdtype ='FO' AND CD7.CDNAME='PRICETYPE' AND CD7.CDVAL=MST.PRICETYPE
                  AND CD10.cdtype ='OD' AND CD10.CDNAME='TRADEPLACE' AND CD10.CDVAL=sb.TRADEPLACE
                   AND tlpro.tlid(+)= mst.tlid
                  --AND MAP.ORGORDERID(+)= ood.orgorderid
              ) DTL
          ORDER BY REFORDERID, TXDATE DESC, TXTIME DESC, ACCTNO;
          PLOG.debug(pkgctx,'End pr_gen_buf_od_account' || p_acctno);
    end if;
    --commit;

    plog.setendsection(pkgctx, 'pr_gen_buf_od_account');
EXCEPTION WHEN others THEN
    plog.error(pkgctx, 'Error when then Account p_acctno:=' || nvl(p_acctno,'NULL'));
    plog.error(pkgctx, sqlerrm || 'Loi tai dong:' || dbms_utility.format_error_backtrace);
    plog.setendsection(pkgctx, 'pr_gen_buf_od_account');
END pr_gen_buf_od_account;

PROCEDURE pr_trg_account_log (p_acctno in VARCHAR2, p_mod varchar2)
IS
BEGIN
    plog.setbeginsection (pkgctx, 'pr_trg_account_log');
    if p_acctno is not null then
        if length(trim(p_acctno))>0 then
            if p_mod = 'SE' THEN
                plog.debug (pkgctx, 'log_se_account: ' || p_acctno);
                insert into log_se_account (autoid,acctno,status, logtime, applytime)
                values (seq_log_se_account.nextval,p_acctno,'P', SYSTIMESTAMP,NULL);
            elsif p_mod = 'CI' THEN
                plog.debug (pkgctx, 'log_ci_account: ' || p_acctno);
                insert into log_ci_account (autoid,acctno,status, logtime, applytime)
                values (seq_log_ci_account.nextval,p_acctno,'P', SYSTIMESTAMP,NULL);
            elsif p_mod = 'OD' THEN
                plog.debug (pkgctx, 'log_of_account: ' || p_acctno);
                insert into log_od_account (autoid,acctno,status, logtime, applytime)
                values (seq_log_od_account.nextval,p_acctno,'P', SYSTIMESTAMP,NULL);
            end if;
        end if;
    end if;
    plog.setendsection (pkgctx, 'pr_trg_account_log');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    plog.debug (pkgctx,'got error on release pr_trg_account_log');
    plog.setbeginsection(pkgctx, 'pr_trg_account_log');
END pr_trg_account_log;

PROCEDURE pr_gen_se_buffer
IS
CURSOR logRecords IS
    select DISTINCT ACCTNO from log_se_account where status = 'P' ;--order by autoid;
    log_rec logRecords%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_gen_se_buffer');
    --plog.debug (pkgctx, '<<BEGIN OF pr_gen_se_buffer');
    OPEN logRecords;
    loop
        FETCH logRecords INTO log_rec;
        EXIT WHEN logRecords%NOTFOUND;
        update log_se_account
        set status = 'A', applytime= SYSTIMESTAMP
        where acctno = log_rec.acctno AND status ='P';
        --Xu ly cap nhat lai buffer theo account
        pr_gen_buf_se_account(log_rec.acctno);
        COMMIT;

    end loop;
    commit;
    plog.setendsection (pkgctx, 'pr_gen_se_buffer');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_gen_se_buffer');
    plog.setbeginsection(pkgctx, 'pr_gen_se_buffer');
END pr_gen_se_buffer;

PROCEDURE pr_gen_ci_buffer
IS
CURSOR logRecords IS
    select distinct acctno  from log_ci_account where status = 'P' ;--order by autoid;
    log_rec logRecords%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_gen_ci_buffer');
    --plog.debug (pkgctx, '<<BEGIN OF pr_gen_ci_buffer');
    OPEN logRecords;
    loop
        FETCH logRecords INTO log_rec;
        EXIT WHEN logRecords%NOTFOUND;

        update log_ci_account
        set status = 'A', applytime= SYSTIMESTAMP
        where acctno = log_rec.acctno AND status ='P';
        --Xu ly cap nhat lai buffer theo account
        pr_gen_buf_ci_account(log_rec.acctno);
        COMMIT;
        /*update log_ci_account
        set status = 'A', applytime= SYSTIMESTAMP
        where autoid = log_rec.autoid;*/
    end loop;
    commit;
    plog.setendsection (pkgctx, 'pr_gen_ci_buffer');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_gen_ci_buffer');
    plog.setbeginsection(pkgctx, 'pr_gen_ci_buffer');
END pr_gen_ci_buffer;

PROCEDURE pr_SECMAST_GENERATE_LOG
IS
CURSOR logRecords IS
    SELECT DISTINCT TXNUM , TXDATE , BUSDATE , AFACCTNO , SYMBOL , SECTYPE , PTYPE , CAMASTID , ORDERID , QTTY ,
        COSTPRICE , MAPAVL
    FROM SECMAST_GENERATE_LOG where status = 'P' ;
    log_rec logRecords%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_SECMAST_GENERATE_LOG');
    OPEN logRecords;
    loop
        FETCH logRecords INTO log_rec;
        EXIT WHEN logRecords%NOTFOUND;

        update SECMAST_GENERATE_LOG
        set status = 'A', applytime= SYSTIMESTAMP
        where TXNUM = log_rec.TXNUM AND TXDATE = log_rec.TXDATE;

        SECMAST_GENERATE(log_rec.TXNUM, log_rec.TXDATE, log_rec.TXDATE, log_rec.AFACCTNO, log_rec.symbol, log_rec.SECTYPE,
            log_rec.PTYPE, log_rec.CAMASTID, log_rec.ORDERID, log_rec.QTTY, log_rec.COSTPRICE, log_rec.MAPAVL);

        COMMIT;
    end loop;
    commit;
    plog.setendsection (pkgctx, 'pr_SECMAST_GENERATE_LOG');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_gen_ci_buffer');
    plog.setbeginsection(pkgctx, 'pr_gen_ci_buffer');
END pr_SECMAST_GENERATE_LOG;

PROCEDURE pr_gen_od_buffer
IS
CURSOR logRecords IS
    --select * from log_od_account where status = 'P' order by autoid;
    select DISTINCT ACCTNO from log_od_account where status = 'P';-- order by autoid;
    log_rec logRecords%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_gen_od_buffer');
    plog.debug (pkgctx, '<<BEGIN OF pr_gen_od_buffer');
    OPEN logRecords;
    loop
        FETCH logRecords INTO log_rec;
        EXIT WHEN logRecords%NOTFOUND;
        update log_od_account
        set status = 'A', applytime= SYSTIMESTAMP
        where ACCTNO = log_rec.ACCTNO AND status ='P';
        --Xu ly cap nhat lai buffer theo account
        pr_gen_buf_od_account(log_rec.acctno);
        COMMIT;

    end loop;
    commit;
    plog.setendsection (pkgctx, 'pr_gen_od_buffer');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_gen_od_buffer');
    plog.setbeginsection(pkgctx, 'pr_gen_od_buffer');
END pr_gen_od_buffer;

PROCEDURE pr_process_od_bankaccount
IS
CURSOR logRecords IS
    select * from log_od_account where status = 'P' order by autoid;
    log_rec logRecords%ROWTYPE;
BEGIN
    plog.setbeginsection (pkgctx, 'pr_process_od_bankaccount');
   -- plog.debug (pkgctx, '<<BEGIN OF pr_process_od_bankaccount');
    OPEN logRecords;
    loop
        FETCH logRecords INTO log_rec;
        EXIT WHEN logRecords%NOTFOUND;
        --Xu ly cap nhat lai buffer theo account
        pr_gen_buf_od_account(log_rec.acctno);
        COMMIT;
        update log_od_account
        set status = 'A', applytime= SYSTIMESTAMP
        where autoid = log_rec.autoid;
    end loop;
    commit;
    plog.setendsection (pkgctx, 'pr_process_od_bankaccount');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_process_od_bankaccount');
    plog.setbeginsection(pkgctx, 'pr_process_od_bankaccount');
END pr_process_od_bankaccount;

PROCEDURE pr_gen_rm_transfer
IS
CURSOR logRecords IS
    select * from log_trf_transact where status = 'P' order by autoid;
    log_rec logRecords%ROWTYPE;
    l_err_code varchar2(100);
    l_alternateacct char(1);
    l_autotrf  char(1);
    l_tltxcd varchar2(4);
    l_txdesc varchar(600);
BEGIN
    plog.setbeginsection (pkgctx, 'pr_process_od_bankaccount');
   -- plog.debug (pkgctx, '<<BEGIN OF pr_process_od_bankaccount');
    OPEN logRecords;
    loop
        FETCH logRecords INTO log_rec;
        EXIT WHEN logRecords%NOTFOUND;
            --Xu ly cap nhat lai buffer theo account
            --Kiem tra neu la tai khoan phu co AUTOTRF='Y' la tu dong chuyen tien sang ngan hang thi sinh giao dich chuyen
            select tltxcd,txdesc  into l_tltxcd,l_txdesc from tllog where txnum =log_rec.txnum and txdate =log_rec.txdate;
            select alternateacct, autotrf into l_alternateacct, l_autotrf from afmast where acctno = log_rec.acctno;
            if l_alternateacct='Y' and l_autotrf='Y' then
                cspks_rmproc.pr_rmSUBReleaseBalance(log_rec.acctno,log_rec.amt,l_tltxcd||'@@'||l_txdesc,l_err_code);
                if l_err_code<> '0' then
                    --Co loi xay ra
                    update log_trf_transact set status ='E' where autoid = log_rec.autoid;
                    plog.error('Error:' || l_err_code);
                end if;
            end if;
            update log_trf_transact set status ='C' where autoid = log_rec.autoid;
        COMMIT;
        update log_od_account
        set status = 'A', applytime= SYSTIMESTAMP
        where autoid = log_rec.autoid;
    end loop;
    commit;
    plog.setendsection (pkgctx, 'pr_gen_rm_transfer');
EXCEPTION WHEN OTHERS THEN
    plog.error(SQLERRM || dbms_utility.format_error_backtrace);
    ROLLBACK;
    plog.debug (pkgctx,'got error on release pr_gen_rm_transfer');
    plog.setbeginsection(pkgctx, 'pr_gen_rm_transfer');
END pr_gen_rm_transfer;

-- initial LOG
BEGIN
   SELECT *
   INTO logrow
   FROM tlogdebug
   WHERE ROWNUM <= 1;

   pkgctx    :=
      plog.init ('jbpks_auto',
                 plevel => logrow.loglevel,
                 plogtable => (logrow.log4table = 'Y'),
                 palert => (logrow.log4alert = 'Y'),
                 ptrace => (logrow.log4trace = 'Y')
      );
END;
/
