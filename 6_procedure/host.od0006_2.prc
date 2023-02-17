SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE od0006_2 (
                                       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
                                       OPT            IN       VARCHAR2,
                                       pv_BRID        IN       VARCHAR2,
                                       TLGOUPS        IN       VARCHAR2,
                                       TLSCOPE        IN       VARCHAR2,
                                       F_DATE         IN       VARCHAR2,
                                       T_DATE         in       varchar2,
                                       PV_SECTYPE     IN       VARCHAR2,
                                       TRADEPLACE     IN       VARCHAR2,                                       
                                       CASHPLACE      IN       VARCHAR2,
                                       PV_BRGID       IN       VARCHAR2
  )
IS
--
-- PURPOSE: TINH PHI GD CUA MOI GIOI, TU DOANH TRONG 1 TIME
--
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- DONT   25-Aug-16  CREATED
-- ---------   ------  -------------------------------------------
    V_STROPTION        VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_PVSTRBRID        VARCHAR2 (40);
    V_PVBRID           VARCHAR2 (4);
    V_STRBRID          VARCHAR2 (4);
    V_BRID             VARCHAR2 (4);
    V_STRAFACCTNO      VARCHAR  (20);
    V_STRTRADEPLACE    VARCHAR2 (4);
    V_STRCASHPLACE     VARCHAR2 (100);
    v_err              varchar2(200);
    TYPEDATE           VARCHAR2(10);
    vstr_typedate      VARCHAR2(10);
    v_CashPlaceName    VARCHAR2(1000);
    V_SECTYPE          VARCHAR2(100);
    v_cleardt          date;
    V_SYSCLEARDAY      number;
