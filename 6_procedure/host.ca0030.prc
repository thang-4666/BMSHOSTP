SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0030" (
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
-- QUOCTA   05-01-2012   CREATED
--  THENN   31-MAR-2012  MODIFIED   SUA LAY LEN KO LOI FONT
-- ---------   ------  -------------------------------------------

   V_CACODE            VARCHAR2(100);
   V_I_BRIDGD          VARCHAR2(100);
   V_ISCOREBANK        VARCHAR2(10);
   V_CASHPLACE         VARCHAR2(100);

   V_BRNAME            NVARCHAR2(500);
   V_COREBANK_NAME     NVARCHAR2(100);
   V_CASHPLACE_NAME    NVARCHAR2(500);

   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (16);
   v_brid               VARCHAR2(4);

BEGIN


    V_STROPTION := OPT;
    v_brid := pv_brid;

    IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STRBRID := v_brid;
    END IF;
/*
BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (BRID <> 'ALL')
   THEN
      V_STRBRID := BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;                                  */


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
      V_BRNAME   :=  utf8nums.c_const_ca0030_name_allbranch;
   END IF;

   IF (ISCOREBANK <> 'ALL' OR ISCOREBANK <> '')
   THEN
      BEGIN
            IF (ISCOREBANK = 'Y') THEN
               V_COREBANK_NAME :=  'Corebank';
            ELSE
               V_COREBANK_NAME :=  utf8nums.c_const_ca0030_name_cb_COM;
            END IF;
      END;
   ELSE
      V_COREBANK_NAME   :=  utf8nums.c_const_ca0030_name_allbranch;
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
IF (ISCOREBANK = 'ALL') THEN
OPEN PV_REFCURSOR
FOR
     SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE, cf.VAT, V_I_BRIDGD,
        V_ISCOREBANK, V_CASHPLACE,
            (case when DEVIDENTVALUE = 0 then  MST.DEVIDENTRATE || '%' else TO_CHAR(mst.DEVIDENTVALUE) end ) PCENT, MST.ACTIONDATE,
            (CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN utf8nums.c_const_ca0030_custodytype_1
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN utf8nums.c_const_ca0030_custodytype_2
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN utf8nums.c_const_ca0030_custodytype_3 END) GR_I,
            (CASE WHEN CF.CUSTTYPE =  'I'  THEN utf8nums.c_const_ca0030_custtype_1
                  WHEN CF.CUSTTYPE =  'B'  THEN utf8nums.c_const_ca0030_custtype_2 END) AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            --CF.IDCODE,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE, CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO, (CA.BALANCE + CA.PBALANCE) BALANCE, (CA.QTTY + CA.PQTTY) QTTY,
            NVL(CA.AMT, 0) AMT,decode( MST.status,'I',NVL(MST.PITRATE, 0),5 ) PITRATE,
            (NVL(CA.AMT, 0) -  round(NVL(CA.AMT, 0) * decode( MST.status,'I',NVL(MST.PITRATE, 0),5 ) / 100) ) AMT_AFT,
            V_BRNAME BR_NAME, V_COREBANK_NAME COREBANK_NAME, V_CASHPLACE_NAME CASHPLACE_NAME
    FROM VW_CASCHD_ALL CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, AFTYPE AFT,
         (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    AND   MST.CATYPE    = '010'
    AND   (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,AF.BRID)<>0)
    AND   CF.BRID       LIKE V_I_BRIDGD
    AND   CA.CAMASTID   LIKE V_CACODE
    AND   AF.ACTYPE     =  AFT.ACTYPE
    AND   AFT.COREBANK  LIKE '%'
    AND   AF.BANKNAME   LIKE V_CASHPLACE

