SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0060" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   CACODE         IN       VARCHAR2,
   I_DATE          IN       VARCHAR2
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
   v_tddate            date;

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
/*   IF (CACODE <> 'ALL' OR CACODE <> '')
   THEN
      V_CACODE :=  CACODE;
   ELSE
      V_CACODE := '%%';
   END IF;*/

SELECT  getduedate(tdateotc,'B','000',1) into v_tddate from camast where camastid=CACODE; 

   -- GET REPORT'S DATA

OPEN PV_REFCURSOR
FOR
  select 'Hà Nội, ngày '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'dd')||' tháng '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'MM')||' năm '||to_char(to_date(I_DATE,'dd/MM/yyyy'),'yyyy') I_DATE
       , mst.optsymbol,
      -- mst.actiondate,
       v_tddate actiondate,
       cf.fullname,
       cf.address,
       cf.idcode,
       cf.iddate,
       cf.idplace,
       cf.mobilesms,
       iss.fullname,
       sb.issuedate licensedate,
       sb.parvalue,
       SB.Intcoupon,
       sb.sbtotalamt, -- tong gia tri dot phat hanh
       mst.reportdate,
       ca.amt,
       'fdfd' amtdesc,
       cf.custodycd,
       sb.expdate,
       b.bankacc,
       b.bankname,
       ca.trade qtty,
       ca.trade*sb.parvalue tongmg,
       mst.interestrate -- lai suat ky
  FROM -----VW_CASCHD_ALL CA,
       AFMAST AF,
       (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) CF,
       ALLCODE AL,
       SBSECURITIES SB,
       ISSUERS ISS,
       (SELECT * FROM CAMAST UNION ALL SELECT * FROM CAMASTHIST) MST,
       (SELECT * FROM caschd UNION ALL SELECT * FROM caschdhist) ca,
       cfotheracc b
 WHERE CA.AFACCTNO = AF.ACCTNO
   AND AF.CUSTID = CF.CUSTID
   AND CF.COUNTRY = AL.CDVAL
   AND AL.CDNAME = 'COUNTRY'
   AND CA.CODEID = SB.CODEID
   AND SB.ISSUERID = ISS.ISSUERID
   AND CA.DELTD <> 'Y'
   and cf.custid = b.cfcustid(+)
   AND CA.CAMASTID = MST.CAMASTID
   AND MST.CATYPE = '027'
   AND CA.CAMASTID = CACODE
;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;
 
 
 
 
/
