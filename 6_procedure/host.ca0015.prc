SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0015" (
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
   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (4);
   V_CACODE            VARCHAR2(100);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := PV_BRID;
   ELSE
      V_STRBRID := '%%';
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
       SELECT  ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, mst.purposedesc CADESC, MST.REPORTDATE,
            NVL(MST.DEVIDENTSHARES, 0) PCENT, MST.REPORTDATE FR_DATE, MST.ACTIONDATE TO_DATE,
            (CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN 'I. MÔI GIỚI TRONG NƯỚC '
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN 'II. MÔI GIỚI NƯỚC NGOÀI '
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN 'III. TỰ DOANH ' END) GR_I,
             (CASE WHEN CF.CUSTTYPE =  'I'  THEN '1. Cá nhân '
              WHEN CF.CUSTTYPE =  'B'  THEN '2. Tổ chức ' END) AFTYPE,
           ----- a1.cdcontent  AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            --CF.IDCODE,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE, CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO, (CA.BALANCE + CA.PBALANCE) BALANCE,
--            (CA.QTTY + CA.PQTTY) QTTY,
    round(CA.trade / (to_number(substr(MST.DEVIDENTSHARES,0, instr(MST.DEVIDENTSHARES,'/')-1)) / to_number(substr(MST.DEVIDENTSHARES,instr(MST.DEVIDENTSHARES,'/')+1))),4)  QTTY,
            MST.CATYPE
    FROM VW_CASCHD_ALL CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, VW_CAMAST_ALL MST, allcode a1
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    and   a1.cdtype = 'CF' and a1.cdname = 'CUSTTYPE'
    and   cf.CUSTTYPE = a1.cdval
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    AND   MST.CATYPE    IN ('022', '005', '006')
    AND   CA.CAMASTID   LIKE V_CACODE
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
