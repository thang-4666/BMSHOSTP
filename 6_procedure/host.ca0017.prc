SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0017" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2
 )
IS
--
-- PURPOSE: BAO CAO DANH SACH NGUOI SO HUU CHUNG KHOAN LUU KY
-- MODIFICATION HISTORY
-- PERSON      DATE      COMMENTS
-- QUOCTA   15-12-2011   CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2(5);
   V_STRBRID           VARCHAR2(40);
   V_INBRID            VARCHAR2(4);
   V_CACODE            VARCHAR2(100);

BEGIN
   V_STROPTION := upper(OPT);
   V_INBRID := pv_BRID;

   IF (V_STROPTION = 'A')
   THEN
      V_STRBRID := '%';
   ELSif (V_STROPTION = 'B') then
        select brgrp.mapid into V_STRBRID from brgrp where brgrp.brid = V_INBRID;
   else
        V_STRBRID := V_INBRID;
   END IF;

   -- GET REPORT'S PARAMETERS
   IF (CACODE <> 'ALL' OR CACODE <> '')
   THEN
      V_CACODE :=  CACODE;
   ELSE
      V_CACODE := '%%';
   END IF;


   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR

     SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE,
            NVL(MST.EXRATE, 0) PCENT_EXRATE, NVL(MST.RIGHTOFFRATE, 0) PCENT_RIGHTOFFRATE,
            NVL(MST.EXPRICE, 0) EXPRICE, MST.FRDATETRANSFER, MST.TODATETRANSFER,
            MST.BEGINDATE, MST.DUEDATE,
            /*
            (CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN 'I. M? GI?I TRONG NU?C '
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN 'II. M? GI?I NU?C NGO?I '
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN 'III. T? DOANH ' END) GR_I,
                  */
            SUBSTR(CF.CUSTODYCD, 4, 1) GR_I,
            /*(CASE WHEN CF.CUSTTYPE =  'I'  THEN '1. C?h?'
                  WHEN CF.CUSTTYPE =  'B'  THEN '2.  T? ch?c ' END) AFTYPE,
                  */
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            --CF.IDCODE,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE,
            CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO,CA.trade BALANCE,-- (CA.BALANCE + CA.PBALANCE) BALANCE,
            --(CA.QTTY + CA.PQTTY) QTTY
            (CA.RETAILBAL+CA.roretailbal) QTTY
    FROM -----VW_CASCHD_ALL CA,
        AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS,
         (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
         (SELECT * FROM caschd UNION ALL SELECT * FROM caschdhist)ca
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
   -- and (af.brid like V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
    AND   MST.CATYPE    =  '014'
    AND   CA.CAMASTID   LIKE V_CACODE
  --  and (CA.RETAILBAL+CA.roretailbal) > 0
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