BEGIN
    V_STROPTION := upper(OPT);
    V_PVBRID := pv_BRID;

    IF V_STROPTION = 'A' THEN     -- TOAN HE THONG
        V_PVSTRBRID := '%';
    ELSE
        if V_STROPTION = 'B' THEN
            select brgrp.mapid into V_PVSTRBRID from brgrp where brgrp.brid = V_PVBRID;
        else
            V_PVSTRBRID := V_PVBRID;
        end if;
    END IF;
    -- GET REPORT'S PARAMETERS

    IF  (TRADEPLACE <> 'ALL')
    THEN
        V_STRTRADEPLACE := TRADEPLACE;
    ELSE
        V_STRTRADEPLACE := '%';
    END IF;


    IF  (CASHPLACE <> 'ALL')
    THEN
        V_STRCASHPLACE := CASHPLACE;
    ELSE
        V_STRCASHPLACE := '%';
    END IF;


    IF  (PV_SECTYPE <> 'ALL')
    THEN
        V_SECTYPE := PV_SECTYPE;
    ELSE
        V_SECTYPE := '%';
    END IF;


    If  CASHPLACE = 'ALL' Then
        v_CashPlaceName := ' Tat ca ';
    ELSIF CASHPLACE = '000' Then
        v_CashPlaceName := ' Cong ty chung khoan';
    Else
        Begin
            Select CDCONTENT Into v_CashPlaceName from Allcode Where cdval = CASHPLACE And cdname ='BANKNAME' and cdtype ='CF';
        EXCEPTION WHEN OTHERS THEN
            v_CashPlaceName := '';
        End;
    End If;

    TYPEDATE      := '001';
    vstr_typedate := TYPEDATE;
    IF(PV_BRGID <> 'ALL') THEN
        V_BRID := PV_BRGID;
    ELSE
        V_BRID := '%';
    END IF;

    if(TRADEPLACE = '999') then
    OPEN PV_REFCURSOR
    FOR
        SELECT  d_bamt, d_samt, bd_bamt, bd_samt, bf_bamt, bf_samt, tradeplace, cashplace,
       sectype, ferate feerate,
       ((d_bamt + d_samt) * (ferate/100)) fee_tudoanh,
       ((bd_bamt + bd_samt) * (ferate/100)) fee_tn,
       ((bf_bamt + bf_samt) * (ferate/100)) fee_nn,

       ((d_bamt ) * (ferate/100)) fee_tudoanh_buy,
       ((bd_bamt ) * (ferate/100)) fee_tn_buy,
       ((bf_bamt ) * (ferate/100)) fee_nn_buy,

       sectype || to_char(ferate) sectypename
      FROM (SELECT vstr_typedate typedate,
                   SUM (d_bamt) d_bamt,
                   SUM (d_samt) d_samt,
                   SUM (bd_bamt) bd_bamt,
                   SUM (bd_samt) bd_samt,
                   SUM (bf_bamt) bf_bamt,
                   SUM (bf_samt) bf_samt,
                   (CASE WHEN tradeplace = '002' THEN 'HNX'
                         WHEN tradeplace = '001' THEN 'HOSE'
                         WHEN tradeplace = '005' THEN 'UPCOM' ELSE '' END) tradeplace,
                   v_cashplacename cashplace,
                   sectype  sectype,
                   (CASE WHEN NVL (bonleg, 'A') = 'A' THEN
                            (CASE WHEN tradeplace = '005' THEN 0.02        ---UPCOM
                                 WHEN sectype IN ('008') THEN 0.02            --- ETF CCQ 
                                 WHEN sectype IN ('006', '003') THEN 0.0075 --- Trai phieu
                                 WHEN sectype IN ('001', '002', '007') THEN 0.03 --- Co Phieu, 
                                 WHEN sectype IN ('011') THEN 0.02
                                   --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011                                     
                                 ELSE 0
                             END) ELSE NVL (bonfeerate, 0)                            ---repo
                    END) ferate,
                   (CASE WHEN tradeplace = '005' THEN
                            (CASE WHEN sectype IN ('001', '008') THEN 0.02 / 100
                                 WHEN sectype IN ('003', '006') THEN 0.0075 / 100 ELSE 0.0075 / 100 END)
                        ELSE
                            (CASE WHEN sectype IN ('001', '008') THEN 0.03 / 100 
                                 WHEN sectype IN ('003', '006') THEN 0.0075 / 100
                                 WHEN sectype IN ('011') THEN 0.02 / 100 --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                                 ELSE 0.0075 / 100 END)
                    END) feerate
              FROM (SELECT chd.cleardate settdate, chd.txdate tradate, cf.custodycd, cf.fullname, chd.tradeplace,  sb.sectype,
                           bon.feerate bonfeerate, bon.leg bonleg,
                              SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'P' THEN DECODE (chd.duetype, 'RS', chd.amt, 0) ELSE 0 END) d_bamt,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'P' THEN DECODE (chd.duetype, 'RM', chd.amt, 0) ELSE 0 END) d_samt,
                             
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'F' THEN DECODE (chd.duetype, 'RS', chd.amt, 0) ELSE 0 END) bf_bamt,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'F' THEN DECODE (chd.duetype, 'RM', chd.amt, 0) ELSE 0 END) bf_samt,
                               
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) NOT IN ( 'P','F') THEN DECODE (chd.duetype, 'RS', chd.amt, 0) ELSE 0 END) bd_bamt,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) NOT IN ( 'P','F') THEN DECODE (chd.duetype, 'RM', chd.amt, 0) ELSE 0 END) bd_samt
                        
               FROM (SELECT * FROM vw_stschd_tradeplace_all
                             WHERE tradeplace IN ('001', '002', '005')) chd,
                           (SELECT orderid, repoacctno, txdate, qtty, amt1, feeamt, leg,
                                   (CASE WHEN leg = 'V' THEN 0
                                        ELSE (CASE WHEN term <= 2 THEN 0.0005
                                                 WHEN term > 2 AND term <= 14 THEN 0.004
                                                 WHEN term > 14 THEN 0.0075 ELSE 0 END) END)  feerate
                              FROM bondrepo) bon,
                           (SELECT * FROM afmast
                             WHERE (CASE WHEN cashplace = 'ALL' THEN 'ALL'
                                        WHEN cashplace = '000' OR cashplace = '---' THEN corebank ELSE corebank || bankname END) =
                                       (CASE WHEN cashplace = 'ALL' THEN 'ALL' WHEN cashplace = '000' OR cashplace = '---' THEN 'N' ELSE 'Y' || v_strcashplace END)
                               /*    AND brid LIKE v_brid
                                   AND (brid LIKE v_pvstrbrid OR INSTR (v_pvstrbrid, brid) <> 0)*/) af,
                           (SELECT * FROM cfmast WHERE fnc_validate_scope (brid, careby, tlscope, pv_brid, tlgoups) = 0) cf,
                           (SELECT * FROM sbsecurities WHERE sectype LIKE v_sectype AND sectype IN ('001', '006', '008', '011')) sb --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                     WHERE   chd.deltd <> 'Y'
                           AND chd.afacctno = af.acctno
                           AND chd.orgorderid = bon.orderid(+)
                           AND af.custid = cf.custid
                           AND cf.brid LIKE v_brid
                           AND (cf.brid LIKE v_pvstrbrid OR INSTR (v_pvstrbrid, cf.brid) <> 0)
                           AND chd.duetype IN ('RS', 'RM')
                           ---AND chd.clearday = fn_getsysclearday (chd.txdate)
                           AND chd.txdate >= TO_DATE (f_date, 'DD/MM/RRRR')
                           AND chd.txdate <= TO_DATE (t_date, 'DD/MM/RRRR')
                           AND cf.custodycd LIKE '%'
                           AND sb.codeid = chd.codeid
                           ---AND cf.custatcom = 'Y'
                    GROUP BY chd.cleardate,
                             cf.custodycd,
                             cf.fullname,
                             chd.txdate,
                             chd.tradeplace,
                             sb.sectype,
                             bon.feerate,
                             bon.leg)
            GROUP BY  tradeplace, sectype,
                     (CASE WHEN NVL (bonleg, 'A') = 'A' THEN
                            (CASE WHEN tradeplace = '005' THEN 0.02        ---UPCOM
                                 WHEN sectype in ('008') THEN 0.02            --- ETF CCQ
                                 WHEN sectype IN ('006', '003') THEN 0.0075 --- Trai phieu
                                 WHEN sectype IN ('001', '002', '007') THEN 0.03 --- Co Phieu, 
                                 WHEN sectype IN ('011') THEN 0.02
                                   --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011                                     
                                 ELSE 0
                             END) ELSE NVL (bonfeerate, 0)                            ---repo
                    END));
    ELSE
    OPEN pv_refcursor
       FOR
        SELECT d_bamt, d_samt, bd_bamt, bd_samt, bf_bamt, bf_samt, tradeplace,
                cashplace, sectype, ferate feerate,
               ( (d_bamt + d_samt) * (ferate/100)) fee_tudoanh,
               ( (bd_bamt + bd_samt) * (ferate/100)) fee_tn,
               ( (bf_bamt + bf_samt) * (ferate/100)) fee_nn,

               ((d_bamt ) * (ferate/100)) fee_tudoanh_buy,
               ((bd_bamt ) * (ferate/100)) fee_tn_buy,
               ((bf_bamt ) * (ferate/100)) fee_nn_buy,

               sectype || to_char(ferate) sectypename
          FROM (SELECT vstr_typedate typedate,
                       SUM (d_bamt) d_bamt,
                       SUM (d_samt) d_samt,
                       SUM (bd_bamt) bd_bamt,
                       SUM (bd_samt) bd_samt,
                       SUM (bf_bamt) bf_bamt,
                       SUM (bf_samt) bf_samt,
                       (CASE
                            WHEN tradeplace = '002' THEN 'HNX'
                            WHEN tradeplace = '001' THEN 'HOSE'
                            WHEN tradeplace = '005' THEN 'UPCOM'
                            WHEN tradeplace = '007' THEN 'TRÁI PHIẾU CHUYÊN BIỆT'
                            WHEN tradeplace = '008' THEN 'TÍN PHIẾU'
                            ELSE '' END) tradeplace,
                        v_cashplacename cashplace,
                        sectype sectype,
                        (CASE WHEN NVL (bonleg, 'A') = 'A' THEN
                            (CASE WHEN tradeplace = '005' THEN 0.02        ---UPCOM
                                 WHEN sectype IN ('008') THEN 0.02            --- ETF CCQ
                                 WHEN sectype IN ('006', '003') THEN 0.0075 --- Trai phieu
                                 WHEN sectype IN ('001', '002', '007') THEN 0.03 --- Co Phieu, 
                                 WHEN sectype IN ('011') THEN 0.02
                                   --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011                                     
                                 ELSE 0
                             END) ELSE NVL (bonfeerate, 0)                            ---repo
                    END) ferate,
                       (CASE
                            WHEN tradeplace = '005'
                            THEN
                                (CASE
                                     WHEN sectype IN ('001', '008') THEN 0.02 / 100
                                     WHEN sectype IN ('003', '006') THEN 0.0075 / 100
                                     ELSE 0.0075 / 100 END)
                            ELSE
                                (CASE WHEN sectype IN ('001', '008') THEN 0.03 / 100 
                                     WHEN sectype IN ('003', '006') THEN 0.0075 / 100
                                     WHEN sectype IN ('011') THEN 0.02 / 100  --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                                     ELSE 0.0075 / 100 END) END) feerate
                  FROM (SELECT chd.txdate tradate, cf.custodycd, cf.fullname, chd.tradeplace, sb.sectype,  bon.feerate bonfeerate, bon.leg bonleg,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'P' THEN DECODE (chd.duetype, 'RS', chd.amt, 0) ELSE 0 END) d_bamt,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'P' THEN DECODE (chd.duetype, 'RM', chd.amt, 0) ELSE 0 END) d_samt,
                             
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'F' THEN DECODE (chd.duetype, 'RS', chd.amt, 0) ELSE 0 END) bf_bamt,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) = 'F' THEN DECODE (chd.duetype, 'RM', chd.amt, 0) ELSE 0 END) bf_samt,
                               
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) NOT IN ( 'P','F') THEN DECODE (chd.duetype, 'RS', chd.amt, 0) ELSE 0 END) bd_bamt,
                               SUM ( CASE WHEN SUBSTR (cf.custodycd, 4, 1) NOT IN ( 'P','F') THEN DECODE (chd.duetype, 'RM', chd.amt, 0) ELSE 0 END) bd_samt
                        
                          
                          FROM (SELECT * FROM vw_stschd_tradeplace_all
                                 WHERE tradeplace LIKE v_strtradeplace
                                       AND tradeplace IN ('001', '002', '005', '007', '008')) chd,
                               (SELECT orderid, repoacctno, txdate, qtty, amt1, feeamt, leg,
                                   (CASE WHEN leg = 'V' THEN 0
                                        ELSE (CASE WHEN term <= 2 THEN 0.0005
                                                 WHEN term > 2 AND term <= 14 THEN 0.004
                                                 WHEN term > 14 THEN 0.0075 ELSE 0 END) END)  feerate
                              FROM bondrepo) bon,
                               (SELECT * FROM afmast
                                 WHERE (CASE WHEN cashplace = 'ALL' THEN 'ALL'
                                            WHEN cashplace = '000' OR cashplace = '---' THEN corebank ELSE corebank || bankname END) =
                                       (CASE WHEN cashplace = 'ALL' THEN 'ALL'
                                           WHEN cashplace = '000' OR cashplace = '---' THEN 'N' ELSE 'Y' || v_strcashplace END)
                                     /*  AND brid LIKE v_brid
                                       --- and SUBSTR(acctno,1,4) like V_STRBRID
                                       AND (brid LIKE v_pvstrbrid
                                            OR INSTR (v_pvstrbrid, brid) <> 0)*/) af,
                               (SELECT * FROM cfmast WHERE fnc_validate_scope (brid, careby, tlscope, pv_brid, tlgoups) = 0) cf,
                               (SELECT * FROM sbsecurities
                                 WHERE sectype LIKE v_sectype
                                       AND sectype IN ('001', '006', '008', '011')) sb --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011
                         WHERE     chd.deltd <> 'Y'
                              AND chd.orgorderid = bon.orderid(+)
                               AND chd.afacctno = af.acctno
                               AND af.custid = cf.custid
                               AND cf.brid LIKE v_brid
                               AND (cf.brid LIKE v_pvstrbrid  OR INSTR (v_pvstrbrid, cf.brid) <> 0)
                               AND chd.duetype IN ('RS', 'RM')
                               AND chd.txdate >= TO_DATE (f_date, 'DD/MM/YYYY')
                               AND chd.txdate <= TO_DATE (t_date, 'DD/MM/YYYY')
                               AND cf.custodycd LIKE '%'
                               AND sb.codeid = chd.codeid
                               ----AND cf.custatcom = 'Y'
                        GROUP BY chd.cleardate,
                                 cf.custodycd,
                                 cf.fullname,
                                 chd.txdate,
                                 chd.tradeplace,
                                 sb.sectype,
                                 bon.feerate,
                                 bon.leg)
                GROUP BY tradeplace, sectype,
                         (CASE WHEN NVL (bonleg, 'A') = 'A' THEN
                            (CASE WHEN tradeplace = '005' THEN 0.02        ---UPCOM
                                 WHEN sectype IN ('008') THEN 0.02            --- ETF  CCQ
                                 WHEN sectype IN ('006', '003') THEN 0.0075 --- Trai phieu
                                 WHEN sectype IN ('001', '002', '007') THEN 0.03 --- Co Phieu,
                                 WHEN sectype IN ('011') THEN 0.02
                                   --Ngay 23/03/2017 CW NamTv chinh sua them sectype 011                                   
                                 ELSE 0
                             END) ELSE NVL (bonfeerate, 0)                            ---repo
                    END));
    end if;
EXCEPTION
   WHEN OTHERS
   THEN
   v_err:=substr(sqlerrm,1,199);
END;


-- End of DDL Script for Procedure HOSTDEV.OD0006_2

 
/
