SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0019" (
       PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
       OPT            IN       VARCHAR2,
       pv_BRID           IN       VARCHAR2,
       TLGOUPS        IN       VARCHAR2,
       TLSCOPE        IN       VARCHAR2,
       I_DATE         IN       VARCHAR2,
       I_BRID         IN       VARCHAR2
)
IS

-- PURPOSE:
-- BAO CAO SO DU TIEN NHA DAU TU
-- PERSON               DATE                COMMENTS
-- ---------------      ----------          ----------------------
-- QUOCTA               11/01/2012          SUA THEO YC BVS
-- ---------------      ----------          ----------------------

  V_STROPTION           VARCHAR2 (5);       -- A: ALL; B: BRANCH; S: SUB-BRANCH
  V_IN_DATE             DATE;
  V_I_BRID              VARCHAR2 (10);

  V_CURR_DATE           DATE;

  V_INBRID        VARCHAR2(4);
  V_STRBRID      VARCHAR2 (50);



BEGIN

    /*V_STROPTION := OPT;

    IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
    THEN
         V_STRBRID := BRID;
    ELSE
         V_STRBRID := '%%';
    END IF;*/
     V_STROPTION := upper(OPT);
      V_INBRID := pv_BRID;
    if(V_STROPTION = 'A') then
        V_STRBRID := '%%';
    else
        if(V_STROPTION = 'B') then
            select br.mapid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

    IF (I_BRID <> 'ALL' OR I_BRID <> '') THEN
         V_I_BRID  := I_BRID;
    ELSE
         V_I_BRID  := '%';
    END IF;

    V_IN_DATE := TO_DATE(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CURR_DATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

-- MAIN REPORT
OPEN PV_REFCURSOR FOR

SELECT    MAX(V_IN_DATE) IN_DATE, CF.CUSTODYCD, CF.FULLNAME,
          ROUND(SUM(CI_CURR.BALANCE - NVL(CI_TR.TR_BALANCE, 0) - NVL(SECU.OD_BUY_SECU, 0))) BALANCE,        --- SO DU GIAO DICH (HIEN TAI - PHAT SINH TU NGAY GD DEN NGAY HT - GT KI QUY TRONG NGAY)
          ROUND(SUM(NVL(SECU.OD_BUY_SECU, 0))) OD_BUY_SECU,                                                 --- GT KI QUY TRONG NGAY
          ROUND(SUM(NVL(SM.AMT, 0))) NETTING,                                                               --- CHO GIAO
          ROUND(SUM(NVL(RM.AMT, 0))) RECEIVING,                                                             --- CHO VE
          ROUND(SUM(CI_CURR.EMKAMT - NVL(CI_TR.TR_EMKAMT, 0))) EMKAMT,                                      --- PHONG TOA
          ROUND(SUM(CI_CURR.FLOATAMT - NVL(CI_TR.TR_FLOATAMT, 0))) FLOATAMT,                                --- CHO XU LY
          (ROUND(SUM(CI_CURR.BALANCE - NVL(CI_TR.TR_BALANCE, 0))) +
          ROUND(SUM(CI_CURR.TRFAMT - NVL(CI_TR.TR_TRFAMT, 0)))) BALANCE_INT

FROM CIMAST CI_CURR, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
    (   --- LAY CAC PHAT SINH BALANCE, EMKAMT, TRFAMT, FLOATAMT LON HON NGAY GIAO DICH THEO NGAY BKDATE(CHI CO TRONG VW_CITRAN_ALL)
        SELECT TR.ACCTNO,
               ROUND(SUM(CASE WHEN TX.FIELD = 'BALANCE' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                        ELSE 0 END)) TR_BALANCE,        -- SO DU GIAO DICH

               ROUND(SUM(CASE WHEN TX.FIELD = 'EMKAMT' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                        ELSE 0 END)) TR_EMKAMT,         -- SO DU PHONG TOA

               ROUND(SUM(CASE WHEN TX.FIELD = 'TRFAMT' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                        ELSE 0 END)) TR_TRFAMT,         -- SO DU CHO THUC CAT KHOI TAI KHOAN

               ROUND(SUM(CASE WHEN TX.FIELD = 'FLOATAMT' THEN (CASE WHEN TX.TXTYPE = 'D' THEN -TR.NAMT ELSE TR.NAMT END)
                        ELSE 0 END)) TR_FLOATAMT        -- SO DU CHO CK SANG NH, DI UNC

        FROM  VW_CITRAN_ALL TR, APPTX TX
        WHERE TR.TXCD      =    TX.TXCD
        AND   TX.APPTYPE   =    'CI'
        AND   TX.TXTYPE    IN   ('C','D')
        AND   TX.FIELD     IN   ('BALANCE','EMKAMT','TRFAMT','FLOATAMT')
        AND   NVL(TR.BKDATE, TR.TXDATE) > TO_DATE(V_IN_DATE, SYSTEMNUMS.C_DATE_FORMAT)
        GROUP BY TR.ACCTNO
    ) CI_TR,
    (   --- LAY GT THANH TOAN BU TRU TU NGAY T DEN NGAY GD - CAC GIAO DICH BAN CK
        SELECT   AFACCTNO, SUM(AMT) AMT
        FROM     VW_STSCHD_ALL
        WHERE    TXDATE >= GET_T_DATE(TO_DATE(V_IN_DATE, SYSTEMNUMS.C_DATE_FORMAT), 3)
        AND      TXDATE <= TO_DATE(V_IN_DATE, SYSTEMNUMS.C_DATE_FORMAT)
        AND      DUETYPE = 'RM'
        GROUP BY AFACCTNO
    ) RM,
   (    --- LAY GT THANH TOAN BU TRU TU NGAY T DEN NGAY GD - CAC GIAO DICH MUA CK
        SELECT   AFACCTNO, SUM(AMT) AMT
        FROM     VW_STSCHD_ALL
        WHERE    TXDATE >= GET_T_DATE(TO_DATE(V_IN_DATE, SYSTEMNUMS.C_DATE_FORMAT), 3)
        AND      TXDATE <= TO_DATE(V_IN_DATE, SYSTEMNUMS.C_DATE_FORMAT)
        AND      DUETYPE = 'RS'
        GROUP BY AFACCTNO
    ) SM,
    (   --- LAY GIA TRI KI QUY LENH MUA (CHI LAY DUOC NEU NGAY GD LA NGAY HIEN TAI)
        SELECT   V.afacctno,
                 (CASE WHEN V_CURR_DATE = V_IN_DATE THEN (V.secureamt + V.advamt)--SUM(V.secureamt + V.advamt)
                  ELSE 0 END) OD_BUY_SECU
        FROM     v_getbuyorderinfo V
        --GROUP BY V.afacctno
    ) SECU
WHERE    AF.ACCTNO               =     CI_CURR.AFACCTNO
AND      AF.CUSTID               =     CF.CUSTID
AND      SUBSTR(CF.brid, 1, 4) LIKE  V_I_BRID
AND      CI_CURR.ACCTNO          =     CI_TR.ACCTNO  (+)
AND      CI_CURR.ACCTNO          =     RM.AFACCTNO   (+)
AND      CI_CURR.ACCTNO          =     SM.AFACCTNO   (+)
AND      CI_CURR.ACCTNO          =     SECU.AFACCTNO (+)
AND      (
             ROUND(CI_CURR.BALANCE   - NVL(CI_TR.TR_BALANCE, 0))    <> 0 OR
             ROUND(CI_CURR.EMKAMT    - NVL(CI_TR.TR_EMKAMT, 0))     <> 0 OR
             ROUND(CI_CURR.TRFAMT    - NVL(CI_TR.TR_TRFAMT, 0))     <> 0 OR
             ROUND(CI_CURR.FLOATAMT  - NVL(CI_TR.TR_FLOATAMT, 0))   <> 0 OR
             ROUND(NVL(RM.AMT, 0))                                  <> 0 OR
             ROUND(NVL(SM.AMT, 0))                                  <> 0
          )
AND       NOT (SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' AND CF.CUSTATCOM = 'Y')
AND (cf.brid LIKE V_STRBRID or instr(V_STRBRID,cf.brid) <> 0 )
GROUP BY  CF.CUSTODYCD, CF.FULLNAME
ORDER BY  CF.CUSTODYCD

;
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;
 
 
 
 
/