;
ELSIF (ISCOREBANK = 'Y') THEN
OPEN PV_REFCURSOR
FOR

     SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE, cf.VAT, V_I_BRIDGD, V_ISCOREBANK, V_CASHPLACE,
            (case when DEVIDENTVALUE = 0 then  MST.DEVIDENTRATE || '%' else TO_CHAR(mst.DEVIDENTVALUE) end ) PCENT, MST.ACTIONDATE,
            (CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN utf8nums.c_const_ca0030_custodytype_1
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN utf8nums.c_const_ca0030_custodytype_2
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN utf8nums.c_const_ca0030_custodytype_3 END) GR_I,
            (CASE WHEN CF.CUSTTYPE =  'I'  THEN utf8nums.c_const_ca0030_custtype_1
                  WHEN CF.CUSTTYPE =  'B'  THEN utf8nums.c_const_ca0030_custtype_2 END) AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE, CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO, (CA.BALANCE + CA.PBALANCE) BALANCE, (CA.QTTY + CA.PQTTY) QTTY,
            NVL(CA.AMT, 0) AMT, decode( MST.status,'I',NVL(MST.PITRATE, 0),5 ) PITRATE,
            (NVL(CA.AMT, 0) -round(NVL(CA.AMT, 0) * decode( MST.status,'I',NVL(MST.PITRATE, 0),5 ) / 100)) AMT_AFT,
            V_BRNAME BR_NAME, V_COREBANK_NAME COREBANK_NAME, V_CASHPLACE_NAME CASHPLACE_NAME
    FROM VW_CASCHD_ALL CA, AFMAST AF, CFMAST CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, AFTYPE AFT,
         (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    AND   MST.CATYPE    = '010'
    AND   (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,AF.BRID)<>0)
    AND   CF.BRID       LIKE V_I_BRIDGD
    AND   CA.CAMASTID   LIKE V_CACODE
    AND   AF.ACTYPE     =  AFT.ACTYPE
    AND   AFT.COREBANK  LIKE  'Y'
    AND   AF.BANKNAME   LIKE  V_CASHPLACE
;
ELSE
OPEN PV_REFCURSOR
FOR

    SELECT ISS.FULLNAME ISS_NAME, SB.SYMBOL, SB.PARVALUE, MST.REPORTDATE, cf.VAT, V_I_BRIDGD, V_ISCOREBANK, V_CASHPLACE,
            (case when DEVIDENTVALUE = 0 then  MST.DEVIDENTRATE || '%' else TO_CHAR(mst.DEVIDENTVALUE) end ) PCENT, MST.ACTIONDATE,
            (CASE WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'C' THEN utf8nums.c_const_ca0030_custodytype_1
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'F' THEN utf8nums.c_const_ca0030_custodytype_2
                  WHEN SUBSTR(CF.CUSTODYCD, 4, 1) = 'P' THEN utf8nums.c_const_ca0030_custodytype_3 END) GR_I,
            (CASE WHEN CF.CUSTTYPE =  'I'  THEN utf8nums.c_const_ca0030_custtype_1
                  WHEN CF.CUSTTYPE =  'B'  THEN utf8nums.c_const_ca0030_custtype_2 END) AFTYPE,
            CF.CUSTID, CF.FULLNAME,
            (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE,
            (case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE,
            CF.ADDRESS, AL.CDCONTENT COUNTRY_NAME,
            CF.CUSTODYCD, AF.ACCTNO AFACCTNO, (CA.BALANCE + CA.PBALANCE) BALANCE, (CA.QTTY + CA.PQTTY) QTTY,
            NVL(CA.AMT, 0) AMT,decode( MST.status,'I',NVL(MST.PITRATE, 0),5 ) PITRATE,
            (NVL(CA.AMT, 0) - round (NVL(CA.AMT, 0) * decode( MST.status,'I',NVL(MST.PITRATE, 0),5 ) / 100)) AMT_AFT,
            V_BRNAME BR_NAME, V_COREBANK_NAME COREBANK_NAME, V_CASHPLACE_NAME CASHPLACE_NAME
    FROM VW_CASCHD_ALL CA, AFMAST AF, CFMAST CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS, AFTYPE AFT,
         (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST
    WHERE CA.AFACCTNO    = AF.ACCTNO
    AND   AF.CUSTID      = CF.CUSTID
    AND   CF.COUNTRY     = AL.CDVAL
    AND   AL.CDNAME      = 'COUNTRY'
    AND   CA.CODEID      = SB.CODEID
    AND   SB.ISSUERID    = ISS.ISSUERID
    AND   CA.DELTD       <>'Y'
    AND   (CA.BALANCE + CA.PBALANCE) > 0
    AND   CA.CAMASTID   =  MST.CAMASTID
    AND   MST.CATYPE    = '010'
    AND   (AF.BRID LIKE V_STRBRID OR INSTR(V_STRBRID,AF.BRID)<>0)
    AND   CF.BRID       LIKE V_I_BRIDGD
    AND   CA.CAMASTID   LIKE V_CACODE
    AND   AF.ACTYPE     =  AFT.ACTYPE
    AND   AFT.COREBANK  LIKE  'N'
    AND   AF.BANKNAME   LIKE  '%'
;

END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;

 
 
 
 
/
