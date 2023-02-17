SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0039" (
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
-- QUYETKD  24-07-2012   CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (4);
   V_CACODE            VARCHAR2(100);
   V_CIROUND           NUMBER;
   V_I_BRIDGD          VARCHAR2(100);
   V_ISCOREBANK        VARCHAR2(10);
   V_CASHPLACE         VARCHAR2(100);

   V_BRNAME            NVARCHAR2(500);
   V_COREBANK_NAME     NVARCHAR2(100);
   V_CASHPLACE_NAME    NVARCHAR2(500);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
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

   SELECT CIROUNDTYPE INTO V_CIROUND FROM CAMAST WHERE CAMASTID LIKE V_CACODE;

   IF (I_BRIDGD <> 'ALL' OR I_BRIDGD <> '')
   THEN
      V_I_BRIDGD :=  I_BRIDGD;
   ELSE
      V_I_BRIDGD := '%';
   END IF;

   IF   (ISCOREBANK <> 'ALL' OR ISCOREBANK <> '')   THEN
    V_ISCOREBANK := ISCOREBANK ;
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
      V_BRNAME   :=  'Toan cong ty';
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
      V_CASHPLACE_NAME :=  'All';

   END IF;

   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR

    SELECT max(ISS.FULLNAME) ISS_NAME, SB.SYMBOL, max(SB.PARVALUE) PARVALUE,
            ' ' CADESC,
            max(MST.REPORTDATE) REPORTDATE,
            max(NVL(MST.EXRATE, 0))  PCENT, max(MST.begindate) FR_DATE, max(MST.duedate) TO_DATE,
            MAX(SUBSTR(CF.CUSTODYCD, 4, 1)) GR_I,
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE AFTYPE,
            max(CF.CUSTID) CUSTID, max(CF.FULLNAME) FULLNAME,
            (case when max(cf.country) = '234' then max(cf.idcode) else max(cf.tradingcode) end) IDCODE,
            max(case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end)  IDDATE,
            max(CF.ADDRESS) ADDRESS,
            max( nvl(cf.mobile,cf.phone)) CF_Phone ,
            max(nvl(cf.email,'')) CF_address,
            max(AL.CDCONTENT) COUNTRY_NAME,
            CF.CUSTODYCD, max(AF.ACCTNO) AFACCTNO,
            sum(CA.TRADE) TRADE ,
            SUM(CA.QTTY) QTTY,
            sum(CA.AMT) AMT,
            max(MST.EXPRICE) EXPRICE,
            round(sum(CA.AMT/decode(MST.EXPRICE,0,1,MST.EXPRICE)),V_CIROUND) LE,
            V_BRNAME BR_NAME,
            nvl(V_COREBANK_NAME,'') COREBANK_NAME,
            nvl(V_CASHPLACE_NAME,'') CASHPLACE_NAME,
            sum(CA.BALANCE) TP_ChuaDK,
            sum(CA.pqtty+CA.qtty) CP_DcNhan
    FROM VW_CASCHD_ALL CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, AFTYPE AFT, VW_CAMAST_ALL MST
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   MST.CODEID     = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   MST.CATYPE     =    '023'
    AND   CA.DELTD       <> 'Y'
    AND CA.STATUS<>'O'
    AND   CA.CAMASTID    =  MST.CAMASTID
    AND   CA.CAMASTID    LIKE V_CACODE
    AND   AF.ACTYPE      =  AFT.ACTYPE
    AND   AF.COREBANK    LIKE V_ISCOREBANK
    AND   AF.BANKNAME    LIKE V_CASHPLACE
    AND   substr(af.acctno,0,4) like V_I_BRIDGD
    Group by SYMBOL,CUSTODYCD, CF.CUSTTYPE;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
