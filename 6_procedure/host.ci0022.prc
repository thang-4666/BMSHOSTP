SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CI0022" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   I_DATE         IN       VARCHAR2,
   I_RRTYPE       IN       VARCHAR2,
   PV_CUSTODYCD   IN       VARCHAR2
)
IS

-- PURPOSE:
-- BANG KE SO DU UNG TRUOC TIEN BAN TOAN CONG TY
-- MODIFICATION HISTORY
-- PERSON               DATE                COMMENTS
-- ---------------      ----------          ----------------------
-- QUOCTA               13/01/2012          TAO THEO YC BVS
-- ---------------      ----------          ----------------------

   V_STROPTION         VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH

   V_INBRID        VARCHAR2(4);
   V_STRBRID      VARCHAR2 (50);


   V_INT_DATE          DATE;
   V_RRTYPE            VARCHAR2(100);
   V_CUSTODYCD         VARCHAR2(100);

   V_CRRDATE           DATE;

BEGIN

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


-- GET REPORT'S PARAMETERS

    IF (PV_CUSTODYCD <> 'ALL' OR PV_CUSTODYCD <> '' OR PV_CUSTODYCD <> NULL)
    THEN
         V_CUSTODYCD    :=    PV_CUSTODYCD;
    ELSE
         V_CUSTODYCD    :=    '%';
    END IF;

    IF (I_RRTYPE <> 'ALL' OR I_RRTYPE <> '' OR I_RRTYPE <> NULL)
    THEN
         V_RRTYPE       :=    I_RRTYPE;
    ELSE
         V_RRTYPE       :=    '%';
    END IF;

    V_INT_DATE          :=    TO_DATE(I_DATE, SYSTEMNUMS.C_DATE_FORMAT);

    SELECT TO_DATE(SY.VARVALUE, SYSTEMNUMS.C_DATE_FORMAT) INTO V_CRRDATE
    FROM SYSVAR SY WHERE SY.VARNAME = 'CURRDATE' AND SY.GRNAME = 'SYSTEM';

-- Main report
OPEN PV_REFCURSOR FOR
    SELECT V_INT_DATE DATE_TRANS, MAX(A1.CDCONTENT) RRTYPE_NAME, AF.ACCTNO, CF.FULLNAME, CF.CUSTODYCD, SUM(NVL(ADS.AMT, 0) + NVL(ADS.FEEAMT, 0)- (case when V_INT_DATE > ads.cleardt then ads.paidamt else 0 end)) AMT,
           SUM(CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '1' THEN (ads.amt + ads.feeamt) ELSE 0 END) T0,
           SUM(CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '2' THEN (ads.amt + ads.feeamt) ELSE 0 END) T1,
           SUM(CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '3' THEN (ads.amt + ads.feeamt) ELSE 0 END) T2,
         /*  SUM(CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '4' THEN (ads.amt + ads.feeamt) ELSE 0 END)*/ 0 T3,
         /*  SUM(CASE WHEN ((SELECT COUNT(*) FROM SBCLDR WHERE sbdate BETWEEN V_INT_DATE AND TO_DATE(ads.cleardt, SYSTEMNUMS.C_DATE_FORMAT) AND holiday = 'N' AND cldrtype = '000')) = '5' THEN (ads.amt + ads.feeamt) ELSE 0 END)*/ 0 T4,
           SUM(NVL(ADS.FEEAMT, 0)) FEEAMT
    FROM   VW_ADSCHD_ALL ADS, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, AFMAST AF, ALLCODE A1
    WHERE  CF.CUSTID      =    AF.CUSTID
    AND    AF.ACCTNO      =    ADS.ACCTNO
    AND    (ADS.AMT > 0   OR   ADS.PAIDDATE = V_CRRDATE)
    AND    ADS.ODDATE     <=   V_INT_DATE
    AND    ADS.TXDATE     <=   V_INT_DATE
    AND    ADS.CLEARDT    >=   V_INT_DATE
    AND    ADS.DELTD <> 'Y'
    AND    A1.CDNAME      =    'RRTYPE'
    AND    A1.CDTYPE      =    'LN'
    AND    A1.CDVAL       =    ADS.RRTYPE
    AND    ADS.RRTYPE     LIKE V_RRTYPE
    AND    CF.CUSTODYCD   LIKE V_CUSTODYCD
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
    GROUP  BY  CF.CUSTODYCD, AF.ACCTNO, CF.FULLNAME, ADS.RRTYPE
    HAVING SUM(NVL(ADS.AMT, 0) + NVL(ADS.FEEAMT, 0)- (case when V_INT_DATE > ads.cleardt then ads.paidamt else 0 end)) <> 0


;
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END;
 
/
