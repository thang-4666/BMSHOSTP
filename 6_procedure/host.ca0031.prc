SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0031" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   I_BRIDGD       IN       VARCHAR2,
   ISCOREBANK     IN       VARCHAR2,
   CASHPLACE      IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO DANH SACH NGUOI SO HUU CHUNG KHOAN LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   06-01-2012   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (50);
   V_CACODE            VARCHAR2(100);
   V_I_BRIDGD          VARCHAR2(100);
   V_ISCOREBANK        VARCHAR2(10);
   V_CASHPLACE         VARCHAR2(100);
    V_INBRID        VARCHAR2(4);
   V_BRNAME            NVARCHAR2(500);
   V_COREBANK_NAME     NVARCHAR2(100);
   V_CASHPLACE_NAME    NVARCHAR2(500);

BEGIN


/*   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
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


   -- GET REPORT'S PARAMETERS
   IF (CACODE <> 'ALL' OR CACODE <> '')
   THEN
      V_CACODE :=  CACODE;
   ELSE
      V_CACODE := '%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%';
   END IF;

   IF (ISCOREBANK <> 'ALL' OR ISCOREBANK <> '')
   THEN
            V_ISCOREBANK :=  ISCOREBANK;
   ELSE
      V_ISCOREBANK := '%';
   END IF;

   IF (CASHPLACE <> 'ALL' OR CASHPLACE <> '')
   THEN
      V_CASHPLACE :=  CASHPLACE;
   ELSE
      V_CASHPLACE := '%';
   END IF;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      BEGIN
            SELECT BRNAME INTO V_BRNAME FROM BRGRP WHERE BRID LIKE I_BRIDGD;
      END;
   ELSE
      V_BRNAME   :=  'Toàn công ty';
   END IF;

   IF (ISCOREBANK <> 'ALL' OR ISCOREBANK <> '')
   THEN
        if (ISCOREBANK = 'Y') then
            V_COREBANK_NAME := 'Corebank';
        else
            V_COREBANK_NAME := 'T?i cty CK';
        end if;
   ELSE
      V_COREBANK_NAME   :=  'Toàn công ty';
   END IF;

   IF (CASHPLACE <> 'ALL' OR CASHPLACE <> '')
   THEN
      BEGIN
            SELECT CDCONTENT INTO V_CASHPLACE_NAME FROM ALLCODE WHERE CDTYPE = 'CF' AND CDNAME = 'BANKNAME' AND CDVAL LIKE CASHPLACE;
      END;

   ELSE
      V_CASHPLACE_NAME   :=  'All';

   END IF;


   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR

     SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE,
            (MST.INTERESTRATE || '%') PCENT, MST.ACTIONDATE,
            /*(CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN 'I.  M? GI?I TRONG NU?C'
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN 'II. M? GI?I NU?C NGO?I'
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN 'III.T? DOANH' END) GR_I,
                  */
            SUBSTR(CF.CUSTODYCD, 4, 1) GR_I,
            /*
            (CASE WHEN CF.CUSTTYPE =  'I'  THEN '1. C?h?
                  WHEN CF.CUSTTYPE =  'B'  THEN '2. T? ch?c' END) AFTYPE,*/
            CF.CUSTTYPE AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            --CF.IDCODE,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE, CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO, (CA.BALANCE + CA.PBALANCE) BALANCE, (CA.QTTY + CA.PQTTY) QTTY,
            (CASE WHEN MST.CATYPE = '016' THEN NVL(CA.AMT, 0) - (CA.BALANCE * SB.PARVALUE) ELSE NVL(CA.AMT, 0) END) AMT_INT,
            (CASE WHEN MST.CATYPE = '016' THEN (CA.BALANCE * SB.PARVALUE) ELSE 0 END) AMT_PRIN,
            (NVL(CA.AMT, 0)) AMT_SUM, V_BRNAME BR_NAME, V_COREBANK_NAME COREBANK_NAME, V_CASHPLACE_NAME CASHPLACE_NAME
    FROM (SELECT sum(amt) amt, sum(pbalance) pbalance, sum(balance) balance, sum(qtty) qtty, sum(pqtty) pqtty , camastid, afacctno, codeid
            FROM VW_CASCHD_ALL
            WHERE deltd <> 'Y' AND STATUS <> 'O' GROUP BY camastid, afacctno, codeid) CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, AFTYPE AFT,
         (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    AND   MST.CATYPE    IN ('015', '016')
    AND   CF.BRID       LIKE V_I_BRIDGD
    AND   CA.CAMASTID   LIKE V_CACODE
    AND   AF.ACTYPE     =  AFT.ACTYPE
    AND   AFT.COREBANK  LIKE V_ISCOREBANK
    AND   AF.BANKNAME   LIKE V_CASHPLACE
    AND (af.brid LIKE V_STRBRID or instr(V_STRBRID,af.brid) <> 0 )
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
