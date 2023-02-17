SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0023" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2,
   PV_AFACCTNO    IN       VARCHAR2
)
IS

-- PURPOSE:
-- BANG KE SO DU UNG TRUOC TIEN BAN THEO TUNG TAI KHOAN KH
-- MODIFICATION HISTORY
-- PERSON               DATE                COMMENTS
-- ---------------      ----------          ----------------------
-- QUOCTA               13/01/2012          TAO THEO YC BVS
-- ---------------      ----------          ----------------------

   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

   V_INBRID        VARCHAR2(4);
    V_STRBRID      VARCHAR2 (50);


   V_INT_DATE          DATE;
   V_CUSTODYCD         VARCHAR2(100);
   V_AFACCTNO          VARCHAR2(100);

   V_CRRDATE           DATE;

BEGIN
/*
    V_STROPTION := OPT;

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
            select br.brid into V_STRBRID from brgrp br where  br.brid = V_INBRID;
        else
            V_STRBRID := V_INBRID;
        end if;
    end if;

-- GET REPORT'S PARAMETERS

    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL)
    THEN
         V_CUSTODYCD    :=    PV_CUSTODYCD;
    ELSE
         V_CUSTODYCD    :=    '%';
    END IF;

    IF (PV_AFACCTNO <> 'ALL' OR PV_AFACCTNO <> '' OR PV_AFACCTNO <> NULL)
    THEN
         V_AFACCTNO     :=    PV_AFACCTNO;
    ELSE
         V_AFACCTNO     :=    '%';
    END IF;

    V_INT_DATE          :=    TO_DATE(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CRRDATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

-- Main report
OPEN PV_REFCURSOR FOR

   SELECT * FROM( SELECT V_INT_DATE DATE_TRANS, AF.ACCTNO, CF.FULLNAME, CF.CUSTODYCD, (NVL(ADS.AMT, 0) + NVL(ADS.FEEAMT, 0)) AMT,
           ADS.ODDATE, ADS.TXDATE,ads.CLEARDT paiddate,
           (CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '1' THEN (ads.amt + ads.feeamt) ELSE 0 END) T0,
           (CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '2' THEN (ads.amt + ads.feeamt) ELSE 0 END) T1,
           (CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '3' THEN (ads.amt + ads.feeamt) ELSE 0 END) T2,
/*           (CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '4' THEN (ads.amt + ads.feeamt) ELSE 0 END)*/ 0 T3,
      /*  (CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '5' THEN (ads.amt + ads.feeamt) ELSE 0 END) */0 T4,
           (NVL(ADS.FEEAMT, 0)) FEEAMT
    FROM   VW_ADSCHD_ALL ADS, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF
    WHERE  CF.CUSTID      =    AF.CUSTID
    AND    AF.ACCTNO      =    ADS.ACCTNO
    AND    (ADS.AMT > 0   OR   ADS.PAIDDATE = V_CRRDATE)
    AND    ADS.ODDATE     <=   V_INT_DATE
    AND    ADS.TXDATE     <=   V_INT_DATE
    AND    ADS.DELTD <> 'Y'
    AND    CF.CUSTODYCD   LIKE V_CUSTODYCD
    AND    AF.ACCTNO      LIKE V_AFACCTNO
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 ))

     WHERE T0+T1+T2+T3+T4>0

;
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;
 
 
 
 
/
