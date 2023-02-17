SET DEFINE OFF;
CREATE OR REPLACE PROCEDURE "CA0029" (
   PV_REFCURSOR   IN OUT   PKG_REPORT.REF_CURSOR,
   OPT            IN       VARCHAR2,
   pv_BRID           IN       VARCHAR2,
   TLGOUPS        IN       VARCHAR2,
   TLSCOPE        IN       VARCHAR2,
   F_DATE       in varchar2,
   T_DATE       in varchar2,
  P_CAMSTID       in varchar2,
  P_CUSTODYCD     in varchar2,
  P_ACCOUNTTYPE   in varchar2,
  P_BRID          in varchar2,
  P_CATYPE        in varchar2
  )
IS
--
-- PURPOSE: BRIEFLY EXPLAIN THE FUNCTIONALITY OF THE PROCEDURE
-- BAO CAO TAI KHOAN TIEN TONG HOP CUA NGUOI DAU TU
-- MODIFICATION HISTORY
-- PERSON      DATE    COMMENTS
-- NAMNT   20-DEC-06  CREATED
-- ---------   ------  -------------------------------------------

    CUR             PKG_REPORT.REF_CURSOR;
    V_STROPTION    VARCHAR2 (5);            -- A: ALL; B: BRANCH; S: SUB-BRANCH
    V_STRBRID      VARCHAR2 (4);

    L_F_DATE    DATE;
    L_T_DATE    DATE;
      L_CAMASTID    VARCHAR2(20);
  L_CUSTODYCD   VARCHAR2(20);
  L_ACCOUNTTYPE VARCHAR2(10);
  L_CUSTTYPE    VARCHAR2(10);
  L_BRID        VARCHAR2(10);

  L_CATYPE      VARCHAR2(20);

BEGIN
   V_STROPTION := OPT;

   IF (V_STROPTION <> 'A') AND (pv_BRID <> 'ALL')
   THEN
      V_STRBRID := pv_BRID;
   ELSE
      V_STRBRID := '%%';
   END IF;

   L_F_DATE := TO_DATE(F_DATE,'DD/MM/RRRR');
   L_T_DATE := TO_DATE(T_DATE,'DD/MM/RRRR');

   IF(P_CAMSTID IS NULL OR UPPER(P_CAMSTID) = 'ALL')THEN
        L_CAMASTID := '%';
  ELSE
        L_CAMASTID := P_CAMSTID;
  END IF;

  IF(P_CUSTODYCD IS NULL OR UPPER(P_CUSTODYCD) = 'ALL')THEN
        L_CUSTODYCD := '%';
  ELSE
        L_CUSTODYCD := P_CUSTODYCD;
  END IF;

  IF(P_ACCOUNTTYPE IS NULL OR UPPER(P_ACCOUNTTYPE) = 'ALL')THEN
        L_ACCOUNTTYPE := '%';
        L_CUSTTYPE    := '%';
  ELSE
        L_ACCOUNTTYPE := SUBSTR(P_ACCOUNTTYPE,1,1);
        L_CUSTTYPE := SUBSTR(P_ACCOUNTTYPE,2,1);
  END IF;

  IF(P_BRID IS NULL OR UPPER(P_BRID) = 'ALL')THEN
        L_BRID := '%';
  ELSE
        L_BRID := P_BRID;
  END IF;

  IF(P_CATYPE IS NULL OR UPPER(P_CATYPE) = 'ALL')THEN
    L_CATYPE := '%';
  ELSE
    L_CATYPE := P_CATYPE;
  END IF;

   -- GET REPORT'S PARAMETERS

--Tinh ngay nhan thanh toan bu tru


OPEN PV_REFCURSOR
   FOR
    SELECT af.acctno, se.symbol, cam.REPORTDATE, cam.actiondate, cf.custodycd, cf.fullname, cf.MOBILE,
        (case when cf.country = '234' then cf.idcode else cf.tradingcode end) IDCODE, cas.trade SLCKSH, cas.Qtty SLCKDN,
        (case when cam.DEVIDENTSHARES is null then (case when cam.devidentrate is null then
        (case when cam.rightoffrate is null then NVL(cam.exrate,1) else cam.rightoffrate end)
        else devidentrate end) else cam.DEVIDENTSHARES end)  DEVIDENTSHARES,
        A0.cdcontent Catype,  A1.cdcontent status, cam.camastid, cas.AMT, af.status status_af
    FROM vw_caschd_all cas, sbsecurities se, vw_camast_all cam, afmast af, (SELECT * FROM CFMAST WHERE FNC_VALIDATE_SCOPE(BRID, CAREBY, TLSCOPE, pv_BRID, TLGOUPS)=0) cf, allcode A0, Allcode A1
    WHERE cas.codeid = se.codeid
        AND cam.camastid = cas.camastid
        AND cas.afacctno = af.acctno
        AND af.custid = cf.custid
        AND a0.CDTYPE = 'CA' AND a0.CDNAME = 'CATYPE' AND a0.CDVAL = cam.CATYPE
        AND A1.CDTYPE = 'CA' AND A1.CDNAME = 'CASTATUS' AND A1.CDVAL = cas.STATUS
        and cas.deltd <> 'Y' and cam.CATYPE <> '010'
        AND CAM.reportdate >= L_F_DATE AND CAM.reportdate <= L_T_DATE
        and af.brid like L_BRID --and cas.STATUS IN ('H','J','C','W')
        AND CF.CUSTODYCD LIKE L_CUSTODYCD
        AND CAM.camastid LIKE L_CAMASTID
        AND CAM.CATYPE LIKE L_CATYPE
        AND (CASE WHEN SUBSTR(CF.CUSTODYCD,4,1) = 'P' THEN 'C' ELSE SUBSTR(CF.CUSTODYCD,4,1) END) LIKE L_CUSTTYPE
        AND CF.CUSTTYPE LIKE L_ACCOUNTTYPE
    ORDER BY af.acctno
  ;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN;
END;                                                              -- PROCEDURE

 
 
 
 
/
