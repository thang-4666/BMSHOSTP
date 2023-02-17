SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0025" (
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
-- DIENNT  05-01-2011   CREATED
-- ---------   ------  -------------------------------------------
   V_STROPTION         VARCHAR2  (5);
   V_STRBRID           VARCHAR2  (40);
   V_CACODE            VARCHAR2(100);
   v_brid              VARCHAR2(4);

BEGIN
   V_STROPTION := OPT;
   v_brid := pv_brid;

IF  V_STROPTION = 'A' and v_brid = '0001' then
    V_STRBRID := '%';
    elsif V_STROPTION = 'B' then
        select br.mapid into V_STRBRID from brgrp br where br.brid = v_brid;
    else V_STROPTION := v_brid;
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
    SELECT MAX(ISS.FULLNAME) ISS_NAME, SB.SYMBOL,
            max(toiss.fullname) to_iss_name, SB2.symbol tosymbol,
            MAX (SB.PARVALUE) PARVALUE,MAX(MST.REPORTDATE) REPORTDATE,
            MAX(NVL(MST.exRATE, 0))  PCENT, MAX(MST.REPORTDATE) FR_DATE, MAX(MST.ACTIONDATE) TO_DATE,
            MAX(SUBSTR(CF.CUSTODYCD, 4, 1)) GR_I,
            (case when CF.CUSTTYPE = 'I' then '1.' else '2.' end) || CF.CUSTTYPE AFTYPE,
            MAX(CF.CUSTID) CUSTID, MAX(CF.FULLNAME) FULLNAME,
            --MAX(CF.IDCODE) IDCODE,
            (case when MAX(cf.country) = '234' then MAX(cf.idcode) else MAX(cf.tradingcode) end) IDCODE,
            MAX(case when cf.country = '234' then cf.IDDATE else cf.tradingcodedt end) IDDATE, MAX(CF.ADDRESS) ADDRESS,MAX( AL.CDCONTENT) COUNTRY_NAME,
            CF.CUSTODYCD, MAX(AF.ACCTNO) AFACCTNO,SUM(CA.TRADE) TRADE,SUM(CA.QTTY) QTTY,SUM(CA.TQTTY) TQTTY, SUM(CA.PBALANCE)PBALANCE
    FROM VW_CASCHD_ALL CA, AFMAST AF, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF, ALLCODE AL, SBSECURITIES SB, ISSUERS ISS,
          (SELECT * FROM camast UNION ALL SELECT * FROM camasthist) MST,
          sbsecurities sb2, issuers toiss
    WHERE CA.AFACCTNO    = AF.ACCTNO
        AND   sb2.codeid = nvl(mst.tocodeid, mst.codeid)
        AND   sb2.issuerid = toiss.ISSUERID
        AND   AF.CUSTID      = CF.CUSTID
        AND   CF.COUNTRY     = AL.CDVAL
        AND   AL.CDNAME      = 'COUNTRY'
        AND   CA.CODEID      = SB.CODEID
        AND   SB.ISSUERID    = ISS.ISSUERID
        AND   MST.CATYPE     = '014'
        AND   CA.DELTD       <>'Y'
        AND CA.STATUS<>'O'
        AND   CA.CAMASTID    = MST.CAMASTID
        AND   (af.brid like  V_STRBRID or instr(V_STRBRID,af.brid) <> 0)
        AND   CA.CAMASTID   LIKE V_CACODE
    GROUP BY sb.SYMBOL, sb2.symbol, cf.CUSTODYCD, CF.CUSTTYPE
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
