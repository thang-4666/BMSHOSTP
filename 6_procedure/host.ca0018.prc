SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0018" (
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
-- QUOCTA   15-12-2011   CREATED
-- ---------   ------  -------------------------------------------

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (50);
   V_BRID              varchar2(4);
   V_CACODE            VARCHAR2(100);
   V_I_BRIDGD          VARCHAR2(100);
   V_ISCOREBANK        VARCHAR2(10);
   V_CASHPLACE         VARCHAR2(100);

   V_BRNAME            NVARCHAR2(500);
   V_COREBANK_NAME     NVARCHAR2(100);
   V_CASHPLACE_NAME    NVARCHAR2(500);

BEGIN
   V_STROPTION := OPT;
   V_BRID := pv_BRID;

   /* IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;*/

    IF (V_STROPTION = 'A') THEN
         V_STRBRID := '%';
    ELSE if (V_STROPTION = 'B') then
            select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_BRID;
        else
            V_STRBRID := V_BRID;
        end if;
    END IF;

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
----      if(ISCOREBANK = 'Corebank') then
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
      V_BRNAME   :=  'To?c?ty';
   END IF;

   IF (ISCOREBANK <> 'ALL' OR ISCOREBANK <> '')
   THEN
        if (ISCOREBANK = 'Y') then
            V_COREBANK_NAME := 'Corebank';
        else
            V_COREBANK_NAME := 'Tai cty CK';
        end if;
   ELSE
      V_COREBANK_NAME   :=  'Toan cong ty';
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
            (CASE WHEN MST.CATYPE = '011' THEN MST.DEVIDENTSHARES
                  WHEN MST.CATYPE = '021' THEN MST.EXRATE END) PCENT,
             MST.EXPRICE EXPRICE, MST.CATYPE CATYPE,
             /*
            (CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN 'I.  M? GI?I TRONG NU?C'
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN 'II. M? GI?I NU?C NGO?I'
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN 'III.T? DOANH' END) GR_I, */
            SUBSTR(CF.CUSTODYCD, 4, 1) GR_I,
            /*(CASE WHEN CF.CUSTTYPE =  '001'  THEN '1. C?h?
                  WHEN CF.CUSTTYPE =  '002'  THEN '2. T? ch?c' END) AFTYPE,*/
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE  AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            --CF.IDCODE,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE, CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO, (CA.BALANCE + CA.PBALANCE) BALANCE, (CA.QTTY + CA.PQTTY) QTTY,
            (CASE WHEN NVL(MST.EXPRICE, 0) = 0 THEN 0 ELSE ROUND(CA.AMT / MST.EXPRICE, 3) END) AMT_OD,
            NVL(CA.AMT, 0) AMT, a2.cdcontent noi_dung, V_BRNAME BR_NAME, V_COREBANK_NAME COREBANK_NAME, V_CASHPLACE_NAME CASHPLACE_NAME
    FROM VW_CASCHD_ALL CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, AFTYPE AFT,
         (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST, allcode a2
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   CA.DELTD       <>  'Y'
    AND   CA.STATUS<>'O'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    AND   MST.CATYPE    IN  ('011', '021')
    and   a2.cdname = 'CATYPE' and a2.cdval = MST.CATYPE
    AND   CF.BRID       LIKE V_I_BRIDGD
    AND   CA.CAMASTID   LIKE V_CACODE
    AND   AF.ACTYPE     =  AFT.ACTYPE
    AND   AFT.COREBANK  LIKE V_ISCOREBANK
    AND   AF.BANKNAME   LIKE V_CASHPLACE
    ANd   (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)

;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
